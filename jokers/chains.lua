SMODS.Joker({
    key = "chains",
    atlas = "Jokers",
    pos = { x = 7, y = 7 },
    rarity = 1,
    cost = 5,
    unlocked = false,
    discovered = false,
    unlock_condition = { type = "hnds_joker_unlock", key = "chains" },
    locked_loc_vars = function(self)
        return HNDS.joker_locked_loc_vars("chains")
    end,
    check_for_unlock = function(self, args)
        return HNDS.joker_unlock_condition_met("chains", args)
    end,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = false,

    config = {
        extra = {
            chips = 0,
            chips_gain = 25,
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
                extra.chips_gain,
                extra.cards_per_gain,
                extra.chips,
                remaining,
            }
        }
    end,

    calculate = function(self, card, context)
        local extra = card.ability.extra

        if context.individual
        and context.cardarea == G.play
        and context.other_card
        and context.other_card:is_suit("Spades")
        then
            extra.cards_scored = extra.cards_scored + 1

            if extra.cards_scored % extra.cards_per_gain == 0 then
                extra.chips = extra.chips + extra.chips_gain

                return {
                    message = localize("k_chip"),
                    colour = G.C.CHIPS,
                }
            end
        end

        if context.joker_main then
            return {
                chips = extra.chips
            }
        end
    end,

    attributes = { "chips", "suit" },
})
