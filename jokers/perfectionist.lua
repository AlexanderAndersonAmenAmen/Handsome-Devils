SMODS.Joker({
    key = "perfectionist",
    config = {
        extra = {
            mult = 4,
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult } }
    end,
    atlas = "Jokers",
    pos = { x = 4, y = 1 },
    cost = 5,
    rarity = 2,
    unlocked = true,
    discovered = true,
    blueprint_compat = false,
    calculate = function(self, card, context)
    end
})
