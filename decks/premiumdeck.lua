SMODS.Back({
	key = "premiumdeck",
	pos = { x = 0, y = 0 },
	atlas = "Extras",
	config = { vouchers = { 'v_hnds_premium', 'v_hnds_top_shelf' } },
	unlocked = true,
	loc_vars = function(self, info_queue, back)
		return {
			vars = { localize { type = 'name_text', key = self.config.voucher, set = 'Voucher' }
			}
		}
	end,
})
