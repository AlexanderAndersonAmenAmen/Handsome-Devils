SMODS.Joker {
    key = "one_punchline_man",
    atlas = "Jokers",
    pos = { x = 9, y = 4 },
    rarity = 2,
    cost = 5,
    unlocked = false,
    discovered = false,
    unlock_condition = { type = "hnds_joker_unlock", key = "one_punchline_man" },
    locked_loc_vars = function(self)
        return HNDS.joker_locked_loc_vars("one_punchline_man")
    end,
    check_for_unlock = function(self, args)
        return HNDS.joker_unlock_condition_met("one_punchline_man", args)
    end,
    blueprint_compat = true,
    eternal_compat = false,
    perishable_compat = true,
    config = { extra = { Xmult = 4, first_hand_active = false } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.Xmult } }
    end,
    calculate = function(self, card, context)
        -- Remember that this is the round's first played hand. The flag lets
        -- the post-scoring check refer to the same hand without depending on
        -- exactly when hands_played is incremented by the base game.
        if context.before and context.cardarea == G.jokers and not context.blueprint then
            card.ability.extra.first_hand_active = G.GAME.current_round.hands_played == 0
        end

        if context.joker_main and G.GAME.current_round.hands_played == 0 then
            return {
                Xmult_mod = card.ability.extra.Xmult,
                message = localize({ type = 'variable', key = 'a_xmult', vars = { card.ability.extra.Xmult } }),
            }
        end

        -- Once the first hand finishes scoring, One Punchline Man survives
        -- only if that hand defeated the Blind. Blueprint copies can receive
        -- the XMult above but never destroy the original Joker.
        if context.after and card.ability.extra.first_hand_active and not context.blueprint then
            card.ability.extra.first_hand_active = false

            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    if card and card.area and G.GAME and G.GAME.blind and G.GAME.blind.in_blind
                        and G.GAME.chips < G.GAME.blind.chips then
                        card:start_dissolve()
                    end
                    return true
                end,
            }))
        end
    end,
    joker_display_def = function(JokerDisplay)
        return {
            text = {
                {
                    border_nodes = {
                        { text = "X" },
                        { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" },
                    },
                },
            },
            calc_function = function(card)
                local first_hand = G.GAME and G.GAME.current_round and G.GAME.current_round.hands_played == 0
                card.joker_display_values.x_mult = first_hand and card.ability.extra.Xmult or 1
            end,
        }
    end,
    attributes = { "hands", "xmult", "destroy_card" }
}
