SMODS.Seal({
    key = 'spectralseal',
    pos = { x = 2, y = 1 },
    atlas = "Extras",
    badge_colour = G.C.SECONDARY_SET.Spectral,
    config = { extra = { cards = 2 } },
    calculate = function(self, card, context)
        if context.remove_playing_cards and #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
            local contains = false
            for _, c in pairs(context.removed) do
                if c == card then
                    contains = true
                    break
                end
            end
            if contains then
                G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + math.min(self.config.extra.cards, G.consumeables.config.card_limit - (#G.consumeables.cards + G.GAME.consumeable_buffer))
                for i = 1, math.min(card.ability.extra.tarots, G.consumeables.config.card_limit - #G.consumeables.cards) do
                    G.E_MANAGER:add_event(Event({
                        trigger = 'before',
                        delay = 0.0,
                        func = function()
                                SMODS.add_card({ set = 'Spectral' })
                                G.GAME.consumeable_buffer = 0
                                return true
                        end
                    }))
                    return { message = localize('k_plus_spectral'), colour = G.C.SECONDARY_SET.Spectral }
                end
            end
        end
    end
})

local can_calc_ref = Card.can_calculate
function Card:can_calculate(ignore_debuff, ignore_sliced)
    if self.seal == "hnds_spectralseal" then ignore_debuff = true end
    return can_calc_ref(self, ignore_debuff, ignore_sliced)
end
