
CardSleeves.Sleeve({
    key = "crystal_sleeve",
    atlas = "hnds_sleeves",
    pos = {x = 3, y = 0},
    unlocked = false,
    unlock_condition = {deck = "b_hnds_crystal", stake = "stake_green"},
    loc_vars = function(self)
        return HNDS.sleeve_loc(self, "b_hnds_crystal")
    end,
    apply = function(self)
        G.GAME.modifiers.hnds_double_showdown = true
        G.GAME.modifiers.hnds_crystal_showdown = true
        if self.get_current_deck_key() == "b_hnds_crystal" then
            G.GAME.modifiers.crystal_sleeve_active = true
        end
    end,
    calculate = function(self, sleeve, context)
        if context.end_of_round and context.main_eval
            and HNDS.active_blind_is_real_ante_boss and HNDS.active_blind_is_real_ante_boss()
            and G.GAME.round_resets.ante == 4 then
            G.GAME.hnds_crystal_queued = true
        end
        if self.get_current_deck_key() == "b_hnds_crystal" then
            if context.end_of_round and context.main_eval
                and HNDS.active_blind_is_real_ante_boss and HNDS.active_blind_is_real_ante_boss()
                and (G.GAME.round_resets.ante == 2 or G.GAME.round_resets.ante == 6) then
                G.GAME.hnds_crystal_queued = true
            end
        end
    end,
})


