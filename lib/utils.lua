
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
	local r = nil
	for i = 1, #HNDS.rarity_cycle do
		if HNDS.rarity_cycle[i] == rarity_key then                   --check to find the current rarity, will attempt to find the next existing rarity in the table after
			r = i+1
		end
	end
	return G.P_JOKER_RARITY_POOLS[r] and r or 1
end


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

SMODS.current_mod.reset_game_globals = function(run_start)
	if run_start then
		G.GAME.ante_stones_scored = 0
	end
	G.GAME.green_seal_draws = {}
	reset_supersuit_card()
    reset_dark_idol()

	-- The suit changes every round, so we use reset_game_globals to choose a suit.

end
