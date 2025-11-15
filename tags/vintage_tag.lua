SMODS.Tag {
    key = "vintage_tag",
    atlas = "HDtags",
    pos = { x = 1, y = 0 },
    discovered = true,
    loc_vars = function(self, info_queue, tag)
        info_queue[#info_queue + 1] = G.P_CENTERS.e_hnds_vintage
    end,
    apply = function(self, tag, context)
        if context.type == 'store_joker_modify' then
            if not context.card.edition and not context.card.temp_edition and context.card.ability.set == 'Joker' then
                local lock = tag.ID
                G.CONTROLLER.locks[lock] = true
                context.card.temp_edition = true
                tag:yep('+', G.C.DARK_EDITION, function()
                    context.card.temp_edition = nil
                    context.card:set_edition("e_hnds_vintage", true)
                    context.card.ability.couponed = true
                    context.card:set_cost()
                    G.CONTROLLER.locks[lock] = nil
                    return true
                end)
                tag.triggered = true
                return true
            end
        end
    end
}
