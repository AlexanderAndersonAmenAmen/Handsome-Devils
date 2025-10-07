SMODS.Consumable({
	key = "possess",
	name = "Possess"
	set = "Spectral",
	config = {
		extra = {
			value_multiplier = 4,
			max_payout = 100,
		},
	},
	loc_vars = function(self, info_queue, card)
		local value = 0
		local destroyable_jokers = {}
		if G.jokers and G.jokers.cards and #G.jokers.cards > 1 then
			for i = 2, #G.jokers.cards do
				if not G.jokers.cards[i].ability.eternal then
					table.insert(destroyable_jokers, G.jokers.cards[i])
				end
			end
		end
		for k, v in pairs(destroyable_jokers) do
			value = value + (v.sell_cost * card.ability.extra.value_multiplier)
		end
		local modified_max = card.ability.extra.max_payout * (G.GAME.gambler_mod or 1)
		return { vars = { card.ability.extra.value_multiplier, modified_max, math.min(value, modified_max) } }
	end,
	discovered = true,
	rarity = 4,
	atlas = "Consumables",
	pos = { x = 4, y = 0 },
	cost = 4,
	use = function(self, card, context, copier)
		local destroyable_jokers = {}
		if G.jokers and G.jokers.cards and #G.jokers.cards > 1 then
			for i = 2, #G.jokers.cards do
				if not G.jokers.cards[i].ability.eternal then
					table.insert(destroyable_jokers, G.jokers.cards[i])
				end
			end
		end
		local no_sound = false
		local value = 0
		G.E_MANAGER:add_event(Event({
			trigger = "before",
			delay = 0.75,
			func = function()
				for k, v in pairs(destroyable_jokers) do
					value = value + (v.sell_cost * card.ability.extra.value_multiplier)
					v:start_dissolve(nil, no_sound)
					no_sound = true
				end
				return true
			end,
		}))
		G.E_MANAGER:add_event(Event({
			trigger = "before",
			delay = 0.4,
			func = function()
				ease_dollars(math.min(value, card.ability.extra.max_payout * (G.GAME.gambler_mod or 1)))
				return true
			end,
		}))
	end,
	can_use = function(self, card)
		if G.jokers and G.jokers.cards and #G.jokers.cards > 1 then
			--Check that not all jokers that would be destroyed are eternal
			local all_eternal = true
			for i = 2, #G.jokers.cards do
				if not G.jokers.cards[i].ability.eternal then
					all_eternal = false
					break
				end
			end
			if not all_eternal then
				return true
			end
		end
		return false
	end,
	force_use = function(self, card, area)
		card:use_consumeable()
	end,
	demicoloncompat = true,
})
