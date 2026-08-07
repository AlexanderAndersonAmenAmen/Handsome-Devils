HNDS = {}

-- Collection layouts for vanilla object pages.
-- The rows argument is a list of per-row card limits, not a {row, column}
-- dimension pair. Handsome Devils currently has 10 Enhancements and 13 Planets,
-- so their bounded layouts are two rows of 5 and rows of 6/7 respectively.
if SMODS.card_collection_UIBox and not HNDS._collection_layout_wrapper then
    local hnds_card_collection_UIBox = SMODS.card_collection_UIBox
    SMODS.card_collection_UIBox = function(pool, rows, args)
        local pools = G and G.P_CENTER_POOLS
        if pools then
            if pool == pools.Seal then
                rows = { 3, 3, 3 }
            elseif pool == pools.Edition then
                rows = { 3, 3, 3 }
            elseif pool == pools.Enhanced then
                rows = { 5, 5 }
            elseif pool == pools.Planet then
                rows = { 6, 7 }
            end
        end
        return hnds_card_collection_UIBox(pool, rows, args)
    end
    HNDS._collection_layout_wrapper = true
end


-- Random effects owned by Handsome Devils must not roll Vintage. Vintage stays
-- in the natural edition pool and remains available from the Vintage Tag.
function HNDS.poll_non_vintage_edition(...)
	local args = { ... }
	local unpack_fn = table.unpack or unpack
	local vintage = G and G.P_CENTERS and G.P_CENTERS.e_hnds_vintage
	if not vintage then
		if type(args[1]) == "table" and SMODS.poll_edition then
			return SMODS.poll_edition(args[1])
		end
		return poll_edition(unpack_fn(args))
	end

	local old_weight, old_in_shop = vintage.weight, vintage.in_shop
	vintage.weight, vintage.in_shop = 0, false
	local result = { pcall(function()
		if type(args[1]) == "table" and SMODS.poll_edition then
			return SMODS.poll_edition(args[1])
		end
		return poll_edition(unpack_fn(args))
	end) }
	vintage.weight, vintage.in_shop = old_weight, old_in_shop
	if not result[1] then error(result[2]) end
	table.remove(result, 1)
	return unpack_fn(result)
end

