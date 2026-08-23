SMODS.Consumable {
    key = "spectrum",
    set = "Spectral",
    atlas = "Consumables",
    pos = { x = 0, y = 1 },
    soul_pos = { x = 0, y = 2 },
    discovered = false,
    cost = 4,
    hidden = true,
    soul_set = "Base",
    soul_rate = 0.003,
    use = function(self, card, area, copier)
        local enh_options = get_current_pool("Enhanced")
        for i, k in pairs(enh_options) do
            if k == "m_bonus" or k == "m_mult" then
                enh_options[i] = "UNAVAILABLE"
            end
        end
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound("tarot1")
                card:juice_up(0.3, 0.5)
                return true
            end
        }))
        for i = 1, #G.hand.cards do
            local percent = 1.15 - (i - 0.999) / (#G.hand.cards - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    G.hand.cards[i]:flip()
                    play_sound('card1', percent)
                    G.hand.cards[i]:juice_up(0.3, 0.3)
                    return true
                end
            }))
        end
        for i = 1, #G.hand.cards do
            G.E_MANAGER:add_event(Event({
                func = function()
                    local c = G.hand.cards[i]
                    
                    local enh = SMODS.poll_enhancement({ guaranteed = true, options = enh_options })
                    
                    c:set_ability(enh)
                    return true
                end
            }))
        end
         for i = 1, #G.hand.cards do
            G.E_MANAGER:add_event(Event({
                func = function()
                    local c = G.hand.cards[i]
                    
                     local seal = SMODS.poll_seal({ guaranteed = true })
                    c:set_seal(seal)
                    return true
                end
            }))
        end

        for i = 1, #G.hand.cards do
            local percent = 0.85 + (i - 0.999) / (#G.hand.cards - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    G.hand.cards[i]:flip()
                    play_sound('tarot2', percent, 0.6)
                    G.hand.cards[i]:juice_up(0.3, 0.3)
                    return true
                end
            }))
        end
        delay(0.5)
    end,
    can_use = function(self, card)
        return G.hand and #G.hand.cards > 0
    end,
    force_use = function(self, card, area)
        if G.hand and #G.hand.cards > 0 then
            self:use(card, area)
        end
    end
}
-- Spectrum is a hidden Spectral that can replace a Base card in Standard
-- packs. Standard-pack generation may attach playing-card modifiers before
-- the forced center is installed; strip those modifiers from Spectrum only.
HNDS.on_context(function(context)
    if not (context.modify_booster_card and context.card
        and context.card.config and context.card.config.center
        and context.card.config.center.key == "c_hnds_spectrum")
    then
        return
    end

    local spectrum = context.card
    if spectrum.set_edition then spectrum:set_edition(nil, true, true) end
    if spectrum.set_seal then spectrum:set_seal(nil, true, true) end
    -- A Spectrum rolled from a Base Standard-pack slot can retain the
    -- playing-card front sprite even after its center becomes Spectral.
    -- Remove that child so it renders and behaves as a consumable only.
    if spectrum.children and spectrum.children.front then
        local old_front = spectrum.children.front
        if old_front.remove then old_front:remove() end
        spectrum.children.front = nil
    end
    if spectrum.ability then
        spectrum.ability.perishable = nil
        spectrum.ability.eternal = nil
        spectrum.ability.rental = nil
        spectrum.ability.perish_tally = nil
        spectrum.ability.perma_bonus = 0
        spectrum.ability.perma_mult = 0
        spectrum.ability.perma_x_mult = 0
        spectrum.ability.perma_h_x_mult = 0
        spectrum.ability.perma_p_dollars = 0
        for _, sticker_key in ipairs((SMODS.Sticker and SMODS.Sticker.obj_buffer) or {}) do
            spectrum.ability[sticker_key] = nil
        end
    end
    spectrum.hnds_spectrum_booster_cleanup = true
end)
