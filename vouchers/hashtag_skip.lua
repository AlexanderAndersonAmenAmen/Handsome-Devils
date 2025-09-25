SMODS.Voucher({
	key = "hashtag_skip",
	atlas = "Vouchers",
	pos = { x = 3, y = 1 },
	config = {
		extra = {
			skips = 0,
			skips_needed = 4,
		},
	},
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.skips_needed, "#" } }
	end,
	discovered = true,
	requires = { "v_hnds_tag_hunter" },
	calculate = function(self, card, context)
		if context.skip_blind then
			card.ability.extra.skips = card.ability.extra.skips + 1
			if card.ability.extra.skips >= card.ability.extra.skips_needed then
				ease_ante(-1)
				G.GAME.round_resets.blind_ante = G.GAME.round_resets.blind_ante or G.GAME.round_resets.ante
				G.GAME.round_resets.blind_ante = G.GAME.round_resets.blind_ante - 1
				card.ability.extra.skips = 0
			end
		end
	end,
})
