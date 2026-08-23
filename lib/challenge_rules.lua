-- Check if the current challenge matches the given key (SMODS format: c_hnds_<key>)
local function is_challenge(key)
	return G and G.GAME and G.GAME.challenge == 'c_hnds_'..key
end

-- Shared cash-out teardown used by Dark Ritual and Time Fc#ked Joker: tear
-- down the round-eval UI, reset round counters, pay out, and re-enter Blind
-- Select without creating a Shop.
-- opts.before runs after the round-eval guard passes (e.g. effect sounds);
-- opts.mid_event runs inside the immediate event after the eval is removed
-- and before counters reset (e.g. restoring replay state).
-- Load order note: challenge_rules loads before time_fcked so Time Fc#ked's
-- own cash-out wrapper sits outermost.
function HNDS.cash_out_skip_to_blind_select(e, opts)
	opts = opts or {}
	stop_use()
	if not G.round_eval then return false end

	if opts.before then opts.before() end

	if e and e.config then e.config.button = nil end
	G.round_eval.alignment.offset.y = G.ROOM.T.y + 15
	G.round_eval.alignment.offset.x = 0
	if G.deck then
		G.deck:shuffle('cashout'..G.GAME.round_resets.ante)
		G.deck:hard_set_T()
	end
	delay(0.3)
	G.E_MANAGER:add_event(Event({
		trigger = 'immediate',
		func = function()
			if G.round_eval then
				G.round_eval:remove()
				G.round_eval = nil
			end
			if opts.mid_event then opts.mid_event() end
			G.GAME.current_round.jokers_purchased = 0
			G.GAME.current_round.discards_left = math.max(0, G.GAME.round_resets.discards + G.GAME.round_bonus.discards)
			G.GAME.current_round.hands_left = (math.max(1, G.GAME.round_resets.hands + G.GAME.round_bonus.next_hands))
			G.STATE = G.STATES.BLIND_SELECT
			G.STATE_COMPLETE = false
			return true
		end
	}))
	ease_dollars(G.GAME.current_round.dollars)
	G.E_MANAGER:add_event(Event({
		func = function()
			G.GAME.previous_round.dollars = G.GAME.dollars
			return true
		end
	}))
	play_sound('coin7')
	G.VIBRATION = G.VIBRATION + 1
	return true
end

-- Dark Ritual
	if G and G.FUNCS and type(G.FUNCS.cash_out) == 'function' and not G.FUNCS._hnds_wrapped_cash_out then
		G.FUNCS._hnds_wrapped_cash_out = true
		local cash_out_ref = G.FUNCS.cash_out
		function G.FUNCS.cash_out(e, delay_seconds, ...)
		if not is_challenge('dark_ritual') then
			return cash_out_ref(e, delay_seconds, ...)
		end

		HNDS.cash_out_skip_to_blind_select(e)
		return
	end
end

-- Gambling Opportunity: banned money-generating enhancements, seals, and editions.
-- Other mods can append to these tables to extend the ban list.
HNDS.GAMBLING_BANNED_ENHANCEMENTS = HNDS.GAMBLING_BANNED_ENHANCEMENTS or { m_gold = true, m_lucky = true }
HNDS.GAMBLING_BANNED_SEALS = HNDS.GAMBLING_BANNED_SEALS or { Gold = true }
HNDS.GAMBLING_BANNED_EDITIONS = HNDS.GAMBLING_BANNED_EDITIONS or { e_hnds_vintage = true }

-- Safety net: strip banned enhancements/seals that slipped through on UI render
if Card and Card.generate_card_ui and not Card._hnds_wrapped_generate_card_ui then
	Card._hnds_wrapped_generate_card_ui = true
	local generate_card_ui_ref = Card.generate_card_ui
	function Card:generate_card_ui(_dim_table, _scale, _rotate, _hover, _focus, _major, ...)
		local ret = generate_card_ui_ref(self, _dim_table, _scale, _rotate, _hover, _focus, _major, ...)
		if is_challenge('gambling_opportunity') then
			if self.config and self.config.center and HNDS.GAMBLING_BANNED_ENHANCEMENTS[self.config.center.key]
				and G and G.P_CENTERS and G.P_CENTERS.m_base then
				self:set_ability(G.P_CENTERS.m_base, true)
			end
			if self.seal and HNDS.GAMBLING_BANNED_SEALS[self.seal] then
				self:set_seal(nil, true)
			end
		end
		return ret
	end
end

-- Block banned enhancements from being applied
if Card and Card.set_ability and not Card._hnds_wrapped_set_ability then
	Card._hnds_wrapped_set_ability = true
	local set_ability_ref = Card.set_ability
	function Card:set_ability(center, initial, silent, ...)
		if is_challenge('gambling_opportunity') and center and HNDS.GAMBLING_BANNED_ENHANCEMENTS[center.key]
			and G and G.P_CENTERS and G.P_CENTERS.m_base then
			center = G.P_CENTERS.m_base
		end
		return set_ability_ref(self, center, initial, silent, ...)
	end
end

-- Block banned seals from being applied
if Card and Card.set_seal and not Card._hnds_wrapped_set_seal then
	Card._hnds_wrapped_set_seal = true
	local set_seal_ref = Card.set_seal
	function Card:set_seal(seal, silent, ...)
		if is_challenge('gambling_opportunity') and seal and HNDS.GAMBLING_BANNED_SEALS[seal] then
			return set_seal_ref(self, nil, silent, ...)
		end
		return set_seal_ref(self, seal, silent, ...)
	end
end

-- Block banned editions from being applied
if Card and Card.set_edition and not Card._hnds_wrapped_set_edition then
	Card._hnds_wrapped_set_edition = true
	local set_edition_ref = Card.set_edition
	function Card:set_edition(edition, immediate, silent, ...)
		if is_challenge('gambling_opportunity') and edition and HNDS.GAMBLING_BANNED_EDITIONS[edition] then
			return set_edition_ref(self, nil, immediate, silent, ...)
		end
		return set_edition_ref(self, edition, immediate, silent, ...)
	end
end

-- Filter banned enhancements from the pool
if get_current_pool and not _G._hnds_wrapped_get_current_pool then
	_G._hnds_wrapped_get_current_pool = true
	local get_current_pool_ref = get_current_pool
	function get_current_pool(_type, _rarity, _legendary, _append, ...)
		local pool, pool_key = get_current_pool_ref(_type, _rarity, _legendary, _append, ...)
		if is_challenge('gambling_opportunity') and _type == 'Enhanced' and type(pool) == 'table' then
			local filtered = {}
			for i = 1, #pool do
				if not HNDS.GAMBLING_BANNED_ENHANCEMENTS[pool[i]] then
					filtered[#filtered + 1] = pool[i]
				end
			end
			pool = filtered
		end
		return pool, pool_key
	end
end

-- Devil's Round: all jokers get cursed on creation.
-- Shared helper: apply curse to a joker if it's eligible and the challenge is active.
function HNDS.try_devils_round_curse(card)
	if not is_challenge('devils_round') then return end
	if not (card and card.config and card.config.center and card.config.center.set == 'Joker') then return end
	if card.ability and card.ability.hnds_eternal_copy_created then return end
	if not (apply_curse and type(apply_curse) == 'function') then return end
	apply_curse(card)
end

