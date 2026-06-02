SMODS.Tag {
    key = "cursed_tag",
    atlas = "HDtags",
    pos = { x = 3, y = 0 },
    discovered = true,
    loc_vars = function(self, info_queue, tag)
        info_queue[#info_queue + 1] = G.P_CENTERS.p_hnds_cursed_pack
    end,
    apply = function(self, tag, context)
        if context.type == 'new_blind_choice' then
            local lock = tag.ID
            G.CONTROLLER.locks[lock] = true
            tag:yep('+', G.C.RED, function()
                local key = 'p_hnds_cursed_pack'
                local booster = Card(G.play.T.x + G.play.T.w/2 - G.CARD_W*1.27/2,
                G.play.T.y + G.play.T.h/2 - G.CARD_H*1.27/2, G.CARD_W*1.27, G.CARD_H*1.27, G.P_CARDS.empty, G.P_CENTERS[key], {bypass_discovery_center = true, bypass_discovery_ui = true})
                booster.cost = 0
                booster.from_tag = true
                if tag.ability and tag.ability.hnds_forced then
                    if not (HNDS and HNDS.joker_slots_full_of_unmovables and HNDS.joker_slots_full_of_unmovables()) then
                        G.GAME.hnds_forced_pack_no_skip = true
                    end
                end
                G.FUNCS.use_card({config = {ref_table = booster}})
                booster:start_materialize()
                G.CONTROLLER.locks[lock] = nil
                return true
            end)
            tag.triggered = true
            return true
        end
    end
}
