SMODS.Joker({
	key = "public_nuisance",
	atlas = "Jokers",
	pos = { x = 8, y = 1 },
	rarity = 1,
	cost = 3,
	unlocked = true,
	discovered = true,
	blueprint_compat = false,
	demicoloncompat = true,
	eternal_compat = true,
	perishable_compat = true,
	loc_vars = function(self, info_queue, card)
		return { vars = {} }
	end,
	calculate = function(self, card, context)
        if (context.selling_self or (context.joker_type_destroyed and context.card == card)) and G.GAME.chips >= G.GAME.blind.chips and not context.blueprint then
	            G.STATE = G.STATES.HAND_PLAYED
	            G.STATE_COMPLETE = true
	            end_round()
        end
	end,
})
