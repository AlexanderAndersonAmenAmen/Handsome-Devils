SMODS.Enhancement({
	key = "obsidian",
	atlas = "Extras",
	pos = { x = 3, y = 0 },
	config = { extra = { cards = 2 } },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.cards } }
	end,
	calculate = function(self, card, context)
		if context.before and (context.cardarea == G.play or context.cardarea == "unscored") or context.discard and context.other_card == card then
			G.GAME.hnds_obsidian_draws = G.GAME.hnds_obsidian_draws + card.ability.extra.cards
			return {
				message = localize("k_hnds_green"),
			}
		end
	end,
	weight = 2.5,
})
