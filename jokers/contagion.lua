SMODS.Joker {
    key = "contagion",
    atlas = "Jokers",
    pos = { x = 5, y = 4 },
    rarity = 3,
    cost = 10,
    unlocked = false,
    discovered = false,
    unlock_condition = { type = "hnds_joker_unlock", key = "contagion" },
    locked_loc_vars = function(self)
        return HNDS.joker_locked_loc_vars("contagion")
    end,
    check_for_unlock = function(self, args)
        return HNDS.joker_unlock_condition_met("contagion", args)
    end,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    config = {},
    calculate = function(self, card, context)


    end,
    attributes = { "consumable", "passive" },
}