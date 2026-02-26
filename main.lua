HNDS = {}
----------------------------
-- Config tab
----------------------------
HD = SMODS.current_mod
hnds_config = SMODS.current_mod.config
-- Helper: builds a single toggle row for the config tab.
-- `label` is the main text, `config_key` is the key in hnds_config,
-- `subtitle` is optional small grey text below the label (e.g. "Requires restart").
local function config_toggle_row(label, config_key, subtitle)
	local label_nodes = {
		{
			n = G.UIT.R,
			config = { padding = 0, align = "cm", minh = 0 },
			nodes = {
				{ n = G.UIT.T, config = { text = label, scale = 0.45, colour = G.C.UI.TEXT_LIGHT } },
			},
		},
	}
	if subtitle then
		label_nodes[#label_nodes + 1] = {
			n = G.UIT.R,
			config = { padding = 0, align = "cm", minh = 0 },
			nodes = {
				{ n = G.UIT.T, config = { text = subtitle, scale = 0.35, colour = G.C.JOKER_GREY } },
			},
		}
	end
	return {
		n = G.UIT.R,
		config = { padding = 0, align = "cm", minh = 0.1 },
		nodes = {
			{ n = G.UIT.C, config = { align = "c", padding = 0, minh = 0.1 }, nodes = label_nodes },
			{
				n = G.UIT.C,
				config = { align = "cl", padding = 0.05 },
				nodes = {
					create_toggle({
						col = true, label = "", scale = 1, w = 0,
						shadow = true, ref_table = hnds_config, ref_value = config_key,
					}),
				},
			},
		},
	}
end

SMODS.current_mod.config_tab = function()
	return {
		n = G.UIT.ROOT,
		config = {
			align = "tm", padding = 0.2, minw = 8, minh = 2,
			colour = G.C.BLACK, r = 0.1, hover = true, shadow = true, emboss = 0.05,
		},
		nodes = {
			config_toggle_row("Enable Stone Ocean hand",           "enableStoneOcean",          "Requires restart"),
			config_toggle_row("Enable Vintage edition",            "enableVintageEdition",      "Requires restart"),
			config_toggle_row("Enable Ultra Spectral packs spawning", "enablePackSpawning"),
			config_toggle_row("Enable Magic packs spawning",       "enableMagicPackSpawning"),
			config_toggle_row("Enable Cursed packs spawning",      "enableCursedPackSpawning"),
		},
	}
end

-- Helper: spawns a free booster pack at the center of the play area.
-- Used by tags that queue packs to open at the start of the next shop.
local function spawn_queued_booster(pack_key, pre_open_func)
	G.E_MANAGER:add_event(Event({
		func = function()
			local booster = SMODS.create_card { key = pack_key, area = G.play }
			booster.T.x = G.play.T.x + G.play.T.w / 2 - G.CARD_W * 1.27 / 2
			booster.T.y = G.play.T.y + G.play.T.h / 2 - G.CARD_H * 1.27 / 2
			booster.T.w = G.CARD_W * 1.27
			booster.T.h = G.CARD_H * 1.27
			booster.cost = 0
			booster.from_tag = true
			if pre_open_func then pre_open_func(booster) end
			G.FUNCS.use_card({ config = { ref_table = booster } })
			booster:start_materialize()
			return true
		end
	}))
end

