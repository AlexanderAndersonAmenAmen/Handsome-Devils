SMODS.Voucher({
	key = "wholesale",
	atlas = "Vouchers",
	pos = { x = 0, y = 1 },
	config = { extra = { boosters = 1 } },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.boosters } }
	end,
	cost = 10,
	unlocked = true,
	discovered = true,
	requires = { "v_hnds_stuffed" },
	redeem = function(self, voucher)
		SMODS.change_booster_limit(voucher.ability.extra.boosters)
	end,
	unredeem = function(self, voucher)
		SMODS.change_booster_limit(-voucher.ability.extra.boosters)
	end,
})
