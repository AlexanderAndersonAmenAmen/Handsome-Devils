SMODS.Consumable({
    key = 'cycle',
    set = 'Spectral',
    discovered = false,
    order = 1,
    cost = 4,
    atlas = "Consumables",
	pos = { x = 1, y = 0 },
    config = { max_highlighted = 1 },
    loc_vars = function(self, info_queue, card)
        if info_queue and G and G.P_SEALS and G.P_SEALS.hnds_green then info_queue[#info_queue + 1] = G.P_SEALS.hnds_green end
        local max_highlighted = card and card.ability and card.ability.max_highlighted or self.config.max_highlighted
        return { vars = { max_highlighted, colours = { HEX('55a383') } } }
    end,
    can_use = function(self, card)
        return G and G.hand and G.hand.highlighted and #G.hand.highlighted == 1
    end,
    use = function(self, card, area, copier)
        local highlighted = G and G.hand and G.hand.highlighted and G.hand.highlighted[1]
        if not highlighted then return end
        G.E_MANAGER:add_event(Event({ func = function() play_sound('tarot1'); highlighted:juice_up(0.3, 0.5); return true end }))
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.1,
            func = function()
                if highlighted and highlighted.set_seal then highlighted:set_seal('hnds_green', nil, true) end
                return true
            end,
        }))
        delay(0.5)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                if G.hand then G.hand:unhighlight_all() end
                return true
            end,
        }))
    end,
    force_use = function(self, card, area)
        local cards = Cryptid and Cryptid.get_highlighted_cards and Cryptid.get_highlighted_cards({ G.hand }, {}, 1, card.ability.max_highlighted)
        if not cards then cards = G and G.hand and G.hand.highlighted or {} end
        for i = 1, math.min(#cards, 1) do
            local highlighted = cards[i]
            if highlighted and highlighted.set_seal then highlighted:set_seal('hnds_green') end
        end
        if G and G.hand then G.hand:unhighlight_all() end
    end,
    demicoloncompat = true,
})
