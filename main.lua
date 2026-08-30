HNDS = {}


function HNDS.draw_flat_sticker(sticker, card, layer)
    local key = sticker and sticker.key
    local sprite = G and G.shared_stickers and key and G.shared_stickers[key]
    if not sprite and G and G.shared_stickers and key and not key:match('^hnds_') then
        sprite = G.shared_stickers['hnds_' .. key]
    end
    if not (sprite and card) then return end
    if sprite.role then sprite.role.draw_major = card end
    if sprite.draw_shader then
        sprite:draw_shader('dissolve', nil, nil, nil, card.children and card.children.center)
    end
end


function HNDS.card_has_stone(card, allow_quantum)
    if not card then return false end
    local center = card.config and card.config.center
    if center and center.key == 'm_stone' then return true end

    local fusions = card.ability and card.ability.hnds_aberrant_fusions
    if type(fusions) == 'table' then
        for _, key in ipairs(fusions) do
            if key == 'm_stone' then return true end
        end
    end


    if allow_quantum and SMODS and type(SMODS.has_enhancement) == 'function' then
        local ok, result = pcall(SMODS.has_enhancement, card, 'm_stone')
        if ok and result then return true end
    end
    return false
end

function HNDS.deck_has_stone()
    for _, playing_card in ipairs((G and G.playing_cards) or {}) do
        if HNDS.card_has_stone(playing_card) then return true end
    end
    return false
end


function HNDS.stone_joker_in_pool(args)
    if args and args.source == 'sho' then
        return HNDS.deck_has_stone()
    end
    return true
end

function HNDS.pack(...)
    return { n = select('#', ...), ... }
end


local hnds_query_guards = {
    no_rank = setmetatable({}, { __mode = 'k' }),
    no_suit = setmetatable({}, { __mode = 'k' }),
    any_suit = setmetatable({}, { __mode = 'k' }),
}

local function hnds_safe_card_query(kind, fn_name, card, fallback)
    if not card then return fallback or false end
    local guard = hnds_query_guards[kind]
    if guard and guard[card] then return fallback or false end
    local fn = SMODS and SMODS[fn_name]
    if type(fn) ~= 'function' then return fallback or false end

    if guard then guard[card] = true end
    local ok, value = pcall(fn, card)
    if guard then guard[card] = nil end
    if ok then return value == true end
    return fallback or false
end

function HNDS.safe_has_no_rank(card)

    if HNDS.is_faceless and HNDS.is_faceless(card) then
        local target = HNDS.faceless_copy_target and HNDS.faceless_copy_target(card)
        if not target then return true end
        return hnds_safe_card_query('no_rank', 'has_no_rank', target, false)
    end
    return hnds_safe_card_query('no_rank', 'has_no_rank', card, false)
end

function HNDS.safe_has_no_suit(card)

    if HNDS.is_faceless and HNDS.is_faceless(card) then
        local target = HNDS.faceless_copy_target and HNDS.faceless_copy_target(card)
        if not target then return true end
        return hnds_safe_card_query('no_suit', 'has_no_suit', target, false)
    end
    return hnds_safe_card_query('no_suit', 'has_no_suit', card, false)
end

function HNDS.safe_has_any_suit(card)
    if HNDS.is_faceless and HNDS.is_faceless(card) then
        local target = HNDS.faceless_copy_target and HNDS.faceless_copy_target(card)
        if not target then return false end
        return hnds_safe_card_query('any_suit', 'has_any_suit', target, false)
    end
    return hnds_safe_card_query('any_suit', 'has_any_suit', card, false)
end

function HNDS.mod_loaded(id)
    if not (SMODS and type(SMODS.find_mod) == 'function' and type(id) == 'string') then
        return false
    end
    local ok, found = pcall(SMODS.find_mod, id)
    return ok and type(found) == 'table' and next(found) ~= nil
