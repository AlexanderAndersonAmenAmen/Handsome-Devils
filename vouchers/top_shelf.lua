SMODS.Voucher({
	key = "top_shelf",
	atlas = "Vouchers",
	pos = { x = 2, y = 1 },
	config = { extra = { rate_mod = 2 } },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.rate_mod } }
	end,
	cost = 10,
	unlocked = true,
	discovered = true,
	requires = { "v_hnds_premium" },
	redeem = function(self, voucher)
		G.GAME.rare_mod = (G.GAME.rare_mod or 1) * voucher.ability.extra.rate_mod
	end,
	unredeem = function(self, voucher)
		G.GAME.rare_mod = (G.GAME.rare_mod or 1) / voucher.ability.extra.rate_mod
	end,
})
