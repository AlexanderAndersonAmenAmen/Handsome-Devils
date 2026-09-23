HNDS = HNDS or {}

local function hnds_has_green_seal(card)
    return card and card.seal == 'hnds_green'
end

function HNDS.queue_green_seal_draw(amount)
    if not (G and G.GAME) then return end
    G.GAME.hnds_green_seal_pending = (tonumber(G.GAME.hnds_green_seal_pending) or 0) + math.max(0, tonumber(amount) or 0)
end

function HNDS.queue_green_seal_cards(cards, face_only)
    if type(cards) ~= 'table' then return 0 end
    local count = 0
    for _, playing_card in ipairs(cards) do
        local valid_face = not face_only or (type(playing_card.is_face) == 'function' and playing_card:is_face())
        if hnds_has_green_seal(playing_card) and not playing_card.debuff and valid_face then count = count + 1 end
    end
    if count > 0 then HNDS.queue_green_seal_draw(count * 3) end
    return count
end

function HNDS.install_green_seal_draw_hook()
    if HNDS._green_seal_draw_hook_installed then return true end
    if not (G and G.FUNCS and type(G.FUNCS.draw_from_deck_to_hand) == 'function') then return false end
    local draw_from_deck_to_hand_ref = G.FUNCS.draw_from_deck_to_hand
    G.FUNCS.draw_from_deck_to_hand = function(e)
        local pending = 0
        if G and G.GAME and G.STATE == G.STATES.DRAW_TO_HAND then
            pending = math.max(0, tonumber(G.GAME.hnds_green_seal_pending) or 0)
            G.GAME.hnds_green_seal_pending = 0
        end
        local result = draw_from_deck_to_hand_ref(e)
        if pending > 0 and G and G.E_MANAGER and Event then
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.05,
                func = function()
                    if not (G.deck and G.deck.cards and G.hand) then return true end
                    local count = math.min(pending, #G.deck.cards)
                    if count <= 0 then return true end
                    for i = 1, count do draw_card(G.deck, G.hand, i * 100 / count, 'up', true) end
                    return true
                end,
            }))
        end
        return result
    end
    HNDS._green_seal_draw_hook_installed = true
    return true
end

SMODS.Seal({
    key = 'green',
    atlas = "Extras",
	pos = { x = 2, y = 1 },
    badge_colour = HEX('55a383'),
    unlocked = true,
    discovered = false,
})

HNDS.install_green_seal_draw_hook()
