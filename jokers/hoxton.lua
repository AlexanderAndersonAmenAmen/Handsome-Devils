SMODS.Joker({
    key = "hoxton",
    atlas = "Jokers",
    pos = { x = 8, y = 7 },
    rarity = 1,
    cost = 5,
    unlocked = false,
    discovered = false,
    unlock_condition = { type = "hnds_joker_unlock", key = "hoxton" },
    locked_loc_vars = function(self)
        return HNDS.joker_locked_loc_vars("hoxton")
    end,
    check_for_unlock = function(self, args)
        return HNDS.joker_unlock_condition_met("hoxton", args)
    end,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = false,

    config = {
        extra = {
            sell_value = 5,
            cards_scored = 0,
            cards_per_gain = 10,
        },
    },

    loc_vars = function(self, info_queue, card)
        local extra = card.ability.extra
        local progress = extra.cards_scored % extra.cards_per_gain
        local remaining = progress == 0 and extra.cards_per_gain
            or (extra.cards_per_gain - progress)
        return {
            vars = {
                extra.sell_value,
                extra.cards_per_gain,
                remaining,
            }
        }
    end,

    calculate = function(self, card, context)
        local extra = card.ability.extra

        if context.individual
        and context.cardarea == G.play
        and context.other_card
        and context.other_card:is_suit("Diamonds")
        then
            extra.cards_scored = extra.cards_scored + 1

            if extra.cards_scored % extra.cards_per_gain == 0 then
                card.ability.extra_value =
                    (card.ability.extra_value or 0) + extra.sell_value
                card:set_cost()

                return {
                    message = localize("k_val_up"),
                    colour = G.C.MONEY,
                }
            end
        end
    end,

    attributes = { "suit", "economy" },
})
