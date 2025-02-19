SMODS.Joker {
    key = 'stone_mask',
    atlas = 'Jokers',
    pos = { x = 5, y = 1 },
    rarity = 2,
    cost = 8,
    unlocked = true,
    discovered = true,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    calculate = function(self, card, context)
        if context.cardarea == G.play and context.individual then
            if context.other_card and context.other_card.config.center == G.P_CENTERS.m_stone and not context.other_card.edition and not context.repetition then
                local othercard = context.other_card
                local edition = poll_edition('standard_edition' .. G.GAME.round_resets.ante, nil, true, true,
                    { 'e_holo', 'e_foil', 'e_polychrome' })
                G.E_MANAGER:add_event(Event({
                    func = function()
                        othercard:set_edition(edition, true)
                        return true
                    end }))
            end
        end
    end
}