----------------------------
-- Config tab
----------------------------
HD = SMODS.current_mod
hnds_config = SMODS.current_mod.config
-- `label` is the main text, `config_key` is the key in hnds_config,
-- `subtitle` is optional small grey text below the label (e.g. "Requires restart").
local function config_toggle_row(label, config_key, subtitle)
	local label_nodes = {
		{
			n = G.UIT.R,
			config = { padding = 0, align = "l", minh = 0 },
			nodes = {
				{ n = G.UIT.T, config = { text = label, scale = 0.4, colour = G.C.UI.TEXT_LIGHT } },
			},
		},
	}
	if subtitle then
		label_nodes[#label_nodes + 1] = {
			n = G.UIT.R,
			config = { padding = 0, align = "l", minh = 0 },
			nodes = {
				{ n = G.UIT.T, config = { text = subtitle, scale = 0.32, colour = G.C.JOKER_GREY } },
			},
		}
	end
	return {
		n = G.UIT.R,
		config = { padding = 0, align = "cm", minh = 0.28 },
		nodes = {
			{
				n = G.UIT.C,
				config = { align = "l", padding = 0, minh = 0.1, minw = 6, maxw = 6 },
				nodes = label_nodes,
			},
			{
				n = G.UIT.C,
				config = { align = "c", padding = 0, minw = 1.2, maxw = 1.2 },
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
			align = "tm", padding = 0.05, minw = 8, minh = 2,
			colour = G.C.BLACK, r = 0.1, hover = true, shadow = true, emboss = 0.05,
		},
		nodes = { -- Here are the localize text variables, you can change the order here to alter the order in the config menu
			config_toggle_row(localize("hnds_config_StoneOcean"), "enableStoneOcean", localize("hnds_require_restart")),
			config_toggle_row(localize("hnds_config_vintage"), "enableVintageEdition", localize("hnds_require_restart")),
			config_toggle_row(localize("hnds_config_UltraSpec"), "enablePackSpawning"),
			config_toggle_row(localize("hnds_config_MagicPack"), "enableMagicPackSpawning"),
			config_toggle_row(localize("hnds_config_CursedPack"), "enableCursedPackSpawning"),
			config_toggle_row(localize("hnds_config_CustomSounds"), "enableCustomSounds"),
			config_toggle_row(localize("hnds_config_VanillaTweaks"), "enableVanillaTweaks", localize("hnds_require_restart")),
		},
	}
end

-- Art the Clown: add one native booster slot before the pack is built.
-- The pending state lives on the exact booster card, avoiding global/index
-- mismatches, and the queue is consumed only when Art is actually created.
local hnds_card_open = Card.open
function Card:open(...)
	local queued_art = G.GAME
		and (tonumber(G.GAME.art_queue) or 0) > 0
		and self.ability
		and self.ability.set == 'Booster'
		and not self.hnds_art_pending
	local original_size = queued_art and tonumber(self.ability.extra) or nil

	if not original_size then
		return hnds_card_open(self, ...)
	end

	local size_mod = tonumber(G.GAME.modifiers and G.GAME.modifiers.booster_size_mod) or 0
	self.hnds_art_pending = true
	self.hnds_art_target_index = math.max(1, original_size + size_mod + 1)

	-- Steamodded derives both the pack CardArea capacity and its centred width
	-- from this value, exactly as it does for the Stuffed voucher modifier.
	-- Booster cards are generated by a delayed event after Card:open returns,
	-- so this must remain increased until the consumed booster finishes opening.
	self.ability.extra = original_size + 1
	return hnds_card_open(self, ...)
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
	if HNDS.calculate_vanilla_tweaks then HNDS.calculate_vanilla_tweaks(context) end
	if HNDS.calculate_aberrant then HNDS.calculate_aberrant(context) end

	-- Spectrum is a hidden Spectral that can replace a Base card in Standard
	-- packs. Standard-pack generation may attach playing-card modifiers before
	-- the forced center is installed; strip those modifiers from Spectrum only.
	if context.modify_booster_card and context.card
		and context.card.config and context.card.config.center
		and context.card.config.center.key == "c_hnds_spectrum"
	then
		local spectrum = context.card
		if spectrum.set_edition then spectrum:set_edition(nil, true, true) end
		if spectrum.set_seal then spectrum:set_seal(nil, true, true) end
		-- A Spectrum rolled from a Base Standard-pack slot can retain the
		-- playing-card front sprite even after its center becomes Spectral.
		-- Remove that child so it renders and behaves as a consumable only.
		if spectrum.children and spectrum.children.front then
			local old_front = spectrum.children.front
			if old_front.remove then old_front:remove() end
			spectrum.children.front = nil
		end
		if spectrum.ability then
			spectrum.ability.perishable = nil
			spectrum.ability.eternal = nil
			spectrum.ability.rental = nil
			spectrum.ability.perish_tally = nil
			spectrum.ability.perma_bonus = 0
			spectrum.ability.perma_mult = 0
			spectrum.ability.perma_x_mult = 0
			spectrum.ability.perma_h_x_mult = 0
			spectrum.ability.perma_p_dollars = 0
			for _, sticker_key in ipairs((SMODS.Sticker and SMODS.Sticker.obj_buffer) or {}) do
				spectrum.ability[sticker_key] = nil
			end
		end
		spectrum.hnds_spectrum_booster_cleanup = true
	end
	local boss_stack_result = HNDS.calculate_platinum_boss_stack
		and HNDS.calculate_platinum_boss_stack(context)
		or nil

	if HNDS.track_unlock_context then HNDS.track_unlock_context(context) end

	-- Track stone cards scored this ante (used by Stone Ocean hand)
	if context.individual and SMODS.has_enhancement(context.other_card, "m_stone") then
		G.GAME.ante_stones_scored = G.GAME.ante_stones_scored + 1
	end
	-- Spawn queued booster packs at the start of each shop
	if context.starting_shop and G.GAME.hnds_crystal_queued then
		spawn_queued_booster('p_hnds_spectral_ultra')
		G.GAME.hnds_crystal_queued = nil
	end
	-- Art the Clown: make the added final slot Art itself. Because this runs
	-- inside Steamodded's normal booster creation loop, Art is centred and
	-- spaced together with every other option, including packs enlarged by
	-- Stuffed or other booster-size modifiers.
	if context.create_booster_card and context.booster
		and context.booster.hnds_art_pending
		and context.index == context.booster.hnds_art_target_index then
		context.booster.hnds_art_pending = nil
		context.booster.hnds_art_target_index = nil
		G.GAME.art_queue = math.max(0, (tonumber(G.GAME.art_queue) or 1) - 1)
		return {
			booster_create_flags = {
				key = "j_hnds_art",
				area = G.pack_cards,
				no_edition = true,
				stickers = {},
			}
		}
	end

	-- Belt-and-suspenders cleanup for the forced Art option: other generation
	-- hooks cannot leave it with an Edition or a Sticker.
	if context.modify_booster_card and context.card
		and context.card.config and context.card.config.center
		and context.card.config.center.key == "j_hnds_art" then
		context.card:set_edition(nil, true, true)
		for sticker_key, _ in pairs(SMODS.Stickers or {}) do
			context.card.ability[sticker_key] = nil
		end
	end
	-- Fregoli Joker: track the last purchased card's sort_id
	if context.buying_card then
		G.GAME.hnds_fregoli_copy = context.card.sort_id
	end
	-- DNA Tag: track the last added card's sort_id for copying
	if context.card_added then
		G.GAME.hnds_dna_tag_copy = context.card.sort_id
	end
	-- Bound: guarantee every marked, non-debuffed card is present in the
	-- opening hand. The helper guards against duplicate first_hand_drawn events.
	if context.first_hand_drawn and HNDS.draw_bound_cards then
		HNDS.draw_bound_cards()
	end

	-- Obsidian: each hand starts a fresh candidate set. Commit it during the
	-- post-scoring context, while the winning cards are still in the play area,
	-- so progress text is attached to each Obsidian card instead of the deck.
	if context.before and HNDS.reset_obsidian_hand_marks then
		HNDS.reset_obsidian_hand_marks()
	end
	if context.after and SMODS.last_hand_oneshot
		and HNDS.complete_obsidian_final_hand
	then
		HNDS.complete_obsidian_final_hand()
	end

	return boss_stack_result
end

SMODS.current_mod.optional_features = {
	retrigger_joker = true,
	object_weights = true,
	quantum_enhancements = true,
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
			"most_wanted",
			"jigsaw_joker",
			"pot_of_greed",

			"dynamic_duos",
			"wait_what",
			"dark_humor",
			"clown_devil",
			"public_nuisance",

			"banana_split",
			"supersuit",
			"jokes_aside",
			"jackpot",
		    "angry_mob",
	
		    "seismic_activity",
	        "creepy",
			"occultist",
			"ms_fortune",
			"head_of_medusa",

		    "deep_pockets",
			"color_of_madness",
			"dark_idol",
			"perfectionist",
			"handsome",
			
			"walking_joke",
			"digital_circus",
			"excommunicado",
			"meme",
			"one_punchline_man",

			"stone_mask",
			"energized",
			"last_laugh",
			"bizzare_joker",
			"jokestone",

			"jester_in_yellow",
			"demented",
			"imposter",
			"contagion",
			"fregoli",

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
			"crystal",
			"cursed",
			"premiumdeck",
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
			"cursed_tag",
			"extinction_tag"
		 },
		directory = "tags/",
	},
	stakes = {
		list = {
			"platinum",
			"blood",
			"nightmare"
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
	},
	blinds = {
		list = {
			"blind_wasted_wish",
			"blind_forbidden_fruit",
			"blind_sinful_soul",
			"blind_devil",
			"blind_perilous_pact",
		},
		directory = "blinds/"
	},
	}

