SMODS.Voucher({
	key = "beginners_luck",
	atlas = "Vouchers",
	config = { extra = {} },
	pos = { x = 1, y = 0 },
	cost = 10,
	unlocked = true,
	discovered = true,
	available = true,
	redeem = function(self)
		G.GAME.probabilities.normal = G.GAME.probabilities.normal * 2
	end
})
