if hnds_config.enableVintageEdition then

SMODS.Shader({ key = 'vintage', path = 'vintage.fs' })

SMODS.Edition({
	key = "vintage",
	disable_shadow = false,
	disable_base_shader = true,
	shader = "vintage",
	discovered = true,
	unlocked = true,
	config = {},
	in_shop = true,
	weight = 14,
	extra_cost = 5,
	sound = { sound = "hnds_vintage", per = 1.2, vol = 0.3 },
	apply_to_float = true,
	loc_vars = function(self, info_queue, card)
		return { vars = {} }
	end,
	calculate = function(self, card, context)
		if (context.cardarea == G.jokers or context.cardarea == G.hand) and (context.end_of_round and context.main_eval or context.playing_card_end_of_round) then
			return { dollars = math.floor(math.min(G.GAME.dollars, G.GAME.interest_cap) / 5)}
		end
	end
})

end
