-- Conjuring Sleeve: Same as Conjuring Deck + Start with Stuffed and Wholesale when paired
CardSleeves.Sleeve({
    key = "conjuring_sleeve",
    atlas = "hnds_sleeves",
    pos = {x = 4, y = 0},
    unlocked = false,
    unlock_condition = {deck = "b_hnds_conjuring", stake = "stake_green"},
    loc_vars = function(self)
        return HNDS.sleeve_loc(self, "b_hnds_conjuring", {
            localize { type = 'name_text', key = 'v_stuffed', set = 'Voucher' },
            localize { type = 'name_text', key = 'v_wholesale', set = 'Voucher' }
        })
    end,
    apply = function(self)
        HNDS.ban_non_magic_boosters()
        if self.get_current_deck_key() == "b_hnds_conjuring" then
            HNDS.grant_vouchers({"v_hnds_stuffed", "v_hnds_wholesale"})
        end
    end,
})