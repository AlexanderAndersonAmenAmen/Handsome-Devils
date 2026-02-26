SMODS.Consumable({
	object_type = "Consumable",
	set = "Spectral",
	name = "Cycle",
	key = "cycle",
	discovered = true,
	order = 1,
	cost = 4,
	atlas = "Consumables",
	pos = { x = 1, y = 0 },
	config = { extra = { free_rerolls = 5 } },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.free_rerolls } }
	end,
	use = function(self, card, area, copier)
		local rerolls = card.ability.extra.free_rerolls
		G.GAME.hnds_cycle_free_rerolls = (G.GAME.hnds_cycle_free_rerolls or 0) + rerolls
		G.GAME.current_round.free_rerolls = G.GAME.current_round.free_rerolls + rerolls
		calculate_reroll_cost(true)
	end,
	can_use = function(self, card)
		return true
	end,
	demicoloncompat = true,
})
