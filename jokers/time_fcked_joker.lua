SMODS.Joker {
    key = 'time_fcked_joker',
    atlas = 'Jokers',
    pos = { x = 8, y = 6 },
    rarity = 2,
    cost = 4,
    unlocked = true,
    discovered = true,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,

    -- The user's operational clarification specifies 1 in 2. Keep the odds in
    -- config so probability modifiers and the tooltip use the same value.
    config = { extra = { odds = 3 } },

    loc_vars = function(self, info_queue, card)
        local extra = card and card.ability and card.ability.extra or self.config.extra
        local numerator, denominator = SMODS.get_probability_vars(
            card, 1, tonumber(extra.odds) or 2, 'hnds_time_fcked'
        )
        return { vars = { numerator, denominator } }
    end,

    calculate = function(self, card, context)
        if context.end_of_round and context.main_eval and not context.game_over
            and not context.blueprint and not context.retrigger_joker
            and HNDS and HNDS.capture_time_fcked_blind
        then
            HNDS.capture_time_fcked_blind()
        end
    end,

    joker_display_def = function(JokerDisplay)
        return {
            reminder_text = {
                { text = '(' },
                { ref_table = 'card.joker_display_values', ref_value = 'odds' },
                { text = ')' },
            },
            calc_function = function(card)
                local normal = G.GAME and G.GAME.probabilities and G.GAME.probabilities.normal or 1
                card.joker_display_values.odds = localize {
                    type = 'variable', key = 'jdis_odds',
                    vars = { normal, tonumber(card.ability.extra.odds) or 2 },
                }
            end,
        }
    end,

    attributes = { 'chance' },
}
