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
		return {}
	end,
	remove_from_deck = function(self, card, from_debuff)
		if not (G.GAME.blind and G.GAME.blind.in_blind) then return end
		if G.GAME.chips >= G.GAME.blind.chips then
			if G.deck and G.deck.cards and #G.deck.cards > 0 then
				G.STATE = G.STATES.HAND_PLAYED
				G.STATE_COMPLETE = true
				end_round()
			else
				-- Player has no cards left; check if chips were scored
				if G.GAME.chips >= G.GAME.blind.chips then
					G.GAME.blind.chips = 0
					G.GAME.blind.disabled = true
					G.STATE = G.STATES.POST_BLIND
					G.STATE_COMPLETE = true
				else
					-- The player is aLoser LMAO, if you ask yourself if this is necessary I got into a situation where I got rid of all my cards and still having 8 hands, then I got the Mr. Bones glitch
					G.STATE = G.STATES.GAME_OVER
					G.STATE_COMPLETE = true
				end
			end
		end
	end,
	attributes = { "passive", "hands" }
})
