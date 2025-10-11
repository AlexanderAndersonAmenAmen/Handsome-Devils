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
		if context.main_scoring and context.cardarea == G.hand then
			local new_context = {}
			for k, v in pairs(context) do
				new_context[k] = v
			end
			new_context.hnds_hand_trigger = true
			new_context.cardarea = G.play
			SMODS.score_card(card, new_context)
			return nil, true
		end
	end,
})