-- Mod-level calculate: handles global context events that aren't tied to a specific card.
SMODS.current_mod.calculate = function(self, context)
	-- Track stone cards scored this ante (used by Stone Ocean hand)
	if context.individual and SMODS.has_enhancement(context.other_card, "m_stone") then
		G.GAME.ante_stones_scored = G.GAME.ante_stones_scored + 1
	end
	-- Spawn queued booster packs at the start of each shop
	if context.starting_shop and G.GAME.hnds_crystal_queued then
		spawn_queued_booster('p_hnds_spectral_ultra')
		G.GAME.hnds_crystal_queued = nil
	end
	if context.starting_shop and G.GAME.hnds_cursed_pack_queued then
		spawn_queued_booster('p_hnds_cursed_pack', function(booster)
			-- Force the player to pick a card unless all joker slots are filled with eternals
			if not (HNDS and HNDS.joker_slots_full_of_unmovables and HNDS.joker_slots_full_of_unmovables()) then
				G.GAME.hnds_forced_pack_no_skip = true
			end
		end)
		G.GAME.hnds_cursed_pack_queued = nil
	end
	-- Arthur Joker: inject an Art card into any opened booster pack
	if context.open_booster and G.GAME.art_queue > 0 then
		G.E_MANAGER:add_event(Event({
			func = function()
				SMODS.add_card({ area = G.pack_cards, key = "j_hnds_art", no_edition = true })
				return true
			end
		}))
		G.GAME.art_queue = G.GAME.art_queue - 1
	end
	-- Arthur Joker: reset state after each hand is played
	if context.after then
		reset_arthur()
	end
	-- Fregoli Joker: track the last purchased card's sort_id
	if context.buying_card then
		G.GAME.hnds_fregoli_copy = context.card.sort_id
	end
	-- DNA Tag: track the last added card's sort_id for copying
	if context.card_added then
		G.GAME.hnds_dna_tag_copy = context.card.sort_id
	end
end

SMODS.current_mod.optional_features = {
	retrigger_joker = true
}

----------------------------
-- Content file registry
-- The order of jokers here determines their order in the collection.
----------------------------

local files = {
	jokers = {
		list = {
			--You can rearrange the joker order in the collection by changing the order here
			"balloons",
			"coffee_break",
			"pot_of_greed",
			"jokestone",
			"public_nuisance",
			"walking_joke",
			"blackjack",
			"jackpot",
			"banana_split",
			"head_of_medusa",
			"color_of_madness",
			"deep_pockets",
			"seismic_activity",
			"jokes_aside",
			"creepy",
			"dark_humor",
			"dark_idol",
			"supersuit",
			"perfectionist",
			"bizzare_joker",
			"most_wanted",
			"clown_devil",
			"jester_in_yellow",
			"excommunicado",
			"wait_what",
			"fregoli",
			"handsome",
			"ms_fortune",
			"last_laugh",
			"occultist",
			"stone_mask",
			"jigsaw_joker",
			"dynamic_duos",
			"meme",
			"angry_mob",
			"digital_circus",
			"energized",
			"one_punchline_man",
			"imposter",
			"contagion",
			"pennywise",
			"art",
			"krusty",
			"sarmenti",
			"arthur",
		},
		directory = "jokers/",
	},
	seals = {
		list = {
			"black_seal",
			"spectralseal"
		},
		directory = "seals/",
	},
	spectrals = {
		list = {
			"abyss",
			"possess",
			"exchange",
			"cycle",
			"petrify",
			"gateway",
			"collision",
			"dream",
			"spectrum",
		},
		directory = "consumables/spectral/",
	},
	vouchers = {
		list = {
			"tag_hunter",
			"hashtag_skip",
			"premium",
			"top_shelf",
			"stuffed",
			"wholesale",
			"soaked",
			"beyond",
		},
		directory = "vouchers/",
	},
	planets = {
		list = {
			"makemake",
		},
		directory = "consumables/planet/",
	},
	poker_hands = {
		list = {},
		directory = "poker_hands/",
	},
	enhancements = {
		list = {
			"obsidian",
			"aberrant",
		},
		directory = "enhancements/",
	},
	decks = {
		list = {
			"premiumdeck",
			"crystal",
			"conjuring",
			"cursed",
			"circus",
			"ol_reliable",
		},
		directory = "decks/",
	},
	editions = {
		list = { "vintage" },
		directory = "editions/",
	},
	tags = {
		list = { 
			"vintage_tag",
			"mystery_tag",
			"magic_tag",
			"dna_tag",
			"cursed_tag",
		 },
		directory = "tags/",
	},
	stakes = {
		list = {
			"platinum",
			"blood"
		},
		directory = "stakes/"
	},
	challenges = {
		list = {
			"devils_round",
			"draw_2_cards",
			"dark_ritual",
			"the_circus",
			"gambling_opportunity",
		},
		directory = "challenges/"
	}
}

