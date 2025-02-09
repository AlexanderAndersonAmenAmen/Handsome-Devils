SMODS.Consumable {
	object_type = "Consumable",
	set = "Spectral",
	name = "Abyss",
	key = "abyss",
	config = {},
	loc_vars = function(self, info_queue, card)
		-- Handle creating a tooltip with set args.
		info_queue[#info_queue + 1] =
			{ set = "Other", key = "black", specific_vars = {} }
		return { 
			key = key,
			vars = { card.ability.max_highlighted } 
		}
	end,
	cost = 4,
	atlas = "THD",
	pos = { x = 0, y = 0 },
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
						highlighted:set_seal("hnds_black")
					end
					return true
				end,
			}))
			delay(0.5)
			G.E_MANAGER:add_event(Event({
				trigger = "after",
				delay = 0.2,
				func = function()
					G.hand:unhighlight_all()
					return true
				end,
			}))
		end
	end,
}
