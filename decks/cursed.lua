SMODS.Back {
    key = "cursed",
    atlas = "Extras",
    pos = { x = 0, y = 1 },
    unlocked = false,
    check_for_unlock = function(self, args)
        return HNDS.unlock_condition_met("cursed", args)
    end,
    calculate = function(self, back, context)
        if context.end_of_round and context.main_eval
            and HNDS.active_blind_is_real_ante_boss and HNDS.active_blind_is_real_ante_boss()
            and G.GAME.round_resets.ante == 1
            and not G.GAME.hnds_cursed_deck_reward_claimed
            and not G.GAME.hnds_cursed_pack_opened then


            G.GAME.hnds_cursed_deck_reward_claimed = true
            G.GAME.hnds_cursed_pack_opened = true
            if HNDS.queue_cursed_pack then
                HNDS.queue_cursed_pack({ forced = true, source = 'cursed_deck' })
            end
        end
    end,
    pools = { RedeemableBacks = true }
}
