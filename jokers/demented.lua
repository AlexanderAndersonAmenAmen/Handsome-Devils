SMODS.Joker({
    key = "demented",
    rarity = 2,
    cost = 5,
    blueprint_compat = false,
    atlas = "Jokers",
    pos = { x = 6, y = 3 },
    unlocked = false,
    discovered = false,
    unlock_condition = { type = "hnds_joker_unlock", key = "demented" },
    locked_loc_vars = function(self)
        return HNDS.joker_locked_loc_vars("demented")
    end,
    check_for_unlock = function(self, args)
        return HNDS.joker_unlock_condition_met("demented", args)
    end,
    calculate = function(self, card, context)
        if (context.before or context.forcetrigger) and G.GAME.current_round and G.GAME.current_round.hands_played == 0 and G.hand and #G.hand.cards > 0 then

            local valid_suits = HNDS.get_pollable_suit_keys and HNDS.get_pollable_suit_keys('hnds_demented') or {}
            if #valid_suits == 0 then valid_suits = { 'Hearts', 'Diamonds', 'Spades', 'Clubs' } end
            local valid_ranks = {'2', '3', '4', '5', '6', '7', '8', '9', '10', 'Jack', 'Queen', 'King', 'Ace'}

            local current_blind = (G.GAME.blind and G.GAME.blind.config and G.GAME.blind.config.blind and G.GAME.blind.config.blind.key) or "blind"
            local round_modifier = tostring(G.GAME.round_resets.ante) .. '_' .. tostring(current_blind)

            for i = 1, #G.hand.cards do
                local target_card = G.hand.cards[i]

                local target_suit = pseudorandom_element(valid_suits, 'demented_suit_' .. round_modifier .. '_' .. tostring(i))
                local target_rank = pseudorandom_element(valid_ranks, 'demented_rank_' .. round_modifier .. '_' .. tostring(i))

                G.E_MANAGER:add_event(Event({
                    func = function()
                        if SMODS and type(SMODS.change_base) == 'function' then
                            SMODS.change_base(target_card, target_suit, target_rank)
                        end
                        target_card:juice_up()
                        return true
                    end
                }))
            end

            return {
                message = "Deal!",
                card = card
            }
        end
    end
})