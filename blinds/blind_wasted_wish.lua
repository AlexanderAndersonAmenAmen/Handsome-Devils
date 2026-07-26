-------------------------------------------------------------------
-- WASTED WISH
-- Ante 10 Showdown Boss Blind
-- Its whole-Ante behaviour is managed by lib/hooks.lua as soon as this Blind
-- is selected, and is removed immediately if the Boss is rerolled away.
-------------------------------------------------------------------

HNDS = HNDS or {}

SMODS.Blind {
    key = "wasted_wish",
    boss = { showdown = true },

    mult = 2,
    atlas_table = "ANIMATION_ATLAS",
    atlas = "ante_10_atlas",
    pos = { x = 0, y = 4 },

    boss_colour = HEX("c58243"),
    discovered = true,
    unlocked = true,

    in_pool = function(self)
        return G and G.GAME
            and G.GAME.win_ante == 10
            and G.GAME.round_resets
            and G.GAME.round_resets.ante == 10
    end,

    set_blind = function(self)
        if HNDS.set_wasted_wish_active then
            HNDS.set_wasted_wish_active(true)
        end
    end,

    -- Disabling the Blind during its fight disables its effect too. Defeating
    -- it leaves cleanup to the Ante transition so the wording "this Ante"
    -- remains literal through the post-boss cashout/shop transition.
    disable = function(self)
        if HNDS.set_wasted_wish_active then
            HNDS.set_wasted_wish_active(false)
        end
    end,
}
