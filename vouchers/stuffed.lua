SMODS.Voucher({
	key = "stuffed",
	atlas = "Vouchers",
	pos = { x = 0, y = 0 },
	config = { extra = { size_mod = 1 } },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.size_mod } }
	end,
	cost = 10,
	unlocked = true,
	discovered = true,
	redeem = function(self, voucher)
		G.GAME.modifiers.booster_size_mod = (G.GAME.modifiers.booster_size_mod or 0) + voucher.ability.extra.size_mod
	end,
	unredeem = function(self, voucher)
		G.GAME.modifiers.booster_size_mod = (G.GAME.modifiers.booster_size_mod or 0) - voucher.ability.extra.size_mod
	end,
})
