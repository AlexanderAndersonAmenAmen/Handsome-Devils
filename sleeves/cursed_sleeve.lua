
CardSleeves.Sleeve({
    key = "cursed_sleeve",
    atlas = "hnds_sleeves",
    pos = {x = 2, y = 0},
    unlocked = false,
    unlock_condition = {deck = "b_hnds_cursed", stake = "stake_green"},
    loc_vars = function(self)
        return HNDS.sleeve_loc(self, "b_hnds_cursed")
    end,
    apply = function(self)


        if self.get_current_deck_key() == "b_hnds_cursed" then
            G.GAME.modifiers.cursed_sleeve_active = true
            G.GAME.hnds_first_cursed_pack = true
        end
    end,
    calculate = function(self, sleeve, context)

        if context.end_of_round and context.main_eval
            and HNDS.active_blind_is_real_ante_boss and HNDS.active_blind_is_real_ante_boss()
            and G.GAME.round_resets.ante == 1
            and not G.GAME.hnds_cursed_deck_reward_claimed
            and not G.GAME.hnds_cursed_pack_opened then
            G.GAME.hnds_cursed_deck_reward_claimed = true
            G.GAME.hnds_cursed_pack_opened = true
            if HNDS.queue_cursed_pack then
                HNDS.queue_cursed_pack({ forced = true, source = 'cursed_sleeve' })
            end
        end
    end,
})
