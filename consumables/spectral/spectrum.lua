SMODS.Consumable {
    key = "spectrum",
    set = "Spectral",
    atlas = "Consumables",
    pos = { x = 0, y = 1 },
    soul_pos = { x = 0, y = 2 },
    discovered = true,
    cost = 4,
    use = function(self, card, area, copier)
        local enh_options = get_current_pool("Enhanced")
        for i, k in pairs(enh_options) do
            if k == "m_bonus" or k == "m_mult" then
                enh_options[i] = "UNAVAILABLE"
            end
        end
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound("tarot1")
                card:juice_up(0.3, 0.5)
                return true
            end
        }))
        for i = 1, #G.hand.cards do
            local percent = 1.15 - (i - 0.999) / (#G.hand.cards - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    G.hand.cards[i]:flip()
                    play_sound('card1', percent)
                    G.hand.cards[i]:juice_up(0.3, 0.3)
                    return true
                end
            }))
        end
        for i = 1, #G.hand.cards do
            G.E_MANAGER:add_event(Event({
                func = function()
                    local c = G.hand.cards[i]
                    
                    local enh = SMODS.poll_enhancement({ guaranteed = true, options = enh_options })
                    
                    c:set_ability(enh)
                    return true
                end
            }))
        end
         for i = 1, #G.hand.cards do
            G.E_MANAGER:add_event(Event({
                func = function()
                    local c = G.hand.cards[i]
                    
                     local seal = SMODS.poll_seal({ guaranteed = true })
                    c:set_seal(seal)
                    return true
                end
            }))
        end

        for i = 1, #G.hand.cards do
            local percent = 0.85 + (i - 0.999) / (#G.hand.cards - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    G.hand.cards[i]:flip()
                    play_sound('tarot2', percent, 0.6)
                    G.hand.cards[i]:juice_up(0.3, 0.3)
                    return true
                end
            }))
        end
        delay(0.5)
    end,
    can_use = function(self, card)
        return G.hand and #G.hand.cards > 0
    end,
    force_use = function(self, card, area)
        if G.hand and #G.hand.cards > 0 then
            self:use(card, area)
        end
    end
}
