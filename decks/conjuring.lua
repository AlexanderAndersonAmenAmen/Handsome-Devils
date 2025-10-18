SMODS.Back ({
    name = "Conjuring Deck",
    key = "conjuring",
    order = 18,
    unlocked = true,
    discovered = true,
    config = {},
    loc_vars = function(self, info_queue, center)
        return { vars = {} }
    end,
    pos = { x = 0, y = 2 },
    atlas = "Extras",
    apply = function(self,card)
        G.GAME.modifiers.booster_choice_mod = (G.GAME.modifiers.booster_choice_mod or 0) + 1
        for _, booster in pairs(G.P_CENTER_POOLS.Booster) do
            if not string.find(booster.key:lower(), "mega") then
                G.GAME.banned_keys[booster.key] = true
            end
        end
    end,
})