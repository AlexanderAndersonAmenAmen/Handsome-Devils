SMODS.Voucher({
	key = "rigged",
	atlas = "Vouchers",
	config = { extra = {} },
	pos = { x = 1, y = 1 },
	cost = 10,
	unlocked = true,
	discovered = true,
	requires = { "v_hnds_beginners_luck" },
	available = true,
	calculate = function(self, card, context)
		if context.mod_probability and G.GAME.blind and G.GAME.blind:get_type() == "Big" or G.GAME.blind.boss then
			return {
				numerator = context.numerator * 2,
			}
		end
	end,
})
