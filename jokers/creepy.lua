SMODS.Joker {
    key = "creepy",
    atlas = "Jokers",
    pos = { x = 7, y = 3 },
    rarity = 2,
    cost = 5,
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    config = { extra = { odds = 5, Xmult = 1.5, cards = 1 } },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.m_hnds_creepyenh
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, 'hnds_creepy')
        return { vars = { card.ability.extra.cards, card.ability.extra.Xmult, numerator, denominator } }
    end,
    calculate = function(self, card, context)
        if context.end_of_round and context.game_over == false and context.main_eval and not context.blueprint then
            if SMODS.pseudorandom_probability(card, 'hnds_creepy', 1, card.ability.extra.odds) then
                SMODS.destroy_cards(card, nil, nil, true)
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.7,
                    func = function()
                        local cards = {}
                        for i = 1, card.ability.extra.cards do
                            local cen_pool = {}
                            for _, enhancement_center in pairs(G.P_CENTER_POOLS["Enhanced"]) do
                                if enhancement_center.key ~= 'm_stone' and not enhancement_center.overrides_base_rank then
                                    cen_pool[#cen_pool + 1] = enhancement_center
                                end
                            end
                            local enhancement = pseudorandom_element(cen_pool, 'spe_card')
                            cards[i] = SMODS.add_card { set = "Base", rank = 'hnds_creepycard', area = G.deck, enhancement = 'm_hnds_creepyenh' }
                        end
                        SMODS.calculate_context({ playing_card_added = true, cards = cards })
                        return true
                    end
                }))
                return {
                    message = localize('k_extinct_ex')
                }
            else
                return {
                    message = localize('k_safe_ex')
                }
            end
        end

        if context.joker_main then
            return {
                mult = card.ability.extra.Xmult
            }
        end
    end
}
