 --black seal and such card destruction hook
HNDS.should_hand_destroy = function(card)
	return card.seal == "hnds_black" or (G.GAME.used_vouchers.v_hnds_soaked and card == G.hand.cards[1]) or
	(G.GAME.used_vouchers.v_hnds_beyond and card == G.hand.cards[#G.hand.cards])
end

local destroy_cards_ref = SMODS.calculate_destroying_cards
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

local get_new_boss_ref = get_new_boss --crystal deck double showdown hook
function get_new_boss()
	local win_ante = G.GAME.win_ante
	if G.GAME.modifiers.hnds_double_showdown and G.GAME.round_resets.ante and G.GAME.round_resets.ante < G.GAME.win_ante then
		G.GAME.win_ante = math.floor(G.GAME.win_ante / 2)
	end
	local boss = get_new_boss_ref()
	G.GAME.win_ante = win_ante
	return boss
end

local set_cost_ref = Card.set_cost --premium deck and coffee break cost hook
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

if CardArea and CardArea.emplace and not CardArea._hnds_wrapped_emplace then
	CardArea._hnds_wrapped_emplace = true
	local emplace_ref = CardArea.emplace
	function CardArea:emplace(card, ...)
		-- Apply curse immediately for Devil's Round challenge before any other logic
		if card and card.config and card.config.center and card.config.center.set == 'Joker' and G.GAME and G.GAME.challenge == 'c_hnds_devils_round' then
			-- Don't apply curse to eternal copies
			if not (card.ability and card.ability.hnds_eternal_copy_created) then
				if (not card.ability or not card.ability.curse) and apply_curse and type(apply_curse) == 'function' then
					apply_curse(card)
				end
			end
		end
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

if SMODS and SMODS.create_card and not SMODS._hnds_wrapped_create_card then
	SMODS._hnds_wrapped_create_card = true
	local smods_create_card_ref = SMODS.create_card
	function SMODS.create_card(args)
		local created_card = smods_create_card_ref(args)
		-- Apply curse immediately for Devil's Round challenge
		if created_card and created_card.config and created_card.config.center and created_card.config.center.set == 'Joker' and G.GAME and G.GAME.challenge == 'c_hnds_devils_round' then
			-- Don't apply curse to eternal copies
			if not (created_card.ability and created_card.ability.hnds_eternal_copy_created) then
				if (not created_card.ability or not created_card.ability.curse) and apply_curse and type(apply_curse) == 'function' then
					apply_curse(created_card)
				end
			end
		end
		
		-- Keep existing logic for shop curses
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

create_card_ref = create_card
function create_card(_type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append)
	local card = create_card_ref(_type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append)
	
	-- Apply curse immediately for Devil's Round challenge
	if card and _type == "Joker" and G.GAME and G.GAME.challenge == 'c_hnds_devils_round' then
		-- Don't apply curse to eternal copies
		if not (card.ability and card.ability.hnds_eternal_copy_created) then
			if (not card.ability or not card.ability.curse) and apply_curse and type(apply_curse) == 'function' then
				apply_curse(card)
			end
		end
	end
	
	if card and next(SMODS.find_card("j_hnds_krusty")) and card.config then
		for _, t in ipairs(G.P_CENTER_POOLS.Food) do
			if t.key == card.config.center.key then
				card:set_edition("e_negative")
				break
			end
		end
	end
	if card and _type == "Joker" and ((area == G.shop_jokers) or (card.area == G.shop_jokers)) and G.GAME and G.GAME.modifiers and G.GAME.modifiers.enable_curses then
		if (not card.ability or not card.ability.curse) and apply_curse and type(apply_curse) == 'function' then
			G.GAME.modifiers.hnds_shop_curse_roll = (G.GAME.modifiers.hnds_shop_curse_roll or 0) + 1
			if pseudorandom('hnds_curse_shop'..G.GAME.modifiers.hnds_shop_curse_roll) < 0.12 then
				apply_curse(card)
			end
		end
	end
	return card
end

local add_to_deck_ref = Card.add_to_deck
function Card:add_to_deck(from_debuff)
	local ret = add_to_deck_ref(self, from_debuff)
	if not from_debuff and self and self.config and self.config.center and self.config.center.set == 'Joker' and G.GAME and G.GAME.challenge == 'c_hnds_devils_round' then
		if not (self.ability and self.ability.hnds_eternal_copy_created) then
			if (not self.ability or not self.ability.curse) and apply_curse and type(apply_curse) == 'function' then
				apply_curse(self)
				if self.ability and self.ability.curse and not self.ability.curse_acquire_triggered and trigger_curse and type(trigger_curse) == 'function' then
					trigger_curse(self, {buying_card = true, challenge_creation = true})
				end
			end
		end
	end
	if not from_debuff and self.ability.hnds_copies_to_create then
		for _ = 1, self.ability.hnds_copies_to_create do
			if #G.jokers.cards + G.GAME.joker_buffer < G.jokers.config.card_limit then
				G.GAME.joker_buffer = G.GAME.joker_buffer + 1
				local source_card = self
				G.E_MANAGER:add_event(Event{
					func = function ()
						local copy = copy_card(source_card)
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

-- Impostor code (Highly Optimized - Context Aware)
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