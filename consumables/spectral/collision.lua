SMODS.Consumable({
	key = "collision",
	atlas = "Consumables",
	pos = { x = 3, y = 1 }, --this is just guessing lmao i still need the sprite
	set = "Spectral",
	config = { mod_conv = "m_hnds_aberrant", max_highlighted = 2 },
	discovered = true,
	cost = 4,
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue + 1] = G.P_CENTERS[card.ability.mod_conv]
		return {
			vars = {
				card.ability.max_highlighted,
				localize({ type = "name_text", set = "Enhanced", key = card.ability.mod_conv }),
			},
		}
	end,
})
