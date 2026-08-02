SMODS.Stake({
    key = "nightmare",
    atlas = "Stakes",
    pos = {x = 2, y = 0},
    sticker_atlas = "Stickers",
    sticker_pos = {x = 3, y = 0},
    applied_stakes = {"stake_hnds_blood_stake"},
    above_stake = "stake_hnds_blood_stake",
    colour = HEX("912e2e"),
    shiny = false,
    prefix_config = {
        applied_stakes = { mod = false },
        above_stake = { mod = false }
    },
    modifiers = function()
        G.GAME.modifiers = G.GAME.modifiers or {}
        G.GAME.modifiers.hnds_nightmare_stake = true
    end,
})