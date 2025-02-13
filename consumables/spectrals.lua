SMODS.Consumable {
	object_type = "Consumable",
	set = "Spectral",
	name = "Abyss",
	key = "abyss",
	order = 1,
	cost = 4,
	atlas = "Consumables",
	pos = { x = 0, y = 0 },
	loc_vars = function(self, info_queue, card)
		-- Handle creating a tooltip with set args.
		info_queue[#info_queue + 1] =
			{ set = "Other", key = "hnds_black_seal", specific_vars = {} }
		return { 
			vars = { card.ability.max_highlighted } 
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
	can_use = function(self, card, area)
		if G.hand and (#G.hand.highlighted == 1) and G.hand.highlighted[1] and (not G.hand.highlighted[1].seal) then
			return true
		else
			return false
		end
	end
}

SMODS.Consumable {
	object_type = "Consumable",
	set = "Spectral",
	name = "Growth",
	key = "growth",
	order = 1,
	cost = 4,
	atlas = "Consumables",
	pos = { x = 1, y = 0 },
	loc_vars = function(self, info_queue, card)
		-- Handle creating a tooltip with set args.
		info_queue[#info_queue + 1] =
			{ set = "Other", key = "hnds_green_seal", specific_vars = {} }
		return { 
			vars = { card.ability.max_highlighted } 
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
						highlighted:set_seal("hnds_green")
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
	can_use = function(self, card, area)
		if G.hand and (#G.hand.highlighted == 1) and G.hand.highlighted[1] and (not G.hand.highlighted[1].seal) then
			return true
		else
			return false
		end
	end
}
