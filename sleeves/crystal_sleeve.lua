-- Crystal Sleeve: Same as Crystal Deck + Showdown Blinds in ante 2 and 6 when paired
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
        if self.get_current_deck_key() == "b_hnds_crystal" then
            G.GAME.modifiers.crystal_sleeve_active = true
        end
    end,
    calculate = function(self, sleeve, context)
        if context.end_of_round and context.main_eval and G.GAME.round_resets.ante == math.floor(G.GAME.win_ante/2) and context.beat_boss then
            G.GAME.hnds_crystal_queued = true
        end
        if self.get_current_deck_key() == "b_hnds_crystal" then
            if context.end_of_round and context.main_eval and context.beat_boss and (G.GAME.round_resets.ante == 2 or G.GAME.round_resets.ante == 6) then
                G.GAME.hnds_crystal_queued = true
            end
        end
    end,
})

-- NOTE: get_new_boss is wrapped once in lib/hooks.lua; do not re-wrap it here
-- (double-wrapping quartered win_ante instead of halving it).