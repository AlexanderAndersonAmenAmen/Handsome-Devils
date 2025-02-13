SMODS.Joker {
    key = 'banana_split',
    atlas = 'Jokers',
    pos = { x = 0, y = 2 },
    rarity = 2,
    cost = 10,
    unlocked = true,
    discovered = true,
    blueprint_compat = false,
    eternal_compat = false,
    perishable_compat = false,
    config =
    { extra = {
        Xmult = 1.5
    }
    },
    loc_vars = function(card, info_queue, center)
        return { vars = { center.ability.extra.Xmult, G.GAME.probabilities.normal } }
    end,
    calculate = function(card, card, context)
        if context.joker_main then
            return {
                card = card,
                Xmult_mod = card.ability.extra.Xmult,
                message = 'X' .. card.ability.extra.Xmult,
                color = G.C.MULT
            }
        end

        if context.end_of_round and context.main_eval and not context.blueprint then
            if pseudorandom('banan') < G.GAME.probabilities.normal / 6 then
                if #G.jokers.cards < G.jokers.config.card_limit then
                    local _card = copy_card(card, nil, nil, nil, card.edition and card.edition.negative)
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            _card:add_to_deck()
                            G.jokers:emplace(_card)
                            return true
                        end
                    }))
                    return
                    {
                        colour = G.C.ORNAGE,
                        card = card,
                        message = 'Split!',
                    }
                else
                    return {
                        message = localize("k_no_room_ex")
                    }
                end
            end
        end
    end
}