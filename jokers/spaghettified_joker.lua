local function hnds_spag_hand_data(hand)
    return G and G.GAME and G.GAME.hands and hand and G.GAME.hands[hand] or nil
end

SMODS.Joker {
    key = 'spaghettified_joker',
    atlas = 'Jokers',
    pos = { x = 1, y = 7 },
    rarity = 1,
    cost = 4,
    unlocked = false,
    discovered = false,
    unlock_condition = { type = "hnds_joker_unlock", key = "spaghettified_joker" },
    locked_loc_vars = function(self)
        return HNDS.joker_locked_loc_vars("spaghettified_joker")
    end,
    check_for_unlock = function(self, args)
        return HNDS.joker_unlock_condition_met("spaghettified_joker", args)
    end,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,

    config = { extra = { chips = 0, mult = 0, last_hand = nil } },

    loc_vars = function(self, info_queue, card)
        local extra = card and card.ability and card.ability.extra or self.config.extra
        return { vars = { tonumber(extra.chips) or 0, tonumber(extra.mult) or 0 } }
    end,

    calculate = function(self, card, context)
        local extra = card.ability.extra

        -- Remember the actual scoring hand on every played hand. The value left
        -- here when the Blind ends is therefore the final poker hand of round.
        if context.before and context.scoring_name and not context.blueprint then
            extra.last_hand = context.scoring_name
        end

        if context.joker_main then
            local ret = {}
            if (tonumber(extra.chips) or 0) ~= 0 then ret.chips = extra.chips end
            if (tonumber(extra.mult) or 0) ~= 0 then ret.mult = extra.mult end
            if next(ret) then return ret end
        end

        if context.end_of_round and context.main_eval and not context.game_over
            and not context.blueprint and not context.retrigger_joker
        then
            local hand = extra.last_hand
            extra.last_hand = nil
            local data = hnds_spag_hand_data(hand)
            if not (data and (tonumber(data.level) or 1) > 1) then return end

            -- l_chips/l_mult are the values the respective Planet currently
            -- grants, including Handsome Devils' Blue Stake rework when active.
            local chip_gain = tonumber(data.l_chips) or 0
            local mult_gain = tonumber(data.l_mult) or 0

            -- Steal exactly one level; never allow the hand to fall below 1.
            level_up_hand(card, hand, nil, -1)
            extra.chips = (tonumber(extra.chips) or 0) + chip_gain
            extra.mult = (tonumber(extra.mult) or 0) + mult_gain

            return {
                message = localize('k_hnds_spaghettified'),
                colour = G.C.FILTER,
            }
        end
    end,

    joker_display_def = function(JokerDisplay)
        return {
            text = {
                { text = '+' },
                { ref_table = 'card.ability.extra', ref_value = 'chips', colour = G.C.CHIPS },
                { text = ' +' },
                { ref_table = 'card.ability.extra', ref_value = 'mult', colour = G.C.MULT },
            },
        }
    end,

    attributes = { 'chips', 'mult', 'hand_type' },
}
