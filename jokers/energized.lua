SMODS.Joker {
    key = "energized",
    atlas = "Jokers",
    pos = { x = 2, y = 2 },
    rarity = 3,
    cost = 10,
    config = { extra = { odds = 2, reps = 4 }},
    loc_vars = function (self, info_queue, card)
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, "hnds_energized")
        return { vars = { numerator, denominator, card.ability.extra.reps }}
    end,
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    calculate = function (self, card, context)
        if context.repetition and #G.play.cards == 1 and context.other_card == G.play.cards[1] then
            return {
                repetitions = card.ability.extra.reps
            }
        end
        if context.destroy_card and #G.play.cards == 1 and context.destroy_card == G.play.cards[1] and not context.blueprint and SMODS.pseudorandom_probability(card, "hnds_energized", 1, card.ability.extra.odds) then
            return {
                remove = true
            }
        end
    end
}