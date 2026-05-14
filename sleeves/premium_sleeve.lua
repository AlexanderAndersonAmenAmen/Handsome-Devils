-- Premium Sleeve: Same as Premium Deck + Common Jokers appear X0.5 less often when paired
CardSleeves.Sleeve({
    key = "premium_sleeve",
    atlas = "hnds_sleeves",
    pos = {x = 0, y = 0},
    unlocked = false,
    unlock_condition = {deck = "b_hnds_premiumdeck", stake = "stake_green"},
    loc_vars = function(self)
        local key
        if self.get_current_deck_key() ~= "b_hnds_premiumdeck" then
            key = self.key
        else
            key = self.key .. "_alt"
        end
        return {key = key, vars = {
            localize { type = 'name_text', key = 'v_hnds_premium', set = 'Voucher' },
            localize { type = 'name_text', key = 'v_hnds_top_shelf', set = 'Voucher' },
            0.5
        }}
    end,
    apply = function(self)
        -- Base effect: Start with Premium and Top Shelf vouchers (always given)
        local vouchers = {'v_hnds_premium', 'v_hnds_top_shelf'}
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

        if self.get_current_deck_key() == "b_hnds_premiumdeck" then
            G.GAME.modifiers.premium_sleeve_active = true
            G.GAME.common_mod = (G.GAME.common_mod or 1) * 0.5
        end
    end,
    calculate = function(self, sleeve, context)
        if context.joker_main and G.GAME.modifiers.premium_sleeve_active then
            return {
                dollars = G.GAME.round_resets.ante
            }
        end
    end,
})

