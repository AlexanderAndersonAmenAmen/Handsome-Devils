HNDS = HNDS or {}

-- Keep these card references out of G.GAME; they only describe the hand that
-- is currently scoring. The transfer itself uses the game's normal cleanup.
HNDS.black_seal_pending = HNDS.black_seal_pending or setmetatable({}, { __mode = 'k' })
HNDS.black_seal_returned = HNDS.black_seal_returned or setmetatable({}, { __mode = 'k' })

local function return_black_seal_neighbor(card, info)
    if not (G and G.deck and G.deck.cards and card and info)
        or card.destroyed or card.shattered or card.seal == 'hnds_black' then
        return false
    end
    if card.area and card.area ~= G.play and card.area ~= G.discard then return false end

    -- Usually vanilla's delayed play -> discard draw_card has already removed
    -- the card from G.play. Handle a still-attached card without duplicating it.
    local from = card.area
    if from then
        for _, candidate in ipairs(from.cards or {}) do
            if candidate == card then
                from:remove_card(card)
                break
            end
        end
    end

    if card.ability then card.ability.wheel_flipped = nil end
    if card.facing == 'front' then card:flip() end
    G.deck:emplace(card)

    -- Deck draws from the end; the front is the visible card on the pile.
    -- Put the returned neighbors at the draw end without sorting the deck.
    -- Inserting later neighbors before earlier ones preserves played order.
    if G.deck.cards[1] == card and #G.deck.cards > 1 then
        table.remove(G.deck.cards, 1)
        local index = #G.deck.cards + 1
        local priority = G.GAME and G.GAME.hnds_one_punchline_next_draw
        for i, existing in ipairs(G.deck.cards) do
            local previous = HNDS.black_seal_returned[existing]
            if existing == priority or (previous and previous.hand == info.hand
                and previous.order < info.order) then
                index = i
                break
            end
        end
        table.insert(G.deck.cards, index, card)
    end

    HNDS.black_seal_returned[card] = info
    G.deck:set_ranks()
    G.deck:align_cards()
    -- Returned cards must not cover the View Deck click target, even when the
    -- deck contained no other cards before they returned.
    for _, returned in ipairs(G.deck.cards) do
        local earlier = HNDS.black_seal_returned[returned]
        if (earlier and earlier.hand == info.hand)
            or (G.GAME and returned == G.GAME.hnds_one_punchline_next_draw) then
            if returned.states and returned.states.collide then
                returned.states.collide.can = false
            end
        end
    end
    -- Reuse the regular deck-return reveal at hand entry; the Blind can still
    -- intentionally keep the next draw face down.
    card.hnds_one_punchline_needs_reveal = true
    return true
end

function HNDS.install_black_seal_return_hook()
    if HNDS._black_seal_return_hook_version == 1 then return true end
    if not (CardArea and type(CardArea.remove_card) == 'function'
        and type(CardArea.emplace) == 'function') then return false end

    local remove_ref = CardArea.remove_card
    CardArea.remove_card = function(self, card, ...)
        local candidate = card or (G and self == G.play and self.cards and self.cards[1])
        local pending = candidate and HNDS.black_seal_pending[candidate]
        local in_play = false
        if pending and G and self == G.play then
            for _, played in ipairs(self.cards or {}) do
                if played == candidate then in_play = true; break end
            end
        end
        local result = remove_ref(self, card, ...)
        if in_play and result == candidate then pending.detached = true end
        if G and self == G.deck then
            -- Removing the first returned card re-ranks the deck. Keep any
            -- remaining returned card from covering the View Deck target.
            for _, remaining in ipairs(self.cards or {}) do
                if HNDS.black_seal_returned[remaining]
                    and remaining.states and remaining.states.collide then
                    remaining.states.collide.can = false
                end
            end
        end
        return result
    end

    local emplace_ref = CardArea.emplace
    CardArea.emplace = function(self, card, location, stay_flipped)
        local pending = card and HNDS.black_seal_pending[card]
        if pending and G then
            if self == G.discard and pending.detached then
                HNDS.black_seal_pending[card] = nil
                if card.area == G.deck or card.area == G.hand then return end
                if card ~= (G.GAME and G.GAME.hnds_one_punchline_pending)
                    and return_black_seal_neighbor(card, pending) then return end
            elseif self == G.hand or self == G.deck then
                -- Another effect already moved this card; do not return it twice.
                HNDS.black_seal_pending[card] = nil
            end
        end
        return emplace_ref(self, card, location, stay_flipped)
    end

    HNDS._black_seal_return_hook_version = 1
    return true
end

SMODS.Seal({
    key = 'black',
    badge_colour = HEX('545454'),
    atlas = 'Extras',
    pos = { x = 3, y = 1 },
    unlocked = true,
    calculate = function(self, card, context)
        HNDS.install_black_seal_return_hook()
        if not (G and G.play and card and not card.debuff
            and card.area == G.play and context.main_scoring
            and context.cardarea == G.play and type(context.full_hand) == 'table') then return end

        local hand = context.full_hand
        for i, played in ipairs(hand) do
            if played == card then
                for _, offset in ipairs({ -1, 1 }) do
                    local neighbor = hand[i + offset]
                    if neighbor and neighbor.area == G.play and neighbor.seal ~= 'hnds_black'
                        and not neighbor.destroyed and not neighbor.shattered then
                        HNDS.black_seal_pending[neighbor] = {
                            hand = G.GAME and G.GAME.hands_played or 0,
                            order = i + offset,
                        }
                    end
                end
                break
            end
        end
    end,
})

HNDS.install_black_seal_return_hook()
