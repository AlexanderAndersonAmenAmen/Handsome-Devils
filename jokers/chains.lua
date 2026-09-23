local function hnds_chains_extra(card)
    local extra = card and card.ability and card.ability.extra
    if type(extra) ~= 'table' then
        extra = {}
        if card and card.ability then card.ability.extra = extra end
    end
    extra.chips = tonumber(extra.chips) or 0
    extra.chips_gain = 25
    extra.cards_drawn = tonumber(extra.cards_drawn) or 0
    extra.cards_per_gain = 10
    return extra
end

SMODS.Joker({
    key = 'chains',
    atlas = 'Jokers',
    pos = { x = 7, y = 7 },
    rarity = 1,
    cost = 5,
    unlocked = false,
    discovered = false,
    unlock_condition = { type = 'hnds_joker_unlock', key = 'chains' },
    locked_loc_vars = function(self)
        return HNDS.joker_locked_loc_vars('chains')
    end,
    check_for_unlock = function(self, args)
        return HNDS.joker_unlock_condition_met('chains', args)
    end,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = false,
    config = { extra = { chips = 0, chips_gain = 25, cards_drawn = 0, cards_per_gain = 10 } },
    loc_vars = function(self, info_queue, card)
        local extra = hnds_chains_extra(card)
        return { vars = { extra.chips_gain, extra.cards_per_gain, extra.chips, HNDS.threshold_remaining(extra) } }
    end,
    calculate = function(self, card, context)
        local extra = hnds_chains_extra(card)
        if context.hand_drawn and not context.blueprint then
            local gains = HNDS.threshold_gains(extra, HNDS.count_drawn_suit(context.hand_drawn, 'Spades'))
            if gains > 0 then
                local gained = extra.chips_gain * gains
                extra.chips = extra.chips + gained
                return { message = localize({ type = 'variable', key = 'a_chips', vars = { gained } }), colour = G.C.CHIPS }
            end
        end
        if context.joker_main and extra.chips ~= 0 then return { chips = extra.chips } end
    end,
    attributes = { 'chips', 'suit', 'scaling' },
})
