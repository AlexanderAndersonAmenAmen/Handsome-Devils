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
        end
        return {key = key}
    end,
    apply = function(self)
        -- Base effect: Initialize cursed deck variables
        G.GAME.hnds_cursed_pack_queued = false
        G.GAME.hnds_cursed_pack_opened = false

        -- Sleeve additional effect: Enable rare-only for first cursed pack when paired with Cursed Deck
        if self.get_current_deck_key() == "b_hnds_cursed" then
            G.GAME.modifiers.cursed_sleeve_active = true
            G.GAME.hnds_first_cursed_pack = true
            G.GAME.hnds_first_cursed_pack_count = 0
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

-- Hook create_card to force rare jokers for first cursed pack
local orig_create_card = create_card
function create_card(_type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append)
    -- Check if this is for the cursed pack and should be rare-only
    if _type == "Joker" and key_append == "cur" and G.GAME.modifiers.cursed_sleeve_active and G.GAME.hnds_first_cursed_pack then
        -- Force rare rarity (3)
        _rarity = 3
        -- Track count and disable after enough cards to cover pack size + modifiers
        G.GAME.hnds_first_cursed_pack_count = (G.GAME.hnds_first_cursed_pack_count or 0) + 1
        -- Using 50 to cover any pack size increases from vouchers/effects
        if G.GAME.hnds_first_cursed_pack_count >= 50 then
            G.GAME.hnds_first_cursed_pack = false
        end
    end
    local card = orig_create_card(_type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append)
    return card
end