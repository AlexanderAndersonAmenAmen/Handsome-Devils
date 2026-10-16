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


local get_enhancements_ref = SMODS.get_enhancements
function SMODS.get_enhancements(card, extra_only, ...)
    local base = get_enhancements_ref(card, extra_only, ...)
    if base == nil then base = {} end
    if not is_aberrant(card) or type(base) ~= 'table' then return base end


    local enhancements = {}
    for key, value in pairs(base) do enhancements[key] = value end

    local entries = fusion_entries(card)
    for _, key in ipairs(entries) do enhancements[key] = true end

    return enhancements
end

local function refresh_aberrant_visuals(card)
    invalidate_enhancement_cache(card)
    if card.set_sprites then card:set_sprites(card.config.center) end
    if card.should_hide_front then card.front_hidden = card:should_hide_front() end


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


local set_ability_ref = Card.set_ability
function Card:set_ability(center, initial, delay_sprites, ...)
    local new_center = resolve_center(center)
    local new_key = new_center and new_center.key
    local old_center = self and self.config and self.config.center
    local old_key = old_center and old_center.key

    if HNDS._aberrant_internal_center_swap then
        return set_ability_ref(self, center, initial, delay_sprites, ...)
    end




    if not initial
        and new_key == ABERRANT_KEY
        and old_center
        and old_center.set == "Enhanced"
        and old_key ~= ABERRANT_KEY
    then
        local results = HNDS.pack(set_ability_ref(self, center, initial, delay_sprites, ...))
        if is_aberrant(self) and old_key then
            local fusions = aberrant_fusions(self)
            if #fusions < MAX_FUSIONS then
                fusions[#fusions + 1] = old_key
                refresh_aberrant_visuals(self)
            end
        end
        return ((table and table.unpack) or unpack)(results, 1, results.n)
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

    return set_ability_ref(self, center, initial, delay_sprites, ...)
end


local calculate_quantum_ref = SMODS.calculate_quantum_enhancements
function SMODS.calculate_quantum_enhancements(card, effects, context, ...)
    local downstream_results
    if calculate_quantum_ref then
        downstream_results = HNDS.pack(calculate_quantum_ref(card, effects, context, ...))
    else
        downstream_results = HNDS.pack()
    end

    local fusions = is_aberrant(card) and aberrant_fusions(card) or nil
    if not fusions or #fusions < 2 then
        return ((table and table.unpack) or unpack)(downstream_results, 1, downstream_results.n)
    end
    if not (SMODS.optional_features and SMODS.optional_features.quantum_enhancements)
        or not context
        or context.extra_enhancement
        or context.check_enhancement
        or SMODS.extra_enhancement_calc_in_progress
    then
        return ((table and table.unpack) or unpack)(downstream_results, 1, downstream_results.n)
    end


    local seen, duplicate_keys = {}, {}
    for _, key in ipairs(fusions) do
        if seen[key] then duplicate_keys[#duplicate_keys + 1] = key
        else seen[key] = true end
    end
    if #duplicate_keys == 0 then
        return ((table and table.unpack) or unpack)(downstream_results, 1, downstream_results.n)
    end

    effects = type(effects) == 'table' and effects or {}
    local old_ability = clone_table(card.ability)
    local old_center = card.config and card.config.center
    local old_center_key = card.config and card.config.center_key
    local old_front_hidden = card.front_hidden
    local old_context_extra = context.extra_enhancement
    local old_progress = SMODS.extra_enhancement_calc_in_progress
    local old_internal_swap = HNDS._aberrant_internal_center_swap

    context.extra_enhancement = true
    SMODS.extra_enhancement_calc_in_progress = true

    local ok, err = xpcall(function()
        for _, key in ipairs(duplicate_keys) do
            local fusion_center = G and G.P_CENTERS and G.P_CENTERS[key]
            if fusion_center then
                if card.quantum_set_ability then
                    card:quantum_set_ability(fusion_center)
                else
                    HNDS._aberrant_internal_center_swap = true
                    card:set_ability(fusion_center, nil, true)
                end
                card.ability.extra_enhancement = key
                effects[#effects + 1] = eval_card(card, context)
            end
        end
    end, function(e) return e end)

    card.ability = old_ability
    if card.config then
        card.config.center = old_center
        card.config.center_key = old_center_key
    end
    card.front_hidden = old_front_hidden
    if not card.quantum_set_ability and card.set_sprites and old_center then
        card:set_sprites(old_center)
    end
    context.extra_enhancement = old_context_extra
    SMODS.extra_enhancement_calc_in_progress = old_progress
    HNDS._aberrant_internal_center_swap = old_internal_swap
    invalidate_enhancement_cache(card)

    if not ok then error(err, 0) end
    return ((table and table.unpack) or unpack)(downstream_results, 1, downstream_results.n)
end


local has_no_suit_ref = SMODS.has_no_suit
function SMODS.has_no_suit(card, ...)
    if is_aberrant(card) and has_fusion(card, "m_stone") then return true end
    return has_no_suit_ref(card, ...)
end

local has_any_suit_ref = SMODS.has_any_suit
function SMODS.has_any_suit(card, ...)
    if is_aberrant(card) and has_fusion(card, "m_stone") then return false end
    return has_any_suit_ref(card, ...)
end


if Card.should_hide_front then
    local should_hide_front_ref = Card.should_hide_front
    function Card:should_hide_front(...)
        if is_aberrant(self) and has_fusion(self, "m_stone") then return true end
        return should_hide_front_ref(self, ...)
    end
end

-- Stone suppresses rank-based chips, but must not erase extra or permanent
-- chips (for example from a second fused enhancement or Hiker).
-- Temporarily clearing nominal keeps the normal scoring and tooltip logic
-- intact, without altering the card's stored rank or its save data.
local function aberrant_without_rank_chips(card, fn, ...)
    if not (is_aberrant(card) and has_fusion(card, 'm_stone') and card.base) then
        return fn(card, ...)
    end
    local saved_nominal = card.base.nominal
    card.base.nominal = 0
    local results = HNDS.pack(pcall(fn, card, ...))
    card.base.nominal = saved_nominal
    if not results[1] then error(results[2], 0) end
    return ((table and table.unpack) or unpack)(results, 2, results.n)
end

if Card.get_chip_bonus then
    local get_chip_bonus_ref = Card.get_chip_bonus
    function Card:get_chip_bonus(...)
        return aberrant_without_rank_chips(self, get_chip_bonus_ref, ...)
    end
end

if Card.generate_UIBox_ability_table then
    local generate_ability_ui_ref = Card.generate_UIBox_ability_table
    function Card:generate_UIBox_ability_table(...)
        return aberrant_without_rank_chips(self, generate_ability_ui_ref, ...)
    end
end


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
}



local ABERRANT_TOP_PRIORITY = {
    stone = true, mult = true, bonus = true, glass = true,
}

local function aberrant_visual_parts(card)
    local fusions = aberrant_fusions(card)
    local first = fusions[1] and (ABERRANT_INDICATOR_KIND[fusions[1]] or 'unknown')
    local second = fusions[2] and (ABERRANT_INDICATOR_KIND[fusions[2]] or 'unknown')
    -- Wild always occupies the top half when fused with another enhancement,
    -- regardless of which one was fused first or their normal priorities.
    if first and second then
        if first == 'wild' then return first, second end
        if second == 'wild' then return second, first end
        if ABERRANT_TOP_PRIORITY[second] and not ABERRANT_TOP_PRIORITY[first] then
            return second, first
        end
    end
    return first, second
end

-- Use the atlases already supplied by Handsome Devils: HDstickers for the
-- enhancement parts, EHD for the Aberrant base, collection art and rift.
-- These sprites are shared rather than created for every card or frame.
local ABERRANT_PART_SPRITES = {}
local ABERRANT_NO_FUSION_BASE_SPRITE
local ABERRANT_NO_FUSION_BASE_ATLAS
local ABERRANT_SINGLE_FUSION_BASE_SPRITE
local ABERRANT_SINGLE_FUSION_BASE_ATLAS
local ABERRANT_COLLECTION_SPRITE
local ABERRANT_COLLECTION_ATLAS
local ABERRANT_OVERLAY_SPRITE
local ABERRANT_OVERLAY_ATLAS

local function aberrant_atlas(key)
    if not (G and G.ASSET_ATLAS) then return nil end
    return G.ASSET_ATLAS['hnds_' .. key] or G.ASSET_ATLAS[key]
        or (SMODS.get_atlas and SMODS.get_atlas(key))
end

local function is_in_aberrant_collection(card)
    return card and card.area and card.area.config and card.area.config.collection == true
end

local function draw_aberrant_part(card, kind, half)
    if not (card.children and card.children.center and G and G.CARD_W and G.CARD_H) then return end
    local part_pos = ABERRANT_INDICATOR_POS[kind]
    local pos = part_pos and part_pos[half]
    local atlas = aberrant_atlas('Stickers')
    if not (pos and atlas and atlas.image) then return end
    local cache_key = kind .. '_' .. half
    local entry = ABERRANT_PART_SPRITES[cache_key]
    if not entry or entry.atlas ~= atlas then
        entry = {
            atlas = atlas,
            sprite = Sprite(0, 0, G.CARD_W, G.CARD_H, atlas, pos),
        }
        ABERRANT_PART_SPRITES[cache_key] = entry
    end
    entry.sprite.role.draw_major = card
    entry.sprite:draw_shader('dissolve', nil, nil, nil, card.children.center)
end

local function draw_aberrant_no_fusion_base(card)
    if not (card.children and card.children.center and G and G.CARD_W and G.CARD_H) then return end
    local atlas = aberrant_atlas('Extras')
    if not (atlas and atlas.image) then return end
    if not ABERRANT_NO_FUSION_BASE_SPRITE or ABERRANT_NO_FUSION_BASE_ATLAS ~= atlas then
        ABERRANT_NO_FUSION_BASE_SPRITE = Sprite(0, 0, G.CARD_W, G.CARD_H, atlas, { x = 4, y = 3 })
        ABERRANT_NO_FUSION_BASE_ATLAS = atlas
    end
    ABERRANT_NO_FUSION_BASE_SPRITE.role.draw_major = card
    ABERRANT_NO_FUSION_BASE_SPRITE:draw_shader('dissolve', nil, nil, nil, card.children.center)
end

local function draw_aberrant_single_fusion_base(card)
    if not (card.children and card.children.center and G and G.CARD_W and G.CARD_H) then return end
    local atlas = aberrant_atlas('Extras')
    if not (atlas and atlas.image) then return end
    if not ABERRANT_SINGLE_FUSION_BASE_SPRITE or ABERRANT_SINGLE_FUSION_BASE_ATLAS ~= atlas then
        ABERRANT_SINGLE_FUSION_BASE_SPRITE = Sprite(0, 0, G.CARD_W, G.CARD_H, atlas, { x = 3, y = 3 })
        ABERRANT_SINGLE_FUSION_BASE_ATLAS = atlas
    end
    ABERRANT_SINGLE_FUSION_BASE_SPRITE.role.draw_major = card
    ABERRANT_SINGLE_FUSION_BASE_SPRITE:draw_shader('dissolve', nil, nil, nil, card.children.center)
end

-- When Aberrant has no fused enhancements yet, render EHD (4,3)
-- as the bottom-most Aberrant layer under every other Aberrant visual.
SMODS.DrawStep({
    key = 'hnds_aberrant_no_fusion_base',
    order = -12,
    conditions = { vortex = false, facing = 'front' },
    func = function(card, layer)
        if not is_aberrant(card) or is_in_aberrant_collection(card) then return end
        if #aberrant_fusions(card) ~= 0 then return end
        draw_aberrant_no_fusion_base(card)
    end,
})

-- When exactly one enhancement is fused into Aberrant, render EHD (3,3)
-- as the bottom-most Aberrant layer under every other Aberrant visual.
SMODS.DrawStep({
    key = 'hnds_aberrant_single_fusion_base',
    order = -11,
    conditions = { vortex = false, facing = 'front' },
    func = function(card, layer)
        if not is_aberrant(card) or is_in_aberrant_collection(card) then return end
        if #aberrant_fusions(card) ~= 1 then return end
        draw_aberrant_single_fusion_base(card)
    end,
})

-- In Steamodded, center/base is drawn at -10 and front/rank/suit at 0.
-- Drawing at -5 places the enhancement parts over the base card art but
-- under its rank and suit. This must run on real cards, not collections.
SMODS.DrawStep({
    key = 'hnds_aberrant_enhancement_parts',
    order = -5,
    conditions = { vortex = false, facing = 'front' },
    func = function(card, layer)
        if not is_aberrant(card) or is_in_aberrant_collection(card) then return end
        local top, bottom = aberrant_visual_parts(card)
        if top then draw_aberrant_part(card, top, 'top') end
        if bottom then draw_aberrant_part(card, bottom, 'bottom') end
    end,
})

local function draw_aberrant_collection_art(card)
    if not (is_in_aberrant_collection(card) and card.children and card.children.center) then return end
    local atlas = aberrant_atlas('Extras')
    if not (atlas and atlas.image) then return end
    if not ABERRANT_COLLECTION_SPRITE or ABERRANT_COLLECTION_ATLAS ~= atlas then
        ABERRANT_COLLECTION_SPRITE = Sprite(0, 0, G.CARD_W, G.CARD_H, atlas, { x = 2, y = 3 })
        ABERRANT_COLLECTION_ATLAS = atlas
    end
    ABERRANT_COLLECTION_SPRITE.role.draw_major = card
    ABERRANT_COLLECTION_SPRITE:draw_shader('dissolve', nil, nil, nil, card.children.center)
end

-- EHD (2,0) supplies the persistent rift overlay. Do not apply it to the
-- collection preview (EHD 2,3). No extra rift texture/atlas is necessary.
SMODS.DrawStep({
    key = 'hnds_aberrant_rift_overlay',
    order = 60,
    conditions = { vortex = false, facing = 'front' },
    func = function(card, layer)
        if not (is_aberrant(card) and not is_in_aberrant_collection(card)
            and card.children and card.children.center) then return end
        local atlas = aberrant_atlas('Extras')
        if not (atlas and atlas.image) then return end
        if not ABERRANT_OVERLAY_SPRITE or ABERRANT_OVERLAY_ATLAS ~= atlas then
            ABERRANT_OVERLAY_SPRITE = Sprite(0, 0, G.CARD_W, G.CARD_H, atlas, { x = 2, y = 0 })
            ABERRANT_OVERLAY_ATLAS = atlas
        end
        ABERRANT_OVERLAY_SPRITE.role.draw_major = card
        ABERRANT_OVERLAY_SPRITE:draw_shader('dissolve', nil, nil, nil, card.children.center)
    end,
})

SMODS.Enhancement({
    key = "aberrant",
    atlas = "Extras",
    pos = { x = 1, y = 3 },
    draw = function(self, card, layer)
        draw_aberrant_collection_art(card)
    end,
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
