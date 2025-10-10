SMODS.Seal({
    key = 'spectralseal',
    pos = { x = 2, y = 1 },
    atlas = "Extras",
    badge_colour = G.C.SECONDARY_SET.Spectral,
    config = { extra = { cards = 2 } },
    loc_vars = function (self, info_queue, card)
        return { vars = { self.config.extra.cards }}
    end,
    calculate = function(self, card, context)
        if context.remove_playing_cards then
            for _, c in ipairs(context.removed) do
                if c == card then
                    local to_create = math.min(self.config.extra.cards,
                        G.consumeables.config.card_limit - (#G.consumeables.cards + G.GAME.consumeable_buffer))
                    G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + to_create
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            for _ = 1, to_create do
                                SMODS.add_card({ set = "Spectral", key_append = "hnds_spectralseal" })
                            end
                            G.GAME.consumeable_buffer = 0
                            return true
                        end
                    }))
                end
            end
        end
        if context.cards_destroyed then
            for _, c in ipairs(context.glass_shattered) do
                if c == card then
                    local to_create = math.min(self.config.extra.cards,
                        G.consumeables.config.card_limit - (#G.consumeables.cards + G.GAME.consumeable_buffer))
                    G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + to_create
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            for _ = 1, to_create do
                                SMODS.add_card({ set = "Spectral", key_append = "hnds_spectralseal" })
                            end
                            G.GAME.consumeable_buffer = 0
                            return true
                        end
                    }))
                end
            end
        end
    end
})
