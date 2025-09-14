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
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, "hnds_banana_split")
        return { vars = { card.ability.extra.Xmult, numerator, denominator } }
    end,
    calculate = function(card, card, context)
        if context.joker_main then
            return {
                xmult = card.ability.extra.Xmult
            }
        end

        if context.end_of_round and context.main_eval and not context.blueprint then
            if #G.jokers.cards < G.jokers.config.card_limit then
                if SMODS.pseudorandom_probability(card, "banan", 1, card.ability.extra.odds, "hnds_banana_split") then
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
                end
            elseif mxms_scale_pessimistics then mxms_scale_pessimistics(G.GAME.probabilities.normal, card.ability.extra.odds) end
        end
    end
}