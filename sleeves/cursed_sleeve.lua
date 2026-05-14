-- Cursed Sleeve: Same as Cursed Deck + First cursed pack opened only offers rare jokers when paired
CardSleeves.Sleeve({
    key = "cursed_sleeve",
    atlas = "hnds_sleeves",
    pos = {x = 2, y = 0},
    unlocked = false,
    unlock_condition = {deck = "b_hnds_cursed", stake = "stake_green"},
    loc_vars = function(self)
        local key
        if self.get_current_deck_key() ~= "b_hnds_cursed" then
            key = self.key
        else
            key = self.key .. "_alt"
            self.config = {matching = true}
        end
        return {key = key}
    end,
    apply = function(self)
        -- Base effect: Initialize cursed deck variables
        G.GAME.hnds_cursed_pack_queued = false
        G.GAME.hnds_cursed_pack_opened = false
        
        -- Sleeve additional effect: Enable rare-only for first cursed pack
        if self.config.matching then
            G.GAME.modifiers.cursed_sleeve_active = true
            G.GAME.hnds_first_cursed_pack = true
        end
    end,
    calculate = function(self, sleeve, context)
        -- Base effect: Cursed pack on first boss blind (same as deck)
        if context.end_of_round and context.main_eval and context.beat_boss and G.GAME.round_resets.ante == 1 and not G.GAME.hnds_cursed_pack_queued and not G.GAME.hnds_cursed_pack_opened then
            G.GAME.hnds_cursed_pack_queued = true
            G.GAME.hnds_cursed_pack_opened = true
        end
    end,
})

-- Modify unskippable pack for Cursed Sleeve
local orig_get_pack = get_pack
function get_pack(key)
    local pack = orig_get_pack(key)
    if pack and pack.key == 'p_hnds_cursed_pack' and G.GAME.modifiers.cursed_sleeve_active and G.GAME.hnds_first_cursed_pack then
        -- Modify pack to only offer rare jokers
        G.GAME.hnds_first_cursed_pack = false
        -- This would need to be implemented in the cursed pack creation logic
    end
    return pack
end