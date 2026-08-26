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


    modifiers = function(self)
        G.GAME.win_ante = 10
        G.GAME.hnds_platinum_active = true
    end
})