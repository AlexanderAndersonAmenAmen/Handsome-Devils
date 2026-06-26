SMODS.Back {
    key = "ol_reliable",
    atlas = "Extras",
    pos = { x = 1, y = 2 },
    unlocked = true,
    calculate = function(self, back, context)
        if context.mod_probability and not context.blueprint and (G.shop or (G.GAME.blind and G.GAME.blind.boss))
            and not (G.GAME and G.GAME.selected_sleeve == "sleeve_hnds_ol_sleeve") then
            return {
                numerator = context.numerator * 3
            }
        end
    end,
    pools = { RedeemableBacks = true }
}
