
CardSleeves.Sleeve({
    key = "crystal_sleeve",
    atlas = "hnds_sleeves",
    pos = {x = 3, y = 0},
    unlocked = false,
    unlock_condition = {deck = "b_hnds_crystal", stake = "stake_green"},
    loc_vars = function(self)
        local result = HNDS.sleeve_loc(self, "b_hnds_crystal")
        if HNDS.mp_active and HNDS.mp_active() then result.key = result.key .. '_mp' end
        return result
    end,
    apply = function(self)
        G.GAME.modifiers.hnds_double_showdown = true
        G.GAME.modifiers.hnds_crystal_showdown = true
        if self.get_current_deck_key() == "b_hnds_crystal" then
            G.GAME.modifiers.crystal_sleeve_active = true
        end
    end,
    calculate = function(self, sleeve, context)
        if not (context.end_of_round and context.main_eval
            and not (HNDS.mp_is_pvp and HNDS.mp_is_pvp())
            and HNDS.active_blind_is_real_ante_boss and HNDS.active_blind_is_real_ante_boss()) then return end
        local ante = G.GAME.round_resets.ante
        if ante == 4 or ((ante == 2 or ante == 6) and self.get_current_deck_key() == "b_hnds_crystal") then
            G.GAME.hnds_crystal_queued = true
        end
    end,
})