if hnds_config.enableStoneOcean then
	table.insert(files.poker_hands.list, "stone_ocean")
end


----------------------------
-- Atlases, colours, and sounds
----------------------------

-- Colors and editions
SMODS.Gradient({key = "SEAL_EDITION", colours = { G.C.RED, G.C.BLUE, G.C.GOLD, G.C.PURPLE }, cycle = 7.5,})
G.C.HNDS_SEAL_EDITION = SMODS.Gradients.hnds_SEAL_EDITION --i dont see a point in doing this tbh but whatever
G.C.HNDS_CARCOSA = HEX('C9A227')
G.C.hnds_carcosa = G.C.HNDS_CARCOSA -- lowercase alias used by localization colour tags
-- Sounds
SMODS.Sound({ key = "madnesscolor", path = "madnesscolor.ogg", })
SMODS.Sound({ key = "vintage", path = "vintage.ogg", })
SMODS.Sound({ key = "jokestone", path = "Jokestone_sfx.ogg", })
SMODS.Sound({ key = "jiy_common_sfx", path = "JIY_common_sfx.ogg", })
SMODS.Sound({ key = "jiy_superrare_sfx", path = "JIY_superrare_sfx.ogg", })
SMODS.Sound({ key = "krusty_laugh", path = "krusty-the-clown-laughing-faded-in-0-5-out-1_a7FQtVJx.ogg", })
SMODS.Sound({ key = "sarmenti_common_tune1", path = "Sarmenti_common_tune1.ogg", })
SMODS.Sound({ key = "sarmenti_common_tune2", path = "Sarmenti_common_tune2.ogg", })
SMODS.Sound({ key = "sarmenti_rare_tune1", path = "Sarmenti_rare_tune1.ogg", })
SMODS.Sound({ key = "sarmenti_rare_tune2", path = "Sarmenti_rare_tune2.ogg", })
SMODS.Sound({ key = "one_punchline_man", path = "voicy-one-punch-man_Eznpw2Sl-faded-in-0-5-out-1.ogg", })
SMODS.Sound({ key = "wp_buy_inshop", path = "WP_buy_inshop.ogg", })
-- Sprites
SMODS.Atlas({ key = "HDtags", path = "HDtags.png", px = 34, py = 34, })
SMODS.Atlas({ key = "Jokers",      path = "Jokers.png", px = 71, py = 95 })
SMODS.Atlas({ key = "Consumables", path = "THD.png",     px = 71, py = 95 })
SMODS.Atlas({ key = "Vouchers",    path = "VHD.png",     px = 71, py = 95 })
SMODS.Atlas({ key = "Extras",      path = "EHD.png",     px = 71, py = 95 })
SMODS.Atlas({ key = "Stakes", path = "HDstakes.png", px = 29, py = 29 })
SMODS.Atlas({ key = "Stickers", path = "HDstickers.png", px = 71, py = 95 })
SMODS.Atlas({ key = "hnds_sleeves", path = "HDS.png", px = 73, py = 95 })
-- Inside main.lua
SMODS.Atlas {
    key = 'ante_10_atlas',
    path = 'Ante10Blinds.png',
    px = 34,         -- Width of ONE individual frame square (NOT 714!)
    py = 34,         -- Height of ONE individual frame square (NOT 170!)
    frames = 21,     -- Essential: Tells the engine there are 21 columns
    fps = 10,        -- Essential: Controls how fast the frames increment
    -- Crucial flag for blind animations:
    atlas_table = 'ANIMATION_ATLAS' 
}

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
	-- Forbidden Fruit tracks Tags that actually trigger ("pop"), not Tags
	-- merely created or held. Existing saves safely fall back to zero.
	ret.hnds_tags_popped = 0
	-- Wholesale unlock progress is deliberately per-run.
	ret.hnds_boosters_bought_run = 0
	ret.hnds_juggle_bonuses = {}
	return ret
