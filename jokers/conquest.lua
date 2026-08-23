-- Conquest
-- Gains X0.25 Mult for every Boss-equivalent Blind defeated this run.
-- Boss-equivalent means either the real Boss slot or a Small/Big Blind that
-- Handsome Devils' Blind Raiser explicitly upgraded into a Boss Blind.

local function conquest_defeated_count()
    if HNDS and HNDS.conquest_bosses_defeated then
        return HNDS.conquest_bosses_defeated()
    end
    return math.max(0, tonumber(G and G.GAME and G.GAME.hnds_conquest_bosses_defeated) or 0)
end

local function conquest_xmult(card)
    local gain = tonumber(card and card.ability and card.ability.extra
        and card.ability.extra.xmult_gain) or 0.25
    return 1 + conquest_defeated_count() * gain
end

SMODS.Joker {
    key = 'conquest',
    atlas = 'Jokers',
    pos = { x = 0, y = 6 },
    rarity = 2,
    cost = 7,
    unlocked = false,
    discovered = false,

    unlock_condition = { type = "hnds_joker_unlock", key = "conquest" },
    locked_loc_vars = function(self)
        return HNDS.joker_locked_loc_vars("conquest")
    end,
    check_for_unlock = function(self, args)
        return HNDS.joker_unlock_condition_met("conquest", args)
    end,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,

    config = {
        extra = {
            xmult_gain = 0.25,
        },
    },

    loc_vars = function(self, info_queue, card)
        local extra = card and card.ability and card.ability.extra or self.config.extra
        local gain = tonumber(extra and extra.xmult_gain) or 0.25
        local count = conquest_defeated_count()
        return { vars = { gain, 1 + count * gain, count } }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            return { xmult = conquest_xmult(card) }
        end
    end,

    joker_display_def = function(JokerDisplay)
        return {
            text = {
                {
                    border_nodes = {
                        { text = 'X' },
                        {
                            ref_table = 'card.joker_display_values',
                            ref_value = 'x_mult',
                            retrigger_type = 'exp',
                        },
                    },
                },
            },
            calc_function = function(card)
                card.joker_display_values.x_mult = conquest_xmult(card)
            end,
        }
    end,

    attributes = { 'mult', 'scaling' },
}
