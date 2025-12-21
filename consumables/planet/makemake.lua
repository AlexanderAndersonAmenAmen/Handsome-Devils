if hnds_config.enableStoneOcean then
	SMODS.Consumable({
		object_type = "Consumable",
		set = "Planet",
		name = "Makemake",
		key = "makemake",
		config = { hand_type = "hnds_stone_ocean", softlock = true },
		pos = { x = 4, y = 1 },
		order = 6,
		cost = 4,
		atlas = "Consumables",
		unlocked = true,
		discovered = false,
		set_card_type_badge = function(self, card, badges)
			badges[1] = create_badge("Dwarf Planet", get_type_colour(self or card.config, card), nil, 1.2)
		end,
		loc_vars = function(self, info_queue, card)
			return {
				vars = {
					G.GAME.hands[card.ability.hand_type].level,
					localize(card.ability.hand_type, "poker_hands"),
					G.GAME.hands[card.ability.hand_type].l_chips
						+ (G.GAME.ante_stones_scored or 0) * G.GAME.hands[card.ability.hand_type].l_chips_scaling,
					G.GAME.hands[card.ability.hand_type].l_chips_scaling,
					G.GAME.ante_stones_scored or 0,
					colours = {
						(
							G.GAME.hands[card.ability.hand_type].level == 1 and G.C.UI.TEXT_DARK
							or G.C.HAND_LEVELS[math.min(7, G.GAME.hands[card.ability.hand_type].level)]
						),
					},
				},
			}
		end,
		use = function(self, card, area, copier)
			SMODS.upgrade_poker_hands{
				hands = card.ability.hand_type,
				parameters = { "chips" },
				level_up = true,
				func = function (current, base, parameter)
					return current + G.GAME.hands[card.ability.hand_type].l_chips + (G.GAME.ante_stones_scored or 0) * G.GAME.hands[card.ability.hand_type].l_chips_scaling
				end
			}
		end,
		force_use = function(self, card, area)
			card:use_consumeable(area)
		end,
		demicoloncompat = true,
		bulk_use = function (self, card, area, copier, number)
			SMODS.upgrade_poker_hands{
				hands = card.ability.hand_type,
				parameters = { "chips" },
				level_up = number,
				func = function (current, base, parameter)
					return current + (G.GAME.hands[card.ability.hand_type].l_chips + (G.GAME.ante_stones_scored or 0) * G.GAME.hands[card.ability.hand_type].l_chips_scaling) * number
				end
			}
		end
	})
end
