SMODS.Consumable {
	object_type = "Consumable",
	set = "Spectral",
	name = "Abyss",
	key = "abyss",
	order = 1,
	cost = 4,
	atlas = "tarot",
	pos = { x = 0, y = 0 },
	loc_vars = function(self, info_queue, card)
		-- Handle creating a tooltip with set args.
		info_queue[#info_queue + 1] =
			{ set = "Other", key = "black"}
		return { 
			vars = { card.ability.max_highlighted } 
		}
	end,
	can_use = function(self, card)
		if G.hand and (get_consumable_use_hand_count(card, G.hand.highlighted) >= 1) and (get_consumable_use_hand_count(card, G.hand.highlighted) <= card.ability.extra.count) then
			return true
		end
		return false
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
						highlighted:set_seal("minty_cement")
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
