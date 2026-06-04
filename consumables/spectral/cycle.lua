SMODS.Consumable({
	key = "cycle",
	set = "Spectral",
	discovered = true,
	order = 1,
	cost = 4,
	atlas = "Consumables",
	pos = { x = 1, y = 0 },
	use = function(self, card, area, copier)
		replace_jokers_keep_rarity(G.jokers.cards, 0.5)
	end,
	can_use = function(self, card)
		return #G.jokers.cards > 0
	end,
	demicoloncompat = true,
})
