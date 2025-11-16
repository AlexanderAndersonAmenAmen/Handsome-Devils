
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
	Common = "Uncommon",
	Uncommon = "Rare",
	Rare = next(SMODS.find_mod("Cryptid")) and "cry_epic" or "Legendary",
	Legendary = "Common"
}

HNDS.get_next_rarity = function(rarity_key)
	return HNDS.rarity_cycle[rarity_key]
end

HNDS.blind_souls = {
    bl_hook = {"j_drunkard", next(SMODS.find_mod("GrabBag")) and "j_gb_hook" or nil},
    bl_ox = {"j_matador", next(SMODS.find_mod("GrabBag")) and "j_gb_ox" or nil},
    bl_house = {"j_burnt", "j_family", next(SMODS.find_mod("GrabBag")) and "j_gb_house" or nil},
    bl_wall = {"j_stone", "j_marble", "j_castle", "j_ancient", "j_bloodstone", next(SMODS.find_mod("GrabBag")) and "j_gb_wall" or nil},
    bl_wheel = {"j_8_ball", "j_bloodstone", "j_hallucination", "j_reserved_parking", "j_space", "j_business", "j_gros_michel", "j_hnds_banana_split", "j_hnds_energized", "j_hnds_jackpot", "j_hnds_ms_fortune", "j_oops", next(SMODS.find_mod("GrabBag")) and "j_gb_wheel" or nil},
    bl_arm = {"j_juggler", next(SMODS.find_mod("GrabBag")) and "j_gb_arm" or nil},
    bl_club = {"j_gluttenous_joker", "j_blackboard", "j_onyx_agate", "j_seeing_double", next(SMODS.find_mod("GrabBag")) and "j_gb_club" or nil},
    bl_fish = {"j_splash", "j_lucky_cat", "j_lucky_cat", "j_lucky_cat", next(SMODS.find_mod("GrabBag")) and "j_gb_fish" or nil},
	bl_psychic = {"j_sixth_sense", "j_seance", next(SMODS.find_mod("GrabBag")) and "j_gb_psychic" or nil},
	bl_goad = {"j_wrathful_joker", "j_blackboard", "j_arrowhead", next(SMODS.find_mod("GrabBag")) and "j_gb_goad" or nil},
	bl_water = {"j_splash", "j_splash", "j_splash", "j_burglar", next(SMODS.find_mod("GrabBag")) and "j_gb_water" or nil},
    bl_window = {"j_greedy_joker", "j_rough_gem", next(SMODS.find_mod("GrabBag")) and "j_gb_window" or nil},
    bl_manacle = {"j_burglar", "j_burglar", "j_burglar", "j_burglar", "j_burglar", "j_burglar", "j_merry_andy", "j_stuntman", next(SMODS.find_mod("GrabBag")) and "j_gb_manacle" or nil},
    bl_eye = {"j_sixth_sense", "j_obelisk", next(SMODS.find_mod("GrabBag")) and "j_gb_eye" or nil},
    bl_mouth = {"j_card_sharp", "Food", next(SMODS.find_mod("GrabBag")) and "j_gb_mouth" or nil},
    bl_plant = {"j_flower_pot", "j_flower_pot", "j_flower_pot", "j_flower_pot", "j_flower_pot", "j_flower_pot", "j_faceless", "j_green_joker", next(SMODS.find_mod("GrabBag")) and "j_gb_plant" or nil},
    bl_serpent = {"j_hnds_head_of_medusa", next(SMODS.find_mod("GrabBag")) and "j_gb_serpent" or nil},
    bl_pillar = {"j_obelisk", next(SMODS.find_mod("GrabBag")) and "j_gb_pillar" or nil},
    bl_needle = {"j_sixth_sense", "j_dna", next(SMODS.find_mod("GrabBag")) and "j_gb_needle" or nil},
    bl_head = {"j_lusty_joker", "j_bloodstone", next(SMODS.find_mod("GrabBag")) and "j_gb_head" or nil},
    bl_tooth = {"j_hnds_coffee_break", next(SMODS.find_mod("GrabBag")) and "j_gb_tooth" or nil},
    bl_flint = {"j_campfire", "j_campfire", "j_campfire", "j_hiker", next(SMODS.find_mod("GrabBag")) and "j_gb_flint" or nil},
    bl_mark = {"j_smiley", "j_scary_face", "j_photograph", "j_pareidolia", "j_sock_and_buskin", next(SMODS.find_mod("GrabBag")) and "j_gb_mark" or nil},
    bl_final_acorn = {"j_half", "j_wee", "j_wee", "j_wee", "j_wee", "j_wee", "j_wee", "j_square"},
    bl_final_leaf = {"j_luchador", "j_diet_cola", "j_invisible", "j_invisible", "j_invisible", "j_invisible", "j_invisible", "j_invisible"},
    bl_final_vessel = {"j_four_fingers", "j_8_ball", "j_sixth_sense", "j_fortune_teller"},
    bl_final_heart = {"j_lusty_joker", "j_bloodstone", "j_bloodstone", "j_bloodstone"},
    bl_final_bell = {"j_sixth_sense", "j_sixth_sense", "j_dna", "j_dna", "j_dna", "j_idol", "j_idol", "j_idol"}
}

