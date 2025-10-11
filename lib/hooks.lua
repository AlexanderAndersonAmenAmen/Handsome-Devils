--black seal and such card destruction hook
HNDS.should_hand_destroy = function (card)
	return card.seal == "hnds_black"
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
