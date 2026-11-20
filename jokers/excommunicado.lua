


SMODS.Joker({
	key = "excommunicado",
	atlas = "Jokers",
	pos = { x = 3, y = 4 },
	rarity = 3,
	cost = 8,
	unlocked = false,
	discovered = false,
	unlock_condition = { type = "hnds_joker_unlock", key = "excommunicado" },
	locked_loc_vars = function(self)
	    return HNDS.joker_locked_loc_vars("excommunicado")
	end,
	check_for_unlock = function(self, args)
	    return HNDS.joker_unlock_condition_met("excommunicado", args)
	end,
	blueprint_compat = true,
	demicoloncompat = true,
	eternal_compat = true,
	perishable_compat = true,
	add_to_deck = function(self, card)
		HNDS.update_excom(card, true)
	end,
	remove_from_deck = function(self, card)
		HNDS.update_excom(card, false)
	end,
	calculate = function(self, card, context)
		if not (context.end_of_round and context.main_eval and not context.game_over) then return end
		if HNDS.mp_boss_reward_allowed and not HNDS.mp_boss_reward_allowed() then return end
		local game = G and G.GAME
		local blind = game and game.blind
		if not (context.beat_boss or (context.beat_boss == nil and type(blind) == 'table' and blind.boss)) then return end

		local tag = HNDS.poll_tag('hnds_excommunicado')
		if not (tag and tag.key and G.P_TAGS and G.P_TAGS[tag.key]) then return end
		if tag.key == 'tag_orbital' then
			local hand = tag.ability and tag.ability.orbital_hand
			if not (game and game.hands and game.hands[hand]) then return end
		end
		add_tag(tag)
		card:juice_up()
		return { message = localize('k_hnds_plus_tag'), colour = G.C.GREEN }
	end,
	attributes = { "generation", "boss_blind" }
})