SMODS.Voucher {
    key = "soaked",
    atlas = "Vouchers",
    pos = { x = 4, y = 0 },
    cost = 10,
    unlocked = true,
    discovered = true,
    calculate = function (self, card, context)
        if context.individual and context.other_card == G.hand.cards[1] and context.cardarea == G.hand then
            local new_context = {}
            for k,v in pairs(context) do
                new_context[k] = v
            end
            new_context.hnds_hand_trigger = true
            new_context.cardarea = G.play
            SMODS.score_card(context.other_card, new_context)
            return nil, true
        end
    end
}