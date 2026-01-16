SMODS.Consumable({
	object_type = "Consumable",
	set = "Spectral",
	name = "Cycle",
	key = "cycle",
	discovered = true,
	order = 1,
	cost = 4,
	atlas = "Consumables",
	pos = { x = 1, y = 0 },
	use = function(self, card, area, copier)
		local jokers_to_replace = {}
		for _, c in ipairs(G.jokers.cards) do
			if not SMODS.is_eternal(c, card) then 
				jokers_to_replace[#jokers_to_replace + 1] = c 
			end
		end
		
		if #jokers_to_replace > 0 then
			G.E_MANAGER:add_event(Event({
				trigger = 'after',
				delay = 0.4,
				func = function()
					play_sound("tarot1")
					card:juice_up(0.3, 0.5)
					return true
				end
			}))
			for i = 1, #jokers_to_replace do
				local percent = 1.15 - (i - 0.999) / (#jokers_to_replace - 0.998) * 0.3
				G.E_MANAGER:add_event(Event({
					trigger = 'after',
					delay = 0.15,
					func = function()
						if jokers_to_replace[i] and jokers_to_replace[i].states then
							jokers_to_replace[i]:flip()
							play_sound('card1', percent)
							jokers_to_replace[i]:juice_up(0.3, 0.3)
						end
						return true
					end
				}))
			end
			delay(0.5)
			G.E_MANAGER:add_event(Event({
				func = function()
					-- Set money to $0
					local current_dollars = tonumber(G.GAME and G.GAME.dollars) or 0
					if current_dollars ~= 0 then
						ease_dollars(-current_dollars, true)
					end
					
					-- Replace each joker with same rarity
					for _, joker in ipairs(jokers_to_replace) do
						if joker and joker.area == G.jokers and joker.config and joker.config.center then
							local rarity = joker.config.center.rarity
							local rarity_name = ({[1] = 'Common', [2] = 'Uncommon', [3] = 'Rare', [4] = 'Legendary'})[rarity] or rarity
							local original_edition = joker.edition
							local original_stickers = {}
							for k, _ in pairs(G.shared_stickers) do
								if joker.ability[k] then
									original_stickers[k] = true
									if k == "perishable" then
										original_stickers["perish_tally"] = joker.ability.perish_tally
									end
								end
							end
							local template = create_card("Joker", G.jokers, nil, rarity_name, true, true, nil, 'cyc')
							copy_card(template, joker, nil, nil, true)
							joker:set_edition(original_edition, true, true)
							for k, v in pairs(original_stickers) do
								joker.ability[k] = v
							end
							template:remove()
						end
					end
					return true
				end
			}))
			for i = 1, #jokers_to_replace do
				local percent = 0.85 + (i - 0.999) / (#jokers_to_replace - 0.998) * 0.3
				G.E_MANAGER:add_event(Event({
					trigger = 'after',
					delay = 0.15,
					func = function()
						if jokers_to_replace[i] and jokers_to_replace[i].states then
							jokers_to_replace[i]:flip()
							play_sound('tarot2', percent, 0.6)
							jokers_to_replace[i]:juice_up(0.3, 0.3)
						end
						return true
					end
				}))
			end
			delay(0.5)
		end
	end,
	can_use = function(self, card)
		local use = false
		for _, c in ipairs(G.jokers.cards) do
			if not SMODS.is_eternal(c, card) then
				use = true
				break
			end
		end
		return use
	end,
	force_use = function(self, card, area)
		local jokers_to_replace = {}
		for _, c in ipairs(G.jokers.cards) do
			if not SMODS.is_eternal(c, card) then 
				jokers_to_replace[#jokers_to_replace + 1] = c 
			end
		end
		
		if #jokers_to_replace > 0 then
			G.E_MANAGER:add_event(Event({
				trigger = 'after',
				delay = 0.4,
				func = function()
					play_sound("tarot1")
					card:juice_up(0.3, 0.5)
					return true
				end
			}))
			for i = 1, #jokers_to_replace do
				local percent = 1.15 - (i - 0.999) / (#jokers_to_replace - 0.998) * 0.3
				G.E_MANAGER:add_event(Event({
					trigger = 'after',
					delay = 0.15,
					func = function()
						if jokers_to_replace[i] and jokers_to_replace[i].states then
							jokers_to_replace[i]:flip()
							play_sound('card1', percent)
							jokers_to_replace[i]:juice_up(0.3, 0.3)
						end
						return true
					end
				}))
			end
			delay(0.5)
			G.E_MANAGER:add_event(Event({
				func = function()
					-- Set money to $0
					local current_dollars = tonumber(G.GAME and G.GAME.dollars) or 0
					if current_dollars ~= 0 then
						ease_dollars(-current_dollars, true)
					end
					
					-- Replace each joker with same rarity
					for _, joker in ipairs(jokers_to_replace) do
						if joker and joker.area == G.jokers and joker.config and joker.config.center then
							local rarity = joker.config.center.rarity
							local rarity_name = ({[1] = 'Common', [2] = 'Uncommon', [3] = 'Rare', [4] = 'Legendary'})[rarity] or rarity
							local original_edition = joker.edition
							local original_stickers = {}
							for k, _ in pairs(G.shared_stickers) do
								if joker.ability[k] then
									original_stickers[k] = true
									if k == "perishable" then
										original_stickers["perish_tally"] = joker.ability.perish_tally
									end
								end
							end
							local template = create_card("Joker", G.jokers, nil, rarity_name, true, true, nil, 'cyc')
							copy_card(template, joker, nil, nil, true)
							joker:set_edition(original_edition, true, true)
							for k, v in pairs(original_stickers) do
								joker.ability[k] = v
							end
							template:remove()
						end
					end
					return true
				end
			}))
			for i = 1, #jokers_to_replace do
				local percent = 0.85 + (i - 0.999) / (#jokers_to_replace - 0.998) * 0.3
				G.E_MANAGER:add_event(Event({
					trigger = 'after',
					delay = 0.15,
					func = function()
						if jokers_to_replace[i] and jokers_to_replace[i].states then
							jokers_to_replace[i]:flip()
							play_sound('tarot2', percent, 0.6)
							jokers_to_replace[i]:juice_up(0.3, 0.3)
						end
						return true
					end
				}))
			end
			delay(0.5)
		end
	end,
	demicoloncompat = true,
})
