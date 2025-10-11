--black seal and such card destruction hook
HNDS.should_hand_destroy = function (card)
	return card.seal == "hnds_black" or (G.GAME.used_vouchers.v_hnds_soaked and card == G.hand.cards[1]) or (G.GAME.used_vouchers.v_hnds_beyond and card == G.hand.cards[#G.hand.cards])
end

local destroy_cards_ref = SMODS.calculate_destroying_cards
function SMODS.calculate_destroying_cards(context, cards_destroyed, scoring_hand)
	destroy_cards_ref(context, cards_destroyed, scoring_hand)
	for i, card in ipairs(G.hand.cards) do
		if HNDS.should_hand_destroy(card) then
			local destroyed = nil
			context.destroy_card = card
			context.cardarea = G.play
			context.destroying_card = card
            context.hnds_hand_trigger = true
			local flags = SMODS.calculate_context(context)
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
    if G.GAME.modifiers.hnds_double_showdown then
        G.GAME.win_ante = math.floor(G.GAME.win_ante/2)
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
	if G.GAME.selected_back and G.GAME.selected_back.effect.center.key == "b_hnds_premiumdeck" and self.config.center.set == "Joker" then
		self.cost = math.floor(self.cost + G.GAME.round_resets.ante)
	end
end
