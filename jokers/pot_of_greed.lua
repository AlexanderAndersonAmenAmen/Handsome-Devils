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
	unlock_condition = { type = 'hnds_consumable_in_blind', extra = 4 },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.draw_per_use } }
	end,
	check_for_unlock = function(self, args)
		if args.type == 'hnds_consumable_in_blind' then
			local count = (args.count or 0)
			return count >= self.unlock_condition.extra
		end
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

-- Pot of Greed Unlock Tracker
-- The counter resets when a new blind starts (called from select_blind)
if G and G.FUNCS and G.FUNCS.select_blind and not _G._hnds_wrapped_select_blind_potofgreed then
	_G._hnds_wrapped_select_blind_potofgreed = true
	local select_blind_ref = G.FUNCS.select_blind
	function G.FUNCS.select_blind(e)
		if G.GAME and G.GAME.current_round then
			G.GAME.current_round.hnds_consumables_used_in_blind = 0
		end
		return select_blind_ref(e)
	end
end

-- Pot of Greed: hook Card.use_consumeable to count uses during a blind
if Card and Card.use_consumeable and not Card._hnds_wrapped_use_consumeable_potofgreed then
	Card._hnds_wrapped_use_consumeable_potofgreed = true
	local use_consumeable_ref = Card.use_consumeable
	function Card:use_consumeable(area, copier)
		local ret = use_consumeable_ref(self, area, copier)
		if check_for_unlock and G.GAME and G.GAME.blind and G.GAME.blind.in_blind then
			G.GAME.current_round = G.GAME.current_round or {}
			G.GAME.current_round.hnds_consumables_used_in_blind = (G.GAME.current_round.hnds_consumables_used_in_blind or 0) + 1
			check_for_unlock({ type = 'hnds_consumable_in_blind', count = G.GAME.current_round.hnds_consumables_used_in_blind })
		end
		return ret
	end
end