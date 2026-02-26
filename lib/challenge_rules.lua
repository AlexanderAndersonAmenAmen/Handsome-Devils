--[[
Handsome Devils - Challenge Runtime Rules

Rules implemented here
- Dark Ritual
  - Skips the shop by overriding `G.FUNCS.cash_out` when the challenge is active.

- Gambling Opportunity
  - Bans money-generating enhancements, seals, and editions via configurable tables:
    - HNDS.GAMBLING_BANNED_ENHANCEMENTS (default: m_gold, m_lucky)
    - HNDS.GAMBLING_BANNED_SEALS (default: Gold)
    - HNDS.GAMBLING_BANNED_EDITIONS (default: e_hnds_vintage)
  - Other mods can append to these tables to extend the ban list.
  - Wraps Card:set_ability, Card:set_seal, Card:set_edition, get_current_pool, and
    Card:generate_card_ui (safety net) to enforce the bans.

- Devil's Round
  - Applies curses to Joker cards created/emplaced during the challenge by wrapping:
    - `CardArea:emplace`
    - `SMODS.create_card`
    - `create_card`
    - `Card:add_to_deck`

Invariants / safety
- Each wrapper is installed at most once using `_hnds_wrapped_*` flags.
- Wrappers are written to be no-ops when the relevant challenge is not active.
- Hooks avoid assuming globals exist at file load time (nil-guards on `G.FUNCS.*`, `Card.*`, etc.).
--]]

_G.HNDS_CHALLENGE_RULES_LOADED = true

-- Check if the current challenge matches the given key (SMODS format: c_hnds_<key>)
local function HNDS_is_challenge(key)
	return G and G.GAME and G.GAME.challenge == 'c_hnds_'..key
end

-- Dark Ritual
local function HNDS_dark_ritual_should_skip_shop()
	if not HNDS_is_challenge('dark_ritual') then return false end
	return true
end

