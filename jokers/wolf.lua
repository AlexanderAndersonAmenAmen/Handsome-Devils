local function hnds_wolf_extra(card)
    local extra = card and card.ability and card.ability.extra
    if type(extra) ~= 'table' then
        extra = {}
        if card and card.ability then card.ability.extra = extra end
    end
    extra.mult = tonumber(extra.mult) or 0
    extra.mult_gain = 3
    extra.cards_drawn = tonumber(extra.cards_drawn) or 0
    extra.cards_per_gain = 10
    return extra
end

SMODS.Joker({
    key = 'wolf',
    atlas = 'Jokers',
    pos = { x = 6, y = 7 },
    rarity = 1,
    cost = 5,
    unlocked = false,
    discovered = false,
    unlock_condition = { type = 'hnds_joker_unlock', key = 'wolf' },
    locked_loc_vars = function(self)
        return HNDS.joker_locked_loc_vars('wolf')
    end,
    check_for_unlock = function(self, args)
        return HNDS.joker_unlock_condition_met('wolf', args)
    end,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = false,
    config = { extra = { mult = 0, mult_gain = 3, cards_drawn = 0, cards_per_gain = 10 } },
    loc_vars = function(self, info_queue, card)
        local extra = hnds_wolf_extra(card)
        return { vars = { extra.mult_gain, extra.cards_per_gain, extra.mult, HNDS.threshold_remaining(extra) } }
    end,
    calculate = function(self, card, context)
        local extra = hnds_wolf_extra(card)
        if context.hand_drawn and not context.blueprint then
            local gains = HNDS.threshold_gains(extra, HNDS.count_drawn_suit(context.hand_drawn, 'Clubs'))
            if gains > 0 then
                local gained = extra.mult_gain * gains
                extra.mult = extra.mult + gained
                return { message = localize({ type = 'variable', key = 'a_mult', vars = { gained } }), colour = G.C.MULT }
            end
        end
        if context.joker_main and extra.mult ~= 0 then return { mult = extra.mult } end
    end,
    attributes = { 'mult', 'suit', 'scaling' },
})
