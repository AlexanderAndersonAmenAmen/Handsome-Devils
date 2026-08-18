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
    unlocked = false,
    discovered = false,
    unlock_condition = { type = "hnds_joker_unlock", key = "supersuit" },
    locked_loc_vars = function(self)
        return HNDS.joker_locked_loc_vars("supersuit")
    end,
    check_for_unlock = function(self, args)
        return HNDS.joker_unlock_condition_met("supersuit", args)
    end,
    loc_vars = function(self, info_queue, card)
        local round = G and G.GAME and G.GAME.current_round
        local current_suit = round and round.supersuit_card and round.supersuit_card.suit or "Spades"
        local suit_colour = G and G.C and G.C.SUITS and G.C.SUITS[current_suit]
        return {vars = {localize(current_suit, 'suits_singular'), colours = {suit_colour}}}
    end,

    calculate = function(self, card, context)
        if type(context) ~= "table" then return end
        local other = context.other_card
        local current_round = G and G.GAME and G.GAME.current_round
        local suit = current_round and current_round.supersuit_card and current_round.supersuit_card.suit
        if not (other and type(other.is_suit) == "function" and suit) then return end

        if context.cardarea == G.play and context.repetition and other:is_suit(suit) then
            return {
                message = localize('k_again_ex'),
                repetitions = card.ability.extra.reps,
                card = card
            }

        elseif context.repetition and context.cardarea == G.hand and other:is_suit(suit) then
            local effects = type(context.card_effects) == "table" and context.card_effects or {}
            if ((type(effects[1]) == "table" and next(effects[1])) or #effects > 1) then
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
    end,
    attributes = { "retrigger", "suit", }
})