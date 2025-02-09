SMODS.Seal {
    key = "black",
    badge_colour = HEX("545454"),
    atlas = "EHD",
    pos = {x= 3, y= 0},
    sound = { sound = 'blk_seal_obtained', per = 1.06, vol = 0.4 },
    discovered = true,

    loc_vars = function(self, info_queue)
        return { vars = {} }
    end,

    -- self - this seal prototype
    -- card - card this seal is applied to
    calculate = function(self, card, context)
        if context.cardarea == G.hand and context.before then
            table.insert(scoring_hand, card)
        end
    end
    }
