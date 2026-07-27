SMODS.Joker {
    key = "contagion",
    atlas = "Jokers",
    pos = { x = 5, y = 4 },
    rarity = 3,
    cost = 10,
    unlocked = true,
    discovered = true,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    config = {},
    calculate = function(self, card, context)
        -- Card-selection limits are synchronized centrally in lib/hooks.lua so
        -- every eligible consumable, including cards already held, updates live.
    end,
    attributes = { "consumable", "passive" },
}