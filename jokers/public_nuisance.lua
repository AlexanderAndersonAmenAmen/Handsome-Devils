SMODS.Joker({
	key = "public_nuisance",
	atlas = "Jokers",
	pos = { x = 8, y = 1 },
	rarity = 1,
	cost = 3,
	unlocked = false,
	discovered = false,
	unlock_condition = { type = "hnds_joker_unlock", key = "public_nuisance" },
	locked_loc_vars = function(self)
		return HNDS.joker_locked_loc_vars("public_nuisance")
	end,
	check_for_unlock = function(self, args)
		return HNDS.joker_unlock_condition_met("public_nuisance", args)
	end,
	blueprint_compat = false,
	demicoloncompat = true,
	eternal_compat = true,
	perishable_compat = true,
	config = { extra = { dollars = 2, score_was_met = false } },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.dollars } }
	end,
	calculate = function(self, card, context)
		if context.before then
			card.ability.extra.score_was_met = G.GAME.chips >= G.GAME.blind.chips
		end
		if context.after and card.ability.extra.score_was_met then
			card.ability.extra.score_was_met = false
			return { dollars = card.ability.extra.dollars }
		end
		if context.end_of_round then
			card.ability.extra.score_was_met = false
		end
	end,
	remove_from_deck = function(self, card, from_debuff)
		if not (G.GAME.blind and G.GAME.blind.in_blind) then return end
		if G.GAME.chips >= G.GAME.blind.chips then
				end_round()
		end
	end,
	attributes = { "passive", "hands" }
})
