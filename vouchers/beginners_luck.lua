SMODS.Voucher({
	key = "beginners_luck",
	atlas = "Vouchers",
	config = { extra = {} },
	pos = { x = 1, y = 0 },
	cost = 10,
	unlocked = true,
	discovered = true,
	available = true,
	calculate = function(self, card, context)
		if context.setting_blind and G.GAME.blind and (G.GAME.blind.name == 'Small Blind') and not self.getting_sliced then
			G.GAME.probabilities.normal = G.GAME.probabilities.normal * 2
		end
		if context.end_of_round and context.main_eval and G.GAME.blind and (G.GAME.blind.name == 'Small Blind') then
			G.GAME.probabilities.normal = G.GAME.probabilities.normal / 2
		end
	end
})
