SMODS.Joker {
    key = "deep_pockets",
    config = {
        extra = {
            slots = 2,
            consumeable_mult = 8,
        }
    },
    rarity = 2,
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.slots, card.ability.extra.consumeable_mult } }
    end,
    atlas = "Jokers",
    pos = { x = 1, y = 0 },
    cost = 6,
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = false,
    calculate = function(self, card, context)
        if not card.debuff then
            if context.other_consumeable and not context.other_consumeable.debuff then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        context.other_consumeable:juice_up(0.5, 0.5)
                        return true
                    end
                }))
                return {
                    message = localize { type = 'variable', key = 'a_mult', vars = { card.ability.extra.consumeable_mult } },
                    mult_mod = card.ability.extra.consumeable_mult
                }
            end
        end
    end,
    add_to_deck = function(self, card, from_debuff)
        G.consumeables.config.card_limit = G.consumeables.config.card_limit + card.ability.extra.slots
    end,
    remove_from_deck = function(self, card, from_debuff)
        G.consumeables.config.card_limit = G.consumeables.config.card_limit - card.ability.extra.slots
    end,
}