SMODS.Tag {
    key = "cursed_tag",
    atlas = "HDtags",
    min_ante = 3,
    pos = { x = 3, y = 0 },
    discovered = false,
    loc_vars = function(self, info_queue, tag)
        info_queue[#info_queue + 1] = G.P_CENTERS.p_hnds_cursed_pack
    end,
    apply = function(self, tag, context)
        if context.type == 'new_blind_choice' then
            local lock = tag.ID
            G.CONTROLLER.locks[lock] = true
            tag:yep('+', G.C.RED, function()
                if HNDS and HNDS.open_cursed_pack then
                    HNDS.open_cursed_pack({
                        from_tag = true,
                        forced = tag.ability and tag.ability.hnds_forced == true,
                        source = 'cursed_tag',
                    })
                end
                G.CONTROLLER.locks[lock] = nil
                return true
            end)
            tag.triggered = true
            return true
        end
    end
}
