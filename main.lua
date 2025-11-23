HNDS = {}

--[[---------------------------
Config tab
--]]
---------------------------
HD = SMODS.current_mod
hnds_config = SMODS.current_mod.config

SMODS.current_mod.config_tab = function()
	return {
		n = G.UIT.ROOT,
		config = {
			align = "tm",
			padding = 0.2,
			minw = 8,
			minh = 2,
			colour = G.C.BLACK,
			r = 0.1,
			hover = true,
			shadow = true,
			emboss = 0.05,
		},
		nodes = {
			{
				n = G.UIT.R,
				config = { padding = 0, align = "cm", minh = 0.1 },
				nodes = {
					{
						n = G.UIT.C,
						config = { align = "c", padding = 0, minh = 0.1 },
						nodes = {
							{
								n = G.UIT.R,
								config = { padding = 0, align = "cm", minh = 0 },
								nodes = {
									{
										n = G.UIT.T,
										config = {
											text = "Enable Stone Ocean hand",
											scale = 0.45,
											colour = G.C.UI.TEXT_LIGHT,
										},
									},
								},
							},
							{
								n = G.UIT.R,
								config = { padding = 0, align = "cm", minh = 0 },
								nodes = {
									{
										n = G.UIT.T,
										config = { text = "Requires restart", scale = 0.35, colour = G.C.JOKER_GREY },
									},
								},
							},
						},
					},
					{
						n = G.UIT.C,
						config = { align = "cl", padding = 0.05 },
						nodes = {
							create_toggle({
								col = true,
								label = "",
								scale = 1,
								w = 0,
								shadow = true,
								ref_table = hnds_config,
								ref_value = "enableStoneOcean",
							}),
						},
					},
				},
			},
			{
				n = G.UIT.R,
				config = { padding = 0, align = "cm", minh = 0.1 },
				nodes = {
					{
						n = G.UIT.C,
						config = { align = "c", padding = 0, minh = 0.1 },
						nodes = {
							{
								n = G.UIT.R,
								config = { padding = 0, align = "cm", minh = 0 },
								nodes = {
									{
										n = G.UIT.T,
										config = {
											text = "Enable Vintage edition",
											scale = 0.45,
											colour = G.C.UI.TEXT_LIGHT,
										},
									},
								},
							},
							{
								n = G.UIT.R,
								config = { padding = 0, align = "cm", minh = 0 },
								nodes = {
									{
										n = G.UIT.T,
										config = { text = "Requires restart", scale = 0.35, colour = G.C.JOKER_GREY },
									},
								},
							},
						},
					},
					{
						n = G.UIT.C,
						config = { align = "cl", padding = 0.05 },
						nodes = {
							create_toggle({
								col = true,
								label = "",
								scale = 1,
								w = 0,
								shadow = true,
								ref_table = hnds_config,
								ref_value = "enableVintageEdition",
							}),
						},
					},
				},
			},
			{
				n = G.UIT.R,
				config = { padding = 0, align = "cm", minh = 0.1 },
				nodes = {
					{
						n = G.UIT.C,
						config = { align = "c", padding = 0, minh = 0.1 },
						nodes = {
							{
								n = G.UIT.R,
								config = { padding = 0, align = "cm", minh = 0 },
								nodes = {
									{
										n = G.UIT.T,
										config = {
											text = "Enable Magic/Ultra Spectral packs spawning",
											scale = 0.45,
											colour = G.C.UI.TEXT_LIGHT,
										},
									},
								},
							},
						},
					},
					{
						n = G.UIT.C,
						config = { align = "cl", padding = 0.05 },
						nodes = {
							create_toggle({
								col = true,
								label = "",
								scale = 1,
								w = 0,
								shadow = true,
								ref_table = hnds_config,
								ref_value = "enablePackSpawning",
							}),
						},
					},
				},
			},
		},
	}
end

