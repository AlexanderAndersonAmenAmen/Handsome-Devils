SMODS.Consumable({
    key = "rebirth",
    name = "Rebirth",
    set = "Spectral",
    discovered = false,
    atlas = "Consumables",
    pos = { x = 4, y = 0 },
    cost = 4,
    use = function(self, card, area, copier)
        replace_jokers_keep_rarity(G.jokers.cards)
    end,
    can_use = function(self, card)
        return G and G.jokers and #G.jokers.cards > 0
    end,
    demicoloncompat = true,
})
