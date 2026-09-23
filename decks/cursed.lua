SMODS.Back {
    key = "cursed",
    atlas = "Extras",
    pos = { x = 0, y = 1 },
    unlocked = false,
    check_for_unlock = function(self, args)
        return HNDS.unlock_condition_met("cursed", args)
    end,
    apply = function(self, back)
        G.GAME.modifiers = G.GAME.modifiers or {}
        G.GAME.modifiers.hnds_cursed_deck_unskippable_boosters = true
    end,
    calculate = function(self, back, context)
        if context.end_of_round and context.main_eval
            and HNDS.active_blind_is_real_ante_boss and HNDS.active_blind_is_real_ante_boss() then
            local ante = G.GAME.round_resets.ante
            if ante and ante > 0 and ante % 2 == 0
                and G.GAME.hnds_cursed_deck_last_ante ~= ante
                and HNDS.queue_cursed_pack
                and HNDS.queue_cursed_pack({ forced = true, source = 'cursed_deck' }) then
                -- The queued pack opens in the next shop, after cash out.
                G.GAME.hnds_cursed_deck_last_ante = ante
            end
        end
    end,
    pools = { RedeemableBacks = true }
}
