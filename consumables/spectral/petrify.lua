SMODS.Consumable({
	object_type = "Consumable",
	set = "Spectral",
	name = "Petrify",
	key = "petrify",
	discovered = true,
	order = 1,
	cost = 4,
	atlas = "Consumables",
	pos = { x = 3, y = 0 },
	config = { extra = { multiplier = 8 } },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.multiplier } }
	end,
	can_use = function(self, card)
		return #G.hand.cards > 0
	end,
	use = function(self, card, area, copier)
		G.E_MANAGER:add_event(Event({
			trigger = "after",
			delay = 0.4,
			func = function()
				play_sound("tarot1")
				card:juice_up(0.3, 0.5)
				return true
			end,
		}))
		for i = 1, #G.hand.cards do
			if G.hand.cards[i]:is_face() then
				local percent = 1.15 - (i - 0.999) / (#G.hand.cards - 0.998) * 0.3
				G.E_MANAGER:add_event(Event({
					trigger = "after",
					delay = 0.15,
					func = function()
						G.hand.cards[i]:flip()
						play_sound("card1", percent)
						G.hand.cards[i]:juice_up(0.3, 0.3)
						return true
					end,
				}))
			end
		end

		G.E_MANAGER:add_event(Event({
			trigger = "after",
			delay = 0.15,
			func = function()
				local converted = 0
				local faces = {}
				for k, v in pairs(G.hand.cards) do
					faces[#faces + 1] = v
					if v.config.center_key ~= "m_stone" and v:is_face() then
						v:set_ability(G.P_CENTERS.m_stone)
						converted = converted + 1
					end
				end
				ease_dollars(converted * card.ability.extra.multiplier)
				return true
			end,
		}))

		for i = 1, #G.hand.cards do
			if G.hand.cards[i]:is_face() then
				local percent = 0.85 + (i - 0.999) / (#G.hand.cards - 0.998) * 0.3
				G.E_MANAGER:add_event(Event({
					trigger = "after",
					delay = 0.15,
					func = function()
						G.hand.cards[i]:flip()
						play_sound("tarot2", percent, 0.6)
						G.hand.cards[i]:juice_up(0.3, 0.3)
						return true
					end,
				}))
			end
		end
	end,
	force_use = function(self, card, area)
		card:use_consumeable()
	end,
	demicoloncompat = true,
})
