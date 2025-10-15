SMODS.Joker {
    key = "handsome",
    atlas = "Jokers",
    pos = { x = 5, y = 0 },
    rarity = 3,
    cost = 8,
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    calculate = function (self, card, context)
        if (context.repetition or (context.retrigger_joker_check and not context.retrigger_joker)) and context.other_card.edition and context.other_card ~= card then --should this also retrigger jokers
            return {
                repetitions = 1
            }
        end
    end
}