SMODS.Joker {
    key = "imposter",
    atlas = "Jokers",
    pos = { x = 6, y = 4 },
    rarity = "Uncommon",
    cost = 6,
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    config = { extra = {} },
    loc_vars = function(self, info_queue, card)
        return { vars = {} }
    end,
    calculate = function(self, card, context)
        -- Effect in hooks file, the Joker is the Boolean
    end
}
