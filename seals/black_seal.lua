SMODS.Seal({
	key = "black",
	badge_colour = HEX("545454"),
	atlas = "Extras",
	pos = { x = 3, y = 1 },
	--sound = { sound = 'blk_seal_obtained', per = 1.06, vol = 0.4 },
	discovered = true,

	loc_vars = function(self, info_queue)
		return { vars = {} }
	end,

	-- self - this seal prototype
	-- card - card this seal is applied to
	calculate = function(self, card, context)
		if context.main_scoring and context.cardarea == G.hand and not context.black_trigger then
			local new_context = {}
			for k, v in pairs(context) do
				new_context[k] = v
			end
			new_context.black_trigger = true
			new_context.cardarea = G.play
			SMODS.score_card(card, new_context)
		end
	end,
})

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
