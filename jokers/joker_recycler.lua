SMODS.Joker({
    key = 'joker_recycler',
    atlas = 'Jokers',
    pos = { x = 2, y = 1 },
    rarity = 1,
    cost = 4,
    unlocked = true,
    discovered = false,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    calculate = function(self, card, context)
        if not (G and G.GAME and G.GAME.blind and G.GAME.blind.in_blind
            and G.GAME.current_round and context) then return end
        local sold = context.selling_self
            or (context.selling_card and context.card ~= card
                and context.card and context.card.ability
                and context.card.ability.set == 'Joker')
        if not sold then return end
        if ease_hands_played then ease_hands_played(1) end
        if ease_discard then ease_discard(1) end
        return { message = localize('k_hnds_recycle'), colour = G.C.GREEN }
    end,
    attributes = { 'joker', 'on_sell' },
})
