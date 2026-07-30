SMODS.Joker({
	key = "pot_of_greed",
	atlas = "Jokers",
	pos = { x = 3, y = 1 },
	rarity = 1,
	cost = 4,
	unlocked = false,
	discovered = false,
	blueprint_compat = true,
	demicoloncompat = true,
	eternal_compat = true,
	perishable_compat = true,
	config = { extra = { draw_per_use = 2, } },
	unlock_condition = { type = "hnds_joker_unlock", key = "pot_of_greed" },
	locked_loc_vars = function(self)
		return HNDS.joker_locked_loc_vars("pot_of_greed")
	end,
	check_for_unlock = function(self, args)
		return HNDS.joker_unlock_condition_met("pot_of_greed", args)
	end,
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.draw_per_use } }
	end,
	calculate = function(self, card, context)
		if (context.using_consumeable or context.forcetrigger) and G.hand and G.hand.cards and #G.hand.cards > 0 then
			G.E_MANAGER:add_event(Event({
				func = function()
					card:juice_up()
					for i = 1, card.ability.extra.draw_per_use do
						if #G.deck.cards > 0 then
							draw_card(G.deck, G.hand, 1, 'up', true)
						end
					end
					return true
				end,
			}))
			return { message = localize("k_hnds_IPLAYPOTOFGREED"), colour = G.C.GREEN }
		end
	end,
})