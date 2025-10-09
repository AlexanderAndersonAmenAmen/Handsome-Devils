SMODS.Seal({
    key = 'spectralseal',
    pos = { x = 2, y = 1 },
    atlas = "Extras",
    badge_colour = G.C.SECONDARY_SET.Spectral,
    calculate = function(self, card, context)
        if context.destroy_card and context.cardarea == G.play or context.cardarea == G.hand and context.other_card == card and #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
            G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
            G.E_MANAGER:add_event(Event({
                trigger = 'before',
                delay = 0.0,
                func = function()
                    if G.consumeables.config.card_limit > #G.consumeables.cards then
                        SMODS.add_card({ set = 'Spectral' })
                        G.GAME.consumeable_buffer = 0
                        return true
                    end
                end
            }))
            return { message = localize('k_plus_spectral'), colour = G.C.SECONDARY_SET.Spectral }
        end
    end
})
