SMODS.Consumable({
	key = "possess",
	name = "Possess",
	set = "Spectral",
	discovered = true,
	atlas = "Consumables",
	pos = { x = 4, y = 0 },
	cost = 4,
	config = { max_highlighted = 1 },
	loc_vars = function(self, info_queue, card)
		-- Handle creating a tooltip with set args.
		info_queue[#info_queue + 1] = G.P_SEALS["hnds_spectralseal"]
		return {
			vars = { card.ability.max_highlighted },
		}
	end,
	use = function(self, card, area, copier) --Good enough
		for i = 1, #G.hand.highlighted do
			local highlighted = G.hand.highlighted[i]
			G.E_MANAGER:add_event(Event({
				func = function()
					play_sound("tarot1")
					highlighted:juice_up(0.3, 0.5)
					return true
				end,
			}))
			G.E_MANAGER:add_event(Event({
				trigger = "after",
				delay = 0.1,
				func = function()
					if highlighted then
						highlighted:set_seal("hnds_spectralseal", nil, true)
					end
					return true
				end,
			}))
		end
		delay(0.5)
		G.E_MANAGER:add_event(Event({
			trigger = "after",
			delay = 0.2,
			func = function()
				G.hand:unhighlight_all()
				return true
			end,
		}))
	end,
	force_use = function(self, card, area)
		local cards = Cryptid and Cryptid.get_highlighted_cards({ G.hand }, {}, 1, card.ability.max_highlighted)
		for i = 1, #cards do
			local highlighted = cards[i]
			G.E_MANAGER:add_event(Event({
				func = function()
					play_sound("tarot1")
					highlighted:juice_up(0.3, 0.5)
					return true
				end,
			}))
			G.E_MANAGER:add_event(Event({
				trigger = "after",
				delay = 0.1,
				func = function()
					if highlighted then
						highlighted:set_seal("hnds_spectralseal")
					end
					return true
				end,
			}))
		end
		delay(0.5)
		G.E_MANAGER:add_event(Event({
			trigger = "after",
			delay = 0.2,
			func = function()
				G.hand:unhighlight_all()
				return true
			end,
		}))
	end,
	demicoloncompat = true,
})
