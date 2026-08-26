local function hnds_famine_xmult(card, context)
    local extra = card and card.ability and card.ability.extra or {}
    local base = tonumber(extra.xmult) or 6
    local loss = tonumber(extra.loss_per_card) or 1
    local full_hand
    if context and context.full_hand then

        full_hand = context.full_hand
    elseif G and G.hand and G.hand.highlighted then


        full_hand = G.hand.highlighted
    elseif G and G.play and G.play.cards then
        full_hand = G.play.cards
    else
        full_hand = {}
    end
    return math.max(0, base - (#full_hand * loss))
end

SMODS.Joker {
    key = 'famine',
    atlas = 'Jokers',
    pos = { x = 1, y = 6 },
    rarity = 2,
    cost = 6,
    unlocked = false,
    discovered = false,
    unlock_condition = { type = "hnds_joker_unlock", key = "famine" },
    locked_loc_vars = function(self)
        return HNDS.joker_locked_loc_vars("famine")
    end,
    check_for_unlock = function(self, args)
        return HNDS.joker_unlock_condition_met("famine", args)
    end,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,

    config = { extra = { xmult = 6, loss_per_card = 1 } },

    loc_vars = function(self, info_queue, card)
        local extra = card and card.ability and card.ability.extra or self.config.extra
        local current_xmult = hnds_famine_xmult(card, nil)
        return { vars = { current_xmult, tonumber(extra.loss_per_card) or 1 } }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            return { xmult = hnds_famine_xmult(card, context) }
        end
    end,

    joker_display_def = function(JokerDisplay)
        return {
            text = {
                {
                    border_nodes = {
                        { text = 'X' },
                        { ref_table = 'card.joker_display_values', ref_value = 'x_mult', retrigger_type = 'exp' },
                    },
                },
            },
            calc_function = function(card)
                card.joker_display_values.x_mult = hnds_famine_xmult(card, nil)
            end,
        }
    end,

    attributes = { 'xmult' },
}
