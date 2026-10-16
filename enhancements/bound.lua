HNDS = HNDS or {}

function HNDS.is_bound_card(card)
    if not card then return false end
    local ability = card.ability
    return (ability and (ability.hnds_bound ~= nil and ability.hnds_bound ~= false
        or ability.hnds_void_draw ~= nil and ability.hnds_void_draw ~= false))
        or (card.stickers and card.stickers.hnds_bound) or false
end

SMODS.Sticker({
    key = 'bound',
    atlas = 'Stickers',
    pos = { x = 2, y = 1 },
    badge_colour = G.C.PURPLE,
    rate = 0,
    default_compat = true,
    sets = { Default = true, Enhanced = true },
})

function HNDS.prepare_bound_cards_for_first_draw()
    if not (G and G.GAME and G.GAME.current_round and G.deck and G.deck.cards) then return end
    local current_round = G.GAME.current_round
    if current_round.hnds_bound_cards_prepared or current_round.hnds_bound_cards_drawn then return end
    current_round.hnds_bound_cards_prepared = true
    local deck = G.deck.cards
    local bound = {}
    for i = #deck, 1, -1 do
        local card = deck[i]
        if HNDS.is_bound_card(card) and not (card.removed or card.REMOVED) then
            table.remove(deck, i)
            table.insert(bound, 1, card)
        end
    end
    for i = #bound, 1, -1 do
        deck[#deck + 1] = bound[i]
    end
end

function HNDS.install_bound_draw_hook()
    if HNDS._bound_draw_hook_installed then return true end
    if not (G and G.FUNCS and type(G.FUNCS.draw_from_deck_to_hand) == 'function') then return false end
    local draw_ref = G.FUNCS.draw_from_deck_to_hand
    G.FUNCS.draw_from_deck_to_hand = function(...)
        if G and G.STATE == G.STATES.DRAW_TO_HAND then
            HNDS.prepare_bound_cards_for_first_draw()
        end
        return draw_ref(...)
    end
    HNDS._bound_draw_hook_installed = true
    return true
end

function HNDS.draw_bound_cards()
    if not (G and G.GAME and G.GAME.current_round and G.deck and G.hand and G.E_MANAGER and Event) then return end
    if G.GAME.current_round.hnds_bound_cards_drawn then return end
    G.GAME.current_round.hnds_bound_cards_drawn = true

    local cards_to_draw = {}
    for _, target in ipairs(G.deck.cards or {}) do
        if HNDS.is_bound_card(target) and not (target.removed or target.REMOVED)
            and not (target.ability and target.ability.hnds_drawing) then
            cards_to_draw[#cards_to_draw + 1] = target
            target.ability = target.ability or {}
            target.ability.hnds_drawing = true
        end
    end
    if #cards_to_draw == 0 then return end

    G.E_MANAGER:add_event(Event({
        trigger = 'before',
        func = function()
            for _, target in ipairs(cards_to_draw) do
                if target.area == G.deck and G.hand then
                    draw_card(G.deck, G.hand, nil, 'up', false, target)
                end
            end
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.2,
                func = function()
                    for _, target in ipairs(cards_to_draw) do
                        if target and target.ability then target.ability.hnds_drawing = nil end
                    end
                    return true
                end,
            }))
            return true
        end,
    }))
end

HNDS.install_bound_draw_hook()
