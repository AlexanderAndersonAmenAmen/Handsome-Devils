function HNDS.trigger_cursed_deck_reward()
    local game = G and G.GAME
    local back = game and game.selected_back
    local center = back and back.effect and back.effect.center
    if not (center and center.key == 'b_hnds_cursed') then return false end
    if not (HNDS.active_blind_is_real_ante_boss and HNDS.active_blind_is_real_ante_boss()) then return false end
    local blind = game.blind
    local ante = blind and (blind.hnds_reward_ante or blind.hnds_crystal_pvp_ante)
        or (game.round_resets and game.round_resets.ante)
    if ante and ante > 0 and ante % 2 == 0
        and game.hnds_cursed_deck_last_ante ~= ante
        and HNDS.queue_cursed_pack and HNDS.queue_cursed_pack({ forced = true, source = 'cursed_deck' }) then
        game.hnds_cursed_deck_last_ante = ante
        return true
    end
    return false
end

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
        if context.end_of_round and context.main_eval and not context.game_over then
            HNDS.trigger_cursed_deck_reward()
        end
    end,
    pools = { RedeemableBacks = true }
}
