local function trinity_mult_gain(card)
    local extra = card and card.ability and card.ability.extra
    return type(extra) == 'table' and tonumber(extra.mult_gain) or 1
end

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
    perishable_compat = false,
    config = { extra = { mult_gain = 1 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { trinity_mult_gain(card) } }
    end,
    calculate = function(self, card, context)
        local trio = context.poker_hands and context.poker_hands['Three of a Kind']
        if context.individual and context.cardarea == G.play and not context.repetition
            and context.other_card and not context.other_card.debuff and not SMODS.no_resolve
            and type(trio) == 'table' and next(trio)
        then
            local ability = context.other_card.ability
            ability.perma_mult = (ability.perma_mult or 0) + trinity_mult_gain(card)
            return { message = localize('k_upgrade_ex'), colour = G.C.MULT, card = context.other_card }
        end
    end,
    attributes = { 'mult', 'hand_type', 'modify_card' },
}
