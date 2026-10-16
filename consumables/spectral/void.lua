local function void_selection()
    if not G then return nil, nil end
    for _, area in pairs({ G.hand, G.pack_cards }) do
        if area and area.highlighted and #area.highlighted == 1 then
            return area, area.highlighted[1]
        end
    end
    return nil, nil
end

local function void_source_for(target)
    if not (G and target) then return nil end
    if G.hand and target.area == G.hand then return G.hand end
    if G.pack_cards and target.area == G.pack_cards then return G.pack_cards end
    return nil
end

local function void_is_playing_card(card)
    return card and card.playing_card ~= nil
end

local function apply_void(source, target)
    if not (G and G.E_MANAGER and Event and source and target) then return end
    local other_cards = {}
    for _, other in ipairs(source.cards or {}) do
        if other ~= target and void_is_playing_card(other) then
            other_cards[#other_cards + 1] = other
        end
    end
    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0.15,
        func = function()
            if target and not target.removed then
                target:set_edition('e_negative', true)
                target:juice_up(0.3, 0.5)
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
                if other and not other.removed and other ~= target and other.area == source then
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
        return { vars = { 1 } }
    end,
    can_use = function(self, card)
        local area, target = void_selection()
        return area ~= nil and void_is_playing_card(target)
    end,
    use = function(self, card, context, copier)
        local area, target = void_selection()
        if area and target then apply_void(area, target) end
    end,
    force_use = function(self, card, area)
        local source, target = void_selection()
        if not source then
            local areas = G and { G.hand, G.pack_cards } or {}
            local cards = Cryptid and Cryptid.get_highlighted_cards
                and Cryptid.get_highlighted_cards(areas, {}, 1, 1)
            target = cards and cards[1]
            source = void_source_for(target)
        end
        if source and target then apply_void(source, target) end
    end,
    demicoloncompat = true,
})
