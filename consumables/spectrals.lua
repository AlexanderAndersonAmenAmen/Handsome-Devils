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

SMODS.Consumable {
	object_type = "Consumable",
	set = "Spectral",
	name = "Petrify",
	key = "petrify",
	order = 1,
	cost = 4,
	atlas = "Consumables",
	pos = { x = 3, y = 0 },
	loc_vars = function(self, info_queue, card)
	end,
	can_use = function(self, card)
		return #G.hand.cards > 0
	end,
	use = function(self, card, area, copier)
		local used_consumable = copier or card

		G.E_MANAGER:add_event(Event({
			trigger = "after",
			delay = 0.4,
			func = function()
				play_sound("tarot1")
				used_consumable:juice_up(0.3, 0.5)
				return true
			end,
		}))
		for i = 1, #G.hand.cards do
			if G.hand.cards[i]:is_face() and not G.hand.cards[i].ability.eternal then
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
					if v.config.center_key ~= 'm_stone' and not v.ability.eternal and v:is_face() then
						v:set_ability(G.P_CENTERS.m_stone)
						converted = converted + 1
					end
				end
				ease_dollars(converted * 5)
				return true
			end
		}))


		for i = 1, #G.hand.cards do
			if G.hand.cards[i]:is_face() and not G.hand.cards[i].ability.eternal then
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
	end
}

SMODS.Consumable {
	key = 'exchange',
	set = 'Spectral',
	config = {
        extra = {
            cards = 2,
			hand_reduction = 1
        }
    },
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue+1] = {key = 'e_negative_playing_card', set = 'Edition', config = {extra = G.P_CENTERS['e_negative'].config.card_limit}}
		return {vars = {card.ability.extra.cards, card.ability.extra.hand_reduction}}
	end,
	rarity = 4,
	atlas = 'Consumables',
	pos = { x = 2, y = 0 },
	cost = 4,
    use = function(self, card, context, copier)
		local used_consumable = copier or card
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
			for i = 1, #G.hand.highlighted do
				G.hand.highlighted[i]:set_edition({negative = true}, true, i == 1 and true or false)
			end
			used_consumable:juice_up(0.3, 0.5)
        return true end }))
		ease_hands_played(-card.ability.extra.hand_reduction)
		G.GAME.round_resets.hands = G.GAME.round_resets.hands - card.ability.extra.hand_reduction
    end,
    can_use = function(self, card)
		if G.hand and #G.hand.highlighted <= card.ability.extra.cards and #G.hand.highlighted > 0 then
			--Check that all selected cards are not editioned
			local all_uneditioned = true
			for i = 1, #G.hand.highlighted do
				if G.hand.highlighted[i].edition then
					all_uneditioned = false
					break
				end
			end
			if all_uneditioned then return true end
		end
		return false
    end,
}


