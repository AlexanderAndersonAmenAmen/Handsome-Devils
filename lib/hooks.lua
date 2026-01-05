--[[
Handsome Devils - Runtime Hooks

Purpose
- This module installs gameplay hooks that are *not specific to a single card definition*.
- It centralizes overrides of core Balatro functions that need to be modified for:
  - custom stakes/decks
  - curse system glue logic
  - UI display patches
  - special-case mechanics that are easier/safer to implement as a hook than as per-card code

Who loads this file
- Loaded by `main.lua` via `assert(SMODS.load_file("lib/hooks.lua"))()`.

What this module touches
- Core functions:
  - `end_round`
  - `create_UIBox_blind_choice`
  - `Blind:set_blind`
  - `Card:set_cost`
  - `create_card`
  - `find_joker`

- SMODS integration:
  - Wraps `SMODS.calculate_destroying_cards` and `SMODS.score_card` to support custom seals/vouchers
    that destroy cards but still need scoring logic.

- UI integration:
  - Wraps `G.UIDEF.challenge_description_tab` (Restrictions tab) so banned Editions display correctly
    by rendering a Joker placeholder with the edition applied.

Safety / invariants
- Wrappers are installed once using `_hnds_wrapped_*` flags.
- Hooks are written to degrade gracefully if optional globals or other mods are not present.
--]]

local HNDS_is_platinum_stake_active

-- Platinum Stake: Doubles blind multiplier when beating blinds by 2x chips
local end_round_ref = end_round
function end_round(...)
	local is_platinum_stake = HNDS_is_platinum_stake_active and HNDS_is_platinum_stake_active() or false
	local blind_chips = (G and G.GAME and G.GAME.blind and G.GAME.blind.chips) or nil
	local chips = (G and G.GAME and G.GAME.chips) or nil
	local won_round = (chips and blind_chips) and (chips - blind_chips >= 0) or false
	local beat_by_2x = is_platinum_stake and won_round and blind_chips and blind_chips > 0 and chips and (chips > blind_chips * 2)
	if beat_by_2x and G and G.GAME then
		G.GAME.modifiers = G.GAME.modifiers or {}
		G.GAME.modifiers.hnds_next_blind_mult = (G.GAME.modifiers.hnds_next_blind_mult or 1) * 2
	end
	return end_round_ref(...)
end

if G and G.UIDEF and G.UIDEF.challenge_description_tab and not G.UIDEF._hnds_wrapped_challenge_description_tab then
	G.UIDEF._hnds_wrapped_challenge_description_tab = true
	local challenge_description_tab_ref = G.UIDEF.challenge_description_tab
	function G.UIDEF.challenge_description_tab(args)
		local ret = challenge_description_tab_ref(args)
		if not (args and args._tab == 'Restrictions') then
			return ret
		end
		if not (G and G.P_CENTERS and G.P_CENTERS.j_joker) then
			return ret
		end

		local function patch_node(node)
			if type(node) ~= 'table' then return end
			local obj = node.config and node.config.object
			if obj and type(obj) == 'table' and obj.cards and type(obj.cards) == 'table' then
				for i = 1, #obj.cards do
					local c = obj.cards[i]
					if c and c.config and c.config.center and c.config.center.set == 'Edition' and c.config.center.key then
						local edition_key = c.config.center.key
						c:set_ability(G.P_CENTERS.j_joker, true, true)
						c:set_edition(edition_key, true, true)
					end
				end
			end
			if node.nodes and type(node.nodes) == 'table' then
				for j = 1, #node.nodes do
					patch_node(node.nodes[j])
				end
			end
		end

		patch_node(ret)
		return ret
	end
end

