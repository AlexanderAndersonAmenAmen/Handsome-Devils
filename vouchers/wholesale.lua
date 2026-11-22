SMODS.Voucher({
	key = "wholesale",
	atlas = "Vouchers",
	pos = { x = 0, y = 1 },
	config = { extra = { boosters = 1 } },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.boosters } }
	end,
	cost = 10,
	unlocked = false,
	locked_loc_vars = function(self)
		local current = HNDS.unlock_progress("wholesale")
		return { vars = { current } }
	end,
	check_for_unlock = function(self, args)
		return HNDS.unlock_condition_met("wholesale", args)
	end,
	discovered = false,
	requires = { "v_hnds_stuffed" },
	redeem = function(self, voucher)
		SMODS.change_booster_limit(voucher.ability.extra.boosters)
	end,
	unredeem = function(self, voucher)
		SMODS.change_booster_limit(-voucher.ability.extra.boosters)
		if G.shop and G.shop_booster then
			local limit = (G.GAME.starting_params.boosters_in_shop or 2) + (G.GAME.modifiers.extra_boosters or 0)
			for i = #G.shop_booster.cards, 1, -1 do
				local card = G.shop_booster.cards[i]
				if (card.ability.booster_pos or i) > limit then card:remove() end
			end
		end
	end,
})
