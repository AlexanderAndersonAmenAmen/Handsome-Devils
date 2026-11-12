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


    loc_vars = function(self)
        if HNDS.mp_active and HNDS.mp_active() then return {key = 'stake_hnds_platinum_mp'} end
    end,
    modifiers = function(self)
        if not (HNDS.mp_active and HNDS.mp_active()) then G.GAME.win_ante = 10 end
        G.GAME.hnds_platinum_active = true
    end
})