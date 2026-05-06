-- Excommunicado: replaces Small and Big blinds with random boss blinds
-- Core logic is in lib/hooks.lua - this file just defines the joker

SMODS.Joker({
	key = "excommunicado",
	atlas = "Jokers",
	pos = { x = 3, y = 4 },
	rarity = 3,
	cost = 7,
	unlocked = true,
	discovered = true,
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