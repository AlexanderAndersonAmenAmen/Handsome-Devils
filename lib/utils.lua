--[[
Handsome Devils - Shared Utilities

Purpose
- This file holds shared helper functions used across multiple Handsome Devils systems.
- These helpers are intentionally kept "dumb" (no hooks) so they can be reused safely from:
  - Joker/consumable definitions
  - deck/stake logic
  - challenge logic
  - cross-mod compatibility glue

Who uses this
- `main.lua` and various content scripts call into `HNDS.*` helpers.
- `hooks.lua` relies on some helpers during run initialization and special deck logic.

Notable helpers
- `HNDS.get_unique_suits(scoring_hand, bypass_debuff, flush_calc)`
  - Counts distinct suits in a scoring hand, handling wild cards.

- `HNDS.poll_tag(seed, options, exclusions)`
  - Re-implements tag selection with exclusions, and fixes Orbital tag selection for modded hands.

- `HNDS.dyn_level_up(card, hand, level, chips, mult, instant)`
  - Applies hand level changes with the same timing/juice patterns as vanilla tarot/planet animations.

- `HNDS.get_shop_joker_tags()`
  - Returns a list of tag keys that can create shop jokers (extended when other mods are installed).

- `HNDS.table_shallow_copy`, `HNDS.get_key_for_value`
  - Small utility helpers used by deck/stake effects.

Notes / invariants
- Some functions consult `SMODS.find_mod(...)` to include optional compatibility behavior.
- This file should avoid hooking globals; that work belongs in `hooks.lua` / `challenge_rules.lua`.
--]]

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
	if not exclusions and not options then exclusions = { "tag_boss", "tag_top_up", "tag_speed" } end
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

-- Dynamic hand level up with animation and effects (used by various jokers/consumables)
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

-- Cursed Deck: Check if all joker slots are filled with unmovable jokers
-- (eternal or negative). Returns true when no slot can accept a new non-negative joker.
function HNDS.joker_slots_full_of_unmovables()
	if not (G and G.jokers and G.jokers.cards and G.jokers.config and G.jokers.config.card_limit) then return false end
	if #G.jokers.cards < G.jokers.config.card_limit then return false end
	for _, j in ipairs(G.jokers.cards) do
		if not j then return false end
		local is_eternal = j.ability and j.ability.eternal
		local is_negative = j.edition and j.edition.negative
		if not (is_eternal or is_negative) then return false end
	end
	return true
end