if hnds_config.enableStoneOcean then
	table.insert(files.poker_hands.list, "stone_ocean")
end

----------------------------
-- Atlases, colours, and sounds
----------------------------

-- Colors and editions
SMODS.Gradient({key = "SEAL_EDITION", colours = { G.C.RED, G.C.BLUE, G.C.GOLD, G.C.PURPLE }, cycle = 7.5,})
G.C.SEAL_EDITION = SMODS.Gradients.hnds_SEAL_EDITION
G.C.HNDS_CARCOSA = HEX('C9A227')
G.C.hnds_carcosa = G.C.HNDS_CARCOSA -- lowercase alias used by localization colour tags
-- Sounds
SMODS.Sound({ key = "madnesscolor", path = "madnesscolor.ogg", })
SMODS.Sound({ key = "vintage", path = "vintage.ogg", })
-- Sprites
SMODS.Atlas({ key = "modicon", path = "hd_icon.png", px = 32, py = 32, })
SMODS.Atlas({ key = "HDtags", path = "HDtags.png", px = 34, py = 34, })
SMODS.Atlas({ key = "Jokers",      path = "Jokers.png", px = 71, py = 95 })
SMODS.Atlas({ key = "Consumables", path = "THD.png",     px = 71, py = 95 })
SMODS.Atlas({ key = "Vouchers",    path = "VHD.png",     px = 71, py = 95 })
SMODS.Atlas({ key = "Extras",      path = "EHD.png",     px = 71, py = 95 })
SMODS.Atlas({ key = "Stakes", path = "HDstakes.png", px = 29, py = 29 })
SMODS.Atlas({ key = "Stickers", path = "HDstickers.png", px = 71, py = 95 })

----------------------------
-- Object types and utility functions
----------------------------

-- Food object type: vanilla food jokers. Modded foods are registered in their own joker files.
SMODS.ObjectType({
	key = "Food",
	default = "j_ice_cream",
	cards = {
		j_gros_michel = true,
		j_egg = true,
		j_ice_cream = true,
		j_cavendish = true,
		j_turtle_bean = true,
		j_diet_cola = true,
		j_popcorn = true,
		j_ramen = true,
		j_selzer = true,
	},
})

-- Imposter Joker: allows face cards (J/Q/K) to match any required rank
-- when the Imposter joker is in the player's joker slots.
HNDS.imposter_rank_match = function(card, required_id)
	if #SMODS.find_card('j_hnds_imposter') > 0 and card:get_id() >= 11 and card:get_id() <= 13 then
		return true
	end
	return card:get_id() == required_id
end

-- Extend the game object with mod-specific state variables
local _init_game_object = Game.init_game_object
function Game:init_game_object()
	local ret = _init_game_object(self)
	ret.hnds_booster_choice_mod = 0
	return ret
end

----------------------------
-- Load content and library files
----------------------------

for _, set in pairs(files) do
	for _, name in ipairs(set.list) do
		assert(SMODS.load_file(set.directory .. name .. ".lua"))()
	end
end
assert(SMODS.load_file("lib/hooks.lua"))()
assert(SMODS.load_file("lib/blind_souls.lua"))()
assert(SMODS.load_file("lib/utils.lua"))()
assert(SMODS.load_file("lib/curses.lua"))()
assert(SMODS.load_file("lib/cross_mod_compat.lua"))()
assert(SMODS.load_file("lib/challenge_rules.lua"))()
