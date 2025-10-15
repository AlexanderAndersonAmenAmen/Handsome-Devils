SMODS.Joker({
	key = "seismic_activity",
	atlas = "Jokers",
	pos = { x = 7, y = 0 },
	rarity = 2,
	cost = 4,
	unlocked = true,
	discovered = true,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	config = {
		extra = {
			repetitions = 1,
		},
	},
	calculate = function(self, card, context)
		if (context.cardarea == G.play or context.cardarea == G.hand) and context.repetition then
			if SMODS.has_enhancement(context.other_card, "m_stone") then
				return {
					message = localize("k_hnds_seismic"),
					repetitions = card.ability.extra.repetitions,
				}
			end
		end
	end,
	in_pool = function(self, args)
		for _, card in pairs(G.playing_cards) do
			if SMODS.has_enhancement(card, "m_stone") then
				return true
			end
		end
		return false
	end,
})
