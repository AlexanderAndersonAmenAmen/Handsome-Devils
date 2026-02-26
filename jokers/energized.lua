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
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    unlock_condition = { type = 'career_stat', extra = 50, stat = 'c_hnds_cards_destroyed' },
    check_for_unlock = function(self, args)
        if args.type == 'career_stat' and args.statname == self.unlock_condition.stat then
            local stats = (G.PROFILES and G.SETTINGS and G.PROFILES[G.SETTINGS.profile] and G.PROFILES[G.SETTINGS.profile].career_stats) or {}
            local destroyed = stats[self.unlock_condition.stat] or 0
            return destroyed >= self.unlock_condition.extra
        end
    end,
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