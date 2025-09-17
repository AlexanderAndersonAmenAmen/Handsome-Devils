SMODS.Enhancement {
    key = "Obsidian",
    atlas = "Extras",
    pos = { x = 3, y = 1 },
    config = { p_dollars = -1, extra = { odds = 3 } },
    loc_vars = function (self, info_queue, card)
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, "hnds_obsidian")
        return { vars = { -card.ability.p_dollars, numerator, denominator }}
    end,
    calculate = function (self, card, context)
        if context.main_scoring and #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit and SMODS.pseudorandom_probability(card, "hnds_obsidian", 1, card.ability.extra.odds) then
            G.GAME.consumeable_buffer = (G.GAME.consumeable_buffer or 0) + 1
            G.E_MANAGER:add_event(Event({
                trigger = "before",
                delay = 0.0,
                func = function ()
                    SMODS.add_card({
                        set = 'Consumeables',
                        edition = "e_negative"
                    })
                    G.GAME.consumeable_buffer = 0
                    return true
                end
            }))
        end
    end,
    weight = 2.5
}