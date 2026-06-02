SMODS.Back {
    key = "cursed",
    atlas = "Extras",
    pos = { x = 0, y = 1 },
    unlocked = true,
    calculate = function(self, back, context)
        if context.end_of_round and context.main_eval and context.beat_boss and G.GAME.round_resets.ante == 1 and not G.GAME.hnds_cursed_pack_opened then
            G.GAME.hnds_cursed_pack_opened = true
            local tag = Tag('tag_hnds_cursed_tag')
            tag.ability = tag.ability or {}
            tag.ability.hnds_forced = true
            add_tag(tag)
        end
    end,
    pools = { RedeemableBacks = true }
}
