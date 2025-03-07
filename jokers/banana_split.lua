SMODS.Joker {
    key = 'banana_split',
    atlas = 'Jokers',
    pos = { x = 0, y = 2 },
    rarity = 2,
    cost = 5,
    unlocked = true,
    discovered = true,
    blueprint_compat = false,
    eternal_compat = false,
    perishable_compat = false,
    config =
    { extra = {
        Xmult = 1.5,
        odds = 6,
    }
    },
    pools = { Food = true },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.Xmult, G.GAME.probabilities.normal, card.ability.extra.odds } }
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
            if pseudorandom('banan') < G.GAME.probabilities.normal / card.ability.extra.odds then
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
                        message = localize("k_hnds_banana_split"),
                    }
                else
                    return {
                        message = localize("k_no_room_ex")
                    }
                end
            elseif mxms_scale_pessimistics then mxms_scale_pessimistics(G.GAME.probabilities.normal, card.ability.extra.odds) end
        end
    end,
    add_to_deck = function(self, card, from_debuff)
        if not from_debuff then
            card.base_cost = 30
            card:set_cost()
        end
    end
}