end

----------------------------
-- Load content and library files
----------------------------

-- Load shared systems needed by content declarations.
assert(SMODS.load_file("lib/devil_bosses.lua"))()
assert(SMODS.load_file("lib/unlocks.lua"))()

for _, set in pairs(files) do
	for _, name in ipairs(set.list) do
		assert(SMODS.load_file(set.directory .. name .. ".lua"))()
	end
end
assert(SMODS.load_file("lib/hooks.lua"))()
if hnds_config.enableVanillaTweaks then assert(SMODS.load_file("lib/vanilla_tweaks.lua"))() end
assert(SMODS.load_file("lib/platinum_blind_upgrades.lua"))()
assert(SMODS.load_file("lib/platinum_boss_stacking.lua"))()
-- Investment must wrap Blind:set_blind/defeat after Blind Raiser does.
assert(SMODS.load_file("lib/vanilla_investment_tag.lua"))()
assert(SMODS.load_file("lib/blind_souls.lua"))()
assert(SMODS.load_file("lib/utils.lua"))()

-- Load sleeves
if CardSleeves then
    assert(SMODS.load_file("sleeves/premium_sleeve.lua"))()
    assert(SMODS.load_file("sleeves/circus_sleeve.lua"))()
    assert(SMODS.load_file("sleeves/cursed_sleeve.lua"))()
    assert(SMODS.load_file("sleeves/crystal_sleeve.lua"))()
    assert(SMODS.load_file("sleeves/conjuring_sleeve.lua"))()
    assert(SMODS.load_file("sleeves/ol_sleeve.lua"))()
end
assert(SMODS.load_file("lib/curses.lua"))()
assert(SMODS.load_file("lib/challenge_rules.lua"))()

if HNDS.apply_unlock_state_migration then HNDS.apply_unlock_state_migration() end
