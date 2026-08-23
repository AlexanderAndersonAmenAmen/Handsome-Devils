SMODS.Joker({
    key = "perfectionist",
    config = { extra = { mult = 4, chips = 30 } },
    loc_vars = function(self, info_queue, card)
        local extra = card and card.ability and card.ability.extra or self.config.extra
        return { vars = { extra.mult, extra.chips } }
    end,
    atlas = "Jokers",
    pos = { x = 4, y = 1 },
    cost = 5,
    rarity = 2,
    unlocked = false,
    discovered = false,
    unlock_condition = { type = "hnds_joker_unlock", key = "perfectionist" },
    locked_loc_vars = function(self)
        return HNDS.joker_locked_loc_vars("perfectionist")
    end,
    check_for_unlock = function(self, args)
        return HNDS.joker_unlock_condition_met("perfectionist", args)
    end,
    blueprint_compat = false,
    attributes = { "modify_card", "chips", "mult", "enhancements", "perma_bonus" }
})