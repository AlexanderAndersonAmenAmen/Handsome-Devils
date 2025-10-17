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
	remove_from_deck = function (self, card, from_debuff)
		if G.GAME.chips >= G.GAME.blind.chips and G.GAME.blind.in_blind then
			G.STATE = G.STATES.HAND_PLAYED
	        G.STATE_COMPLETE = true
	        end_round()
		end
	end
})
