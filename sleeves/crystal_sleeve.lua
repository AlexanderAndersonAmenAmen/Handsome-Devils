-- Crystal Sleeve: Same as Crystal Deck + Showdown Blinds in ante 2 and 6 when paired
CardSleeves.Sleeve({
    key = "crystal_sleeve",
    atlas = "hnds_sleeves",
    pos = {x = 3, y = 0},
    unlocked = false,
    unlock_condition = {deck = "b_hnds_crystal", stake = "stake_green"},
    loc_vars = function(self)
        local key
        if self.get_current_deck_key() ~= "b_hnds_crystal" then
            key = self.key
        else
            key = self.key .. "_alt"
        end
        return {key = key}
    end,
    apply = function(self)
        -- Base effect: Double showdown (same as deck)
        G.GAME.modifiers.hnds_double_showdown = true

        -- Sleeve additional effect: Enable ante 2 and 6 spectral packs when paired with Crystal Deck
        if self.get_current_deck_key() == "b_hnds_crystal" then
            G.GAME.modifiers.crystal_sleeve_active = true
        end
    end,
    calculate = function(self, sleeve, context)
        -- Base effect: Ultra Spectral Pack on ante 4 boss (same as deck)
        if context.end_of_round and context.main_eval and G.GAME.round_resets.ante == math.floor(G.GAME.win_ante/2) and context.beat_boss then
            G.GAME.hnds_crystal_queued = true
        end

        -- Sleeve additional effect: Ultra Spectral Pack in ante 2 and 6 when paired with Crystal Deck
        if self.get_current_deck_key() == "b_hnds_crystal" then
            if context.end_of_round and context.main_eval and context.beat_boss and (G.GAME.round_resets.ante == 2 or G.GAME.round_resets.ante == 6) then
                G.GAME.hnds_crystal_queued = true
            end
        end
    end,
})

-- Hook to force showdown blinds in ante 2 and 6 for Crystal Sleeve
local get_new_boss_ref = get_new_boss
function get_new_boss()
    local win_ante = G.GAME.win_ante
    -- Check if Crystal Sleeve is active (with or without Crystal Deck)
    if G.GAME.modifiers.hnds_double_showdown and G.GAME.round_resets.ante and G.GAME.round_resets.ante < G.GAME.win_ante then
        G.GAME.win_ante = math.floor(G.GAME.win_ante / 2)
    end
    local boss = get_new_boss_ref()
    G.GAME.win_ante = win_ante
    return boss
end