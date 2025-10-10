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
		},
	}
end

SMODS.current_mod.reset_game_globals = function(run_start)
	if run_start then
		G.GAME.ante_stones_scored = 0
	end
	G.GAME.green_seal_draws = {}
	reset_supersuit_card()

	-- The suit changes every round, so we use reset_game_globals to choose a suit.
	G.GAME.current_round.dark_idol = { suit = 'Spades', rank = 'Ace' }
	local valid_dark_idol_cards = {}
	for _, v in ipairs(G.playing_cards) do
		if not SMODS.has_no_suit(v) and not SMODS.has_no_rank(v) then -- Abstracted enhancement check for jokers being able to give cards additional enhancements
			valid_dark_idol_cards[#valid_dark_idol_cards + 1] = v
		end
	end
	if valid_dark_idol_cards[1] then
		local dark_idol_card = pseudorandom_element(valid_dark_idol_cards,
			pseudoseed('dark_idol' .. G.GAME.round_resets.ante))
		G.GAME.current_round.dark_idol.suit = dark_idol_card.base.suit
		G.GAME.current_round.dark_idol.rank = dark_idol_card.base.value
		G.GAME.current_round.dark_idol.id = dark_idol_card.base.id
	end
end

SMODS.current_mod.calculate = function(self, context)
	if context.drawing_cards and #G.GAME.green_seal_draws > 0 then --green seal effect
		G.E_MANAGER:add_event(Event({
			blockable = true,
			func = function()
				for _, card in ipairs(G.GAME.green_seal_draws) do
					if card.area == G.deck and card.config then
						draw_card(G.deck, G.hand, nil, "up", true, card)
					end
				end
				G.GAME.green_seal_draws = {}
				save_run()
				return true
			end
		}))
	end
	if context.individual and SMODS.has_enhancement(context.other_card, "m_stone") then
		G.GAME.ante_stones_scored = G.GAME.ante_stones_scored + 1
	end
end

--[[---------------------------
Script names
--]]
---------------------------

local files = {
	jokers = {
		list = {
			--You can rearrange the joker order in the collection by changing the order here
			"coffee_break",
			"jackpot",
			"balloons",
			"banana_split",
			"head_of_medusa",
			"pot_of_greed",
			"jokestone",
			"color_of_madness",
			"deep_pockets",
			"seismic_activity",
			"occultist",
			"stone_mask",
			"meme",
			"digital_circus",
			"jokes_aside",
			"ms_fortune",
			"dark_humor",
			"dark_idol",
			"supersuit",
			"perfectionist",
			"krusty",
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
			"exchange",
			"cycle",
			"possess",
			"petrify",
			"dream",
			"gateway",
			"collision",
		},
		directory = "consumables/spectral/",
	},
	vouchers = {
		list = {
			"tag_hunter",
			"hashtag_skip",
			"beginners_luck",
			"rigged",
			"premium",
			"top_shelf",
			"extra_filling",
			"wholesale",
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
			"antimatter",
		},
		directory = "enhancements/",
	},
	decks = {
		list = {
			"premiumdeck",
		},
		directory = "decks/",
	},
}

if hnds_config.enableStoneOcean then
	table.insert(files.poker_hands.list, "stone_ocean")
end

--[[---------------------------
Atlases and other resources
--]]
---------------------------

SMODS.Sound({
	key = "madnesscolor",
	path = "madnesscolor.ogg",
})

SMODS.Atlas({
	key = "modicon",
	path = "hd_icon.png",
	px = 32,
	py = 32,
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

--[[---------------------------
Function hooks
--]]
---------------------------

local set_cost_ref = Card.set_cost
function Card.set_cost(self)
	set_cost_ref(self)
	if self.config.center.key == "j_hnds_coffee_break" then
		self.sell_cost = 0
	end
	if G.GAME.selected_back and G.GAME.selected_back.effect.center.key == "b_hnds_premiumdeck" and self.config.center.set == "Joker" then
		self.cost = math.floor(self.cost + G.GAME.round_resets.ante)
	end
end

local old_card_ui = generate_card_ui
function generate_card_ui(_c, full_UI_table, specific_vars, card_type, badges, hide_desc, main_start, main_end, card)
	if _c.set == "Joker" and _c.key == "j_hnds_banana_split" then
		if card.edition and card.edition.negative then
			main_end = {}
			localize({ type = "other", key = "remove_negative", nodes = main_end, vars = {} })
			main_end = main_end[1]
		end
	end

	old_ret = old_card_ui(_c, full_UI_table, specific_vars, card_type, badges, hide_desc, main_start, main_end, card)
	return old_ret
end

--[[---------------------------
Utility functions
--]]
---------------------------

function reset_supersuit_card()
	local supersuit_suits = {}
	G.GAME.current_round.supersuit_card = G.GAME.current_round.supersuit_card or {}
	for k, suit in pairs(SMODS.Suits) do
		if
			k ~= G.GAME.current_round.supersuit_card.suit
			and (type(suit.in_pool) ~= "function" or suit:in_pool({ rank = "" }))
		then
			supersuit_suits[#supersuit_suits + 1] = k
		end
	end
	local supersuit_card = pseudorandom_element(supersuit_suits, pseudoseed("sup" .. G.GAME.round_resets.ante))
	G.GAME.current_round.supersuit_card.suit = supersuit_card
end

---Gets the number of unique suits in a provided scoring hand - code from Paperback, try it if you haven't!
function HNDS.get_unique_suits(scoring_hand, bypass_debuff, flush_calc)
	-- Set each suit's count to 0
	local suits = {}

	for k, _ in pairs(SMODS.Suits) do
		suits[k] = 0
	end

	-- First we cover all the non Wild Cards in the hand
	for _, card in ipairs(scoring_hand) do
		if not SMODS.has_any_suit(card) then
			for suit, count in pairs(suits) do
				if card:is_suit(suit, bypass_debuff, flush_calc) and count == 0 then
					suits[suit] = count + 1
					break
				end
			end
		end
	end

	-- Then we cover Wild Cards, filling the missing suits
	for _, card in ipairs(scoring_hand) do
		if SMODS.has_any_suit(card) then
			for suit, count in pairs(suits) do
				if card:is_suit(suit, bypass_debuff, flush_calc) and count == 0 then
					suits[suit] = count + 1
					break
				end
			end
		end
	end

	-- Count the amount of suits that were found
	local num_suits = 0

	for _, v in pairs(suits) do
		if v > 0 then
			num_suits = num_suits + 1
		end
	end

	return num_suits
end

---Gets a pseudorandom tag from the Tag pool - Also from Paperback. Go play it!!!!!
function HNDS.poll_tag(seed, options, exclusions)
	-- This part is basically a copy of how the base game does it
	-- Look at get_next_tag_key in common_events.lua
	local pool = options or get_current_pool("Tag")
	if exclusions then
		for excluded_index = 1, #exclusions do
			for pool_index = 1, #pool do
				if exclusions[excluded_index] == pool[pool_index] then
					table.remove(pool, pool_index)
					break
				end
			end
		end
	end
	local tag_key = pseudorandom_element(pool, pseudoseed(seed))

	while tag_key == "UNAVAILABLE" do
		tag_key = pseudorandom_element(pool, pseudoseed(seed))
	end

	local tag = Tag(tag_key)

	-- The way the hand for an orbital tag in the base game is selected could cause issues
	-- with mods that modify blinds, so we randomly pick one from all visible hands
	if tag_key == "tag_orbital" then
		local available_hands = {}

		for k, hand in pairs(G.GAME.hands) do
			if hand.visible then
				available_hands[#available_hands + 1] = k
			end
		end

		tag.ability.orbital_hand = pseudorandom_element(available_hands, pseudoseed(seed .. "_orbital"))
	end

	return tag
end

--For cross-mod compatibility with Maximus
--Use this function when adding to a joker's value
if not Card.scale_value then
	function Card:scale_value(applied_value, scalar)
		return applied_value + scalar
	end
end

function HNDS.dyn_level_up(card, hand, level, chips, mult, instant)
	level = level or 1
	chips = chips or G.GAME.hands[hand].l_chips * level
	mult = mult or G.GAME.hands[hand].l_mult * level
	G.GAME.hands[hand].level = G.GAME.hands[hand].level + level
	if not instant then
		G.E_MANAGER:add_event(Event({
			trigger = "after",
			delay = 0.2,
			func = function()
				play_sound("tarot1")
				if card then
					card:juice_up(0.8, 0.5)
				end
				G.TAROT_INTERRUPT_PULSE = true
				return true
			end,
		}))
		update_hand_text({ delay = 0 }, { mult = G.GAME.hands[hand].mult, StatusText = true })
		G.E_MANAGER:add_event(Event({
			trigger = "after",
			delay = 0.9,
			func = function()
				play_sound("tarot1")
				if card then
					card:juice_up(0.8, 0.5)
				end
				return true
			end,
		}))
		update_hand_text({ delay = 0 }, { chips = G.GAME.hands[hand].chips, StatusText = true })
		G.E_MANAGER:add_event(Event({
			trigger = "after",
			delay = 0.9,
			func = function()
				play_sound("tarot1")
				if card then
					card:juice_up(0.8, 0.5)
				end
				G.TAROT_INTERRUPT_PULSE = nil
				return true
			end,
		}))
		update_hand_text(
			{ sound = "button", volume = 0.7, pitch = 0.9, delay = 0 },
			{ level = G.GAME.hands[hand].level }
		)
		delay(1.3)
	end
	G.E_MANAGER:add_event(Event({
		trigger = "immediate",
		func = function()
			check_for_unlock({ type = "upgrade_hand", hand = hand, level = G.GAME.hands[hand].level })
			return true
		end,
	}))
end

--Return a list of all the jokers that create jokers in shop
function HNDS.get_shop_joker_tags()
	local tag_list = {
		"tag_foil",
		"tag_holo",
		"tag_polychrome",
		"tag_negative",
		"tag_rare",
		"tag_uncommon",
		"tag_buffoon",
	}

	--Add tags from other mods
	if next(SMODS.find_mod("paperback")) then --paperback tags
		table.insert(tag_list, "tag_paperback_dichrome")
	end

	if next(SMODS.find_mod("Pokermon")) then --pokermon tags
		table.insert(tag_list, "tag_poke_shiny_tag")
		table.insert(tag_list, "tag_poke_stage_one_tag")
		table.insert(tag_list, "tag_poke_safari_tag")
	end

	if next(SMODS.find_mod("Cryptid")) then --cryptid tags (why are there so fucking many)
		table.insert(tag_list, "tag_cry_epic")
		table.insert(tag_list, "tag_cry_glitched")
		table.insert(tag_list, "tag_cry_mosaic")
		table.insert(tag_list, "tag_cry_oversat")
		table.insert(tag_list, "tag_cry_glass")
		table.insert(tag_list, "tag_cry_gold")
		table.insert(tag_list, "tag_cry_blur")
		table.insert(tag_list, "tag_cry_astral")
		table.insert(tag_list, "tag_cry_m")
		table.insert(tag_list, "tag_cry_double_m")
		table.insert(tag_list, "tag_cry_gambler")
		table.insert(tag_list, "tag_cry_bettertop_up")
		table.insert(tag_list, "tag_cry_gourmand")
		table.insert(tag_list, "tag_cry_schematic")
		table.insert(tag_list, "tag_cry_banana")
		table.insert(tag_list, "tag_cry_loss")
	end

	if next(SMODS.find_mod("entr")) then --entropy tags
		table.insert(tag_list, "tag_entr_sunny")
		table.insert(tag_list, "tag_entr_solar")
		table.insert(tag_list, "tag_entr_fractured")
		table.insert(tag_list, "tag_entr_freaky")
		table.insert(tag_list, "tag_entr_neon")
		table.insert(tag_list, "tag_entr_lowres")
		table.insert(tag_list, "tag_entr_kaleidoscopic")
	end

	if next(SMODS.find_mod("GARBPACK")) then --garbshit tags
		table.insert(tag_list, "tag_garb_carnival")
	end

	if next(SMODS.find_mod("ortalab")) then --ortalab patches
		table.insert(tag_list, "tag_ortalab_common")
		table.insert(tag_list, "tag_ortalab_anaglyphic")
		table.insert(tag_list, "tag_ortalab_fluorescent")
		table.insert(tag_list, "tag_ortalab_greyscale")
		table.insert(tag_list, "tag_ortalab_overexposed")
		table.insert(tag_list, "tag_ortalab_soul")
	end

	if next(SMODS.find_mod("MoreFluff")) then --morefluff tags
		table.insert(tag_list, "tag_mf_moddedpack")
		if Entropy then
			table.insert(tag_list, "tag_mf_absolute")
		end
	end

	if next(SMODS.find_mod("Bunco")) then --bunco tags
		table.insert(tag_list, "tag_bunc_glitter")
		table.insert(tag_list, "tag_bunc_fuorescent")
	end

	if next(SMODS.find_mod("JoyousSpring")) then --joyousspring tags
		table.insert(tag_list, "tag_joy_monster")
	end

	if next(SMODS.find_mod("allinjest")) then --all in jest
		table.insert(tag_list, "tag_aij_soulbound")
		table.insert(tag_list, "tag_aij_glimmer")
		table.insert(tag_list, "tag_aij_stellar")
	end

	if next(SMODS.find_mod("Yahimod")) then --yahimod
		table.insert(tag_list, "tag_yahimod_tag_yahimodrare")
	end

	if next(SMODS.find_mod("Bakery")) then
		table.insert(tag_list, "tag_Bakery_RetriggerTag")
	end

	if next(SMODS.find_mod("RevosVault")) then
		table.insert(tag_list, "tag_crv_pst")
		table.insert(tag_list, "tag_crv_reintag")
	end

	return tag_list
end

HNDS.rarity_cycle = {
	1,
	2,
	3,
	"val_renowned",
	"cry_epic",
	4,
	"entr_reverse_legendary",
	"valk_exquisite",
	"cry_exotic", --maybe a bit unbalanced youre playing cryptid already anyway so :shrug:
	"entr_entropic",
	"valk_prestigious",
	"ast_empyrean"
}

HNDS.get_next_rarity = function(rarity_key)
	local found = false
	for i = 1, #HNDS.rarity_cycle do
		if HNDS.rarity_cycle[i] == rarity_key then                   --check to find the current rarity, will attempt to find the next existing rarity in the table after
			found = true
		elseif found and G.P_JOKER_RARITY_POOLS[HNDS.rarity_cycle[i]] then --check if the current rarity has been found and the table rarity actually exists
			local rarity = HNDS.rarity_cycle[i]
			if rarity == 1 then rarity = "Common" end
			if rarity == 2 then rarity = "Uncommon" end
			if rarity == 3 then rarity = "Rare" end
			if rarity == 4 then rarity = "Legendary" end
			return rarity
		end
	end
	return 1 --default to common when no upgrade found
end

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
