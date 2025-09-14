SMODS.Voucher({
	key = "beginners_luck",
	atlas = "Vouchers",
	config = { extra = {} },
	pos = { x = 1, y = 0 },
	cost = 10,
	unlocked = true,
	discovered = true,
	available = true,
	calculate = function(self, card, context)
		if context.mod_probability and G.GAME.blind and G.GAME.blind:get_type() == "Small" and not G.GAME.used_vouchers.v_hnds_rigged then
			return {
				numerator = context.numerator * 2
			}
		end
	end
})
