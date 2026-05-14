-- Conjuring Sleeve: Same as Conjuring Deck + Start with Stuffed and Wholesale when paired
CardSleeves.Sleeve({
    key = "conjuring_sleeve",
    atlas = "hnds_sleeves",
    pos = {x = 4, y = 0},
    unlocked = false,
    unlock_condition = {deck = "b_hnds_conjuring", stake = "stake_green"},
    loc_vars = function(self)
        local key
        if self.get_current_deck_key() ~= "b_hnds_conjuring" then
            key = self.key
        else
            key = self.key .. "_alt"
        end
        return {key = key, vars = {
            localize { type = 'name_text', key = 'v_stuffed', set = 'Voucher' },
            localize { type = 'name_text', key = 'v_wholesale', set = 'Voucher' }
        }}
    end,
    apply = function(self)
        for _, booster in pairs(G.P_CENTER_POOLS.Booster) do
            if booster.kind ~= "hnds_magic" then
                G.GAME.banned_keys[booster.key] = true
            end
        end
        if self.get_current_deck_key() == "b_hnds_conjuring" then
            local vouchers = {"v_hnds_stuffed", "v_hnds_wholesale"}
            for _, v in ipairs(vouchers) do
                if G.P_CENTERS[v] then
                    G.GAME.used_vouchers[v] = true
                    G.GAME.starting_voucher_count = (G.GAME.starting_voucher_count or 0) + 1
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            Card.apply_to_run(nil, G.P_CENTERS[v])
                            return true
                        end
                    }))
                end
            end
        end
    end,
})