end

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


    local hnds_collection_blank = {}

    local function hnds_legendary_joker_collection_UIBox(_pool, args)
        args = args or {}
        args.w_mod = args.w_mod or 1
        args.h_mod = args.h_mod or 1
        args.card_scale = args.card_scale or 1


        local rows = { 5, 5, 5 }
        local cards_per_page = 15
        local source_pool = SMODS.collection_pool(_pool)
        if type(source_pool) ~= 'table' then return nil end
        local pool = {}
        local legendary_by_key = {}


        for _, center in ipairs(source_pool) do
            if center and hnds_legendary_collection_lookup[center.key] then
                legendary_by_key[center.key] = center
            else
                pool[#pool + 1] = center
            end
        end


        local remainder = #pool % cards_per_page
        if remainder ~= 0 then
            for _ = 1, cards_per_page - remainder do
                pool[#pool + 1] = hnds_collection_blank
            end
        end


        for _ = 1, 5 do pool[#pool + 1] = hnds_collection_blank end
        for _, key in ipairs(hnds_legendary_collection_order) do
            local center = legendary_by_key[key]
            if center then
                pool[#pool + 1] = center
            else


                pool[#pool + 1] = hnds_collection_blank
            end
        end
        for _ = 1, 5 do pool[#pool + 1] = hnds_collection_blank end


        if type(G.your_collection) == 'table' then
            for _, old_area in ipairs(G.your_collection) do
                if old_area and old_area.cards then
                    for i = #old_area.cards, 1, -1 do
                        local old_card = old_area.cards[i]
                        if old_card then
                            if old_area.remove_card then old_area:remove_card(old_card) end
                            if old_card.remove then old_card:remove() end
                        end
                    end
                end
                if old_area and old_area.remove then old_area:remove() end
            end
        end

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

        G.FUNCS.hnds_legendary_collection_page = function(e)
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

        G.FUNCS.hnds_legendary_collection_page { cycle_config = { current_option = 1 } }

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
                            opt_callback = 'hnds_legendary_collection_page',
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


        if not (G and G.FUNCS and G.ROOM and G.UIT and CardArea and Card
            and SMODS and type(SMODS.collection_pool) == 'function') then
            return hnds_card_collection_UIBox(pool, rows, args)
        end


        if SMODS and SMODS.Stickers and pool == SMODS.Stickers then
            rows = { 4, 4 }
        elseif pools then
            if pool == pools.Joker then
                local ok, result = pcall(hnds_legendary_joker_collection_UIBox, pool, args)
                if ok and result then return result end
                if sendDebugMessage and not ok then
                    sendDebugMessage('Legendary collection layout fallback: '..tostring(result), 'HandsomeDevils')
                end
                return hnds_card_collection_UIBox(pool, rows, args)
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


HD = SMODS.current_mod
hnds_config = SMODS.current_mod.config


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


if hnds_config.enableCustomMenu ~= false then
SMODS.current_mod.menu_cards = function()


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


    chosen_key = chosen_key or 'c_devil'

    return {
        remove_original = true,
        { key = chosen_key },
        func = function()
            if not (G and G.title_top and G.title_top.cards) then return end
            local kept_hnds
            for i = #G.title_top.cards, 1, -1 do
                local card = G.title_top.cards[i]
                local center = card and card.config and card.config.center
                local key = center and center.key
                local is_hnds = type(key) == 'string' and (key:match('^j_hnds_') or key:match('^c_hnds_') or key:match('^p_hnds_'))
                if is_hnds then
                    if not kept_hnds then
                        kept_hnds = card
                    else
                        G.title_top:remove_card(card)
                        if card.remove then card:remove() end
                    end
                end
            end
        end,
    }
end
end


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
		nodes = {
			config_toggle_row(localize("hnds_config_StoneOcean"), "enableStoneOcean", localize("hnds_require_restart")),
			config_toggle_row(localize("hnds_config_vintage"), "enableVintageEdition", localize("hnds_require_restart")),
			config_toggle_row(localize("hnds_config_UltraSpec"), "enablePackSpawning"),
			config_toggle_row(localize("hnds_config_MagicPack"), "enableMagicPackSpawning"),
			config_toggle_row(localize("hnds_config_CursedPack"), "enableCursedPackSpawning"),
			config_toggle_row(localize("hnds_config_CustomSounds"), "enableCustomSounds"),
			config_toggle_row(localize("hnds_config_VanillaTweaks"), "enableVanillaTweaks", localize("hnds_require_restart")),
			config_toggle_row(localize("hnds_config_BlindUpgradeButton"), "enableBlindUpgradeButton", localize("hnds_require_restart")),
			config_toggle_row(localize("hnds_config_CustomMenu"), "enableCustomMenu", localize("hnds_require_restart")),
			config_toggle_row(localize("hnds_config_ChaosSuits"), "enableChaosSuits"),
		},
	}
end


local hnds_card_open = Card.open
function Card:open(...)
	local queued_art = G and G.GAME
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


	self.ability.extra = original_size + 1
	return hnds_card_open(self, ...)
end


local function spawn_queued_booster(pack_key, pre_open_func)
	if not (G and G.E_MANAGER and G.play and G.FUNCS and G.FUNCS.use_card
		and SMODS and type(SMODS.create_card) == 'function' and Event) then return false end
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
	return true
end


SMODS.current_mod.calculate = function(self, context)
	if type(context) ~= 'table' then return end
	if HNDS.calculate_vanilla_tweaks then HNDS.calculate_vanilla_tweaks(context) end
	if HNDS.calculate_aberrant then HNDS.calculate_aberrant(context) end


	if context.create_shop_card and HNDS.ms_fortune_shop_create_flags then
		local flags = HNDS.ms_fortune_shop_create_flags(context)
		if flags then return { shop_create_flags = flags } end
	end

	if context.card_added and context.card and HNDS.ms_fortune_obtained then
		HNDS.ms_fortune_obtained(context.card, false)
	end



	if (context.modify_shop_card or context.modify_booster_card) and context.card
		and HNDS.ms_fortune_ensure_cursed
	then
		HNDS.ms_fortune_ensure_cursed(context.card)
		if HNDS.ms_fortune_sync_sell_value then
			HNDS.ms_fortune_sync_sell_value(context.card)
		end
	end


	if context.modify_booster_card and context.card
		and context.card.config and context.card.config.center
		and context.card.config.center.key == "c_hnds_spectrum"
	then
		local spectrum = context.card
		if spectrum.set_edition then spectrum:set_edition(nil, true, true) end
		if spectrum.set_seal then spectrum:set_seal(nil, true, true) end


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


	if context.individual and context.cardarea == G.play and context.other_card and G and G.GAME
		and HNDS.card_has_stone(context.other_card, true)
	then
		G.GAME.ante_stones_scored = (tonumber(G.GAME.ante_stones_scored) or 0) + 1
	end

	if context.individual and context.cardarea == G.play and context.other_card
		and not context.repetition and HNDS.card_has_obsidian
		and HNDS.card_has_obsidian(context.other_card) and not context.other_card.debuff
	then
		context.other_card.ability.hnds_obsidian_scored_last_hand = true
	end


	if context.ante_change and context.ante_end and G and G.GAME then
		G.GAME.ante_stones_scored = 0
	end


	if context.starting_shop then
		if HNDS.abstract_force_first_shop_standard then
			HNDS.abstract_force_first_shop_standard()
		end
		if G.GAME.hnds_crystal_queued then
			spawn_queued_booster('p_hnds_spectral_ultra')
			G.GAME.hnds_crystal_queued = nil
		end
		if HNDS.open_pending_cursed_pack_at_shop then
			HNDS.open_pending_cursed_pack_at_shop()
		end
	end


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


	if context.modify_booster_card and context.card
		and context.card.config and context.card.config.center
		and context.card.config.center.key == "j_hnds_art" then
		context.card:set_edition(nil, true, true)
		for sticker_key, _ in pairs(SMODS.Stickers or {}) do
			context.card.ability[sticker_key] = nil
		end
	end

	if context.buying_card then
		G.GAME.hnds_fregoli_copy = context.card.sort_id
	end

	if context.card_added then
		G.GAME.hnds_dna_tag_copy = context.card.sort_id
	end


	if context.first_hand_drawn and HNDS.jevil_schedule_starting_hand then
		HNDS.jevil_schedule_starting_hand()
	end


	if context.end_of_round and context.main_eval and HNDS.jevil_clear_round then
		HNDS.jevil_clear_round()
	end


	if context.setting_blind and HNDS.restore_stone_mask_cards then


		HNDS.restore_stone_mask_cards()
	elseif context.end_of_round and context.main_eval and HNDS.restore_stone_mask_cards then


		if G and G.E_MANAGER and Event then
			G.E_MANAGER:add_event(Event({
				trigger = 'after', delay = 0, blockable = false,
				func = function()
					if HNDS.restore_stone_mask_cards then HNDS.restore_stone_mask_cards() end
					return true
				end,
			}))
		else
			HNDS.restore_stone_mask_cards()
		end
	end


	if context.first_hand_drawn and HNDS.draw_bound_cards then
		HNDS.draw_bound_cards()
	end


	if context.before and HNDS.reset_obsidian_hand_marks then
		HNDS.reset_obsidian_hand_marks()
	end
	if context.after and SMODS.last_hand_oneshot
		and HNDS.complete_obsidian_final_hand
	then
		HNDS.complete_obsidian_final_hand()
	end

	local abstract_result = HNDS.calculate_abstract_suits and HNDS.calculate_abstract_suits(context) or nil
	if abstract_result and boss_stack_result and type(abstract_result) == 'table' and type(boss_stack_result) == 'table' then
		local merged = {}
		for key, value in pairs(boss_stack_result) do merged[key] = value end
		for key, value in pairs(abstract_result) do
			if type(value) == 'number' and type(merged[key]) == 'number'
				and (key == 'mult' or key == 'chips' or key == 'dollars' or key == 'repetitions')
			then
				merged[key] = merged[key] + value
			else
				merged[key] = value
			end
		end
		return merged
	end
	return abstract_result or boss_stack_result
end

SMODS.current_mod.optional_features = {
	retrigger_joker = true,
	object_weights = true,
	quantum_enhancements = true,
}


local files = {
	jokers = {
		list = {

			"balloons",
			"coffee_break",
			"most_wanted",
			"jackpot",
			"pot_of_greed",

			"dynamic_duos",
			"wait_what",
			"jokestone",
			"clown_devil",
			"public_nuisance",

			"dallas",
			"hoxton",
			"bizzare_joker",
			"wolf",
			"chains",

			"spaghettified_joker",
			"ecg",
			"jevil",
			"jodiac",
			"jack_in_the_box",

			"water_slide",
			"be_not_afraid",
			"time_fcked_joker",
			"joker_reverse",
			"jigsaw_joker",

			"banana_split",
			"supersuit",
			"jokes_aside",
		    "headless_joker",
		    "angry_mob",

		    "seismic_activity",
	        "creepy",
			"imposter",
			"stone_mask",
			"head_of_medusa",

		    "deep_pockets",
			"color_of_madness",
			"dark_idol",
			"perfectionist",
			"one_punchline_man",

			"conquest",
			"plague",
			"war",
			"famine",
			"death",

			"dark_humor",
			"demented",
			"ancestor",
			"fregoli",
			"ms_fortune",

			"jester_in_yellow",
			"occultist",
			"contagion",
			"energized",
			"last_laugh",

			"walking_joke",
			"digital_circus",
			"excommunicado",
			"meme",
			"handsome",

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
			"circus",
			"ol_reliable",
			"premiumdeck",
			"conjuring",
			"abstract",
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


if hnds_config.enableBlindUpgradeButton then
	table.insert(files.stakes.list, "nightmare")
end


SMODS.Gradient({key = "SEAL_EDITION", colours = { G.C.RED, G.C.BLUE, G.C.GOLD, G.C.PURPLE }, cycle = 7.5,})
G.C.HNDS_SEAL_EDITION = SMODS.Gradients.hnds_SEAL_EDITION
SMODS.Gradient({
    key = "chaos_abilities",
    colours = {
        HEX('c9a500'),
        HEX('9bb031'),
        HEX('479d7a'),
        HEX('ff5d9b'),
        HEX('6CA2A6'),
        HEX('7a73bb'),
        HEX('4189e9'),
        HEX('4f6367'),
        HEX('6e8965'),
    },
    cycle = 2 * math.pi / 1.5,
})
G.C.HNDS_CHAOS_ABILITIES = SMODS.Gradients.hnds_chaos_abilities
G.C.HNDS_CARCOSA = HEX('C9A227')
G.C.hnds_carcosa = G.C.HNDS_CARCOSA

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
SMODS.Sound({ key = "creepy_1", path = "Creepy_1.ogg", })
SMODS.Sound({ key = "creepy_2", path = "Creepy_2.ogg", })
SMODS.Sound({ key = "creepy_3", path = "Creepy_3.ogg", })
SMODS.Sound({ key = "creepy_4", path = "Creepy_4.ogg", })

SMODS.Atlas({ key = "HDtags", path = "HDtags.png", px = 34, py = 34, })
SMODS.Atlas({ key = "Jokers",      path = "Jokers.png", px = 71, py = 95 })
SMODS.Atlas({ key = "JackOfLanterns", path = "JackOfLanterns.png", px = 71, py = 95 })
SMODS.Atlas({ key = "Faceless_opt1", path = "Faceless_opt1.png", px = 71, py = 95 })
SMODS.Atlas({ key = "Faceless_opt2", path = "Faceless_opt2.png", px = 71, py = 95 })
SMODS.Atlas({ key = "SUITS", path = "SUITS.png", px = 71, py = 95 })
SMODS.Atlas({ key = "SUITS_UI", path = "SUITS_UI.png", px = 18, py = 18 })
SMODS.Atlas({ key = "Consumables", path = "THD.png",     px = 71, py = 95 })
SMODS.Atlas({ key = "Vouchers",    path = "VHD.png",     px = 71, py = 95 })
SMODS.Atlas({ key = "Extras",      path = "EHD.png",     px = 71, py = 95 })
SMODS.Atlas({ key = "Stakes", path = "HDstakes.png", px = 29, py = 29 })
SMODS.Atlas({ key = "Stickers", path = "HDstickers.png", px = 71, py = 95 })
SMODS.Atlas({ key = "hnds_sleeves", path = "HDS.png", px = 73, py = 95 })


if hnds_config.enableCustomMenu ~= false then
SMODS.Atlas({
    key = "balatro",
    path = "balatro.png",


    px = 499,
    py = 232,
    raw_key = true,
})
end

SMODS.Atlas {
    key = 'ante_10_atlas',
    path = 'Ante10Blinds.png',
    px = 34,
    py = 34,
    frames = 21,
    fps = 10,

    atlas_table = 'ANIMATION_ATLAS'
}


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


local _init_game_object = Game.init_game_object
function Game:init_game_object(...)
	local ret = _init_game_object(self, ...)


	if type(ret) ~= 'table' then return ret end
	ret.hnds_booster_choice_mod = ret.hnds_booster_choice_mod or 0


	ret.hnds_tags_popped = ret.hnds_tags_popped or 0

	ret.hnds_boosters_bought_run = ret.hnds_boosters_bought_run or 0
	ret.hnds_juggle_bonuses = ret.hnds_juggle_bonuses or {}


	ret.hnds_conquest_bosses_defeated = ret.hnds_conquest_bosses_defeated or 0
	ret.hnds_ms_fortune_sell_bonus = ret.hnds_ms_fortune_sell_bonus or 0
	ret.hnds_ms_fortune_shop_active = ret.hnds_ms_fortune_shop_active or false
	ret.hnds_ms_fortune_obtained = ret.hnds_ms_fortune_obtained or {}
	return ret
end


assert(SMODS.load_file("lib/devil_bosses.lua"))()
assert(SMODS.load_file("lib/unlocks.lua"))()


local hnds_content_load_order = {
    'enhancements', 'seals', 'editions', 'jokers', 'spectrals', 'planets',
    'vouchers', 'tags', 'decks', 'stakes', 'challenges', 'blinds', 'poker_hands',
}
for _, set_key in ipairs(hnds_content_load_order) do
    local set = files[set_key]
    if set then
        for _, name in ipairs(set.list) do
            assert(SMODS.load_file(set.directory .. name .. ".lua"))()
        end
    end
end
assert(SMODS.load_file("lib/hooks.lua"))()
if hnds_config.enableVanillaTweaks then assert(SMODS.load_file("lib/vanilla_tweaks.lua"))() end
if hnds_config.enableBlindUpgradeButton then
	assert(SMODS.load_file("lib/platinum_blind_upgrades.lua"))()
end
assert(SMODS.load_file("lib/platinum_boss_stacking.lua"))()

assert(SMODS.load_file("lib/vanilla_investment_tag.lua"))()
assert(SMODS.load_file("lib/conquest_tracker.lua"))()
assert(SMODS.load_file("lib/blind_souls.lua"))()
assert(SMODS.load_file("lib/utils.lua"))()
assert(SMODS.load_file("lib/headless_jack.lua"))()
assert(SMODS.load_file("lib/cursed_pack.lua"))()


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


assert(SMODS.load_file("lib/time_fcked.lua"))()

if HNDS.apply_unlock_state_migration then HNDS.apply_unlock_state_migration() end
