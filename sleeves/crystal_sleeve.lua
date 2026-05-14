-- Crystal Sleeve: Same as Crystal Deck + Showdown Blinds in ante 2 and 6 when paired
CardSleeves.Sleeve({
    key = "crystal_sleeve",
    atlas = "hnds_sleeves",
    pos = {x = 3, y = 0},
    unlocked = false,
    unlock_condition = {deck = "b_hnds_crystal", stake = "stake_green"},
    loc_vars = function(self)
        local key
        if self.get_current_deck_key() ~= "b_hnds_crystal" then
            key = self.key
        else
            key = self.key .. "_alt"
            self.config = {matching = true}
        end
        return {key = key}
    end,
    apply = function(self)
        -- Base effect: Double showdown (same as deck)
        G.GAME.modifiers.hnds_double_showdown = true
        
        -- Sleeve additional effect: Enable ante 2,4,6 spectral packs
        if self.config.matching then
            G.GAME.modifiers.crystal_sleeve_active = true
            G.GAME.crystal_pack_given = false
        end
    end,
    calculate = function(self, sleeve, context)
        -- Base effect: Ultra Spectral Pack on ante 4 boss (same as deck)
        if context.end_of_round and context.main_eval and G.GAME.round_resets.ante == math.floor(G.GAME.win_ante/2) and context.beat_boss then
            G.GAME.hnds_crystal_queued = true
        end
        
        -- Sleeve additional effect: Showdown Blinds in ante 2 and 6 + Ultra Spectral Pack
        if self.config.matching then
            -- Trigger showdown blinds in ante 2 and 6
            if context.setting_blind and (G.GAME.round_resets.ante == 2 or G.GAME.round_resets.ante == 6) then
                -- Force showdown blind
                G.GAME.blind.choice = G.P_BLINDS.blind_showdown
                G.GAME.blind:set_blind(G.P_BLINDS.blind_showdown, nil, true)
            end
            
            -- Ultra Spectral Pack on defeating showdown blinds in ante 2 and 6
            if context.end_of_round and context.main_eval and context.beat_boss and (G.GAME.round_resets.ante == 2 or G.GAME.round_resets.ante == 6) then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        local pack = Card(G.shop.T.x + G.shop.T.w/2 - G.CARD_W*1.5, G.shop.T.y + G.shop.T.h/2 - G.CARD_H/2, G.CARD_W*1.5, G.CARD_H*1.5, G.P_CARDS.empty, G.P_CENTERS.p_hnds_spectral_ultra)
                        pack.cost = 0
                        pack:set_cost()
                        G.shop:emplace(pack)
                        return true
                    end
                }))
            end
        end
    end,
})