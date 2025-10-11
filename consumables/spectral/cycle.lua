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
	use = function(self, card, area, copier) --Good enough
		local available = {}
		for _, c in ipairs(G.jokers.cards) do
			if not SMODS.is_eternal(c, card) then available[#available + 1] = c end
		end
		if #available > 0 then
			local joker = pseudorandom_element(available)
			local rarity = joker.config.center.rarity
			if rarity == 1 then rarity = "Common" end
			if rarity == 2 then rarity = "Uncommon" end
			if rarity == 3 then rarity = "Rare" end
			if rarity == 4 then rarity = "Legendary" end
			G.E_MANAGER:add_event(Event({
				func = function()
					SMODS.add_card({
						set = "Joker",
						rarity = HNDS.get_next_rarity(rarity)
					})
					SMODS.destroy_cards(joker)
					return true
				end
			}))
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
		local available = {}
		for _, c in ipairs(G.jokers.cards) do
			if not SMODS.is_eternal(c, card) then available[#available + 1] = c end
		end
		if #available > 0 then
			local joker = pseudorandom_element(available)
			local rarity = HNDS.get_next_rarity(joker.config.center.rarity)
			G.E_MANAGER:add_event(Event({
				func = function()
					SMODS.add_card({
						set = "Joker",
						rarity = rarity
					})
					SMODS.destroy_cards(joker)
					return true
				end
			}))
		end
	end,
	demicoloncompat = true,
})
