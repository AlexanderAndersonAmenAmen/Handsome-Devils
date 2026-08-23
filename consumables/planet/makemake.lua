if hnds_config.enableStoneOcean then
	SMODS.Consumable({
		object_type = "Consumable",
		set = "Planet",
		name = "Makemake",
		key = "makemake",
		config = { hand_type = "hnds_stone_ocean", softlock = true },
		pos = { x = 4, y = 1 },
		order = 6,
		cost = 3,
		atlas = "Consumables",
		unlocked = true,
		discovered = false,
		set_card_type_badge = function(self, card, badges)
			badges[1] = create_badge("Dwarf Planet", get_type_colour(self or card.config, card), nil, 1.2)
		end,
		loc_vars = function(self, info_queue, card)
			local hand_type = card and card.ability and card.ability.hand_type or "hnds_stone_ocean"
			local game = G and G.GAME
			local hand = game and game.hands and game.hands[hand_type] or {}
			local level = tonumber(hand.level) or 1
			local level_chips = tonumber(hand.l_chips) or 50
			local scaling = tonumber(hand.l_chips_scaling) or 5
			local stones = tonumber(game and game.ante_stones_scored) or 0
			local level_colour = (G and G.C and level == 1 and G.C.UI and G.C.UI.TEXT_DARK)
				or (G and G.C and G.C.HAND_LEVELS and G.C.HAND_LEVELS[math.min(7, level)])
			return {
				vars = {
					level,
					localize(hand_type, "poker_hands"),
					level_chips + stones * scaling,
					scaling,
					stones,
					colours = { level_colour },
				},
			}
		end,
		use = function(self, card, area, copier)
			SMODS.upgrade_poker_hands{
				from = card,
				hands = card.ability.hand_type,
				parameters = { "chips" },
				level_up = true,
				func = function (base, hand, param)
					return base + G.GAME.hands[hand]["l_"..param] + (G.GAME.ante_stones_scored or 0) * (G.GAME.hands[hand].l_chips_scaling or 5)
				end
			}
		end,
		force_use = function(self, card, area)
			self:use(card, area)
		end,
		demicoloncompat = true,
		bulk_use = function (self, card, area, copier, number)
			SMODS.upgrade_poker_hands{
				from = card,
				hands = card.ability.hand_type,
				parameters = { "chips" },
				level_up = number,
				func = function (base, hand, param)
					return base + (G.GAME.hands[hand]["l_"..param] + (G.GAME.ante_stones_scored or 0) * (G.GAME.hands[hand].l_chips_scaling or 5)) * number
				end
			}
		end
	})
end
