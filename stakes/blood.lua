SMODS.Stake {
    key = 'blood_stake',
    atlas = "Stakes",
    pos = { x = 1, y = 0 },
    sticker_atlas = "Stickers",
    sticker_pos = {x = 2, y = 0},
    applied_stakes = {"stake_hnds_platinum"},
    above_stake = "stake_hnds_platinum",
    colour = HEX("cc6c6c"),
    shiny = false,
    requires = { "stake_hnds_platinum" },
    prefix_config = {
        applied_stakes = { mod = false },
        above_stake = { mod = false }
    },
    modifiers = function()
        G.GAME.modifiers.enable_curses = true
        G.GAME.modifiers.hnds_blood_stake = true

        local cursed_pack = G.P_CENTERS
            and G.P_CENTERS.p_hnds_cursed_pack
        if cursed_pack then cursed_pack.weight = 1.6 end
    end,
}