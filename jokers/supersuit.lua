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
    end
})