SMODS.Joker {
    key = "imposter",
    atlas = "Jokers",
    pos = { x = 6, y = 4 },
    rarity = 2,
    cost = 6,
    unlocked = false,
    discovered = false,
    unlock_condition = { type = "hnds_joker_unlock", key = "imposter" },
    locked_loc_vars = function(self)
        return HNDS.joker_locked_loc_vars("imposter")
    end,
    check_for_unlock = function(self, args)
        return HNDS.joker_unlock_condition_met("imposter", args)
    end,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    config = { extra = {} },
    calculate = function(self, card, context)
        -- Effect in hooks file, the Joker is the Boolean
    end,
    attributes = { "passive", "face" }
}
