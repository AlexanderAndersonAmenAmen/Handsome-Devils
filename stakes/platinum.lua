SMODS.Stake({
    key = "platinum",
    atlas = "Stakes",
    pos = {x = 0, y = 0},
    sticker_atlas = "Stickers",
    sticker_pos = {x = 1, y = 0},
    applied_stakes = {"stake_gold"},
    above_stake = "stake_gold",
    colour = HEX("c0c6d1"),
    shiny = true,
    prefix_config = {
        applied_stakes = { mod = false },
        above_stake = { mod = false }
    },
    -- Called by SMODS when this stake is applied at the start of a run.
    -- Extends the run to Ante 10 and flags Platinum as active so other
    -- systems (e.g. The Devil's forced-showdown-boss hook) can check for
    -- it without needing to look up G.P_STAKES or compare stake numbers.
    modifiers = function(self)
        G.GAME.win_ante = 10
        G.GAME.hnds_platinum_active = true
    end
})