-- Return a list of all the jokers that create jokers in shop (for tag compatibility)
function HNDS.get_shop_joker_tags()
	local tag_list = {
		"tag_foil",
		"tag_holo",
		"tag_polychrome",
		"tag_negative",
		"vintage_tag",
		"tag_rare",
		"tag_uncommon",
		"tag_buffoon",
		"cursed_tag"
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

-- Rarity cycling system: Common -> Uncommon -> Rare -> Epic(Cryptid)/Legendary -> Common.
-- Used by effects that upgrade or cycle a joker's rarity.
HNDS.rarity_cycle = {
	Common = "Uncommon",
	Uncommon = "Rare",
	Rare = next(SMODS.find_mod("Cryptid")) and "cry_epic" or "Legendary",
	Legendary = "Common"
}

HNDS.get_next_rarity = function(rarity_key)
	return HNDS.rarity_cycle[rarity_key]
end

-- Get a random soul joker for defeating a blind (supports custom soul definitions).
-- `blind` should be G.GAME.blind. Other mods can define `blind.config.blind.hnds_soul`
-- to provide their own soul reward pools.
HNDS.get_blind_soul = function (blind, seed)
	local soul_opts = blind.config.blind.hnds_soul or HNDS.blind_souls[blind.config.blind.key] or {"j_joker"}
	local ret = pseudorandom_element(soul_opts, seed) or "j_joker"
	if G.P_CENTER_POOLS[ret] then
		ret = pseudorandom_element(G.P_CENTER_POOLS[ret]).key
	end
	return ret
end

-- Supersuit Joker: Reset the randomly chosen suit for the round
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

-- Dark Idol Joker: Reset the randomly chosen card for the round
function reset_dark_idol()
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

-- Circus Deck: pool of jokers that can be randomly assigned each ante.
-- One is picked at random (excluding the previous ante's pick) and placed
-- in an offscreen CardArea so it appears in find_joker() results.
HNDS.circus_joker_pool = {
	'j_hack',
	'j_juggler',
	'j_drunkard',
	'j_chaos',
	'j_sock_and_buskin',
	'j_smeared',
	'j_ring_master', -- Showman's internal key
	'j_oops',
	'j_vagabond',
	'j_astronomer',
	'j_sixth_sense',
	'j_hanging_chad',
	'j_dusk',
	'j_hnds_supersuit',
	'j_hnds_pot_of_greed'
}

-- Reset game globals: called at run start and at the beginning of each round.
-- Initializes round-specific variables, re-rolls per-round joker state
-- (Supersuit suit, Dark Idol card, Bizarre suit), and manages the Circus Deck's
-- rotating joker effect.
SMODS.current_mod.reset_game_globals = function(run_start)
	if run_start then
		G.GAME.ante_stones_scored = 0
		G.GAME.art_queue = 0
		G.GAME.hnds_exchange_minus = 1
	end

	-- Re-roll per-round joker state (suit/card changes every round)
	reset_supersuit_card()
	reset_dark_idol()
	bizzare_suit()

	-- Circus Deck: assign a random joker from the pool each ante.
	-- The joker lives in an offscreen CardArea and is found by find_joker().
	if HNDS.DeckOrSleeve('circus') then
		if not G.hnds_circus_joker then
			G.hnds_circus_joker = CardArea(
				17.5, 5.75, G.CARD_W, G.CARD_H,
				{card_limit = 1, highlighted_limit = 0, type = 'title'}
			)
		end

		if (G.GAME and G.GAME.blind) or run_start then
			-- Remove the previous joker
			if #G.hnds_circus_joker.cards > 0 then
				G.hnds_circus_joker.cards[1]:start_dissolve()
				G.hnds_circus_joker.cards = {}
			end

			-- Pick a new joker, excluding the one from last ante
			local poolcopy = HNDS.table_shallow_copy(HNDS.circus_joker_pool)
			if G.GAME.hnds_circus_joker_key then
				local i = HNDS.get_key_for_value(poolcopy, G.GAME.hnds_circus_joker_key)
				if i then table.remove(poolcopy, i) end
			end

			local new_joker = pseudorandom_element(poolcopy, pseudoseed('circus'))
			G.GAME.hnds_circus_joker_key = new_joker

			-- Silently add the joker to the offscreen area (transparent shader)
			local j = SMODS.add_card({set = 'Jokers', area = G.hnds_circus_joker, key = new_joker, no_edition = true, skip_materialize = true})
			j.ignore_base_shader = {true}
			j.ignore_shadow = {true}
		end
	else
		if G.hnds_circus_joker then
			G.hnds_circus_joker:remove()
		end
	end
end

---Copies the context of the table `t` non-recursively into a new table.
---@param t table
---@return table
function HNDS.table_shallow_copy(t)
	local t2 = {}
	for k,v in pairs(t) do
		t2[k] = v
	end
	return t2
end

-- Utility: Get key for a given value in a table
function HNDS.get_key_for_value(t, value)
  for k,v in pairs(t) do
    if v==value then return k end
  end
  return nil
end

-- Check if the active deck or sleeve matches the provided key.
-- Returns the match count (truthy) or nil. Supports CardSleeves mod and Entropy's
-- bought-deck system. (Pattern from Entropy)
function HNDS.DeckOrSleeve(key)
	local num = 0
	if CardSleeves and G.GAME.selected_sleeve == ("sleeve_hnds_"..key) then
		num = num + 1
	end
	for _, v in pairs(G.GAME.entr_bought_decks or {}) do
		if v == "b_hnds_"..key then num = num + 1 end
	end
	if G.GAME.selected_back and G.GAME.selected_back.effect.center.original_key == key then
		num = num + 1
	end
	return num > 0 and num or nil
end