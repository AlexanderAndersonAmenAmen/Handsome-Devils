-- Excommunicado: replaces Small and Big blinds with random boss blinds
-- Core logic is in lib/hooks.lua - this file just defines the joker

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
	add_to_deck = function(self, card, from_debuff)
		HNDS.replace_current_blinds_with_bosses()
	end,
	remove_from_deck = function (self, card, from_debuff)
		HNDS.update_excom()
	end,
	calculate = function(self, card, context)
		if context.end_of_round and context.main_eval then
			-- Add a random tag for beating any blind
			add_tag(HNDS.poll_tag('hnds_excommunicado'))
			card:juice_up()
			return { message = localize('k_hnds_plus_tag'), colour = G.C.GREEN }
		end
	end,
	attributes = { "generation", "boss_blind" }
})