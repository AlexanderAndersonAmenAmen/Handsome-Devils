SMODS.Joker({
    key = "perfectionist",
    config = {
        extra = {
            mult = 4,
            chips = 30
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult, card.ability.extra.chips } }
    end,
    atlas = "Jokers",
    pos = { x = 4, y = 1 },
    cost = 5,
    rarity = 2,
    unlocked = true,
    discovered = true,
    blueprint_compat = false,
    calculate = function(self, card, context)
        if context.setting_ability and context.old and context.old ~= "c_base" and context.new ~= "c_base" and not context.unchanged then
            print(context.old)
            context.other_card.ability.perma_mult = context.other_card.ability.perma_mult + card.ability.extra.mult
            context.other_card.ability.perma_bonus = context.other_card.ability.perma_bonus + card.ability.extra.chips
            return {
                message = localize("k_upgrade_ex")
            }
        end
    end
})
