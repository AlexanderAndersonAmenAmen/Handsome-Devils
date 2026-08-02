local EXCHANGE_STICKER = "hnds_exchange_draw"

local function hnds_exchange_target_limit(card)
    local base = card and card.ability and card.ability.extra
        and tonumber(card.ability.extra.cards) or 3
    local bonus = HNDS and HNDS.get_contagion_bonus and HNDS.get_contagion_bonus() or 0
    return math.max(1, base + bonus)
end

local function exchange_selected_cards(card, forced_cards)
    if type(forced_cards) == "table" then return forced_cards end
    return G and G.hand and G.hand.highlighted or {}
end

local function apply_exchange(card, cards)
    -- Copy the highlighted-card references immediately; use_card may clear the
    -- highlight table before this delayed visual/application event executes.
    local targets = {}
    for _, target in ipairs(cards or {}) do targets[#targets + 1] = target end

    G.E_MANAGER:add_event(Event({
        trigger = "after",
        delay = 0.4,
        func = function()
            for _, target in ipairs(targets) do
                if target and target.add_sticker then
                    target:add_sticker(EXCHANGE_STICKER, true)
                    target:juice_up(0.3, 0.5)
                elseif target and target.ability then
                    -- Compatibility fallback for Steamodded builds that do not
                    -- expose Card:add_sticker on playing cards.
                    target.ability[EXCHANGE_STICKER] = true
                end
            end
            if card then card:juice_up(0.3, 0.5) end
            return true
        end,
    }))

    -- Every Exchange permanently removes exactly one hand from this run. The
    -- round reset value supplies the penalty again at the start of each round.
    G.GAME.hnds_exchange_hand_penalty = (G.GAME.hnds_exchange_hand_penalty or 0) + 1
    G.GAME.round_resets.hands = math.max(1, (G.GAME.round_resets.hands or 1) - 1)
    ease_hands_played(-1)
end

SMODS.Consumable({
    key = "exchange",
    set = "Spectral",
    config = {
        max_highlighted = 1,
        extra = { cards = 1 },
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = { key = EXCHANGE_STICKER, set = "Other" }
        local target_limit = hnds_exchange_target_limit(card)
        local bonus = HNDS and HNDS.get_contagion_bonus and HNDS.get_contagion_bonus() or 0
        return {
            key = bonus > 0 and "c_hnds_exchange_contagion" or nil,
            vars = { target_limit, 1 },
        }
    end,
    discovered = false,
    atlas = "Consumables",
    pos = { x = 2, y = 0 },
    cost = 4,
    use = function(self, card, context, copier)
        local cards = exchange_selected_cards(card)
        apply_exchange(card, cards)
    end,
    can_use = function(self, card)
        if G.STATE ~= G.STATES.SELECTING_HAND then return false end
        if not (G.GAME.current_round and G.GAME.current_round.hands_left > 1) then return false end
        if not (G.GAME.round_resets and (G.GAME.round_resets.hands or 0) > 1) then return false end
        if not (G.hand and #G.hand.highlighted > 0
            and #G.hand.highlighted <= hnds_exchange_target_limit(card))
        then
            return false
        end

        -- Re-selecting an already marked card should not consume another copy
        -- of Exchange without adding a new permanent target.
        for _, target in ipairs(G.hand.highlighted) do
            if target and target.ability and target.ability[EXCHANGE_STICKER] then
                return false
            end
        end
        return true
    end,
    force_use = function(self, card, area)
        local cards = Cryptid and Cryptid.get_highlighted_cards
            and Cryptid.get_highlighted_cards(
                { G.hand }, {}, 1, hnds_exchange_target_limit(card)
            ) or exchange_selected_cards(card)
        apply_exchange(card, cards)
    end,
    demicoloncompat = true,
})

-- Permanent playing-card marker. It is manually applied by Exchange and never
-- rolls naturally. Position requested: HDstickers atlas {x = 2, y = 1}.
SMODS.Sticker({
    key = "exchange_draw",
    atlas = "Stickers",
    pos = { x = 2, y = 1 },
    badge_colour = G.C.PURPLE,
    rate = 0,
    default_compat = true,
    sets = { Default = true, Enhanced = true },
    apply = function(self, card, val)
        SMODS.Sticker.apply(self, card, val)
    end,
})

-- Called from the mod-level first_hand_drawn context. Marked cards already in
-- the opening hand need no action; marked cards still in the deck are drawn as
-- extra opening cards, matching Jokestone's draw behaviour. Boss-debuffed
-- targets remain in the deck.
HNDS.draw_exchange_cards = function()
    if not (G and G.GAME and G.GAME.current_round and G.deck and G.hand) then return end
    if G.GAME.current_round.hnds_exchange_cards_drawn then return end
    G.GAME.current_round.hnds_exchange_cards_drawn = true

    local cards_to_draw = {}
    for _, target in ipairs(G.deck.cards or {}) do
        if target and target.ability and target.ability[EXCHANGE_STICKER]
            and not target.debuff and not target.ability.hnds_drawing
        then
            cards_to_draw[#cards_to_draw + 1] = target
            target.ability.hnds_drawing = true
        end
    end
    if #cards_to_draw == 0 then return end

    G.E_MANAGER:add_event(Event({
        trigger = "before",
        func = function()
            for _, target in ipairs(cards_to_draw) do
                if target.area == G.deck and not target.debuff then
                    draw_card(G.deck, G.hand, nil, "up", true, target)
                end
            end
            G.E_MANAGER:add_event(Event({
                trigger = "before",
                delay = 0.1,
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
