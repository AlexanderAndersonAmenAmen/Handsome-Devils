SMODS.Tag {
    key = "magic_tag",
    atlas = "HDtags",
    min_ante = 3,
    pos = { x = 2, y = 0 },
    discovered = false,
    loc_vars = function(self, info_queue, tag)
        info_queue[#info_queue + 1] = G.P_CENTERS.p_hnds_magic_1
    end,
    apply = function(self, tag, context)
        if context.type == 'new_blind_choice' then
            local lock = tag.ID
            G.CONTROLLER.locks[lock] = true
            tag:yep('+', G.C.SECONDARY_SET.Planet, function()


                local magic_keys = {}
                for i = 1, 6 do
                    local candidate = 'p_hnds_magic_' .. i
                    if G.P_CENTERS[candidate] then
                        magic_keys[#magic_keys + 1] = candidate
                    end
                end
                local key = (#magic_keys > 0) and magic_keys[math.random(#magic_keys)] or nil
                local center = key and G.P_CENTERS[key] or G.P_CENTERS.p_hnds_magic_1
                if not center then
                    G.CONTROLLER.locks[lock] = nil
                    return true
                end
                local booster = Card(G.play.T.x + G.play.T.w/2 - G.CARD_W*1.27/2,
                G.play.T.y + G.play.T.h/2 - G.CARD_H*1.27/2, G.CARD_W*1.27, G.CARD_H*1.27, G.P_CARDS.empty, center, {bypass_discovery_center = true, bypass_discovery_ui = true})
                booster.cost = 0
                booster.from_tag = true
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