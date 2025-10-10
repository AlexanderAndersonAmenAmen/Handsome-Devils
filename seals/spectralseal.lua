SMODS.Seal({
    key = 'spectralseal',
    pos = { x = 2, y = 1 },
    atlas = "Extras",
    badge_colour = G.C.SECONDARY_SET.Spectral,
    config = { extra = { cards = 2 } },
    calculate = function (self, card, context)
        if context.remove_playing_cards then
            for _, c in ipairs(context.removed) do
                if c == card then
                    for _ = 1, math.min(self.config.extra.cards, G.consumeables.config.card_limit - (#G.consumeables.cards + G.GAME.consumeable_buffer)) do
                        G.E_MANAGER:add_event(Event({
                            func = function ()
                                SMODS.add_card({ set = "Spectral"})
                            end
                        }))
                    end
                end
            end
        end
    end
})
