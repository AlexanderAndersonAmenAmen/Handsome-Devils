SMODS.Joker({
    key = "angry_mob",
    rarity = 2,
    cost = 6,
    blueprint_compat = true,
    atlas = "Jokers",
    pos = { x = 8, y = 3 },
    config = {
        extra = {
            xmult = 2,
        }
    },
    loc_vars = function(self, info_queue, card)
        return {
            vars = {card.ability.extra.xmult, card.ability.extra.old_rate}
        }
    end,
    add_to_deck = function(self, card, from_debuff)
        card.ability.extra.already_jokerless = G.GAME.modifiers.no_shop_jokers
        G.GAME.modifiers.no_shop_jokers = true
    end,
    remove_from_deck = function(self, card, from_debuff)
        if not card.ability.extra.already_jokerless then
            G.GAME.modifiers.no_shop_jokers = nil
        end
    end,
    calculate = function(self, card, context)
        local cae = card.ability.extra
        if context.joker_main then
            return{
                xmult = cae.xmult
            }
        end
    end
})

