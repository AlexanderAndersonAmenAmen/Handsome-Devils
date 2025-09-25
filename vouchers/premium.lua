SMODS.Voucher({
	key = "premium",
	atlas = "Vouchers",
	pos = { x = 2, y = 0 },
	config = { extra = { rate_mod = 2 } },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.rate_mod } }
	end,
	cost = 10,
	unlocked = true,
	discovered = true,
	redeem = function(self, voucher)
		G.GAME.uncommon_mod = (G.GAME.uncommon_mod or 1) * voucher.ability.extra.rate_mod
	end,
	unredeem = function(self, voucher)
		G.GAME.uncommon_mod = (G.GAME.uncommon_mod or 1) / voucher.ability.extra.rate_mod
	end,
})
