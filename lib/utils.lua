


function HNDS.get_unique_suits(scoring_hand, bypass_debuff, flush_calc)

	local suits = {}

	for k, _ in pairs(SMODS.Suits) do
		suits[k] = 0
	end


	for _, card in ipairs(scoring_hand or {}) do
		if not (HNDS.safe_has_any_suit and HNDS.safe_has_any_suit(card) or false) then
			for suit, count in pairs(suits) do
				if card:is_suit(suit, bypass_debuff, flush_calc) and count == 0 then
					suits[suit] = count + 1
					break
				end
			end
		end
	end


	for _, card in ipairs(scoring_hand or {}) do
		if HNDS.safe_has_any_suit and HNDS.safe_has_any_suit(card) then
			for suit, count in pairs(suits) do
				if card:is_suit(suit, bypass_debuff, flush_calc) and count == 0 then
					suits[suit] = count + 1
					break
				end
			end
		end
	end


	local num_suits = 0

	for _, v in pairs(suits) do
		if v > 0 then
			num_suits = num_suits + 1
		end
	end

	return num_suits
end


function HNDS.poll_tag(seed, options, exclusions)
	if not exclusions and not options then exclusions = { 'tag_boss', 'tag_top_up', 'tag_speed' } end


	local source_pool = options or get_current_pool('Tag') or {}
	local excluded = {}
	for _, key in ipairs(exclusions or {}) do excluded[key] = true end
	local pool = {}
	for _, key in ipairs(type(source_pool) == 'table' and source_pool or {}) do
		if key ~= 'UNAVAILABLE' and not excluded[key]
			and (not G or not G.P_TAGS or G.P_TAGS[key])
		then
			pool[#pool + 1] = key
		end
	end


	if #pool == 0 then
		local fallback = G and G.P_TAGS and (G.P_TAGS.tag_handy and 'tag_handy' or G.P_TAGS.tag_double and 'tag_double')


		return Tag(fallback or 'tag_handy')
	end

	local tag_key = pseudorandom_element(pool, pseudoseed(seed))
	if not tag_key then return nil end
	local tag = Tag(tag_key)
	if not tag then return nil end


	if tag_key == 'tag_orbital' then
		local available_hands = {}
		for k, hand in pairs((G and G.GAME and G.GAME.hands) or {}) do
			if hand and hand.visible then available_hands[#available_hands + 1] = k end
		end
		if #available_hands > 0 and tag.ability then
			tag.ability.orbital_hand = pseudorandom_element(available_hands, pseudoseed(seed .. '_orbital'))
		end
	end

	return tag
end


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


function HNDS.get_shop_joker_tags()
	local tag_list = {
		"tag_foil",
		"tag_holo",
		"tag_polychrome",
		"tag_negative",
		"tag_hnds_vintage_tag",
		"tag_rare",
		"tag_uncommon",
		"tag_buffoon",
		"tag_hnds_cursed_tag"
	}


	if HNDS.mod_loaded and HNDS.mod_loaded('paperback') then
		table.insert(tag_list, "tag_paperback_dichrome")
	end

	if HNDS.mod_loaded and HNDS.mod_loaded('Pokermon') then
		table.insert(tag_list, "tag_poke_shiny_tag")
		table.insert(tag_list, "tag_poke_stage_one_tag")
		table.insert(tag_list, "tag_poke_safari_tag")
	end

	if HNDS.mod_loaded and HNDS.mod_loaded('Cryptid') then
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

	if HNDS.mod_loaded and HNDS.mod_loaded('entr') then
		table.insert(tag_list, "tag_entr_sunny")
		table.insert(tag_list, "tag_entr_solar")
		table.insert(tag_list, "tag_entr_fractured")
		table.insert(tag_list, "tag_entr_freaky")
		table.insert(tag_list, "tag_entr_neon")
		table.insert(tag_list, "tag_entr_lowres")
		table.insert(tag_list, "tag_entr_kaleidoscopic")
	end

	if HNDS.mod_loaded and HNDS.mod_loaded('GARBPACK') then
		table.insert(tag_list, "tag_garb_carnival")
	end

	if HNDS.mod_loaded and HNDS.mod_loaded('ortalab') then
		table.insert(tag_list, "tag_ortalab_common")
		table.insert(tag_list, "tag_ortalab_anaglyphic")
		table.insert(tag_list, "tag_ortalab_fluorescent")
		table.insert(tag_list, "tag_ortalab_greyscale")
		table.insert(tag_list, "tag_ortalab_overexposed")
		table.insert(tag_list, "tag_ortalab_soul")
	end

	if HNDS.mod_loaded and HNDS.mod_loaded('MoreFluff') then
		table.insert(tag_list, "tag_mf_moddedpack")
		if Entropy then
			table.insert(tag_list, "tag_mf_absolute")
		end
	end

	if HNDS.mod_loaded and HNDS.mod_loaded('Bunco') then
		table.insert(tag_list, "tag_bunc_glitter")
		table.insert(tag_list, "tag_bunc_fuorescent")
	end

	if HNDS.mod_loaded and HNDS.mod_loaded('JoyousSpring') then
		table.insert(tag_list, "tag_joy_monster")
	end

	if HNDS.mod_loaded and HNDS.mod_loaded('allinjest') then
		table.insert(tag_list, "tag_aij_soulbound")
		table.insert(tag_list, "tag_aij_glimmer")
		table.insert(tag_list, "tag_aij_stellar")
	end

	if HNDS.mod_loaded and HNDS.mod_loaded('Yahimod') then
		table.insert(tag_list, "tag_yahimod_tag_yahimodrare")
	end

	if HNDS.mod_loaded and HNDS.mod_loaded('Bakery') then
		table.insert(tag_list, "tag_Bakery_RetriggerTag")
	end

	if HNDS.mod_loaded and HNDS.mod_loaded('RevosVault') then
		table.insert(tag_list, "tag_crv_pst")
		table.insert(tag_list, "tag_crv_reintag")
	end

	return tag_list
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
	local supersuit_card = #supersuit_suits > 0
		and pseudorandom_element(supersuit_suits, pseudoseed("sup" .. G.GAME.round_resets.ante)) or nil


	if supersuit_card then G.GAME.current_round.supersuit_card.suit = supersuit_card end
end


function reset_dark_idol()
	G.GAME.current_round.dark_idol = { suit = 'Spades', rank = 'Ace' }
	local valid_dark_idol_cards = {}
	for _, v in ipairs((G and G.playing_cards) or {}) do
		local no_suit = HNDS.safe_has_no_suit and HNDS.safe_has_no_suit(v) or false
		local no_rank = HNDS.safe_has_no_rank and HNDS.safe_has_no_rank(v) or false
		if not no_suit and not no_rank then
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
	'j_ring_master',
	'j_oops',
	'j_vagabond',
	'j_astronomer',
	'j_seance',
	'j_hanging_chad',
	'j_dusk',
	'j_hnds_supersuit',
	'j_hnds_pot_of_greed'
}


SMODS.current_mod.reset_game_globals = function(run_start)
	if run_start then
		G.GAME.ante_stones_scored = 0
		G.GAME.art_queue = 0
		G.GAME.hnds_exchange_hand_penalty = 0
	end


	for _, card in ipairs((G and G.playing_cards) or {}) do
		if card and card.ability and card.ability.hnds_exchange_draw then
			card.ability.hnds_exchange_draw = nil
			if not card.edition and card.set_edition then
				card:set_edition("e_negative", true, true)
			end
		end
	end


	if G.GAME.current_round then
		G.GAME.current_round.hnds_bound_cards_drawn = nil
	end


	reset_supersuit_card()
	reset_dark_idol()


	if HNDS.DeckOrSleeve('circus') then
		if (G.GAME and G.GAME.blind) or run_start then

			if #G.hnds_circus_joker.cards > 0 then
				G.hnds_circus_joker.cards[1]:start_dissolve()
				G.hnds_circus_joker.cards = {}
			end


			local poolcopy = SMODS.shallow_copy(HNDS.circus_joker_pool)
			if G.GAME.hnds_circus_joker_key then
				local i = HNDS.get_key_for_value(poolcopy, G.GAME.hnds_circus_joker_key)
				if i then table.remove(poolcopy, i) end
			end

			local new_joker = pseudorandom_element(poolcopy, pseudoseed('circus'))
			G.GAME.hnds_circus_joker_key = new_joker

			local old_ban_state = G.GAME.banned_keys[new_joker]
			G.GAME.banned_keys[new_joker] = nil
			local ok_add, j = pcall(SMODS.add_card, { area = G.hnds_circus_joker, key = new_joker, set = "Joker", no_edition = true, key_append = "hnds_circus" })
			G.GAME.banned_keys[new_joker] = old_ban_state
			if not ok_add then error(j) end
			if j then
				j.ignore_base_shader = j.ignore_base_shader or {}
				j.ignore_base_shader.hnds_circus = true
				j.ignore_shadow = j.ignore_shadow or {}
				j.ignore_shadow.hnds_circus = true
				j.hnds_circus = true
			end
		end
	elseif G.hnds_circus_joker then
		G.hnds_circus_joker:remove()
	end
end

SMODS.current_mod.custom_card_areas = function (game)
	if HNDS.DeckOrSleeve("circus") then
		game.hnds_circus_joker = CardArea(
			17.5, 5.75, G.CARD_W, G.CARD_H,
			{ card_limit = 1, highlighted_limit = 0, type = 'title' }
		)
	end
end


function HNDS.get_key_for_value(t, value)
  for k,v in pairs(t) do
    if v==value then return k end
  end
  return nil
end


function HNDS.DeckOrSleeve(key)
	local num = 0
	if CardSleeves and G.GAME.selected_sleeve == ("sleeve_hnds_"..key.."_sleeve") then
		num = num + 1
	end
	for _, v in pairs(G.GAME.entr_bought_decks or {}) do
		if v == "b_hnds_"..key then num = num + 1 end
	end
	if G.GAME.selected_back and G.GAME.selected_back.effect.center.key == ("b_hnds_"..key) then
		num = num + 1
	end
	return num > 0 and num or nil
end


function HNDS.sleeve_loc(self, deck_key, vars)
	local key = self.key
	if self.get_current_deck_key() == deck_key then key = key .. "_alt" end
	return { key = key, vars = vars }
end


function HNDS.grant_vouchers(vouchers)
	for _, v in ipairs(vouchers) do
		if G.P_CENTERS[v] then
			G.GAME.used_vouchers[v] = true
			G.GAME.starting_voucher_count = (G.GAME.starting_voucher_count or 0) + 1
			G.E_MANAGER:add_event(Event({
				func = function()
					Card.apply_to_run(nil, G.P_CENTERS[v])
					return true
				end
			}))
		end
	end
end


function HNDS.ban_non_magic_boosters()
	for _, booster in pairs(G.P_CENTER_POOLS.Booster) do
		if booster.kind ~= "hnds_magic" then
			G.GAME.banned_keys[booster.key] = true
		end
	end
end


function replace_jokers_keep_rarity(jokers, sticker_removal_chance)
	if not jokers or #jokers == 0 then return end

	local replacements = {}


	for i, card in ipairs(jokers) do
		local rarity = card.config.center.rarity
		local pool = {}
		local src = G.P_JOKER_RARITY_POOLS and G.P_JOKER_RARITY_POOLS[rarity] or G.P_CENTER_POOLS['Joker']


		for _, center in ipairs(src) do
			if center.key ~= card.config.center.key then
				pool[#pool + 1] = center
			end
		end

		local new_center = nil
		if #pool > 0 then
			new_center = pseudorandom_element(pool, pseudoseed('replace_joker' .. i))
		end


		local remove_stickers = pseudorandom('replace_sticker' .. i) < sticker_removal_chance


		local has_cursed = card.ability and card.ability.hnds_cursed
		local curse_data = has_cursed and card.ability.hnds_curse and copy_table(card.ability.hnds_curse) or nil

		replacements[i] = {
			card = card,
			center = new_center,
			remove_stickers = remove_stickers,
			has_cursed = has_cursed,
			curse_data = curse_data,
		}
	end


	for i, rep in ipairs(replacements) do
		if rep.center then
			G.E_MANAGER:add_event(Event({
				trigger = 'after',
				delay = i == 1 and 0 or 0.45,
				func = function()
					local card = rep.card


					G.E_MANAGER:add_event(Event({
						trigger = 'after',
						delay = i == 1 and 0.2 or 0.4,
						func = function()

							if card.remove_from_deck and type(card.remove_from_deck) == 'function' then
								pcall(card.remove_from_deck, card)
							end


							card:set_ability(rep.center, true)


							card:add_to_deck()


							if rep.remove_stickers then

								if card.ability then
									card.ability.perishable = nil
									card.ability.rental = nil
								end

								if SMODS and SMODS.Sticker and SMODS.Sticker.obj_buffer then
									for _, k in ipairs(SMODS.Sticker.obj_buffer) do
										if card.ability and card.ability[k] then
											card.ability[k] = nil
										end
									end
								end
							end


							card:start_materialize()
							card:juice_up(0.5, 0.3)
							play_sound('card1', 1 + (i - 1) * 0.05, 0.6)
							return true
						end
					}))
					return true
				end
			}))
		end
	end
end