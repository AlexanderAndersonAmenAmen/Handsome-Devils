
CardSleeves.Sleeve({
    key = "ol_sleeve",
    atlas = "hnds_sleeves",
    pos = {x = 0, y = 1},
    unlocked = false,
    unlock_condition = {deck = "b_hnds_ol_reliable", stake = "stake_green"},
    loc_vars = function(self)
        return HNDS.sleeve_loc(self, "b_hnds_ol_reliable", {3, 4})
    end,
    apply = function(self)
        if self.get_current_deck_key() == "b_hnds_ol_reliable" then
            G.GAME.modifiers.hnds_ol_sleeve_paired = true
        end
    end,
    calculate = function(self, sleeve, context)
        if not context.mod_probability or context.blueprint then return end


        local is_paired = self.get_current_deck_key() == "b_hnds_ol_reliable"

        if is_paired then


            local multiplier = 2
            if G.shop or (G.GAME.blind and G.GAME.blind.boss) then
                multiplier = 4
            end
            return { numerator = context.numerator * multiplier }
        else

            if G.shop or (G.GAME.blind and G.GAME.blind.boss) then
                return { numerator = context.numerator * 3 }
            end
        end
    end,
})