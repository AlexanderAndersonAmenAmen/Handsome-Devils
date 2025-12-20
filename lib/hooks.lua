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
		-- Don't apply curse to eternal copies
		if not (self.ability and self.ability.hnds_eternal_copy_created) then
			if (not self.ability or not self.ability.curse) and apply_curse and type(apply_curse) == 'function' then
				apply_curse(self)
				-- Only trigger curse penalty if it hasn't been triggered already (to prevent double-triggering in challenges)
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