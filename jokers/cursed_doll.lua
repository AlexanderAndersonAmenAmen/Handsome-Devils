SMODS.Joker {
    key = 'cursed_doll',
    atlas = 'Jokers',
    pos = { x = 0, y = 8 },
    rarity = 2,
    cost = 5,
    unlocked = true,
    discovered = false,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    calculate = function(self, card, context)
        local hand_cards = G and G.hand and G.hand.cards
        if not (context.using_consumeable or context.forcetrigger)
            or type(hand_cards) ~= 'table' or #hand_cards == 0
        then
            return
        end

        local target = pseudorandom_element(
            hand_cards,
            pseudoseed('hnds_cursed_doll_target_' .. tostring(card.sort_id or card.ID or ''))
        )
        if not target then return end

        if SMODS and type(SMODS.destroy_cards) == 'function' then
            SMODS.destroy_cards(target)
        elseif target.start_dissolve then
            target:start_dissolve()
        end
        return { message = 'Destroyed!', colour = G.C.RED }
    end,
    attributes = { 'consumable', 'destroy_card' },
}
