SMODS.Seal {
    key = "black",
    badge_colour = HEX("545454"),
    atlas = "Extras",
    pos = {x= 3, y= 0},
    --sound = { sound = 'blk_seal_obtained', per = 1.06, vol = 0.4 },
    discovered = true,

    loc_vars = function(self, info_queue)
        return { vars = {} }
    end,

    -- self - this seal prototype
    -- card - card this seal is applied to
    calculate = function(self, card, context)
        if context.cardarea == G.hand and context.hnds_pre_before then
            table.insert(context.full_hand, card)
            table.insert(context.scoring_hand, card)
        end
        if context.cardarea == G.hand and context.after then
            table.remove(context.full_hand)
            table.remove(context.scoring_hand)
        end
    end
}
