SMODS.Joker {
    key = "fregoli",
    rarity = 2,
    loc_vars = function(self, info_queue, card)
        local main_end = nil
        if G.jokers and G.jokers.cards[1] then
            local copied
            for _, c in ipairs(G.jokers.cards) do
                if c.sort_id == G.GAME.hnds_fregoli_copy then
                    copied = c
                end
            end
            if not copied then copied = card end --failsafe
            local name, compat
            name = localize { key = copied.config.center.key, type = "name_text", set = copied.ability.set } or
            localize("k_none")
            compat = copied.config.center.blueprint_compat and copied ~= card
            local colour = compat and G.C.GREEN or G.C.RED
            local comp_txt = compat and localize("k_compatible") or localize("k_incompatible")
            main_end = {
                {
                    n = G.UIT.C,
                    config = { align = "bm", padding = 0.02 },
                    nodes = {
                        {
                            n = G.UIT.C,
                            config = { align = "m", colour = colour, r = 0.05, padding = 0.05 },
                            nodes = { { n = G.UIT.T, config = { text = " " .. name .. " | " .. comp_txt .. " ", colour = G.C.UI.TEXT_LIGHT, scale = 0.3, shadow = true } } }
                        }
                    }
                }
            }
        end
        return { main_end = main_end }
    end,
    atlas = "Jokers",
    pos = { x = 4, y = 0 },
    cost = 7,
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    calculate = function(self, card, context)
        for _, c in ipairs(G.jokers.cards) do
            if c.sort_id == G.GAME.hnds_fregoli_copy and c ~= card then
                return SMODS.blueprint_effect(card, c, context)
            end
        end
    end
}
