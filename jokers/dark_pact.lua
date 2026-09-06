local function hnds_dark_pact_target_areas()
    local areas, seen = {}, {}
    local function add(area)
        if area and not seen[area] then
            seen[area] = true
            areas[#areas + 1] = area
        end
    end
    add(G and G.hand)
    add(G and G.jokers)
    add(G and G.consumeables)
    add(G and G.pack_cards)
    return areas
end

local function hnds_dark_pact_clear_highlights()
    local areas = hnds_dark_pact_target_areas()
    local seen = {}
    for _, area in ipairs(areas) do
        if area and not seen[area] then
            seen[area] = true
            if type(area.unhighlight_all) == 'function' then
                pcall(area.unhighlight_all, area)
            elseif type(area.highlighted) == 'table' then
                for _, target in ipairs(area.highlighted) do
                    if target then target.highlighted = false end
                end
                area.highlighted = {}
            end
        end
    end
end

local function hnds_dark_pact_live_cards(area)
    local cards = {}
    for _, target in ipairs((area and area.cards) or {}) do
        if target and not target.REMOVED and not target.removed then
            cards[#cards + 1] = target
        end
    end
    return cards
end

local function hnds_dark_pact_highlight_random(area, count, seed)
    if not area or count < 1 then return false end
    local available = hnds_dark_pact_live_cards(area)
    if #available < count then return false end

    if type(area.unhighlight_all) == 'function' then
        pcall(area.unhighlight_all, area)
    else
        area.highlighted = {}
    end

    for index = 1, count do
        local target, target_index = pseudorandom_element(
            available,
            pseudoseed(seed .. '_' .. tostring(index))
        )
        if not target then return false end
        table.remove(available, target_index)

        if type(area.add_to_highlighted) == 'function' then
            area:add_to_highlighted(target, true)
        else
            area.highlighted = area.highlighted or {}
            area.highlighted[#area.highlighted + 1] = target
            target.highlighted = true
        end
    end
    return type(area.highlighted) ~= 'table' or #area.highlighted == count
end

local function hnds_dark_pact_selection_limits(card, center)
    local configs = {
        card and card.ability,
        card and card.ability and card.ability.consumeable,
        card and card.ability and card.ability.consumable,
        center and center.config,
        center and center.config and center.config.consumeable,
        center and center.config and center.config.consumable,
    }
    local maximum, minimum
    for _, config in pairs(configs) do
        if type(config) == 'table' then
            maximum = maximum or tonumber(config.max_highlighted)
                or tonumber(config.max_highlighted_cards)
            minimum = minimum or tonumber(config.min_highlighted)
                or tonumber(config.min_highlighted_cards)
        end
    end
    if maximum then maximum = math.max(0, math.floor(maximum)) end
    if minimum then minimum = math.max(0, math.floor(minimum)) end
    return maximum, minimum
end

local function hnds_dark_pact_can_use(card, center)
    if card and type(card.can_use_consumeable) == 'function' then
        local ok, result = pcall(card.can_use_consumeable, card, true, true)
        if ok then return result == true, true end
    end
    if center and type(center.can_use) == 'function' then
        local ok, result = pcall(center.can_use, center, card)
        if ok then return result == true, true end
    end
    return false, false
end

local function hnds_dark_pact_prepare_targets(card, center, seed)
    hnds_dark_pact_clear_highlights()

    local usable, validated = hnds_dark_pact_can_use(card, center)
    if usable then return true end

    local maximum, minimum = hnds_dark_pact_selection_limits(card, center)
    local has_selection_config = maximum ~= nil or minimum ~= nil
    maximum = maximum or math.max(1, minimum or 1)
    minimum = minimum or 1
    if maximum < minimum then maximum = minimum end

    local areas = hnds_dark_pact_target_areas()
    local seen = {}
    for area_index, area in ipairs(areas) do
        if area and not seen[area] then
            seen[area] = true
            local available = hnds_dark_pact_live_cards(area)
            for count = math.min(maximum, #available), minimum, -1 do
                local attempts = math.min(8, math.max(1, #available * 2))
                for attempt = 1, attempts do
                    hnds_dark_pact_clear_highlights()
                    local target_seed = table.concat({
                        seed, tostring(area_index), tostring(count), tostring(attempt),
                    }, '_')
                    if hnds_dark_pact_highlight_random(area, count, target_seed) then
                        usable, validated = hnds_dark_pact_can_use(card, center)
                        if usable or (not validated and has_selection_config) then
                            return true
                        end
                    end
                end
            end
        end
    end

    hnds_dark_pact_clear_highlights()
    return false
end

local function hnds_dark_pact_pool(seed)
    local raw_pool
    if SMODS and type(SMODS.get_clean_pool) == 'function' then
        local ok, result = pcall(SMODS.get_clean_pool, 'Spectral', nil, false, seed)
        if ok and type(result) == 'table' then raw_pool = result end
    end
    if not raw_pool and type(get_current_pool) == 'function' then
        local ok, result = pcall(get_current_pool, 'Spectral', nil, false, seed)
        if ok and type(result) == 'table' then raw_pool = result end
    end

    local pool, seen = {}, {}
    for _, entry in ipairs(raw_pool or {}) do
        local center = type(entry) == 'table' and entry
            or (G and G.P_CENTERS and G.P_CENTERS[entry])
        if center and center.key and center.set == 'Spectral'
            and center.hidden ~= true and entry ~= 'UNAVAILABLE'
            and not seen[center.key]
        then
            seen[center.key] = true
            pool[#pool + 1] = center.key
        end
    end
    return pool
end

local function hnds_dark_pact_dispose(card)
    if not card or card.REMOVED or card.removed then return true end
    if type(card.remove) == 'function' then pcall(card.remove, card) end
    return true
end

local function hnds_dark_pact_queue_cleanup(card)
    local function cleanup()
        hnds_dark_pact_clear_highlights()
        return hnds_dark_pact_dispose(card)
    end
    if G and G.E_MANAGER and Event then
        G.E_MANAGER:add_event(Event {
            trigger = 'after', delay = 0.2, func = cleanup,
        })
    else
        cleanup()
    end
end

local function hnds_dark_pact_create_spectral(key, seed)
    if not (SMODS and type(SMODS.create_card) == 'function') then return nil end
    local area = G and (G.consumeables or G.play or G.hand)
    local ok, card = pcall(SMODS.create_card, {
        set = 'Spectral',
        key = key,
        area = area,
        skip_materialize = true,
        soulable = false,
        no_edition = true,
        bypass_discovery_center = true,
        bypass_discovery_ui = true,
        key_append = seed,
    })
    if ok then return card end
end

local function hnds_dark_pact_use_random_spectral(owner)
    local owner_id = tostring(owner and (owner.sort_id or owner.ID) or 'dark_pact')
    local serial = G and G.GAME and G.GAME.hnds_dark_pact_serial or 0
    serial = serial + 1
    if G and G.GAME then G.GAME.hnds_dark_pact_serial = serial end
    local seed = 'hnds_dark_pact_' .. owner_id .. '_' .. tostring(serial)
    local pool = hnds_dark_pact_pool(seed)

    for attempt = 1, #pool do
        local key, pool_index = pseudorandom_element(
            pool,
            pseudoseed(seed .. '_spectral_' .. tostring(attempt))
        )
        if not key then break end
        table.remove(pool, pool_index)

        local spectral = hnds_dark_pact_create_spectral(key, seed .. '_' .. tostring(attempt))
        local center = spectral and spectral.config and spectral.config.center
        if spectral and center
            and hnds_dark_pact_prepare_targets(spectral, center, seed .. '_targets_' .. tostring(attempt))
        then
            spectral.hnds_dark_pact_generated = true
            local used = false
            if type(spectral.use_consumeable) == 'function' then
                local ok = pcall(spectral.use_consumeable, spectral, G and G.consumeables)
                used = ok
            elseif type(center.use) == 'function' then
                local ok = pcall(center.use, center, spectral, G and G.consumeables)
                used = ok
            end

            hnds_dark_pact_queue_cleanup(spectral)
            if used then return key end
            return nil
        end

        hnds_dark_pact_dispose(spectral)
    end

    hnds_dark_pact_clear_highlights()
end

local function hnds_dark_pact_hand_has_three_sixes(context)
    local played_hand = context and (context.full_hand or context.scoring_hand)
    if type(played_hand) ~= 'table' then return false end

    local sixes = 0
    for _, playing_card in ipairs(played_hand) do
        local rank
        if playing_card and type(playing_card.get_id) == 'function' then
            local ok, value = pcall(playing_card.get_id, playing_card)
            if ok then rank = value end
        end
        rank = rank or (playing_card and playing_card.base and playing_card.base.id)
        if rank == 6 then
            sixes = sixes + 1
            if sixes >= 3 then return true end
        end
    end
    return false
end

SMODS.Joker {
    key = 'dark_pact',
    prefix_config = { key = { mod = false } },
    atlas = 'Jokers',
    pos = { x = 2, y = 8 },
    rarity = 2,
    cost = 8,
    unlocked = true,
    discovered = false,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    config = { extra = { odds = 2 } },
    loc_vars = function(self, info_queue, card)
        local extra = card and card.ability and card.ability.extra or self.config.extra
        local numerator, denominator = 1, tonumber(extra.odds) or 2
        if SMODS and type(SMODS.get_probability_vars) == 'function' then
            numerator, denominator = SMODS.get_probability_vars(
                card or self, 1, denominator, 'hnds_dark_pact'
            )
        end
        return { vars = { numerator, denominator } }
    end,
    calculate = function(self, card, context)
        local valid_context = context.forcetrigger
            or (context.after and not context.repetition and not context.repetition_only)
        if not valid_context then return end
        if not context.forcetrigger and not hnds_dark_pact_hand_has_three_sixes(context) then
            return
        end

        local odds = tonumber(card.ability.extra and card.ability.extra.odds) or 2
        if not context.forcetrigger and not SMODS.pseudorandom_probability(
            card, 'hnds_dark_pact', 1, odds, 'hnds_dark_pact'
        ) then
            return { message = localize('k_nope_ex'), colour = G.C.RED }
        end

        local display_card = context.blueprint_card or card
        local function activate()
            local spectral_key = hnds_dark_pact_use_random_spectral(display_card)
            if type(card_eval_status_text) == 'function' then
                local message = spectral_key and localize({
                    type = 'name_text', set = 'Spectral', key = spectral_key,
                }) or localize('k_nope_ex')
                card_eval_status_text(display_card, 'extra', nil, nil, nil, {
                    message = message,
                    colour = spectral_key and G.C.SECONDARY_SET.Spectral or G.C.RED,
                })
            end
            return true
        end

        if G and G.E_MANAGER and Event then
            G.E_MANAGER:add_event(Event {
                trigger = 'after', delay = 0.1, blockable = false, func = activate,
            })
        else
            activate()
        end
        return { message = 'Pact!', colour = G.C.SECONDARY_SET.Spectral }
    end,
    attributes = { 'joker', 'chance', 'spectral', 'generation' },
}
