SMODS.Enhancement {
    key = "Antimatter",
    atlas = "Extras",
    pos = { x = 2, y = 1 },
    config = { Xmult = 0.5, extra = { odds = 3, scaling = 0.5, max = 3 } },
    loc_vars = function (self, info_queue, card)
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, "hnds_antimatter")
        return { card.ability.Xmult, numerator, denominator, card.ability.extra.scaling, card.ability.extra.max }
    end,
    calculate = function (self, card, context)
        if context.main_scoring and SMODS.pseudorandom_probability(card, "hnds_antimatter", 1, card.ability.extra.odds) then
            SMODS.scale_card(card, {
                ref_table = card.ability,
                ref_value = "Xmult",
                scalar_table = card.ability.extra,
                scalar_value = "scaling"
            })
            card.ability.Xmult = math.min(card.ability.Xmult, card.ability.extra.max)
        end
    end,
    weight = 2.5
}