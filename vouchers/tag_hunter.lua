SMODS.Voucher({
	key = "tag_hunter",
	atlas = "Vouchers",
	pos = { x = 3, y = 0 },
	discovered = true,
	requires = {},
	calculate = function(self, card, context)
		if context.end_of_round and context.main_eval and G.GAME.blind.boss then
			add_tag(HNDS.poll_tag("tag_hunter_hnds", nil, {
				--Excluded tags
				"tag_top_up",
				"tag_juggle",
				"tag_boss",
			}))
		end
	end,
})