if next(SMODS.find_mod("Entropy")) then
	for _ = 1, 4 do
		HNDS.blind_souls.bl_wheel[#HNDS.blind_souls.bl_wheel+1] = "Dice" --add a roughly 25% chance for a dice joker with entropy
	end
end

HNDS.get_blind_soul = function (blind, seed) --G.GAME.blind should go in here
	local soul_opts = blind.config.blind.hnds_soul or HNDS.blind_souls[blind.config.blind.key] or {"j_joker"} --allow other mods to define their own blind souls
    ret = pseudorandom_element(soul_opts, seed) or "j_joker" --in case someone has an exmpty list of souls for whatever reason
	if G.P_CENTER_POOLS[ret] then
		ret = pseudorandom_element(G.P_CENTER_POOLS[ret]).key
	end
	return ret
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

HNDS.circus_joker_pool = {
	'j_hack', 
	'j_juggler', 
	'j_drunkard', 
	'j_chaos', 
	'j_sock_and_buskin', 
	'j_smeared', 
	'j_ring_master', -- why the heck is showman called this in the game files bruh
	'j_oops',
	'j_vagabond', 
	'j_astronomer', 
	'j_sixth_sense', 
	'j_hanging_chad', 
	'j_dusk', 
	'j_hnds_supersuit', 
	'j_hnds_pot_of_greed'
}

SMODS.current_mod.reset_game_globals = function(run_start)
	if run_start then
		G.GAME.ante_stones_scored = 0
		G.GAME.art_queue = 0
		G.GAME.hnds_exchange_minus = 1
	end
	reset_supersuit_card()
    reset_dark_idol()
	bizzare_suit()

	-- The suit changes every round, so we use reset_game_globals to choose a suit.

	
	-- vv FOR CIRCUS DECK vv --

	if HNDS.DeckOrSleeve('circus') then

		if not G.hnds_circus_joker then
			G.hnds_circus_joker = CardArea (
				17.5, 5.75, G.CARD_W, G.CARD_H,
				{card_limit = 1, highlighted_limit = 0, type = 'title'}
			)
		end

		if ((G.GAME and G.GAME.blind and G.GAME.blind:get_type() == 'Boss') or run_start) then
			G.GAME.hnds_circus_joker_key = G.GAME.hnds_circus_joker_key or nil

			if #G.hnds_circus_joker.cards > 0 then
				G.hnds_circus_joker.cards[1]:start_dissolve() --remove the previous joker
				G.hnds_circus_joker.cards = {}
			end
			
			local poolcopy = HNDS.table_shallow_copy(HNDS.circus_joker_pool)
			if G.GAME.hnds_circus_joker_key then
				local i = HNDS.get_key_for_value(poolcopy, G.GAME.hnds_circus_joker_key)
				if i then
					table.remove(poolcopy, i) -- can't pick the same joker 2 antes in a row
				end
			end
			
			local new_joker = pseudorandom_element(poolcopy, pseudoseed('circus'))
			G.GAME.hnds_circus_joker_key = new_joker

			print('joker picked: ' .. new_joker)

			local j = SMODS.add_card({set = 'Jokers', area = G.hnds_circus_joker, key = new_joker, no_edition = true, skip_materialize = true}) --silently and sneakily add the joker to the offscreen cardarea
			j.ignore_base_shader = {true}
			j.ignore_shadow = {true} -- force ignore shadow/base shader for transparent shader
		end
	
	else
		if G.hnds_circus_joker then
			G.hnds_circus_joker:remove()
		end
	end

	-- PLATINUM STAKE --

	if G.GAME.stake == G.P_STAKES["stake_hnds_platinum"].stake_level and not run_start then

		print (G.GAME.chips .. " / " .. G.GAME.blind.chips)

		if G.GAME.chips >= (G.GAME.blind.chips * 2) then
			print("blind was beat by over 2X required score!")
			G.GAME.starting_params.ante_scaling = G.GAME.starting_params.ante_scaling * 2
		end
	end

end

local find_joker_ref = find_joker

function find_joker(name, non_debuff)

	local jokers = find_joker_ref(name, non_debuff)

	if G.hnds_circus_joker then
		for _, v in pairs(G.hnds_circus_joker.cards) do
			if v and type(v) == 'table' and v.ability.name == name and (non_debuff or not v.debuff) then
				table.insert(jokers, v)
			end
		end
	end

	return jokers

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

function HNDS.get_key_for_value(t, value)
  for k,v in pairs(t) do
    if v==value then return k end
  end
  return nil
end

--Checks if the active deck or sleeve is the provided key. Code from Entropy.
function HNDS.DeckOrSleeve(key)
    local num = 0
    if CardSleeves then
        if G.GAME.selected_sleeve == ("sleeve_hnds_"..key) then num = num + 1 end
    end
    for i, v in pairs(G.GAME.entr_bought_decks or {}) do
        if v == "b_hnds_"..key then num = num + 1 end
    end
    if  G.GAME.selected_back and G.GAME.selected_back.effect.center.original_key == key then num = num + 1 end
    return num > 0 and num or nil
end