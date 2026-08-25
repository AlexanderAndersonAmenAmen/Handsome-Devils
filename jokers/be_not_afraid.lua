SMODS.Joker {
    key = 'be_not_afraid',
    atlas = 'Jokers',
    pos = { x = 6, y = 6 },
    rarity = 2,
    cost = 5,
    unlocked = false,
    discovered = false,
    unlock_condition = { type = "hnds_joker_unlock", key = "be_not_afraid" },
    locked_loc_vars = function(self)
        return HNDS.joker_locked_loc_vars("be_not_afraid")
    end,
    check_for_unlock = function(self, args)
        return HNDS.joker_unlock_condition_met("be_not_afraid", args)
    end,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,

    config = { extra = { mult = 1 } },

    loc_vars = function(self, info_queue, card)
        local extra = card and card.ability and card.ability.extra or self.config.extra
        return { vars = { tonumber(extra.mult) or 1 } }
    end,

    calculate = function(self, card, context)
        local three_kind = context.poker_hands
            and context.poker_hands['Three of a Kind']


        if context.individual and context.cardarea == G.play
            and three_kind and next(three_kind)
            and context.other_card and context.other_card.ability
            and not context.other_card.debuff
        then
            local amount = tonumber(card.ability.extra.mult) or 1
            context.other_card.ability.perma_mult =
                (tonumber(context.other_card.ability.perma_mult) or 0) + amount

            return {


                mult = amount,
                remove_default_message = true,
                message = localize('k_upgrade_ex'),
                colour = G.C.MULT,
            }
        end
    end,

    attributes = { 'modify_card', 'mult', 'hand_type', 'perma_bonus' },
}
