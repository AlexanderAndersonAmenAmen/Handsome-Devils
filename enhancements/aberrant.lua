HNDS = HNDS or {}

local ABERRANT_KEY = "m_hnds_aberrant"
local MAX_FUSIONS = 2
local function resolve_center(center)
    if type(center) == "string" then
        return G and G.P_CENTERS and G.P_CENTERS[center] or nil
    end
    return center
end

local function is_aberrant(card)
    return card
        and card.config
        and card.config.center
        and card.config.center.key == ABERRANT_KEY
end

local function aberrant_fusions(card)
    if not (card and card.ability) then return {} end

    -- Migrate cards made by the previous draw-count version. Keeping that old
    -- table in `ability.extra` also breaks vanilla numeric enhancement fields
    -- (notably Glass), so remove it when encountered.
    if type(card.ability.extra) == "table"
        and (card.ability.extra.draws ~= nil
            or card.ability.extra.drawn ~= nil
            or card.ability.extra.pending ~= nil)
    then
        card.ability.extra = nil
    end

    if type(card.ability.hnds_aberrant_fusions) ~= "table" then
        card.ability.hnds_aberrant_fusions = {}
    end
    return card.ability.hnds_aberrant_fusions
end

local function has_fusion(card, key)
    for _, fusion_key in ipairs(aberrant_fusions(card)) do
        if fusion_key == key then return true end
    end
    return false
end

HNDS.is_aberrant = is_aberrant
HNDS.aberrant_has_fusion = has_fusion

local function enhancement_name(key)
    local name
    if localize then
        local ok, value = pcall(localize, { type = "name_text", set = "Enhanced", key = key })
        if ok then name = value end
    end
    if type(name) ~= "string" or name == "" then
        local center = G and G.P_CENTERS and G.P_CENTERS[key]
        name = (center and center.name) or key
    end
    -- The compact status requested for Aberrant is `(Steel/Gold)`, rather
    -- than `(Steel Card/Gold Card)` in English.
    name = name:gsub(" Card$", "")
    return name
end

