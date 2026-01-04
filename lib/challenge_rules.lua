--[[
Handsome Devils - Challenge Runtime Rules

Rules implemented here
- Dark Ritual
  - Skips the shop by overriding `G.FUNCS.cash_out` when the challenge is active.

- Gambling Opportunity
  - Forces blind reward dollars to 0 by wrapping `G.FUNCS.evaluate_round`.
  - Prevents the Gold/Lucky enhancements from being applied/kept by:
    - wrapping `Card:set_ability` to remap `m_gold`/`m_lucky` -> `m_base`
    - wrapping `get_current_pool('Enhanced', ...)` to filter `m_gold`/`m_lucky` out of the enhancement pool
    - wrapping `Card:set_seal` to prevent Gold seals from being set
    - wrapping `Card:generate_card_ui` as a last-resort UI cleanup pass (safety net)
	- It breaks a bit the Spectrum spectral cards, sometime the cards will not obtain a seal

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

-- Shared, it helps to find the proper Challenge name needed to implement the Functions
local function HNDS_is_challenge(key)
	if not (G and G.GAME) then return false end
	local c = G.GAME.challenge
	if not c then return false end
	return c == key or c == ('c_'..key) or c == ('c_hnds_'..key) or c == ('hnds_'..key)
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

-- Gambling Opportunity
if Card and Card.generate_card_ui and not Card._hnds_wrapped_generate_card_ui then
	Card._hnds_wrapped_generate_card_ui = true
	local generate_card_ui_ref = Card.generate_card_ui
	function Card:generate_card_ui(_dim_table, _scale, _rotate, _hover, _focus, _major)
		local ret = generate_card_ui_ref(self, _dim_table, _scale, _rotate, _hover, _focus, _major)
		if HNDS_is_challenge('gambling_opportunity') then
			if self.config and self.config.center and (self.config.center.key == 'm_lucky' or self.config.center.key == 'm_gold') then
				self:set_ability(G.P_CENTERS.m_base, true)
			end
			if self.seal and self.seal == 'Gold' then
				self:set_seal(nil, true)
			end
		end
		return ret
	end
end

if Card and Card.set_ability and not Card._hnds_wrapped_set_ability then
	Card._hnds_wrapped_set_ability = true
	local set_ability_ref = Card.set_ability
	function Card:set_ability(center, initial, silent)
		if HNDS_is_challenge('gambling_opportunity') and center and (center.key == 'm_lucky' or center.key == 'm_gold') then
			center = G.P_CENTERS.m_base
		end
		return set_ability_ref(self, center, initial, silent)
	end
end

if Card and Card.set_seal and not Card._hnds_wrapped_set_seal then
	Card._hnds_wrapped_set_seal = true
	local set_seal_ref = Card.set_seal
	function Card:set_seal(seal, silent)
		-- Only block seal setting for gambling_opportunity if it's a Gold seal
		if HNDS_is_challenge('gambling_opportunity') and seal == 'Gold' then
			return set_seal_ref(self, 'Red', silent)
		end
		return set_seal_ref(self, seal, silent)
	end
end

if Card and Card.set_edition and not Card._hnds_wrapped_set_edition then
	Card._hnds_wrapped_set_edition = true
	local set_edition_ref = Card.set_edition
	function Card:set_edition(edition, immediate, silent)
		if not HNDS_is_challenge('gambling_opportunity') then
			return set_edition_ref(self, edition, immediate, silent)
		end
		if silent == nil and type(immediate) == 'boolean' then
			silent = immediate
			immediate = nil
		end
		return set_edition_ref(self, edition, immediate, silent)
	end
end

if get_current_pool and not _G._hnds_wrapped_get_current_pool then
	_G._hnds_wrapped_get_current_pool = true
	local get_current_pool_ref = get_current_pool
	function get_current_pool(_type, _rarity, _legendary, _append)
		local pool, pool_key = get_current_pool_ref(_type, _rarity, _legendary, _append)
		if HNDS_is_challenge('gambling_opportunity') and _type == 'Enhanced' and type(pool) == 'table' then
			local filtered_pool = {}
			for i = 1, #pool do
				local key = pool[i]
				if key ~= 'm_gold' and key ~= 'm_lucky' then
					filtered_pool[#filtered_pool + 1] = key
				end
			end
			pool = filtered_pool
		end
		return pool, pool_key
	end
end

-- Devil's Round
if CardArea and CardArea.emplace and not CardArea._hnds_wrapped_emplace then
	CardArea._hnds_wrapped_emplace = true
	local emplace_ref = CardArea.emplace
	function CardArea:emplace(card, ...)
		if card and card.config and card.config.center and card.config.center.set == 'Joker' and G.GAME and G.GAME.challenge == 'c_hnds_devils_round' then
			if not (card.ability and card.ability.hnds_eternal_copy_created) then
				if (not card.ability or not card.ability.curse) and apply_curse and type(apply_curse) == 'function' then
					apply_curse(card)
				end
			end
		end
		return emplace_ref(self, card, ...)
	end
end

if SMODS and SMODS.create_card and not SMODS._hnds_wrapped_create_card then
	SMODS._hnds_wrapped_create_card = true
	local smods_create_card_ref = SMODS.create_card
	function SMODS.create_card(args)
		local created_card = smods_create_card_ref(args)
		if created_card and created_card.config and created_card.config.center and created_card.config.center.set == 'Joker' and G.GAME and G.GAME.challenge == 'c_hnds_devils_round' then
			if not (created_card.ability and created_card.ability.hnds_eternal_copy_created) then
				if (not created_card.ability or not created_card.ability.curse) and apply_curse and type(apply_curse) == 'function' then
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
	if card and _type == "Joker" and G.GAME and G.GAME.challenge == 'c_hnds_devils_round' then
		if not (card.ability and card.ability.hnds_eternal_copy_created) then
			if (not card.ability or not card.ability.curse) and apply_curse and type(apply_curse) == 'function' then
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
	return ret
end