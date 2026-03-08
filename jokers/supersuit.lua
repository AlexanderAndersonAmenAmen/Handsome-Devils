SMODS.Joker ({
    key = "supersuit",
    config = {
        extra = {
            reps = 1,
        }
    },
    pos = {
        x = 2,
        y = 1
    },
    cost = 6,
    rarity = 2,
	atlas = "Jokers",
    blueprint_compat = true,
    eternal_compat = true,
    unlocked = true,
    discovered = true,
    loc_vars = function(self, info_queue, card)
        local current_suit = G.GAME.current_round.supersuit_card and G.GAME.current_round.supersuit_card.suit or "Spades"
        return {vars = {localize(current_suit, 'suits_singular'), colours = {G.C.SUITS[current_suit]}}}
    end,

    calculate = function(self, card, context)


        if context.cardarea == G.play and context.repetition and context.other_card:is_suit(G.GAME.current_round.supersuit_card.suit) then
            return {
                message = localize('k_again_ex'),
                repetitions = card.ability.extra.reps,
                card = card
            }

        elseif context.repetition and context.cardarea == G.hand and context.other_card:is_suit(G.GAME.current_round.supersuit_card.suit) then
            if (next(context.card_effects[1]) or #context.card_effects > 1) then
                return {
                    message = localize('k_again_ex'),
                    repetitions = card.ability.extra.reps,
                    card = card
                }
            end
        end
    end,
    joker_display_def = function(JokerDisplay)
        return {
            text = {
                { text = "+" },
                { ref_table = "card.joker_display_values", ref_value = "repetitions" }
            },
            text_config = { colour = G.C.UI.TEXT_LIGHT },
            reminder_text = {
                { text = "(" },
                { ref_table = "card.joker_display_values", ref_value = "suit", colour = G.C.ORANGE },
                { text = ")" }
            },
            calc_function = function(card)
                local current_suit = (G.GAME and G.GAME.current_round and G.GAME.current_round.supersuit_card) and G.GAME.current_round.supersuit_card.suit or "Spades"
                card.joker_display_values.suit = localize(current_suit, 'suits_plural')
                card.joker_display_values.repetitions = card.ability.extra.reps
            end,
            retrigger_function = function(playing_card, scoring_hand, held_in_hand, joker_card)
                local current_suit = (G.GAME and G.GAME.current_round and G.GAME.current_round.supersuit_card) and G.GAME.current_round.supersuit_card.suit or "Spades"
                if playing_card:is_suit(current_suit) then
                    return joker_card.ability.extra.reps * JokerDisplay.calculate_joker_triggers(joker_card)
                end
                return 0
            end
        }
    end
})