if G and G.FUNCS and G.FUNCS.cash_out and not G.FUNCS._hnds_wrapped_cash_out then
	G.FUNCS._hnds_wrapped_cash_out = true
	local cash_out_ref = G.FUNCS.cash_out
	function G.FUNCS.cash_out(e, delay_seconds)
		if not HNDS_dark_ritual_should_skip_shop() then
			return cash_out_ref(e, delay_seconds)
		end

		stop_use()
		if G.round_eval then  
			e.config.button = nil
			G.round_eval.alignment.offset.y = G.ROOM.T.y + 15
			G.round_eval.alignment.offset.x = 0
			G.deck:shuffle('cashout'..G.GAME.round_resets.ante)
			G.deck:hard_set_T()
			delay(0.3)
			G.E_MANAGER:add_event(Event({
				trigger = 'immediate',
				func = function()
					if G.round_eval then 
						G.round_eval:remove()
						G.round_eval = nil
					end
					G.GAME.current_round.jokers_purchased = 0
					G.GAME.current_round.discards_left = math.max(0, G.GAME.round_resets.discards + G.GAME.round_bonus.discards)
					G.GAME.current_round.hands_left = (math.max(1, G.GAME.round_resets.hands + G.GAME.round_bonus.next_hands))
					-- KEY CHANGE: Skip shop and go directly to blind select
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
		end
		return
	end
end

-- Gambling Opportunity: banned money-generating enhancements, seals, and editions.
-- Other mods can append to these tables to extend the ban list.
HNDS = HNDS or {}
HNDS.GAMBLING_BANNED_ENHANCEMENTS = HNDS.GAMBLING_BANNED_ENHANCEMENTS or { m_gold = true, m_lucky = true }
HNDS.GAMBLING_BANNED_SEALS = HNDS.GAMBLING_BANNED_SEALS or { Gold = true }
HNDS.GAMBLING_BANNED_EDITIONS = HNDS.GAMBLING_BANNED_EDITIONS or { e_hnds_vintage = true }

-- Safety net: strip banned enhancements/seals that slipped through on UI render
if Card and Card.generate_card_ui and not Card._hnds_wrapped_generate_card_ui then
	Card._hnds_wrapped_generate_card_ui = true
	local generate_card_ui_ref = Card.generate_card_ui
	function Card:generate_card_ui(_dim_table, _scale, _rotate, _hover, _focus, _major)
		local ret = generate_card_ui_ref(self, _dim_table, _scale, _rotate, _hover, _focus, _major)
		if HNDS_is_challenge('gambling_opportunity') then
			if self.config and self.config.center and HNDS.GAMBLING_BANNED_ENHANCEMENTS[self.config.center.key] then
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
	function Card:set_ability(center, initial, silent)
		if HNDS_is_challenge('gambling_opportunity') and center and HNDS.GAMBLING_BANNED_ENHANCEMENTS[center.key] then
			center = G.P_CENTERS.m_base
		end
		return set_ability_ref(self, center, initial, silent)
	end
end

-- Block banned seals from being applied
if Card and Card.set_seal and not Card._hnds_wrapped_set_seal then
	Card._hnds_wrapped_set_seal = true
	local set_seal_ref = Card.set_seal
	function Card:set_seal(seal, silent)
		if HNDS_is_challenge('gambling_opportunity') and seal and HNDS.GAMBLING_BANNED_SEALS[seal] then
			return set_seal_ref(self, nil, silent)
		end
		return set_seal_ref(self, seal, silent)
	end
end

-- Block banned editions from being applied
if Card and Card.set_edition and not Card._hnds_wrapped_set_edition then
	Card._hnds_wrapped_set_edition = true
	local set_edition_ref = Card.set_edition
	function Card:set_edition(edition, immediate, silent)
		if HNDS_is_challenge('gambling_opportunity') and edition and HNDS.GAMBLING_BANNED_EDITIONS[edition] then
			return set_edition_ref(self, nil, immediate, silent)
		end
		return set_edition_ref(self, edition, immediate, silent)
	end
end

-- Filter banned enhancements from the pool
if get_current_pool and not _G._hnds_wrapped_get_current_pool then
	_G._hnds_wrapped_get_current_pool = true
	local get_current_pool_ref = get_current_pool
	function get_current_pool(_type, _rarity, _legendary, _append)
		local pool, pool_key = get_current_pool_ref(_type, _rarity, _legendary, _append)
		if HNDS_is_challenge('gambling_opportunity') and _type == 'Enhanced' and type(pool) == 'table' then
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
local function try_devils_round_curse(card)
	if not HNDS_is_challenge('devils_round') then return end
	if not (card and card.config and card.config.center and card.config.center.set == 'Joker') then return end
	if card.ability and card.ability.hnds_eternal_copy_created then return end
	if card.ability and card.ability.hnds_curse then return end
	if not (apply_curse and type(apply_curse) == 'function') then return end
	apply_curse(card)
end

-- Wrap three card-creation paths to ensure full coverage.
if CardArea and CardArea.emplace and not CardArea._hnds_wrapped_emplace then
	CardArea._hnds_wrapped_emplace = true
	local emplace_ref = CardArea.emplace
	function CardArea:emplace(card, ...)
		try_devils_round_curse(card)
		return emplace_ref(self, card, ...)
	end
end

if SMODS and SMODS.create_card and not SMODS._hnds_wrapped_create_card then
	SMODS._hnds_wrapped_create_card = true
	local smods_create_card_ref = SMODS.create_card
	function SMODS.create_card(args)
		local card = smods_create_card_ref(args)
		try_devils_round_curse(card)
		return card
	end
end

local create_card_ref = create_card
function create_card(_type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append)
	local card = create_card_ref(_type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append)
	try_devils_round_curse(card)
	return card
end

-- Also apply curses when a joker is added to the deck
-- (catches jokers that bypass the creation wrappers, e.g. from tags).
local add_to_deck_ref = Card.add_to_deck
function Card:add_to_deck(from_debuff)
	local ret = add_to_deck_ref(self, from_debuff)
	if not from_debuff then
		try_devils_round_curse(self)
		if self.ability and self.ability.hnds_curse and not self.ability.hnds_curse_acquire_triggered
			and trigger_curse and type(trigger_curse) == 'function' then
			trigger_curse(self, {buying_card = true, challenge_creation = true})
		end
	end
	return ret
end