SMODS.Back {
    key = "cursed",
    atlas = "Extras",
    pos = { x = 0, y = 1 },
    unlocked = true,
    calculate = function(self, back, context)
        if context.end_of_round and context.main_eval and context.beat_boss and G.GAME.round_resets.ante == 1 and not G.GAME.hnds_cursed_pack_queued and not G.GAME.hnds_cursed_pack_opened then
            G.GAME.hnds_cursed_pack_queued = true
            G.GAME.hnds_cursed_pack_opened = true
        end
    end,
    pools = { RedeemableBacks = true }
}
