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
    calculate = function(self, card, context)
        if type(context) ~= "table" or not card or not card.ability or not card.ability.extra then return end
        local other = context.other_card
        local ortalab_rolling = G and G._ortalab_bottle_rolling
        if context.setting_ability and context.old and context.old ~= "c_base" and context.new ~= "c_base"
            and not context.unchanged and not ortalab_rolling and other and other.ability then
            other.ability.perma_mult = (other.ability.perma_mult or 0) + card.ability.extra.mult
            other.ability.perma_bonus = (other.ability.perma_bonus or 0) + card.ability.extra.chips
            return { message = localize("k_upgrade_ex") }
        end
    end,
    attributes = { "modify_card", "chips", "mult", "enhancements", "perma_bonus" }
})