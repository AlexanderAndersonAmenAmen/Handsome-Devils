local function hnds_hoxton_extra(card)
    local extra = card and card.ability and card.ability.extra
    if type(extra) ~= 'table' then
        extra = {}
        if card and card.ability then card.ability.extra = extra end
    end
    extra.sell_value_gain = 2
    extra.cards_drawn = tonumber(extra.cards_drawn) or 0
    extra.cards_per_gain = 5
    return extra
end

SMODS.Joker({
    key = 'hoxton',
    atlas = 'Jokers',
    pos = { x = 8, y = 7 },
    rarity = 1,
    cost = 5,
    unlocked = false,
    discovered = false,
    unlock_condition = { type = 'hnds_joker_unlock', key = 'hoxton' },
    locked_loc_vars = function(self)
        return HNDS.joker_locked_loc_vars('hoxton')
    end,
    check_for_unlock = function(self, args)
        return HNDS.joker_unlock_condition_met('hoxton', args)
    end,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = false,
    config = { extra = { sell_value_gain = 2, cards_drawn = 0, cards_per_gain = 5 } },
    loc_vars = function(self, info_queue, card)
        local extra = hnds_hoxton_extra(card)
        return { vars = { extra.sell_value_gain, extra.cards_per_gain, HNDS.threshold_remaining(extra) } }
    end,
    calculate = function(self, card, context)
        local extra = hnds_hoxton_extra(card)
        if context.hand_drawn and not context.blueprint then
            local gains = HNDS.threshold_gains(extra, HNDS.count_drawn_suit(context.hand_drawn, 'Diamonds'))
            if gains > 0 then
                card.ability.extra_value = (card.ability.extra_value or 0) + extra.sell_value_gain * gains
                if card.set_cost then card:set_cost() end
                return { message = localize('k_val_up'), colour = G.C.MONEY }
            end
        end
    end,
    attributes = { 'suit', 'economy', 'scaling' },
})
