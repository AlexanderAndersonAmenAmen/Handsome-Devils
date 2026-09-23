HNDS = HNDS or {}

-- The draw destination knows whether the Blind intentionally hid a card.
-- Capture that answer when the returned card enters the hand, instead of
-- guessing from wheel_flipped, which can also be stale from an earlier draw.
local function reveal_one_punchline_card(card)
    card.facing = 'front'
    card.sprite_facing = 'front'
    card.flipping = nil
    if card.pinch then card.pinch.x = false end
    if card.ability then card.ability.wheel_flipped = nil end
end

function HNDS.install_one_punchline_face_hook()
    if HNDS._one_punchline_face_hook_version == 3 then return true end
    if not (Card and type(Card.update) == 'function' and CardArea
        and type(CardArea.emplace) == 'function') then return false end
    local emplace_ref = CardArea.emplace
    CardArea.emplace = function(self, card, location, stay_flipped)
        -- Let the scoring card remain in G.play through all scoring events.
        -- Vanilla removes it from play in a later draw_card event; redirect
        -- that transfer to the deck at the moment it would enter discard.
        if card and G and self == G.discard and G.GAME
            and card == G.GAME.hnds_one_punchline_pending
            and HNDS.finish_one_punchline_return(card) then
            return
        end
        -- draw_card captures the scored card when it schedules play -> discard.
        -- If we returned it to the deck before that event runs, vanilla's
        -- remove_card still returns the card even though it is no longer in
        -- G.play. Do not let the stale event insert a second reference into
        -- discard: deck alignment would then flip the card while it is in hand.
        if card and card.hnds_one_punchline_returned and G
            and self == G.discard and (card.area == G.deck or card.area == G.hand) then
            return
        end
        local result = emplace_ref(self, card, location, stay_flipped)
        if card and G and G.GAME and self == G.hand
            and G.GAME.hnds_one_punchline_next_draw == card then
            G.GAME.hnds_one_punchline_next_draw = nil
        end
        if card and card.hnds_one_punchline_needs_reveal and G and self == G.hand then
            card.hnds_one_punchline_needs_reveal = nil
            if not stay_flipped then
                card.hnds_one_punchline_reveal_time = 1.5
                reveal_one_punchline_card(card)
            end
        end
        return result
    end
    local update_ref = Card.update
    Card.update = function(self, dt, ...)
        local result = update_ref(self, dt, ...)
        if self.hnds_one_punchline_needs_reveal and G and self.area == G.hand then
            self.hnds_one_punchline_needs_reveal = nil
            if not (self.ability and self.ability.wheel_flipped) then
                self.hnds_one_punchline_reveal_time = 1.5
            end
        end
        if self.hnds_one_punchline_reveal_time then
            if G and self.area == G.hand then
                reveal_one_punchline_card(self)
                self.hnds_one_punchline_reveal_time = self.hnds_one_punchline_reveal_time - (dt or 0)
                if self.hnds_one_punchline_reveal_time <= 0 then
                    self.hnds_one_punchline_reveal_time = nil
                end
            else
                self.hnds_one_punchline_reveal_time = nil
            end
        end
        return result
    end
    HNDS._one_punchline_face_hook_installed = true
    HNDS._one_punchline_face_hook_version = 3
    return true
end

-- Steamodded may compute hand_space before its drawing_cards context runs.
-- Intercept the entry point itself so the returned card is counted on both
-- the vanilla and Steamodded draw paths, including an otherwise empty deck.
function HNDS.install_one_punchline_draw_hook()
    if HNDS._one_punchline_draw_hook_version == 2 then return true end
    if not (G and G.FUNCS and type(G.FUNCS.draw_from_deck_to_hand) == 'function') then
        return false
    end
    local draw_ref = G.FUNCS.draw_from_deck_to_hand
    G.FUNCS.draw_from_deck_to_hand = function(...)
        HNDS.finish_one_punchline_return(nil, true)
        return draw_ref(...)
    end
    HNDS._one_punchline_draw_hook_installed = true
    HNDS._one_punchline_draw_hook_version = 2
    return true
