local function hnds_exchange_target_limit(card)
	local base = card and card.ability and card.ability.extra and tonumber(card.ability.extra.cards) or 1
	local bonus = HNDS and HNDS.get_contagion_bonus and HNDS.get_contagion_bonus() or 0
	return math.max(1, base + bonus)
end

SMODS.Consumable({
	key = "exchange",
	set = "Spectral",
	config = {
		max_highlighted = 1,
		extra = {
			cards = 1,
		},
	},
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue + 1] = {
			key = "e_negative_playing_card",
			set = "Edition",
			config = { extra = G.P_CENTERS["e_negative"].config.card_limit },
		}
		local target_limit = hnds_exchange_target_limit(card)
		local bonus = HNDS and HNDS.get_contagion_bonus and HNDS.get_contagion_bonus() or 0
		return {
			key = bonus > 0 and "c_hnds_exchange_contagion" or nil,
			vars = { target_limit, G.GAME.hnds_exchange_minus or 1 },
		}
	end,
	discovered = false,
	atlas = "Consumables",
	pos = { x = 2, y = 0 },
	cost = 4,
	use = function(self, card, context, copier)
		G.E_MANAGER:add_event(Event({
			trigger = "after",
			delay = 0.4,
			func = function()
				for i = 1, #G.hand.highlighted do
					G.hand.highlighted[i]:set_edition("e_negative", true, i == 1 and true or false)
				end
				card:juice_up(0.3, 0.5)
				return true
			end,
		}))
		G.GAME.hnds_exchange_minus = G.GAME.hnds_exchange_minus or 1
		local mod = G.GAME.hnds_exchange_minus
		ease_hands_played(-mod)
		G.GAME.round_resets.hands = G.GAME.round_resets.hands - mod
		G.GAME.hnds_exchange_minus = G.GAME.hnds_exchange_minus + 1
	end,
	can_use = function(self, card)
		if G.STATE == G.STATES.SELECTING_HAND and G.GAME.current_round.hands_left <= 1 then
			return false
		end
		if G.hand and #G.hand.highlighted <= hnds_exchange_target_limit(card) and #G.hand.highlighted > 0 then
			--Check that all selected cards are not editioned
			local all_uneditioned = true
			for i = 1, #G.hand.highlighted do
				if G.hand.highlighted[i].edition then
					all_uneditioned = false
					break
				end
			end
			if all_uneditioned then
				return true
			end
		end
		return false
	end,
	force_use = function(self, card, area)
		local cards = Cryptid and Cryptid.get_highlighted_cards({ G.hand }, {}, 1, hnds_exchange_target_limit(card))
		G.E_MANAGER:add_event(Event({
			trigger = "after",
			delay = 0.4,
			func = function()
				for i = 1, #cards do
					cards[i]:set_edition("e_negative", true, i == 1 and true or false)
				end
				card:juice_up(0.3, 0.5)
				return true
			end,
		}))
		G.GAME.hnds_exchange_minus = G.GAME.hnds_exchange_minus or 1
		local mod = G.GAME.hnds_exchange_minus
		ease_hands_played(-mod)
		G.GAME.round_resets.hands = G.GAME.round_resets.hands - mod
		G.GAME.hnds_exchange_minus = mod + 1
	end,
	demicoloncompat = true,
})
