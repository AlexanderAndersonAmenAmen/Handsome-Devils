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
		if context.setting_blind then
			G.GAME.current_round = G.GAME.current_round or {}
			G.GAME.current_round.hnds_consumables_used_in_blind = 0
		end
		if context.using_consumeable and G.GAME.blind and G.GAME.blind.in_blind then
			G.GAME.current_round = G.GAME.current_round or {}
			G.GAME.current_round.hnds_consumables_used_in_blind = (G.GAME.current_round.hnds_consumables_used_in_blind or 0) + 1
			check_for_unlock({ type = 'hnds_consumable_in_blind', count = G.GAME.current_round.hnds_consumables_used_in_blind })
		end
		if (context.using_consumeable or context.forcetrigger) and G.hand and G.hand.cards and #G.hand.cards > 0 then
			-- Do not trigger inside joker booster packs (cursed_pack, buffoon pack, etc.)
			if G.STATE == G.STATES.BUFFOON_PACK then return nil end
			-- If in a booster pack with no cards left (all selections used), do nothing
			if G.pack_cards and G.pack_cards.cards and #G.pack_cards.cards == 0 then
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