end

-- The deck draws from the end of its card list, while the front of that list
-- is the visible, clickable card on the pile.
function HNDS.finish_one_punchline_return(detached_card, before_refill)
    if not (G and G.GAME and G.deck) then return false end
    local target = G.GAME.hnds_one_punchline_pending
    if not target then return false end
    -- Old queued callbacks (and older hot-reloaded wrappers) must not move
    -- the card during scoring. Only the real cleanup transfer or a refill
    -- that has already begun may commit it.
    if detached_card ~= target and not before_refill then return false end

    local from = target.area
    if from and from ~= G.play and from ~= G.discard then return false end
    -- CardArea:remove_card returns its argument even if the area does not
    -- contain it. Verify membership so the same card can never enter the deck
    -- twice when another mod has already moved it.
    local in_area = false
    if from then
        for _, other in ipairs(from.cards or {}) do
            if other == target then in_area = true; break end
        end
    end
    if in_area then
        if from:remove_card(target) ~= target then return false end
    elseif detached_card ~= target then
        return false
    end

    G.GAME.hnds_one_punchline_pending = nil
    target.hnds_one_punchline_returning = nil
    target.hnds_one_punchline_reveal_time = nil

    -- Moving through a real CardArea lets the card fly toward the deck. A
    -- normal deck-to-hand draw flips it face up unless the Blind prevents it.
    if target.ability then target.ability.wheel_flipped = nil end
    if target.facing == 'front' then target:flip() end
    target.hnds_one_punchline_returned = true
    G.GAME.hnds_one_punchline_next_draw = target
    G.deck:emplace(target)

    -- emplace inserts at index 1. Move only this card to the next-draw end;
    -- sorting the deck would destroy its shuffled order.
    if G.deck.cards[1] == target and #G.deck.cards > 1 then
        table.remove(G.deck.cards, 1)
        table.insert(G.deck.cards, target)
        G.deck:set_ranks()
        G.deck:align_cards()
    end

    -- If it is the only card left, let clicks reach the View Deck UI.
    if target.states and target.states.collide then
        target.states.collide.can = false
    end
    target.hnds_one_punchline_needs_reveal = true
    return true
end

SMODS.Joker({
    key = "one_punchline_man",
    atlas = "Jokers",
    pos = { x = 9, y = 4 },
    rarity = 1,
    cost = 4,
    unlocked = false,
    discovered = false,
    unlock_condition = { type = "hnds_joker_unlock", key = "one_punchline_man" },
    locked_loc_vars = function(self)
        return HNDS.joker_locked_loc_vars("one_punchline_man")
    end,
    check_for_unlock = function(self, args)
        return HNDS.joker_unlock_condition_met("one_punchline_man", args)
    end,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    calculate = function(self, card, context)
        HNDS.install_one_punchline_face_hook()
        HNDS.install_one_punchline_draw_hook()
        if context.after and not context.blueprint and context.scoring_hand and context.scoring_hand[1] then
            local target = context.scoring_hand[1]
            if target.area == G.play and not target.hnds_one_punchline_returning
                and not G.GAME.hnds_one_punchline_pending then
                target.hnds_one_punchline_returning = true
                G.GAME.hnds_one_punchline_pending = target
            end
        end
        -- Direct SMODS.draw_cards calls bypass G.FUNCS. This still moves the
        -- card ahead of Steamodded's final #G.deck.cards draw count.
        if context.drawing_cards and not context.blueprint then
            HNDS.finish_one_punchline_return(nil, true)
        end
    end,
    attributes = { "hands", "deck_manipulation" }
})

HNDS.install_one_punchline_face_hook()
HNDS.install_one_punchline_draw_hook()
