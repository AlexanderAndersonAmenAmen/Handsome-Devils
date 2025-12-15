--  black seal and such card destruction hook (should no longer be needed but commented out just in case)
HNDS.should_hand_destroy = function(card)
	return card:get_seal() == "hnds_black" or (G.GAME.used_vouchers.v_hnds_soaked and card == G.hand.cards[1]) or
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
			if flags.remove then destroyed = true end
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
end

create_card_ref = create_card
function create_card(_type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append)
	local card = create_card_ref(_type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append)
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