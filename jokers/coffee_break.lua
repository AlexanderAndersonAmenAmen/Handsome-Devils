SMODS.Joker {
    key = 'coffee_break',
    atlas = 'Jokers',
    pos = { x = 3, y = 2 },
    rarity = 1,
    cost = 5,
    unlocked = true,
    discovered = true,
    blueprint_compat = false,
    eternal_compat = false,
    perishable_compat = true,
    config =
    { extra = {
        money = 50,
        coffee_rounds = 0,
        target = 3
    }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.target, card.ability.extra.coffee_rounds, card.ability.extra.money } }
    end,
    calculate = function(self, card, context)
        if context.before then
            for _, played_card in pairs(context.full_hand) do
                card.ability.extra.money = card.ability.extra.money - 1
                SMODS.calculate_effect({
                    message = '-$1',
                    colour = G.C.RED,
                    message_card = card,
                }, played_card)
            end
        end
        if context.end_of_round and context.main_eval then
            card.ability.extra.coffee_rounds = card.ability.extra.coffee_rounds + 1
            if card.ability.extra.coffee_rounds == card.ability.extra.target then
                card.ability.extra.active = true
                local eval = function() return card.ability.extra.active end
                juice_card_until(card, eval, true)
            end
            return {
                message = card.ability.extra.active and localize('k_active_ex') or
                card.ability.extra.coffee_rounds .. '/' .. card.ability.extra.target,
                colour = G.C.FILTER
            }
        end
        if context.selling_self and card.ability.extra.active then
            return {
                dollars = card.ability.extra.money
            }
        end
    end,
    add_to_deck = function(self, card, from_debuff)
        --card:set_cost()
    end
}