-- Cursed Sleeve: Same as Cursed Deck + First cursed pack opened only offers rare jokers when paired
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
        -- The one-shot Cursed Pack reward uses lazy run-state markers in the
        -- calculate callback.  Do not reset them here: sleeve/back apply hooks
        -- may be revisited while loading a saved run.

        -- Sleeve additional effect: Enable rare-only for first cursed pack when paired with Cursed Deck
        if self.get_current_deck_key() == "b_hnds_cursed" then
            G.GAME.modifiers.cursed_sleeve_active = true
            G.GAME.hnds_first_cursed_pack = true
        end
    end,
    calculate = function(self, sleeve, context)
        -- Base effect: Cursed pack on first boss blind (same as deck)
        if context.end_of_round and context.main_eval
            and HNDS.active_blind_is_real_ante_boss and HNDS.active_blind_is_real_ante_boss()
            and G.GAME.round_resets.ante == 1
            and not G.GAME.hnds_cursed_deck_reward_claimed
            and not G.GAME.hnds_cursed_pack_opened then
            G.GAME.hnds_cursed_deck_reward_claimed = true
            G.GAME.hnds_cursed_pack_opened = true -- legacy/save compatibility
            if HNDS.queue_cursed_pack then
                HNDS.queue_cursed_pack({ forced = true, source = 'cursed_sleeve' })
            end
        end
    end,
})
