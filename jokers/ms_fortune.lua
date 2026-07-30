SMODS.Joker({
	key = "ms_fortune",
	unlocked = false,
	discovered = false,
	unlock_condition = { type = "hnds_joker_unlock", key = "ms_fortune" },
	locked_loc_vars = function(self)
	    return HNDS.joker_locked_loc_vars("ms_fortune")
	end,
	check_for_unlock = function(self, args)
	    return HNDS.joker_unlock_condition_met("ms_fortune", args)
	end,
	blueprint_compat = false,
	eternal_compat = true,
	perishable_compat = true,
	config = { extra = { numerator = 4 } },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.numerator, 0 } }
	end,
	rarity = 3,
	cost = 10,
	atlas = "Jokers",
	pos = { x = 1, y = 1 },
	demicoloncompat = true,
	calculate = function(self, card, context)
		if context.mod_probability and not context.blueprint then
			return { numerator = context.numerator * card.ability.extra.numerator, }
		end
		if context.setting_blind or context.forcetrigger and not context.blueprint then
			return { dollars = -G.GAME.dollars, }
		end
	end,
	attributes = { "mod_chance", } -- i dont think this is economy
})
