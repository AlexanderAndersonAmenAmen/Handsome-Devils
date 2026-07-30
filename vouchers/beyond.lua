SMODS.Voucher {
    key = "beyond",
    atlas = "Vouchers",
    pos = { x = 4, y = 1 },
    cost = 10,
    unlocked = false,
    locked_loc_vars = function(self)
        local current = HNDS.unlock_progress("beyond")
        return { vars = { current } }
    end,
    check_for_unlock = function(self, args)
        return HNDS.unlock_condition_met("beyond", args)
    end,
    discovered = false,
    requires = { "v_hnds_soaked" },
}