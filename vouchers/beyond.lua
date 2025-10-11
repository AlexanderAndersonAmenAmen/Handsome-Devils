SMODS.Voucher {
    key = "beyond",
    atlas = "Vouchers",
    pos = { x = 4, y = 1 },
    cost = 10,
    unlocked = true,
    discovered = true,
    requires = { "v_hnds_soaked" },
    calculate = function (self, card, context)
        if context.individual and context.other_card == G.hand.cards[#G.hand.cards] and context.cardarea == G.hand and not context.end_of_round then
            local new_context = {}
            for k,v in pairs(context) do
                new_context[k] = v
            end
            new_context.hnds_hand_trigger = true
            new_context.cardarea = G.play
            return {
                message = localize("k_hnds_splashed"),
                message_card = context.other_card,
                func = function ()
                    SMODS.score_card(context.other_card, new_context)
                end
            }
        end
    end
}