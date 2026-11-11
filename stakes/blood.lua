for _, key in ipairs({ 'buffoon_normal_1', 'buffoon_normal_2', 'buffoon_jumbo_1', 'buffoon_mega_1' }) do
    local pack = G.P_CENTERS['p_' .. key]
    local previous_weight = pack and pack.get_weight
    SMODS.Booster:take_ownership(key, {
        get_weight = function(self, weight, args)
            local result = previous_weight and previous_weight(self, weight, args) or weight or self.weight
            if G.GAME and G.GAME.modifiers and G.GAME.modifiers.hnds_blood_stake then
                return result * 0.5
            end
            return result
        end,
    }, true)
end

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
    end,
}
