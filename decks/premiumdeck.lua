SMODS.Back({
	key = "premiumdeck",
	pos = { x = 0, y = 0 },
	atlas = "Extras",
	config = { vouchers = { 'v_hnds_premium', 'v_hnds_top_shelf' } },
	unlocked = false,
	check_for_unlock = function(self, args)
		return HNDS.unlock_condition_met("premiumdeck", args)
	end,
})