if not _G._hnds_wrapped_blind_choice then
	-- UI wrapper for blind choice to display modified blind amounts
	_G._hnds_wrapped_blind_choice = true
	local create_UIBox_blind_choice_ref = create_UIBox_blind_choice
	function create_UIBox_blind_choice(blind_type, run_info)
		local t = create_UIBox_blind_choice_ref(blind_type, run_info)
		local on_deck = (G and G.GAME and G.GAME.blind_on_deck) or nil
		if run_info or not on_deck or blind_type ~= on_deck then
			return t
		end
		if G and G.GAME and G.GAME.modifiers and G.GAME.modifiers.hnds_next_blind_mult then
			local mult = G.GAME.modifiers.hnds_next_blind_mult
			if mult and mult > 1 then
				local blind_key = G.GAME.round_resets and G.GAME.round_resets.blind_choices and G.GAME.round_resets.blind_choices[blind_type]
				local blind_cfg = blind_key and G.P_BLINDS and G.P_BLINDS[blind_key]
				if blind_cfg and blind_cfg.mult and get_blind_amount and number_format and score_number_scale then
					local ante = (G.GAME.round_resets and G.GAME.round_resets.blind_ante) or (G.GAME.round_resets and G.GAME.round_resets.ante)
					local base_amt = get_blind_amount(ante) * blind_cfg.mult * (G.GAME.starting_params and G.GAME.starting_params.ante_scaling or 1)
					local from_text = number_format(base_amt)
					local to_amt = base_amt * mult
					local to_text = number_format(to_amt)
					local function patch_nodes(nodes)
						if _G.type(nodes) ~= 'table' then return end
						for _, n in ipairs(nodes) do
							if n and n.config and n.config.text and n.config.text == from_text then
								n.config.text = to_text
								n.config.scale = score_number_scale(0.9, to_amt)
							elseif n and n.nodes then
								patch_nodes(n.nodes)
							end
						end
					end
					patch_nodes(t.nodes)
				end
			end
		end
		return t
	end
end

local function HNDS_is_stake_active(stake_key)
	-- Helper function to check if a specific stake is active
	if not (G and G.GAME and G.GAME.applied_stakes and G.P_STAKES and stake_key) then return false end
	local stake = G.P_STAKES[stake_key]
	for _, applied in ipairs(G.GAME.applied_stakes) do
		if applied == stake_key then
			return true
		end
		if stake and stake.order and applied == stake.order then
			return true
		end
	end
	return false
end

HNDS_is_platinum_stake_active = function()
	-- Check if platinum stake is active (supports multiple stake key variations)
	if not (G and G.GAME) then return false end
	if HNDS_is_stake_active('platinum') then return true end
	if HNDS_is_stake_active('stake_hnds_platinum') then return true end
	if HNDS_is_stake_active('hnds_platinum') then return true end
	return false
end

local Blind_set_blind_ref = Blind.set_blind
-- Apply blind multiplier from platinum stake when setting new blind
function Blind:set_blind(blind, reset, silent)
	local ret = Blind_set_blind_ref(self, blind, reset, silent)
	if not (G and G.GAME and G.GAME.facing_blind) then
		return ret
	end

	local mult = nil
	if G and G.GAME then
		if G.GAME.modifiers and G.GAME.modifiers.hnds_next_blind_mult and G.GAME.modifiers.hnds_next_blind_mult > 1 then
			mult = G.GAME.modifiers.hnds_next_blind_mult
			G.GAME.modifiers.hnds_next_blind_mult = nil
		end
	end
	if mult then
		if self and self.chips then
			self.chips = self.chips * mult
			if number_format then
				self.chip_text = number_format(self.chips)
			end
			if G and G.FUNCS and G.hand_text_area and G.hand_text_area.blind_chips then
				G.FUNCS.blind_chip_UI_scale(G.hand_text_area.blind_chips)
			end
			if G and G.HUD and G.HUD.recalculate then
				G.HUD:recalculate()
			end
		end
	end
	return ret
end

