if hnds_config.enableStoneOcean then
	SMODS.Consumable {
		object_type = "Consumable",
		set = "Planet",
		name = "Makemake",
		key = "makemake",
		config = { hand_type = 'hnds_stone_ocean', softlock = true },
		pos = { x = 4, y = 1 },
		order = 6,
		cost = 4,
		atlas = "Consumables",
		unlocked = true,
		discovered = false,
		set_card_type_badge = function(self, card, badges)
			badges[1] = create_badge("Dwarf Planet", get_type_colour(self or card.config, card), nil, 1.2)
		end

	}
end