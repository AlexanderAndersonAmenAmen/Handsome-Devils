SMODS.Joker({
	key = "pot_of_greed",
	atlas = "Jokers",
	pos = { x = 3, y = 1 },
	rarity = 1,
	cost = 4,
	unlocked = true,
	discovered = true,
	blueprint_compat = true,
	demicoloncompat = true,
	eternal_compat = true,
	perishable_compat = true,
	config = { extra = { draw_per_use = 2, } },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.draw_per_use } }
	end,
	calculate = function(self, card, context)
		if (context.using_consumeable or context.forcetrigger) and G.hand and G.hand.cards and #G.hand.cards > 0 then
			-- If booster pack have less than 1 option, Pot of Greed does nothing, prevents trigger if booster pack is empty
			if G.pack_cards and G.pack_cards.config and #G.pack_cards.cards < G.pack_cards.config.card_limit then
				return nil
			end
			
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