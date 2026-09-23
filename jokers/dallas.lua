local function hnds_dallas_extra(card, config)
    local extra = card and card.ability and card.ability.extra
    if type(extra) ~= 'table' then
        extra = {}
        if card and card.ability then card.ability.extra = extra end
    end
    extra.xmult = tonumber(extra.xmult) or 1
    extra.xmult_gain = 0.5
    extra.cards_drawn = tonumber(extra.cards_drawn) or 0
    extra.cards_per_gain = 5
    return extra
end

SMODS.Joker({
    key = 'dallas',
    atlas = 'Jokers',
    pos = { x = 5, y = 7 },
    rarity = 1,
    cost = 5,
    unlocked = false,
    discovered = false,
    unlock_condition = { type = 'hnds_joker_unlock', key = 'dallas' },
    locked_loc_vars = function(self)
        return HNDS.joker_locked_loc_vars('dallas')
    end,
    check_for_unlock = function(self, args)
        return HNDS.joker_unlock_condition_met('dallas', args)
    end,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = false,
    config = { extra = { xmult = 1, xmult_gain = 0.5, cards_drawn = 0, cards_per_gain = 5 } },
    loc_vars = function(self, info_queue, card)
        local extra = hnds_dallas_extra(card, self.config.extra)
        return { vars = { extra.xmult_gain, extra.cards_per_gain, extra.xmult, HNDS.threshold_remaining(extra) } }
    end,
    calculate = function(self, card, context)
        local extra = hnds_dallas_extra(card, self.config.extra)
        if context.hand_drawn and not context.blueprint then
            local gains = HNDS.threshold_gains(extra, HNDS.count_drawn_suit(context.hand_drawn, 'Hearts'))
            if gains > 0 then
                local gained = extra.xmult_gain * gains
                extra.xmult = extra.xmult + gained
                return { message = localize({ type = 'variable', key = 'a_xmult', vars = { gained } }), colour = G.C.MULT }
            end
        end
        if context.end_of_round and context.main_eval and not context.blueprint and not context.game_over then
            if extra.xmult ~= 1 then
                extra.xmult = 1
                return { message = 'X1', colour = G.C.MULT }
            end
        end
        if context.joker_main and extra.xmult ~= 1 then return { xmult = extra.xmult } end
    end,
    attributes = { 'xmult', 'suit', 'scaling' },
})
