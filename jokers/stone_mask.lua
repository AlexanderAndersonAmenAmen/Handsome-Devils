SMODS.Joker {
    key = 'stone_mask',
    atlas = 'Jokers',
    pos = { x = 5, y = 1 },
    rarity = 3,
    cost = 8,
    unlocked = true,
    discovered = true,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.e_foil
        info_queue[#info_queue + 1] = G.P_CENTERS.e_holo
        info_queue[#info_queue + 1] = G.P_CENTERS.e_polychrome
        return {
            vars = { card.ability.max_highlighted }
        }
    end,
    calculate = function(self, card, context)
        if context.cardarea == G.play and context.individual and #context.full_hand == 1 and G.GAME.current_round.hands_played == 0 then
            if context.other_card and context.other_card.ability.set == "Enhanced" and not context.other_card.edition and not context.repetition then
                local othercard = context.other_card
                local edition = poll_edition('standard_edition' .. G.GAME.round_resets.ante, nil, true, true,
                    { 'e_holo', 'e_foil', 'e_polychrome' })
                G.E_MANAGER:add_event(Event({
                    func = function()
                        othercard:set_edition(edition, true)
                        return true
                    end
                }))
            end
            return {
                message = localize('k_hnds_awaken'),
                colour = G.C.GREY,
                card = card
            }
        end
    end
}
