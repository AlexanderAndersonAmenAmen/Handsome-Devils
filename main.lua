HNDS = {}

-- Collection layouts for vanilla object pages.
-- The rows argument is a list of per-row card limits, not a {row, column}
-- dimension pair. Handsome Devils currently has 10 Enhancements and 13 Planets,
-- so their bounded layouts are two rows of 5 and rows of 6/7 respectively.
--
-- Joker collection special case: the five Handsome Devils Legendary Jokers are
-- removed from the normal sequence and placed on a dedicated FINAL page. That
-- page is exactly 3 rows x 5 cards: empty top row, the 5 Legendaries in the
-- middle row, empty bottom row. The padding is renderer-only; no fake Jokers are
-- registered and gameplay pools / collection completion counts are unaffected.
if SMODS.card_collection_UIBox and not HNDS._collection_layout_wrapper then
    local hnds_card_collection_UIBox = SMODS.card_collection_UIBox

    local hnds_legendary_collection_order = {
        'j_hnds_pennywise',
        'j_hnds_art',
        'j_hnds_krusty',
        'j_hnds_sarmenti',
        'j_hnds_arthur',
    }
    local hnds_legendary_collection_lookup = {}
    for _, key in ipairs(hnds_legendary_collection_order) do
        hnds_legendary_collection_lookup[key] = true
    end

    -- A private sentinel used only by the collection renderer. It occupies a
    -- layout position but never becomes a Card or a registered game object.
    local hnds_collection_blank = {}

    local function hnds_legendary_joker_collection_UIBox(_pool, args)
        args = args or {}
        args.w_mod = args.w_mod or 1
        args.h_mod = args.h_mod or 1
        args.card_scale = args.card_scale or 1

        -- Joker collection is intentionally fixed at 3 x 5. This gives the
        -- dedicated Legendary page a literal row above and beneath the cards.
        local rows = { 5, 5, 5 }
        local cards_per_page = 15
        local source_pool = SMODS.collection_pool(_pool)
        local pool = {}
        local legendary_by_key = {}

        -- Keep every non-HD-Legendary center in its existing collection order.
        -- Pull the five HD Legendaries out so nothing can share their final page.
        for _, center in ipairs(source_pool) do
            if center and hnds_legendary_collection_lookup[center.key] then
                legendary_by_key[center.key] = center
            else
                pool[#pool + 1] = center
            end
        end

        -- Finish the preceding page first. These are true empty positions, not
        -- hidden/dummy Jokers, so they cannot affect unlock or discovery counts.
        local remainder = #pool % cards_per_page
        if remainder ~= 0 then
            for _ = 1, cards_per_page - remainder do
                pool[#pool + 1] = hnds_collection_blank
            end
        end

        -- Dedicated final page: blank row / Legendaries / blank row.
        for _ = 1, 5 do pool[#pool + 1] = hnds_collection_blank end
        for _, key in ipairs(hnds_legendary_collection_order) do
            local center = legendary_by_key[key]
            if center then
                pool[#pool + 1] = center
            else
                -- Keep the five middle-row positions stable even in an unusual
                -- partial-load state where one center has not registered yet.
                pool[#pool + 1] = hnds_collection_blank
            end
        end
        for _ = 1, 5 do pool[#pool + 1] = hnds_collection_blank end

        local deck_tables = {}
        local row_totals = {}
        G.your_collection = {}

        local running_total = 0
        for j = 1, #rows do
            row_totals[j] = running_total
            running_total = running_total + rows[j]
            G.your_collection[j] = CardArea(
                G.ROOM.T.x + 0.2 * G.ROOM.T.w / 2,
                G.ROOM.T.h,
                (args.w_mod * rows[j] + 0.25) * G.CARD_W,
                args.h_mod * G.CARD_H,
                { card_limit = rows[j], type = args.area_type or 'title', highlight_limit = 0, collection = true }
            )
            table.insert(deck_tables, {
                n = G.UIT.R,
                config = { align = 'cm', padding = 0.07, no_fill = true },
                nodes = {
                    { n = G.UIT.O, config = { object = G.your_collection[j] } }
                }
            })
        end

        local total_pages = math.max(1, math.ceil(#pool / cards_per_page))
        local options = {}
        for i = 1, total_pages do
            table.insert(options, localize('k_page') .. ' ' .. tostring(i) .. '/' .. tostring(total_pages))
        end

        G.FUNCS.SMODS_card_collection_page = function(e)
            if not e or not e.cycle_config then return end

            for j = 1, #G.your_collection do
                for i = #G.your_collection[j].cards, 1, -1 do
                    local c = G.your_collection[j]:remove_card(G.your_collection[j].cards[i])
                    c:remove()
                end
            end

            local page = e.cycle_config.current_option or 1
            for j = 1, #rows do
                for i = 1, rows[j] do
                    local index = i + row_totals[j] + (cards_per_page * (page - 1))
                    local center = pool[index]
                    if not center then break end

                    -- Sentinels deliberately leave this exact collection slot
                    -- empty while allowing later positions in the row/page to
                    -- be populated normally.
                    if center ~= hnds_collection_blank then
                        local card = Card(
                            G.your_collection[j].T.x + G.your_collection[j].T.w / 2,
                            G.your_collection[j].T.y,
                            G.CARD_W * args.card_scale,
                            G.CARD_H * args.card_scale,
                            G.P_CARDS.empty,
                            (args.center and G.P_CENTERS[args.center]) or center
                        )
                        if args.modify_card then args.modify_card(card, center, i, j) end
                        if not args.no_materialize then card:start_materialize(nil, i > 1 or j > 1) end
                        G.your_collection[j]:emplace(card)
                    end
                end
            end
            INIT_COLLECTION_CARD_ALERTS()
        end

        G.FUNCS.SMODS_card_collection_page { cycle_config = { current_option = 1 } }

        return create_UIBox_generic_options({
            colour = G.ACTIVE_MOD_UI and ((G.ACTIVE_MOD_UI.ui_config or {}).collection_colour or (G.ACTIVE_MOD_UI.ui_config or {}).colour),
            bg_colour = G.ACTIVE_MOD_UI and ((G.ACTIVE_MOD_UI.ui_config or {}).collection_bg_colour or (G.ACTIVE_MOD_UI.ui_config or {}).bg_colour),
            back_colour = G.ACTIVE_MOD_UI and ((G.ACTIVE_MOD_UI.ui_config or {}).collection_back_colour or (G.ACTIVE_MOD_UI.ui_config or {}).back_colour),
            outline_colour = G.ACTIVE_MOD_UI and ((G.ACTIVE_MOD_UI.ui_config or {}).collection_outline_colour or (G.ACTIVE_MOD_UI.ui_config or {}).outline_colour),
            back_func = (args and args.back_func) or G.ACTIVE_MOD_UI and 'openModUI_' .. G.ACTIVE_MOD_UI.id or 'your_collection',
            snap_back = args.snap_back,
            infotip = args.infotip,
            contents = {
                { n = G.UIT.R, config = { align = 'cm', r = 0.1, colour = G.C.BLACK, emboss = 0.05 }, nodes = deck_tables },
                (not args.hide_single_page or cards_per_page < #pool) and {
                    n = G.UIT.R,
                    config = { align = 'cm' },
                    nodes = {
                        create_option_cycle({
                            options = options,
                            w = 4.5,
                            cycle_shoulders = true,
                            opt_callback = 'SMODS_card_collection_page',
                            current_option = 1,
                            colour = G.ACTIVE_MOD_UI and (G.ACTIVE_MOD_UI.ui_config or {}).collection_option_cycle_colour or G.C.RED,
                            no_pips = true,
                            focus_args = { snap_to = true, nav = 'wide' }
                        })
                    }
                } or nil,
            }
        })
    end

    SMODS.card_collection_UIBox = function(pool, rows, args)
        local pools = G and G.P_CENTER_POOLS
        -- Steamodded's Sticker collection passes SMODS.Stickers directly, not
        -- a G.P_CENTER_POOLS entry. Force exactly 2 rows x 4 cards here.
        if SMODS and SMODS.Stickers and pool == SMODS.Stickers then
            rows = { 4, 4 }
        elseif pools then
            if pool == pools.Joker then
                return hnds_legendary_joker_collection_UIBox(pool, args)
            elseif pool == pools.Seal then
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

-- Digital Circus and Most Wanted use a guaranteed weighted Edition pool.
-- These are relative weights, matching the requested Edition weighting:
-- Foil 20, Holographic 14, Vintage 7, Polychrome 3, Negative 3.
local HNDS_FEATURED_EDITION_WEIGHTS = {
	{ key = 'e_foil',         weight = 20 },
	{ key = 'e_holo',         weight = 14 },
	{ key = 'e_hnds_vintage', weight = 7  },
	{ key = 'e_polychrome',   weight = 3  },
	{ key = 'e_negative',     weight = 3  },
}

function HNDS.poll_featured_edition(seed)
	local available = {}
	local total_weight = 0

	for _, entry in ipairs(HNDS_FEATURED_EDITION_WEIGHTS) do
		-- Vintage can be disabled by config, so only include Editions that
		-- actually exist in the current center registry.
		if G and G.P_CENTERS and G.P_CENTERS[entry.key] then
			available[#available + 1] = entry
			total_weight = total_weight + entry.weight
		end
	end

	if total_weight <= 0 then return nil end

	local roll = pseudorandom(seed or 'hnds_featured_edition') * total_weight
	local cumulative = 0
	for _, entry in ipairs(available) do
		cumulative = cumulative + entry.weight
		if roll < cumulative then return entry.key end
	end

	return available[#available] and available[#available].key or nil
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



-- Main-menu presentation: replace the vanilla title card with Handsome
-- Joker and recolour the background swirl to black and gold.


if hnds_config.enableCustomMenu ~= false then
SMODS.current_mod.menu_cards = function()
    -- Weighted title-card categories:
    --   3/5) a random UNLOCKED Handsome Devils Joker
    --   1/5) Dream
    --   1/5) Cursed Pack
    -- Jokers are collected dynamically so newly added HD Jokers automatically
    -- become eligible once unlocked, without maintaining a hard-coded list.
    local roll = math.random(5)
    local chosen_key

    if roll <= 3 then
        local hnds_jokers = {}
        for key, center in pairs((G and G.P_CENTERS) or {}) do
            if type(key) == 'string'
                and key:match('^j_hnds_')
                and center
                and center.set == 'Joker'
                and center.unlocked == true
            then
                hnds_jokers[#hnds_jokers + 1] = key
            end
        end
        table.sort(hnds_jokers)
        if #hnds_jokers > 0 then
            chosen_key = hnds_jokers[math.random(#hnds_jokers)]
        end
    elseif roll == 4 then
        chosen_key = 'c_hnds_dream'
    else
        chosen_key = 'p_hnds_cursed_pack'
    end

    -- Safety fallback for unusual load orders where the Joker pool has not
    -- been populated yet.
    chosen_key = chosen_key or 'c_devil'

    return {
        remove_original = true,
        { key = chosen_key },
    }
end
end

-- local HNDS_MENU_COLOUR_1_HEX = '4c6064'
-- local HNDS_MENU_COLOUR_2_HEX = 'fda200'

--local hnds_game_main_menu_ref = Game.main_menu
--[[
function Game:main_menu(change_context)
    local ret = hnds_game_main_menu_ref(self, change_context)

    if G and G.C then
        G.C.HNDS_MENU_COLOUR_1 = G.C.HNDS_MENU_COLOUR_1 or HEX(HNDS_MENU_COLOUR_1_HEX)
        G.C.HNDS_MENU_COLOUR_2 = G.C.HNDS_MENU_COLOUR_2 or HEX(HNDS_MENU_COLOUR_2_HEX)
    end

    if G and G.SPLASH_BACK then
        G.SPLASH_BACK:define_draw_steps({
            {
                shader = 'splash',
                send = {
                    { name = 'time', ref_table = G.TIMERS, ref_value = 'REAL_SHADER' },
                    { name = 'vort_speed', val = 0.4 },
                    { name = 'colour_1', ref_table = G.C, ref_value = 'HNDS_MENU_COLOUR_1' },
                    { name = 'colour_2', ref_table = G.C, ref_value = 'HNDS_MENU_COLOUR_2' },
                }
            }
        })
    end

    return ret
end
]]

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
			config_toggle_row(localize("hnds_config_CustomMenu"), "enableCustomMenu", localize("hnds_require_restart")),
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
	-- Spawn queued booster packs at the start of each shop.  Cursed Deck uses
	-- this boundary instead of a cash_out polling Event: payout has completed,
	-- while the queued booster can cleanly return to the Shop after selection.
	if context.starting_shop then
		if G.GAME.hnds_crystal_queued then
			spawn_queued_booster('p_hnds_spectral_ultra')
			G.GAME.hnds_crystal_queued = nil
		end
		if HNDS.open_pending_cursed_pack_at_shop then
			HNDS.open_pending_cursed_pack_at_shop()
		end
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
			"one_punchline_man",
			
			"walking_joke",
			"digital_circus",
			"excommunicado",
			"meme",
			"handsome",

			"stone_mask",
			"energized",
			"last_laugh",
			"bizzare_joker",
			"jokestone",

			"conquest",
			"be_not_afraid",
			"jodiac",
			"jack_in_the_box",
			"joker_reverse",

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

-- Replace Balatro's main-menu title/logo with the Handsome Devils title art.
-- raw_key keeps the vanilla atlas key ("balatro") instead of prefixing it
-- with this mod's ID, so the existing title UI picks this texture up directly.
if hnds_config.enableCustomMenu ~= false then
SMODS.Atlas({
    key = "balatro",
    path = "balatro.png",
    -- Wider title frame: artwork can use a 499x232 canvas at 1x
    -- (998x464 at 2x) without resizing the pixels inside it.
    px = 499,
    py = 232,
    raw_key = true,
})
end
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
	-- Conquest tracks Boss-equivalent Blind defeats for the entire run, even
	-- before the Joker is owned.
	ret.hnds_conquest_bosses_defeated = 0
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
assert(SMODS.load_file("lib/conquest_tracker.lua"))()
assert(SMODS.load_file("lib/blind_souls.lua"))()
assert(SMODS.load_file("lib/utils.lua"))()
assert(SMODS.load_file("lib/cursed_pack.lua"))()

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