local function fusion_status(card)
    local names = {}
    for _, key in ipairs(aberrant_fusions(card)) do
        names[#names + 1] = enhancement_name(key)
    end
    if #names == 0 then return "(Currently none)" end
    return "(" .. table.concat(names, "/") .. ")"
end

local function clone_table(value, seen)
    if type(value) ~= "table" then return value end
    if copy_table then return copy_table(value) end
    seen = seen or {}
    if seen[value] then return seen[value] end
    local result = {}
    seen[value] = result
    for k, v in pairs(value) do result[clone_table(k, seen)] = clone_table(v, seen) end
    return setmetatable(result, getmetatable(value))
end

local function fusion_entries(card)
    -- `SMODS.get_enhancements` is a key set, so duplicate fusions should not be
    -- represented by fake Center keys. Duplicate effects are evaluated from the
    -- ordered fusion slots in `SMODS.calculate_quantum_enhancements` below.
    -- Keeping only real enhancement keys here avoids invalid/synthetic Centers
    -- leaking into probability and compatibility checks (notably Lucky/Lucky).
    local entries, seen = {}, {}
    for _, key in ipairs(aberrant_fusions(card)) do
        if not seen[key] then
            entries[#entries + 1] = key
            seen[key] = true
        end
    end
    return entries
end

local function invalidate_enhancement_cache(card)
    if SMODS.enh_cache and SMODS.enh_cache.write then
        SMODS.enh_cache:write(card, nil)
    end
end

-- Expose fused enhancement TYPES to normal Steamodded enhancement helpers.
-- Duplicate slots intentionally collapse here because this API is a key set;
-- their effects are still evaluated once per stored fusion slot below.
local get_enhancements_ref = SMODS.get_enhancements
function SMODS.get_enhancements(card, extra_only)
    local enhancements = get_enhancements_ref(card, extra_only) or {}
    if not is_aberrant(card) then return enhancements end

    local entries = fusion_entries(card)
    for _, key in ipairs(entries) do enhancements[key] = true end

    return enhancements
end

local function refresh_aberrant_visuals(card)
    invalidate_enhancement_cache(card)
    if card.set_sprites then card:set_sprites(card.config.center) end
    if card.should_hide_front then card.front_hidden = card:should_hide_front() end

    -- A newly fused Wild card immediately sheds an existing debuff.
    if has_fusion(card, "m_wild") and card.debuff and card.set_debuff then
        card:set_debuff(false)
    elseif G and G.GAME and G.GAME.blind and G.GAME.blind.debuff_card then
        G.GAME.blind:debuff_card(card)
    end
end

local function destroy_overstacked_card(card)
    if card.hnds_aberrant_overstacked then return end
    card.hnds_aberrant_overstacked = true

    local function destroy()
        if card and not card.removed then
            if SMODS.destroy_cards then
                SMODS.destroy_cards(card)
            elseif card.start_dissolve then
                card:start_dissolve()
            end
        end
        return true
    end

    if G and G.E_MANAGER and Event then
        G.E_MANAGER:add_event(Event({ trigger = "after", delay = 0.1, func = destroy }))
    else
        destroy()
    end
end

-- Applying another Enhancement to an Aberrant card fuses it instead of
-- replacing Aberrant. Once both slots are occupied, any further attempt
-- destroys the playing card.
local set_ability_ref = Card.set_ability
function Card:set_ability(center, initial, delay_sprites)
    local new_center = resolve_center(center)
    local new_key = new_center and new_center.key

    if HNDS._aberrant_internal_center_swap then
        return set_ability_ref(self, center, initial, delay_sprites)
    end

    -- A permanently Bound card being changed to Obsidian is a visual
    -- replacement, not an Aberrant fusion. Let Obsidian's wrapper handle it.
    if new_key == "m_hnds_obsidian"
        and HNDS.is_bound_card and HNDS.is_bound_card(self)
    then
        return set_ability_ref(self, center, initial, delay_sprites)
    end

    if is_aberrant(self)
        and not initial
        and new_center
        and new_center.set == "Enhanced"
        and new_key ~= ABERRANT_KEY
    then
        local fusions = aberrant_fusions(self)
        if #fusions >= MAX_FUSIONS then
            destroy_overstacked_card(self)
            return self
        end

        fusions[#fusions + 1] = new_key
        refresh_aberrant_visuals(self)
        if self.juice_up then self:juice_up(0.35, 0.35) end
        return self
    end

    return set_ability_ref(self, center, initial, delay_sprites)
end

-- Run every fused enhancement as a full quantum enhancement pass. Iterating the
-- stored slots (rather than a key set) is what makes Steel/Steel, Gold/Gold,
-- etc. stack exactly twice without using a card retrigger.
local calculate_quantum_ref = SMODS.calculate_quantum_enhancements
function SMODS.calculate_quantum_enhancements(card, effects, context)
    local fusions = is_aberrant(card) and aberrant_fusions(card) or nil
    if not fusions or #fusions == 0 then
        if calculate_quantum_ref then return calculate_quantum_ref(card, effects, context) end
        return
    end
    if not (SMODS.optional_features and SMODS.optional_features.quantum_enhancements)
        or context.extra_enhancement
        or context.check_enhancement
        or SMODS.extra_enhancement_calc_in_progress
    then
        return
    end

    local evaluation_keys = {}
    local fused_set = {}
    for _, key in ipairs(fusions) do
        evaluation_keys[#evaluation_keys + 1] = key
        fused_set[key] = true
    end

    -- Preserve enhancements granted externally by Jokers while avoiding keys
    -- that are already supplied by Aberrant's own fusion slots.
    HNDS._aberrant_reading_quantum = true
    local extra = SMODS.get_enhancements(card, true) or {}
    HNDS._aberrant_reading_quantum = nil
    local external = {}
    for key in pairs(extra) do
        local center = G.P_CENTERS[key]
        if center and not fused_set[key] then
            external[#external + 1] = key
        end
    end
    table.sort(external, function(a, b)
        return (tonumber(G.P_CENTERS[a].order) or 0) < (tonumber(G.P_CENTERS[b].order) or 0)
    end)
    for _, key in ipairs(external) do evaluation_keys[#evaluation_keys + 1] = key end

    local old_ability = clone_table(card.ability)
    local old_center = card.config.center
    local old_center_key = card.config.center_key
    local old_front_hidden = card.front_hidden
    local old_context_extra = context.extra_enhancement
    local old_progress = SMODS.extra_enhancement_calc_in_progress

    context.extra_enhancement = true
    SMODS.extra_enhancement_calc_in_progress = true

    local ok, err = pcall(function()
        for _, key in ipairs(evaluation_keys) do
            local fusion_center = G.P_CENTERS[key]
            if fusion_center then
                if card.quantum_set_ability then
                    card:quantum_set_ability(fusion_center)
                else
                    HNDS._aberrant_internal_center_swap = true
                    card:set_ability(fusion_center, nil, true)
                    HNDS._aberrant_internal_center_swap = nil
                end
                card.ability.extra_enhancement = key
                effects[#effects + 1] = eval_card(card, context)
            end
        end
    end)

    card.ability = old_ability
    card.config.center = old_center
    card.config.center_key = old_center_key
    card.front_hidden = old_front_hidden
    if not card.quantum_set_ability and card.set_sprites then card:set_sprites(old_center) end
    context.extra_enhancement = old_context_extra
    SMODS.extra_enhancement_calc_in_progress = old_progress
    HNDS._aberrant_internal_center_swap = nil

    if not ok then error(err) end
end

-- Stone is deliberately dominant over Wild on Aberrant cards.
local has_no_suit_ref = SMODS.has_no_suit
function SMODS.has_no_suit(card)
    if is_aberrant(card) and has_fusion(card, "m_stone") then return true end
    return has_no_suit_ref(card)
end

local has_any_suit_ref = SMODS.has_any_suit
function SMODS.has_any_suit(card)
    if is_aberrant(card) and has_fusion(card, "m_stone") then return false end
    return has_any_suit_ref(card)
end

-- Stone also removes the normal rank/suit front and its base-rank chip value,
-- leaving only the Aberrant enhancement art visible.
if Card.should_hide_front then
    local should_hide_front_ref = Card.should_hide_front
    function Card:should_hide_front(...)
        if is_aberrant(self) and has_fusion(self, "m_stone") then return true end
        return should_hide_front_ref(self, ...)
    end
end

if Card.get_chip_bonus then
    local get_chip_bonus_ref = Card.get_chip_bonus
    function Card:get_chip_bonus(...)
        if is_aberrant(self) and has_fusion(self, "m_stone") then return 0 end
        return get_chip_bonus_ref(self, ...)
    end
end

-- Wild's anti-debuff clause remains active even when Stone suppresses its suit
-- wildcard clause, and works independently of the optional vanilla-tweaks file.
local mod = SMODS.current_mod
local set_debuff_hook_ref = mod.set_debuff
mod.set_debuff = function(card)
    if set_debuff_hook_ref then
        local result = set_debuff_hook_ref(card)
        if result ~= nil then return result end
    end
    if is_aberrant(card) and has_fusion(card, "m_wild") then
        return "prevent_debuff"
    end
end

-- Aberrant fusion indicators are visual-only sticker sprites. They are never
-- applied to the card as real Stickers, so they cannot create badges/tooltips,
-- participate in sticker rolls, or interfere with Cursed sticker exclusivity.
local ABERRANT_INDICATOR_POS = {
    unknown = { top = { x = 4, y = 0 }, bottom = { x = 5, y = 0 } },
    stone = { top = { x = 3, y = 1 }, bottom = { x = 5, y = 3 } },
    bonus = { top = { x = 4, y = 1 }, bottom = { x = 0, y = 4 } },
    mult = { top = { x = 5, y = 1 }, bottom = { x = 1, y = 4 } },
    glass = { top = { x = 0, y = 2 }, bottom = { x = 2, y = 4 } },
    gold = { top = { x = 1, y = 2 }, bottom = { x = 0, y = 3 } },
    steel = { top = { x = 2, y = 2 }, bottom = { x = 1, y = 3 } },
    wild = { top = { x = 3, y = 2 }, bottom = { x = 2, y = 3 } },
    lucky = { top = { x = 4, y = 2 }, bottom = { x = 3, y = 3 } },
    obsidian = { top = { x = 5, y = 2 }, bottom = { x = 4, y = 3 } },
}

local ABERRANT_INDICATOR_KIND = {
    m_stone = "stone",
    m_bonus = "bonus",
    m_mult = "mult",
    m_glass = "glass",
    m_gold = "gold",
    m_steel = "steel",
    m_wild = "wild",
    m_lucky = "lucky",
    m_hnds_obsidian = "obsidian",
}

-- These four take the top position whenever paired with a lower-priority
-- enhancement. When both fusions are from this group, fusion order breaks the
-- tie (first = top, second = bottom), which is the only way to show both.
local ABERRANT_TOP_PRIORITY = {
    stone = true, mult = true, bonus = true, glass = true,
}

local function aberrant_indicator_kind(key)
    return ABERRANT_INDICATOR_KIND[key] or "unknown"
end

local function aberrant_indicator_slots(card)
    local fusions = aberrant_fusions(card)
    if #fusions == 0 then return nil, nil end

    local first = aberrant_indicator_kind(fusions[1])
    if #fusions == 1 then return first, nil end

    local second = aberrant_indicator_kind(fusions[2])
    if first == second then
        return first, second
    end

    local first_priority = ABERRANT_TOP_PRIORITY[first]
    local second_priority = ABERRANT_TOP_PRIORITY[second]

    -- Stone/Mult/Bonus/Glass versus Stone/Mult/Bonus/Glass is order-based:
    -- the first fused enhancement stays on top and the second goes on bottom.
    -- (The identical-pair case above also draws one copy in each position.)
    if first_priority and second_priority then
        return first, second
    elseif first_priority then
        return first, second
    elseif second_priority then
        return second, first
    end

    -- Steel/Gold/Lucky/Wild/Obsidian/Unknown combinations are also order-based.
    return first, second
end

-- These are intentionally NOT registered as SMODS.Sticker objects. In
-- Steamodded BETA-1620a Sticker has no object-level :draw() method, and
-- registering visual-only helpers also makes them appear in the Stickers
-- collection. Instead, cache plain sprites from HDstickers and render them
-- directly in a DrawStep.
local ABERRANT_INDICATOR_ATLAS = "hnds_Stickers"
local ABERRANT_INDICATOR_SPRITES = {}

local function aberrant_indicator_sprite(kind, slot)
    local cache_key = kind .. "_" .. slot
    if ABERRANT_INDICATOR_SPRITES[cache_key] then
        return ABERRANT_INDICATOR_SPRITES[cache_key]
    end

    local positions = ABERRANT_INDICATOR_POS[kind]
    local pos = positions and positions[slot]
    if not pos or not (G and G.ASSET_ATLAS and G.ASSET_ATLAS[ABERRANT_INDICATOR_ATLAS]) then
        return nil
    end

    local sprite = SMODS.create_sprite(
        0, 0, G.CARD_W, G.CARD_H,
        ABERRANT_INDICATOR_ATLAS, pos
    )
    ABERRANT_INDICATOR_SPRITES[cache_key] = sprite
    return sprite
end

local function draw_aberrant_indicator(card, kind, slot)
    local sprite = aberrant_indicator_sprite(kind, slot)
    if not sprite or not card.children or not card.children.center then return end

    sprite.role.draw_major = card
    -- Keep the indicators flat: only use the dissolve pass so they follow the
    -- card's materialize/dissolve animation. The vanilla sticker-style
    -- 'voucher' pass adds the moving shine, which these indicators should not
    -- have.
    sprite:draw_shader('dissolve', nil, nil, nil, card.children.center)
end

SMODS.DrawStep({
    key = "hnds_aberrant_fusion_indicators",
    order = 35,
    func = function(card, layer)
        if not is_aberrant(card) then return end
        -- A Card flip updates `facing` and `sprite_facing` at slightly
        -- different points. Draw only once both agree that the front is
        -- visible; this prevents an indicator frame leaking onto the card back.
        if card.facing ~= "front" or card.sprite_facing ~= "front" then return end

        local top_kind, bottom_kind = aberrant_indicator_slots(card)
        if not top_kind then return end

        draw_aberrant_indicator(card, top_kind, "top")
        if bottom_kind then
            draw_aberrant_indicator(card, bottom_kind, "bottom")
        end
    end,
})

SMODS.Enhancement({
    key = "aberrant",
    atlas = "Extras",
    pos = { x = 2, y = 0 },
    config = {},
    weight = 2.5,

    loc_vars = function(self, info_queue, card)
        local seen = {}
        for _, key in ipairs(aberrant_fusions(card)) do
            if not seen[key] and G.P_CENTERS[key] then
                info_queue[#info_queue + 1] = G.P_CENTERS[key]
                seen[key] = true
            end
        end

        local in_collection = card
            and card.area
            and card.area.config
            and card.area.config.collection
        return {
            key = in_collection and "m_hnds_aberrant_collection" or self.key,
            vars = { fusion_status(card) },
        }
    end,

    calculate = function(self, card, context)
        if context.stay_flipped
            and context.other_card == card
            and has_fusion(card, "m_wild")
        then
            return { prevent_stay_flipped = true }
        end
    end,
})
