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
            self.config = {vouchers = {'v_hnds_premium', 'v_hnds_top_shelf'}}
        else
            key = self.key .. "_alt"
            self.config = {matching = true, vouchers = {'v_hnds_premium', 'v_hnds_top_shelf'}, reduction = 0.5}
        end
        return {key = key, vars = {
            localize { type = 'name_text', key = self.config.vouchers[1], set = 'Voucher' },
            localize { type = 'name_text', key = self.config.vouchers[2], set = 'Voucher' },
            self.config.reduction
        }}
    end,
    apply = function(self)
        -- Base effect: Start with Premium and Top Shelf vouchers
        if self.config.vouchers then
            for k, v in pairs(self.config.vouchers) do
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
        
        -- Sleeve additional effect: Reduce common joker appearance rate
        if self.config.matching then
            G.GAME.modifiers.premium_sleeve_active = true
            G.GAME.joker_slot_weights = G.GAME.joker_slot_weights or {}
            for k, v in pairs(G.GAME.joker_slot_weights) do
                if k == 'Common' then
                    G.GAME.joker_slot_weights[k] = v * self.config.reduction
                end
            end
        end
    end,
    calculate = function(self, sleeve, context)
        -- Joker cost increase effect (same as deck)
        if context.joker_main then
            if G.GAME.modifiers.premium_sleeve_active then
                return {
                    dollars = G.GAME.round_resets.ante
                }
            end
        end
    end,
})