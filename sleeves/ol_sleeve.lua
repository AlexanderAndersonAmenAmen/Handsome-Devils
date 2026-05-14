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
            self.config = {multiplier = 3}
        else
            key = self.key .. "_alt"
            self.config = {matching = true, multiplier = 3, sleeve_multiplier = 2}
        end
        return {key = key, vars = {self.config.multiplier, self.config.sleeve_multiplier}}
    end,
    calculate = function(self, sleeve, context)
        -- Base effect: Triple probabilities during shop and boss blinds (same as deck)
        if not self.config.matching and context.mod_probability and not context.blueprint and (G.shop or (G.GAME.blind and G.GAME.blind.boss)) then
            return {
                numerator = context.numerator * self.config.multiplier
            }
        end
        
        -- Sleeve additional effect: Double normally, cuadruple during shop and boss blinds (replaces deck effect)
        if self.config.matching and context.mod_probability and not context.blueprint then
            local multiplier = 2 -- Default double
            if G.shop or (G.GAME.blind and G.GAME.blind.boss) then
                multiplier = 4 -- Cuadruple during shop and boss blinds
            end
            return {
                numerator = context.numerator * multiplier
            }
        end
    end,
})