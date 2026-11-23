local function void_is_playing_card(card)
    return card and card.playing_card ~= nil
end

local function void_selection(card)
    if not G then return nil, nil end
    local selected_area, selected
    for _, area in pairs({ G.hand, G.pack_cards }) do
        if area and area.highlighted and #area.highlighted > 0 then
            local playing_cards = {}
            for _, target in ipairs(area.highlighted) do
                if void_is_playing_card(target) then playing_cards[#playing_cards + 1] = target end
            end
            -- The consumable itself may be highlighted in a Spectral Pack.
            -- Only playing-card highlights compete with the hand selection.
            if #playing_cards > 0 then
                if selected_area or #playing_cards > HNDS.contagion_target_limit(card, 1) then return nil, nil end
                selected_area, selected = area, playing_cards
            end
        end
    end
    return selected_area, selected
end

local function void_source_for(target)
    if not (G and target) then return nil end
    if G.hand and target.area == G.hand then return G.hand end
    if G.pack_cards and target.area == G.pack_cards then return G.pack_cards end
    return nil
end

local function apply_void(source, targets)
    if not (G and G.E_MANAGER and Event and source and targets and #targets > 0) then return end
    -- Resolve the whole selection at once: applying Void separately to each
    -- target would destroy the other selected cards.
    local selected = {}
    for _, target in ipairs(targets) do selected[target] = true end
    local other_cards = {}
    for _, other in ipairs(source.cards or {}) do
        if not selected[other] and void_is_playing_card(other) then
            other_cards[#other_cards + 1] = other
        end
    end
    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0.15,
        func = function()
            for _, target in ipairs(targets) do
                if target and not target.removed and not target.REMOVED then
                    target:set_edition('e_negative', true)
                    target:juice_up(0.3, 0.5)
                end
            end
            return true
        end,
    }))
    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0.2,
        func = function()
            local remaining = {}
            for _, other in ipairs(other_cards) do
                if other and not other.removed and not selected[other] and other.area == source then
                    remaining[#remaining + 1] = other
                end
            end
            if #remaining > 0 then
                if SMODS and SMODS.destroy_cards then
                    SMODS.destroy_cards(remaining)
                else
                    for _, other in ipairs(remaining) do other:start_dissolve() end
                end
            end
            return true
        end,
    }))
    if source.unhighlight_all then source:unhighlight_all() end
end

SMODS.Consumable({
    key = 'void',
    set = 'Spectral',
    config = { max_highlighted = 1 },
    discovered = false,
    atlas = 'Consumables',
    pos = { x = 2, y = 0 },
    cost = 4,
    loc_vars = function(self, info_queue, card)
        if info_queue then info_queue[#info_queue + 1] = { key = 'hnds_negative_playing_card', set = 'Other' } end
        local count = HNDS.contagion_target_limit(card, self.config.max_highlighted)
        return { key = count > 1 and 'c_hnds_void_plural' or 'c_hnds_void', vars = { count } }
    end,
    can_use = function(self, card)
        local area = void_selection(card)
        return area ~= nil
    end,
    use = function(self, card, context, copier)
        local area, targets = void_selection(card)
        if area and targets then apply_void(area, targets) end
    end,
    force_use = function(self, card, area)
        local source, targets = void_selection(card)
        if not source then
            local areas = G and { G.hand, G.pack_cards } or {}
            local cards = Cryptid and Cryptid.get_highlighted_cards
                and Cryptid.get_highlighted_cards(areas, {}, 1, HNDS.contagion_target_limit(card, 1))
            source = cards and void_source_for(cards[1])
            targets = {}
            for _, target in ipairs(cards or {}) do
                if source ~= void_source_for(target) or not void_is_playing_card(target) then return end
                if #targets < HNDS.contagion_target_limit(card, 1) then targets[#targets + 1] = target end
            end
        end
        if source and targets then apply_void(source, targets) end
    end,
    demicoloncompat = true,
})
