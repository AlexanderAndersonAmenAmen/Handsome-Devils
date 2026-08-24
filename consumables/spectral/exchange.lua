local function hnds_exchange_target_limit(card)
    local base = card and card.ability and card.ability.extra
        and tonumber(card.ability.extra.cards) or 1
    local bonus = HNDS and HNDS.get_contagion_bonus and HNDS.get_contagion_bonus() or 0
    return math.max(1, base + bonus)
end

local function exchange_selected_cards(card, forced_cards)
    if type(forced_cards) == "table" then return forced_cards end
    return G and G.hand and G.hand.highlighted or {}
end

local function is_negative(target)
    return target and target.edition
        and (target.edition.negative or target.edition.key == "e_negative")
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
                if target and target.set_edition then
                    target:set_edition("e_negative", true)
                    target:juice_up(0.3, 0.5)
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
        info_queue[#info_queue + 1] = { key = "hnds_negative_playing_card", set = "Other" }
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
        apply_exchange(card, exchange_selected_cards(card))
    end,
    can_use = function(self, card)
        -- Do not hard-code game-state names here. Steamodded/Card:can_use_consumeable
        -- already owns the global state/lock rules, including modded booster-open
        -- states. Exchange only needs to validate its own target and hand-cost
        -- requirements. This keeps it usable when drawn directly inside a pack.
        if not (G and G.GAME and G.hand) then return false end
        if not (G.GAME.current_round and G.GAME.current_round.hands_left > 1) then return false end
        if not (G.GAME.round_resets and (G.GAME.round_resets.hands or 0) > 1) then return false end
        if not (G.hand and #G.hand.highlighted > 0
            and #G.hand.highlighted <= hnds_exchange_target_limit(card))
        then
            return false
        end

        -- Existing Editions are valid Exchange targets. Only cards that are
        -- already Negative are rejected, so an Editioned card can be selected
        -- and converted to Negative normally.
        for _, target in ipairs(G.hand.highlighted) do
            if target and not is_negative(target) then return true end
        end
        return false
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
