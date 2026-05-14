-- Ol' Sleeve: Same as Ol' Reliable Deck + Doubles all listed probabilities when paired
CardSleeves.Sleeve({
    key = "ol_sleeve",
    atlas = "hnds_sleeves",
    pos = {x = 0, y = 1},
    unlocked = false,
    unlock_condition = {deck = "b_hnds_ol_reliable", stake = "stake_green"},
    loc_vars = function(self)
        local key
        if self.get_current_deck_key() ~= "b_hnds_ol_reliable" then
            key = self.key
        else
            key = self.key .. "_alt"
        end
        return {key = key, vars = {3, 4}}
    end,
    apply = function(self)
        if self.get_current_deck_key() == "b_hnds_ol_reliable" then
            G.GAME.modifiers.hnds_ol_sleeve_paired = true
        end
    end,
    calculate = function(self, sleeve, context)
        if not context.mod_probability or context.blueprint then return end

        -- Check if paired with Ol' Reliable Deck
        local is_paired = self.get_current_deck_key() == "b_hnds_ol_reliable"

        if is_paired then
            -- Paired: Double normally (2x), Cuadruple during shop and boss blinds (4x)
            -- This REPLACES the deck's 3x effect
            local multiplier = 2
            if G.shop or (G.GAME.blind and G.GAME.blind.boss) then
                multiplier = 4
            end
            return { numerator = context.numerator * multiplier }
        else
            -- Not paired: Same as deck - Triple during shop and boss blinds (3x)
            if G.shop or (G.GAME.blind and G.GAME.blind.boss) then
                return { numerator = context.numerator * 3 }
            end
        end
    end,
})