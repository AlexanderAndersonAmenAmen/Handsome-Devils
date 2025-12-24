SMODS.Joker {
    key = "one_punchline_man",
    atlas = "Jokers",
    pos = { x = 9, y = 4 },
    rarity = "Rare",
    cost = 10,
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    config = { extra = { Xmult = 1, Xmult_extra = 0.25 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.Xmult, card.ability.extra.Xmult_extra, card.ability.extra.xmult_gains } }
    end,
    calculate = function(self, card, context)
        if context.end_of_round and not context.individual and not context.repetition and not context.blueprint then
            local unused_hands = G.GAME.current_round.hands_left
            if unused_hands > 0 then
                local xmult_gains = card.ability.extra.Xmult_extra * unused_hands
                card.ability.extra.Xmult = card.ability.extra.Xmult + xmult_gains
                return {
                    message = localize{type='variable',key='a_xmult',vars={card.ability.extra.Xmult}},
                    colour = G.C.RED
                }
            end
        end
        if context.joker_main then
            if card.ability.extra.Xmult > 1 then
                return {
                    Xmult_mod = card.ability.extra.Xmult,
                    message = localize{type='variable',key='a_xmult',vars={card.ability.extra.Xmult}}
                }
            end
        end
    end
}
