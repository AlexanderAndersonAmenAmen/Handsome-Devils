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
    unlocked = false,
    discovered = false,
    unlock_condition = { type = "hnds_joker_unlock", key = "energized" },
    locked_loc_vars = function(self)
        return HNDS.joker_locked_loc_vars("energized")
    end,
    check_for_unlock = function(self, args)
        return HNDS.joker_unlock_condition_met("energized", args)
    end,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    calculate = function (self, card, context)
        if context.repetition and #G.play.cards == 1 and context.other_card == G.play.cards[1] then
            return { repetitions = card.ability.extra.reps }
        end
        if context.destroy_card and #G.play.cards == 1 and context.destroy_card == G.play.cards[1] and not context.blueprint and SMODS.pseudorandom_probability(card, "hnds_energized", 1, card.ability.extra.odds) then
            return { remove = true }
        end
    end,
    attributes = { "destroy_card", "retrigger", "chance", }
}