-- Black Seal and voucher card destruction detection
HNDS.should_hand_destroy = function(card)
	return card.seal == "hnds_black" or (G.GAME.used_vouchers.v_hnds_soaked and card == G.hand.cards[1]) or
	(G.GAME.used_vouchers.v_hnds_beyond and card == G.hand.cards[#G.hand.cards])
end

local destroy_cards_ref = SMODS.calculate_destroying_cards
-- Handle destruction of cards with black seal or voucher effects
function SMODS.calculate_destroying_cards(context, cards_destroyed, scoring_hand)
	destroy_cards_ref(context, cards_destroyed, scoring_hand)
	for i, card in ipairs(G.hand.cards) do
		if HNDS.should_hand_destroy(card) then
			local destroyed = nil
			local new_context = {}
			for k, v in pairs(context) do
				new_context[k] = v
			end
			new_context.destroy_card = card
			new_context.cardarea = G.play
			new_context.destroying_card = card
			new_context.hnds_hand_trigger = true
			new_context.full_hand = G.hand.cards
			local flags = SMODS.calculate_context(new_context)
			if flags and flags.remove then destroyed = true end
			if destroyed then
				card.getting_sliced = true
				if SMODS.shatters(card) then
					card.shattered = true
				else
					card.destroyed = true
				end
				cards_destroyed[#cards_destroyed + 1] = card
			end
		end
	end
end

local get_new_boss_ref = get_new_boss
-- Crystal Deck: Halves win ante for double showdown effect
function get_new_boss()
	local win_ante = G.GAME.win_ante
	if G.GAME.modifiers.hnds_double_showdown and G.GAME.round_resets.ante and G.GAME.round_resets.ante < G.GAME.win_ante then
		G.GAME.win_ante = math.floor(G.GAME.win_ante / 2)
	end
	local boss = get_new_boss_ref()
	G.GAME.win_ante = win_ante
	return boss
end

local set_cost_ref = Card.set_cost
-- Premium Deck and Coffee Break Joker cost modifications
function Card.set_cost(self)
	set_cost_ref(self)
	if self.config.center.key == "j_hnds_coffee_break" then
		self.sell_cost = 0
	end
	if self.config.center.key == "j_hnds_art" then
		self.sell_cost = -5
	end
	if G.GAME.selected_back and G.GAME.selected_back.effect.center.key == "b_hnds_premiumdeck" and self.config.center.set == "Joker" then
		self.cost = math.floor(self.cost + G.GAME.round_resets.ante)
	end
	-- Apply curse price multiplier
	if G.GAME and G.GAME.hnds_price_multiplier and G.GAME.hnds_price_multiplier > 1 then
		if self.config.center.set == "Joker" or self.config.center.set == "Booster" then
			self.cost = math.max(0, math.floor(self.cost * G.GAME.hnds_price_multiplier))
		end
	end
end

if CardArea and CardArea.emplace and not CardArea._hnds_wrapped_emplace_shop then
	-- Shop curses: Apply curses to jokers when they enter shop (Blood Stake)
	CardArea._hnds_wrapped_emplace_shop = true
	local emplace_ref = CardArea.emplace
	function CardArea:emplace(card, ...)
		local ret = emplace_ref(self, card, ...)
		-- Keep existing logic for other scenarios
		if self == G.shop_jokers and card and card.config and card.config.center and card.config.center.set == 'Joker' and G.GAME and G.GAME.modifiers and G.GAME.modifiers.enable_curses then
			if (not card.ability or not card.ability.curse) and apply_curse and type(apply_curse) == 'function' then
				G.GAME.modifiers.hnds_shop_curse_roll = (G.GAME.modifiers.hnds_shop_curse_roll or 0) + 1
				if pseudorandom('hnds_curse_shop'..G.GAME.modifiers.hnds_shop_curse_roll) < 0.25 then
					apply_curse(card)
				end
			end
		end
		return ret
	end
end

-- Shop curses (Cursed Pack logic)
if SMODS and SMODS.create_card and not SMODS._hnds_wrapped_create_card_shop then
	-- Alternative method for applying curses to shop jokers
	SMODS._hnds_wrapped_create_card_shop = true
	local smods_create_card_ref = SMODS.create_card
	function SMODS.create_card(args)
		local created_card = smods_create_card_ref(args)
		-- Apply curses to shop jokers when enable_curses is active (Blood Stake)
		if created_card and args and args.area == G.shop_jokers and G.GAME and G.GAME.modifiers and G.GAME.modifiers.enable_curses then
			if (not created_card.ability or not created_card.ability.curse) and apply_curse and type(apply_curse) == 'function' then
				G.GAME.modifiers.hnds_shop_curse_roll = (G.GAME.modifiers.hnds_shop_curse_roll or 0) + 1
				if pseudorandom('hnds_curse_shop'..G.GAME.modifiers.hnds_shop_curse_roll) < 0.12 then
					apply_curse(created_card)
				end
			end
		end
		return created_card
	end
end

-- Krusty Food negative edition (separate from curses)
local create_card_ref = create_card
function create_card(_type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append)
	local card = create_card_ref(_type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append)

	-- Krusty gives negative edition to Food cards when created
	if card and next(SMODS.find_card("j_hnds_krusty")) and card.config then
		for _, t in ipairs(G.P_CENTER_POOLS.Food) do
			if t.key == card.config.center.key then
				card:set_edition("e_negative")
				break
			end
		end
	end

	return card
end

local add_to_deck_ref = Card.add_to_deck
-- Handle joker copying abilities (e.g., DNA tag)
function Card:add_to_deck(from_debuff)
	local ret = add_to_deck_ref(self, from_debuff)
	if not from_debuff and self.ability.hnds_copies_to_create then
		for _ = 1, self.ability.hnds_copies_to_create do
			if #G.jokers.cards + G.GAME.joker_buffer < G.jokers.config.card_limit then
				G.GAME.joker_buffer = G.GAME.joker_buffer + 1
				local c = self
				G.E_MANAGER:add_event(Event{
					func = function ()
						local copy = copy_card(c)
						copy.ability.hnds_copies_to_create = nil
						copy:add_to_deck()
						G.jokers:emplace(copy)
						G.GAME.joker_buffer = 0
						return true
					end
				})
			end
		end
		self.ability.hnds_copies_to_create = nil
	end
	return ret
end

score_card_ref = SMODS.score_card
-- Black Seal scoring: Force scoring of destroyed cards as if they were played
function SMODS.score_card(card, context)
	if not G.scorehand and HNDS.should_hand_destroy(card) and context.cardarea == G.hand then
		G.scorehand = true
		context.cardarea = G.play
		if context.destroy_card then context.destroying_card = context.destroy_card end
		SMODS.score_card(card, context)
		G.scorehand = nil
		context.destroying_card = nil
		context.cardarea = G.play
	end
	return score_card_ref(card, context)
end

-- Impostor Joker: Highly optimized context-aware rank spoofing system
if Card and Card.calculate_joker and not Card._hnds_wrapped_calculate_joker_imposter then
    Card._hnds_wrapped_calculate_joker_imposter = true
    local calculate_joker_ref = Card.calculate_joker
    local hnds_unpack = (table and table.unpack) or unpack
    local hnds_impostor_available = false
    local hnds_primary_impostor_id = nil
    local hnds_cached_round = -1
    local hnds_cached_joker_count = -1
    local hnds_cached_hand_tick = -1

    local spoof_cache = {}
    local spoof_hints = {}
    local hnds_clear_spoof_cache

    hnds_clear_spoof_cache = function()
        spoof_cache = {}
    end

    local function hnds_clear_spoof_hints()
        spoof_hints = {}
    end

    local function hnds_impostor_is_active()
        if not (G and G.STAGE == G.STAGES.RUN) then
            if hnds_impostor_available then
                hnds_impostor_available = false
                hnds_primary_impostor_id = nil
                hnds_cached_round = -1
                hnds_cached_joker_count = -1
                hnds_cached_hand_tick = -1
                hnds_clear_spoof_cache()
                hnds_clear_spoof_hints()
            end
            return false
        end
        local current_round = (G and G.GAME and G.GAME.current_round and G.GAME.current_round.round) or 0
        local joker_count = (G and G.jokers and G.jokers.cards and #G.jokers.cards) or 0
        local hands_played = (G and G.GAME and G.GAME.current_round and G.GAME.current_round.hands_played) or 0
        local discards_used = (G and G.GAME and G.GAME.current_round and G.GAME.current_round.discards_used) or 0
        local hand_tick = hands_played * 1024 + discards_used

        if hand_tick ~= hnds_cached_hand_tick then
            hnds_cached_hand_tick = hand_tick
            hnds_clear_spoof_cache()
        end

        if current_round ~= hnds_cached_round then
            hnds_cached_round = current_round
            hnds_clear_spoof_hints()
        end

        local needs_recalc = (joker_count ~= hnds_cached_joker_count)

        if needs_recalc then
            hnds_cached_joker_count = joker_count
            hnds_impostor_available = false
            hnds_primary_impostor_id = nil
            hnds_clear_spoof_cache()
            hnds_clear_spoof_hints()

            if G and G.jokers and G.jokers.cards then
                for i = 1, #G.jokers.cards do
                    local jc = G.jokers.cards[i]
                    if jc and jc.config and jc.config.center and jc.config.center.key == 'j_hnds_imposter' then
                        hnds_impostor_available = true
                        hnds_primary_impostor_id = jc.ID or jc.sort_id or ('hnds_imposter_' .. tostring(i))
                        break
                    end
                end
            end

            hnds_impostor_available = hnds_impostor_available and HNDS and HNDS.imposter_rank_match
        end
        return hnds_impostor_available
    end

    local function hnds_context_signature(context, target)
        local sig = ''
        if context.individual then sig = sig .. 'i' end
        if context.repetition then sig = sig .. 'r' end
        if context.other_joker then sig = sig .. 'o' end
        if context.before then sig = sig .. 'b' end
        if context.after then sig = sig .. 'a' end
        if context.cardarea then sig = sig .. 'c' end
        if context.joker_main then sig = sig .. 'm' end
        if context.joker_act then sig = sig .. 'x' end
        if context.joker_post then sig = sig .. 'p' end
        if context.scoring_hand then sig = sig .. 's' end
        if context.discard then sig = sig .. 'd' end
        if context.destroying_card then sig = sig .. 'D' end
        if context.setting_blind then sig = sig .. 'B' end
        if context.other_joker and context.other_joker.config and context.other_joker.config.center then
            sig = sig .. '|oj:' .. (context.other_joker.config.center.key or '')
        end
        if context.blind and context.blind.config and context.blind.config.blind then
            sig = sig .. '|blind:' .. (context.blind.config.blind.key or '')
        end
        if target then
            local target_key = target.ID or target.sort_id or (target.base and target.base.id) or tostring(target)
            sig = sig .. '|t:' .. tostring(target_key)
        end
        return sig
    end

    function Card:calculate_joker(context, ...)
		local hnds_args = {...}
		if (self.area and self.area.config and self.area.config.collection) then
			hnds_impostor_is_active()
			return calculate_joker_ref(self, context, hnds_unpack(hnds_args))
		end

		if not (G and G.STAGE == G.STAGES.RUN) then
			hnds_impostor_is_active()
			return calculate_joker_ref(self, context, hnds_unpack(hnds_args))
		end

        if not (self.ability and self.ability.set == 'Joker' and self.added_to_deck) then
            return calculate_joker_ref(self, context, hnds_unpack(hnds_args))
        end

		if type(context) ~= 'table' then
			return calculate_joker_ref(self, context, hnds_unpack(hnds_args))
		end

        if not (context.individual or context.repetition or context.other_joker or context.before or context.after or context.cardarea
            or context.joker_main or context.joker_act or context.joker_post or context.destroying_card or context.setting_blind) then
            return calculate_joker_ref(self, context, hnds_unpack(hnds_args))
        end

		local eff, post = calculate_joker_ref(self, context, hnds_unpack(hnds_args))

        if not hnds_impostor_is_active() then
            return eff, post
        end

        local joker_key = self.config and self.config.center and self.config.center.key
        if joker_key == 'j_hnds_imposter' then
            return eff, post
        end

        if joker_key == 'j_cloud_9' then
            return eff, post
        end

        local target = context.other_card or context.card or context.cardarea or nil
        if not target or not target.get_id or not target.ability then
            return eff, post
        end

        if target.ability.set == 'Tarot' or
           target.ability.set == 'Planet' or
           target.ability.set == 'Spectral' or
           target.ability.set == 'Voucher' or
           target.ability.consumeable then
            return eff, post
        end

        if target.ability.set ~= 'Default' and target.ability.set ~= 'Enhanced' then
            return eff, post
        end

        if SMODS and SMODS.has_no_rank and SMODS.has_no_rank(target) then
            return eff, post
        end

        local target_id = target:get_id()
        if not target_id or target_id < 11 or target_id > 13 then
            return eff, post
        end

        if eff or post then
            if type(eff) == 'table' and next(eff) then return eff, post end
            if type(post) == 'table' and #post > 0 then return eff, post end
        end

        if not joker_key then
            return eff, post
        end

        local cache_key = self.ID or self.sort_id or joker_key or 'unknown'
        local sig = hnds_context_signature(context, target)
        local round_index = (G and G.GAME and G.GAME.current_round and G.GAME.current_round.round) or 0
        local hint_key = joker_key .. '|r:' .. tostring(round_index) .. '|' .. hnds_context_signature(context, nil)
        spoof_cache[cache_key] = spoof_cache[cache_key] or {}
        local cached_spoof = spoof_cache[cache_key][sig]
        local hint_spoof = spoof_hints[hint_key]
        local original_get_id = target.get_id

        		local function hnds_try_spoof(spoof_id)
			target.get_id = function() return spoof_id end
			local e, p = calculate_joker_ref(self, context, hnds_unpack(hnds_args))
			local has_e = e and (type(e) ~= 'table' or next(e))
			local has_p = p and (type(p) ~= 'table' or #p > 0)
			target.get_id = original_get_id
			if has_e or has_p then
				return e, p, true
            end
            return e, p, false
        end

        if type(cached_spoof) == 'number' then
            local e, p, ok = hnds_try_spoof(cached_spoof)
            if ok then
                return e, p
            end
        elseif cached_spoof == false then
            return eff, post
        end

        if type(hint_spoof) == 'number' then
            local e, p, ok = hnds_try_spoof(hint_spoof)
            if ok then
                spoof_cache[cache_key][sig] = hint_spoof
                return e, p
            end
            spoof_cache[cache_key][sig] = false
            return eff, post
        end

        		for spoof_id = 2, 14 do
			local e, p, ok = hnds_try_spoof(spoof_id)
			if ok then
                				spoof_cache[cache_key][sig] = spoof_id
				spoof_hints[hint_key] = spoof_id
				return e, p
			end
		end

		spoof_cache[cache_key][sig] = false
		return eff, post
	end
end