SMODS.current_mod.calculate = function(self, context)
	if context.individual and SMODS.has_enhancement(context.other_card, "m_stone") then
		G.GAME.ante_stones_scored = G.GAME.ante_stones_scored + 1
	end
	if context.starting_shop and G.GAME.hnds_crystal_queued then
		G.E_MANAGER:add_event(Event({
			func = function()
				local booster = SMODS.create_card { key = 'p_hnds_spectral_ultra', area = G.play }
				booster.T.x = G.play.T.x + G.play.T.w / 2 - G.CARD_W * 1.27 / 2
				booster.T.y = G.play.T.y + G.play.T.h / 2 - G.CARD_H * 1.27 / 2
				booster.T.w = G.CARD_W * 1.27
				booster.T.h = G.CARD_H * 1.27
				booster.cost = 0
				booster.from_tag = true
				G.FUNCS.use_card({ config = { ref_table = booster } })
				booster:start_materialize()
				return true
			end
		}))
		G.GAME.hnds_crystal_queued = nil
	end
	if context.open_booster and G.GAME.art_queue > 0 then
		G.E_MANAGER:add_event(Event({
			func = function()
				SMODS.add_card({
					area = G.pack_cards,
					key = "j_hnds_art",
					no_edition = true,
				})
				return true
			end
		}))
		G.GAME.art_queue = G.GAME.art_queue - 1
	end
	if context.after then
		reset_arthur()
	end
	if context.buying_card then
		G.GAME.hnds_fregoli_copy = context.card.sort_id
	end
	if context.card_added then
		G.GAME.hnds_dna_tag_copy = context.card.sort_id
	end
end

SMODS.current_mod.optional_features = {
	retrigger_joker = true
}

--[[---------------------------
Script names
--]]
---------------------------

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
			"dark_humor",
			"dark_idol",
			"supersuit",
			"perfectionist",
			"bizzare_joker",
			"fregoli",
			"handsome",
			"ms_fortune",
			"last_laugh",
			"occultist",
			"stone_mask",
			"meme",
			"angry_mob",
			"digital_circus",
			"energized",
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
		 },
		directory = "tags/",
	},
	stakes = {
		list = {
			"platinum",
		},
		directory = "stakes/"
	}
}

if hnds_config.enableStoneOcean then
	table.insert(files.poker_hands.list, "stone_ocean")
end

--[[---------------------------
Atlases and other resources
--]]
---------------------------

SMODS.Gradient({
    key = "SEAL_EDITION",
    colours = { G.C.RED, G.C.BLUE, G.C.GOLD, G.C.PURPLE },
    cycle = 7.5,
})

G.C.SEAL_EDITION = SMODS.Gradients.hnds_SEAL_EDITION

SMODS.Sound({
	key = "madnesscolor",
	path = "madnesscolor.ogg",
})

SMODS.Sound({
	key = "vintage",
	path = "vintage.ogg",
})

SMODS.Atlas({
	key = "modicon",
	path = "hd_icon.png",
	px = 32,
	py = 32,
})

SMODS.Atlas({
	key = "HDtags",
	path = "HDtags.png",
	px = 34,
	py = 34,
})

SMODS.Atlas({
	key = "Jokers",   --atlas key
	path = "Jokers.png", --atlas' path in (yourMod)/assets/1x or (yourMod)/assets/2x
	px = 71,          --width of one card
	py = 95,          -- height of one card
})

SMODS.Atlas({
	key = "Consumables", --atlas key
	path = "THD.png", --atlas' path in (yourMod)/assets/1x or (yourMod)/assets/2x
	px = 71,          --width of one card
	py = 95,          -- height of one card
})

SMODS.Atlas({
	key = "Vouchers", --atlas key
	path = "VHD.png", --atlas' path in (yourMod)/assets/1x or (yourMod)/assets/2x
	px = 71,       --width of one card
	py = 95,       -- height of one card
})

SMODS.Atlas({
	key = "Extras", --atlas key
	path = "EHD.png", --atlas' path in (yourMod)/assets/1x or (yourMod)/assets/2x
	px = 71,       --width of one card
	py = 95,       -- height of one card
})

SMODS.Atlas({
	key = "Stakes",
	path = "HDstakes.png",
	px = 29,
	py = 29,
})

SMODS.Atlas({
	key = "Stickers",
	path = "HDstickers.png",
	px = 71,
	py = 95,
})

--[[---------------------------
Utility functions
--]]
---------------------------

SMODS.ObjectType({ --vanilla foods, modded foods are added in their joker def
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

local _init_game_object = Game.init_game_object
function Game:init_game_object()
	local ret = _init_game_object(self)
	ret.hnds_booster_choice_mod = 0 --Booster pack choice
	return ret
end

--[[---------------------------
Load files
--]]
---------------------------

local function load_files(set)
	for i = 1, #files[set].list do
		if files[set].list[i] then
			assert(SMODS.load_file(files[set].directory .. files[set].list[i] .. ".lua"))()
		end
	end
end

for key, value in pairs(files) do
	load_files(key)
end
assert(SMODS.load_file("lib/hooks.lua"))()
assert(SMODS.load_file("lib/utils.lua"))()
