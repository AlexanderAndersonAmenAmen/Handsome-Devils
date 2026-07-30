SMODS.Joker({
    key = "perfectionist",
    config = { extra = { mult = 4, chips = 30 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult, card.ability.extra.chips } }
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
    calculate = function(self, card, context)
        if context.setting_ability and context.old and context.old ~= "c_base" and context.new ~= "c_base" and not context.unchanged and not G._ortalab_bottle_rolling then
            context.other_card.ability.perma_mult = context.other_card.ability.perma_mult + card.ability.extra.mult
            context.other_card.ability.perma_bonus = context.other_card.ability.perma_bonus + card.ability.extra.chips
            return { message = localize("k_upgrade_ex") }
        end
    end,
    attributes = { "modify_card", "chips", "mult", "enhancements", "perma_bonus" }
})