SMODS.Enhancement {
	key = 'creepyenh',
	atlas = "Jokers",
	pos = { x = 0, y = 4 },
	config = { Xmult = 1.5 },
	no_collection = true,
	no_suit = true,
	always_scores = true,
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.Xmult } }
	end,
}
