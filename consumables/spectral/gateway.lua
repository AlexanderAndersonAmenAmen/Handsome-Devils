SMODS.Consumable({
    key = 'gateway',
    atlas = 'Consumables',
    pos = { x = 2, y = 1 },
    set = 'Spectral',
    config = { max_highlighted = 1 },
    discovered = false,
    cost = 4,
    loc_vars = function(self, info_queue, card)
        if info_queue then info_queue[#info_queue + 1] = { key = 'hnds_bound', set = 'Other' } end
        return { vars = { HNDS.contagion_target_limit(card, 1) } }
    end,
    can_use = function(self, card)
        return G and G.hand and G.hand.highlighted and #G.hand.highlighted > 0
            and #G.hand.highlighted <= HNDS.contagion_target_limit(card, 1)
    end,
    use = function(self, card, area, copier)
        local targets = {}
        for i, target in ipairs(G.hand.highlighted) do
            if i <= HNDS.contagion_target_limit(card, 1) then targets[#targets+1] = target end
        end
        if #targets == 0 then return end
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.1,
            func = function()
                for _, target in ipairs(targets) do
                if target and not target.removed and not target.REMOVED then
                    if target.add_sticker then target:add_sticker('hnds_bound', true) end
                    target.ability = target.ability or {}
                    target.ability.hnds_bound = true
                    target:juice_up(0.3, 0.5)
                    play_sound('tarot1')
                end
                end
                return true
            end,
        }))
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
        local cards = Cryptid and Cryptid.get_highlighted_cards
            and Cryptid.get_highlighted_cards({ G.hand }, {}, 1, HNDS.contagion_target_limit(card, 1))
            or (G and G.hand and G.hand.highlighted or {})
        for i, target in ipairs(cards or {}) do
        if i <= HNDS.contagion_target_limit(card, 1) and target and not target.removed and not target.REMOVED then
            if target.add_sticker then target:add_sticker('hnds_bound', true) end
            target.ability = target.ability or {}
            target.ability.hnds_bound = true
        end
        end
    end,
    demicoloncompat = true,
})
