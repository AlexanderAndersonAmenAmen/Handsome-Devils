SMODS.Joker {
    key = "contagion",
    atlas = "Jokers",
    pos = { x = 5, y = 4 },
    rarity = "Uncommon",
    cost = 6,
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    config = { extra = { odds = 4 } },
    loc_vars = function(self, info_queue, card)
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, 'hnds_contagion')
        return { vars = { numerator, denominator } }
    end,
    calculate = function(self, card, context)
        if context.before and context.scoring_hand and not context.blueprint then
            for i, scoring_card in ipairs(context.scoring_hand) do
                if scoring_card.config.center ~= G.P_CENTERS.c_base then
                    local right_index = i + 1
                    if right_index <= #context.scoring_hand then
                        local right_card = context.scoring_hand[right_index]
                        if right_card.config.center == G.P_CENTERS.c_base then
                            if SMODS.pseudorandom_probability(card, 'hnds_contagion', 1, card.ability.extra.odds) then
                                right_card:flip()
                                right_card:set_ability(scoring_card.config.center)
                                G.E_MANAGER:add_event(Event({
                                    trigger = 'after',
                                    delay = 0.3,
                                    func = function()
                                        right_card:juice_up()
                                        play_sound('card1', 1)
                                        return true
                                    end
                                }))
                                G.E_MANAGER:add_event(Event({
                                    trigger = 'after',
                                    delay = 0.15,
                                    func = function()
                                        right_card:flip()
                                        play_sound('tarot2', 1, 0.6)
                                        return true
                                    end
                                }))
                            end
                        end
                    end
                end
            end
        end
    end
}