SMODS.Voucher({
	key = "rigged",
	atlas = "Vouchers",
	config = { extra = {} },
	pos = { x = 1, y = 1 },
	cost = 10,
	unlocked = true,
	discovered = true,
	available = true,
	redeem = function(self)
			G.GAME.probabilities.normal = G.GAME.probabilities.normal * 1.5
	end
})