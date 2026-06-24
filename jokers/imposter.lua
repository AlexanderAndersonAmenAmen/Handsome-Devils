SMODS.Joker {
    key = "imposter",
    atlas = "Jokers",
    pos = { x = 6, y = 4 },
    rarity = 2,
    cost = 6,
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    config = { extra = {} },
    calculate = function(self, card, context)
        -- Effect in hooks file, the Joker is the Boolean
    end,
    attributes = { "passive", "face" }
}
