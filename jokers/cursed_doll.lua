SMODS.Joker {
    key = 'cursed_doll',
    atlas = 'Jokers',
    pos = { x = 0, y = 8 },
    rarity = 1,
    cost = 5,
    unlocked = true,
    discovered = false,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    config = { extra = { odds = 2 } },
    loc_vars = function(self, info_queue, card)
        local extra = card and card.ability and card.ability.extra or self.config.extra
        local numerator, denominator = 1, tonumber(extra.odds) or 2
        if SMODS and type(SMODS.get_probability_vars) == 'function' then
            numerator, denominator = SMODS.get_probability_vars(
                card or self, 1, denominator, 'hnds_cursed_doll'
            )
        end
        return { vars = { numerator, denominator } }
    end,
    calculate = function(self, card, context)
        local hand_cards = G and G.hand and G.hand.cards
        if not (context.using_consumeable or context.forcetrigger)
            or type(hand_cards) ~= 'table' or #hand_cards == 0
        then
            return
        end

        local odds = tonumber(card.ability.extra and card.ability.extra.odds) or 2
        if not context.forcetrigger and not SMODS.pseudorandom_probability(
            card, 'hnds_cursed_doll', 1, odds, 'hnds_cursed_doll'
        ) then
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
    attributes = { 'chance', 'consumable', 'destroy_card' },
}
