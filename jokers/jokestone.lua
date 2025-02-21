SMODS.Joker {
    key = 'jokestone',
    atlas = 'Jokers',
    pos = { x = 6, y = 3 },
    rarity = 1,
    cost = 5,
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    config =
    { extra = {
        draw = 2,
    }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.draw } }
    end,
    calculate = function(self, card, context)
        if context.first_hand_drawn and #G.deck.cards > 0 then
            G.E_MANAGER:add_event(Event({
                trigger = 'before',
                func = function()
                    local _cards = {}
                    for i = 1, #G.deck.cards do
                        local _card = G.deck.cards[i]
                        if _card.ability.set == "Enhanced" and not _card.ability.hnds_drawing then
                            _cards[#_cards + 1] = _card
                        end
                    end
                    if #_cards > 0 then
                        local _card = pseudorandom_element(_cards, pseudoseed("j_hnds_jokestone"))
                        _card.ability.hnds_drawing = true
                        card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, {
                            message = 'tour guide',
                            colour = G.C.PURPLE,
                            instant = true
                        })
                        draw_card(G.deck, G.hand, nil, 'up', true, _card)
                        G.E_MANAGER:add_event(Event({
                            trigger = 'before',
                            delay = 0.1,
                            func = function()
                                _card.ability.hnds_drawing = nil
                                return true
                            end
                        }))
                    end
                    return true
                end
            }))
        end
    end
}
