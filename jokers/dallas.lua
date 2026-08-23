SMODS.Joker({
    key = "dallas",
    atlas = "Jokers",
    pos = { x = 5, y = 7 },
    rarity = 1,
    cost = 5,
    unlocked = false,
    discovered = false,
    unlock_condition = { type = "hnds_joker_unlock", key = "dallas" },
    locked_loc_vars = function(self)
        return HNDS.joker_locked_loc_vars("dallas")
    end,
    check_for_unlock = function(self, args)
        return HNDS.joker_unlock_condition_met("dallas", args)
    end,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = false,

    config = {
        extra = {
            xmult = 1,
            xmult_gain = 0.1,
            odds = 3,
        },
    },

    loc_vars = function(self, info_queue, card)
        local extra = card.ability.extra
        local numerator, denominator = SMODS.get_probability_vars(card, 1, extra.odds, "hnds_dallas")
        return {
            vars = {
                numerator,
                denominator,
                extra.xmult_gain,
                extra.xmult,
            }
        }
    end,

    calculate = function(self, card, context)
        local extra = card.ability.extra

        if context.individual
        and context.cardarea == G.play
        and context.other_card
        and context.other_card:is_suit("Hearts")
        then
            if SMODS.pseudorandom_probability(card, "hnds_dallas", 1, extra.odds) then
                extra.xmult = extra.xmult + extra.xmult_gain
                return {
                    message = "X" .. extra.xmult_gain,
                    colour = G.C.MULT,
                }
            end
        end

        if context.joker_main then
            return { xmult = extra.xmult }
        end
    end,

    attributes = { "xmult", "suit" },
})
