function HNDS.calculate_sixth_sense(card, context)
    local played = context.destroying_card
    local full_hand = context.full_hand
    if SMODS.no_resolve or not played or not full_hand or #full_hand ~= 1 or full_hand[1] ~= played
        or played:get_id() ~= 6 or G.GAME.current_round.hands_played ~= 0 then return end

    local retrigger = context.retrigger_joker
    if retrigger then
        if context.hnds_sixth_sense_source ~= card then return end
    else
        if played.sixth_sense then return end
        played.sixth_sense = true
        context.hnds_sixth_sense_source = card
    end

    local game, area = G.GAME, G.consumeables
    local reserved = game.consumeable_buffer or 0
    local free_slots = area.config.card_limit - #area.cards - reserved
    local effect = {}
    if not retrigger then
        effect.remove = true
        effect.hnds_retrigger_limit = math.max(0, free_slots - 1)
    end
    if free_slots <= 0 then return not retrigger and effect or nil end

    if retrigger then HNDS.spend_limited_joker_retrigger(retrigger) end
    game.consumeable_buffer = reserved + 1
    G.E_MANAGER:add_event(Event({
        trigger = 'before',
        delay = 0,
        func = function()
            if G.GAME == game and G.consumeables == area and #area.cards < area.config.card_limit then
                local spectral = create_card('Spectral', area, nil, nil, nil, nil, nil, 'sixth')
                spectral:add_to_deck()
                area:emplace(spectral)
            end
            game.consumeable_buffer = math.max(0, (game.consumeable_buffer or 1) - 1)
            return true
        end,
    }))
    effect.message = localize('k_plus_spectral')
    effect.colour = G.C.SECONDARY_SET.Spectral
    return effect
end
