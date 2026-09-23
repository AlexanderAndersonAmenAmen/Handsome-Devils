local DARK_PACT_NO_SELL_FIELD = 'hnds_dark_pact_unsellable'

function HNDS.is_dark_pact_unsellable(card)
    return card and type(card.ability) == 'table'
        and card.ability[DARK_PACT_NO_SELL_FIELD] == true
end

local function hnds_dark_pact_ui_card(e)
    if HNDS.is_dark_pact_unsellable(e) then return e end
    local ref = e and e.config and e.config.ref_table
    if HNDS.is_dark_pact_unsellable(ref) then return ref end
    if type(ref) == 'table' and HNDS.is_dark_pact_unsellable(ref.card) then
        return ref.card
    end
end

local function hnds_dark_pact_disable_sell_button(e)
    if not (e and e.config) then return end
    e.config.button = nil
    local inactive = G and G.C and (
        (G.C.UI and G.C.UI.BACKGROUND_INACTIVE) or G.C.INACTIVE or G.C.GREY
    )
    if inactive then e.config.colour = inactive end
end

function HNDS.install_dark_pact_hooks()
    if Card and type(Card.set_cost) == 'function'
        and not Card._hnds_dark_pact_cost_wrapped
    then
        Card._hnds_dark_pact_cost_wrapped = true
        local set_cost_ref = Card.set_cost
        function Card:set_cost(...)
            local result = HNDS.pack(set_cost_ref(self, ...))
            if HNDS.is_dark_pact_unsellable(self) then
                self.sell_cost = 0
                if self.sell_cost_label ~= '?' then self.sell_cost_label = 0 end
            end
            return ((table and table.unpack) or unpack)(result, 1, result.n)
        end
    end

    if Card and type(Card.can_sell_card) == 'function'
        and not Card._hnds_dark_pact_can_sell_wrapped
    then
        Card._hnds_dark_pact_can_sell_wrapped = true
        local can_sell_card_ref = Card.can_sell_card
        function Card:can_sell_card(...)
            if HNDS.is_dark_pact_unsellable(self) then return false end
            return can_sell_card_ref(self, ...)
        end
    end

    if Card and type(Card.sell_card) == 'function'
        and not Card._hnds_dark_pact_sell_wrapped
    then
        Card._hnds_dark_pact_sell_wrapped = true
        local sell_card_ref = Card.sell_card
        function Card:sell_card(...)
            if HNDS.is_dark_pact_unsellable(self) then return false end
            return sell_card_ref(self, ...)
        end
    end

    if G and G.FUNCS and type(G.FUNCS.can_sell_card) == 'function'
        and not G.FUNCS._hnds_dark_pact_can_sell_wrapped
    then
        G.FUNCS._hnds_dark_pact_can_sell_wrapped = true
        local can_sell_card_ref = G.FUNCS.can_sell_card
        G.FUNCS.can_sell_card = function(e, ...)
            if hnds_dark_pact_ui_card(e) then
                hnds_dark_pact_disable_sell_button(e)
                return false
            end
            return can_sell_card_ref(e, ...)
        end
    end

    if G and G.FUNCS and type(G.FUNCS.sell_card) == 'function'
        and not G.FUNCS._hnds_dark_pact_sell_wrapped
    then
        G.FUNCS._hnds_dark_pact_sell_wrapped = true
        local sell_card_ref = G.FUNCS.sell_card
        G.FUNCS.sell_card = function(e, ...)
            if hnds_dark_pact_ui_card(e) then
                hnds_dark_pact_disable_sell_button(e)
                return false
            end
            return sell_card_ref(e, ...)
        end
    end
end

local function hnds_dark_pact_mark_unsellable(card)
    if not card then return end
    card.ability = card.ability or {}
    card.ability[DARK_PACT_NO_SELL_FIELD] = true

    if type(card.set_cost) == 'function' then card:set_cost() end
    card.sell_cost = 0
    if card.sell_cost_label ~= '?' then card.sell_cost_label = 0 end
end

local function hnds_dark_pact_is_six(playing_card, context)
    if not playing_card then return false end
    if HNDS.safe_has_no_rank and HNDS.safe_has_no_rank(playing_card) then
        return false
    end

    if HNDS.imposter_rank_match then
        local ok, matches = pcall(HNDS.imposter_rank_match, playing_card, 6, context)
        if ok then return matches == true end
    end

    if type(playing_card.get_id) == 'function' then
        local ok, rank = pcall(playing_card.get_id, playing_card)
        if ok then return rank == 6 end
    end
    return playing_card.base and playing_card.base.id == 6
end

local function hnds_dark_pact_hand_has_three_sixes(context)
    local played_hand = context and (context.full_hand or context.scoring_hand)
    if type(played_hand) ~= 'table' then return false end

    local sixes = 0
    for _, playing_card in ipairs(played_hand) do
        if hnds_dark_pact_is_six(playing_card, context) then
            sixes = sixes + 1
            if sixes >= 3 then return true end
        end
    end
    return false
end

local function hnds_dark_pact_has_consumable_room()
    if not (G and G.GAME and G.consumeables and G.consumeables.cards
        and G.consumeables.config and G.consumeables.config.card_limit)
    then
        return false
    end
    local buffer = tonumber(G.GAME.consumeable_buffer) or 0
    return #G.consumeables.cards + buffer < G.consumeables.config.card_limit
end

local function hnds_dark_pact_queue_spectral()
    if not (SMODS and type(SMODS.add_card) == 'function'
        and hnds_dark_pact_has_consumable_room())
    then
        return false
    end

    HNDS.install_dark_pact_hooks()
    G.GAME.consumeable_buffer = (tonumber(G.GAME.consumeable_buffer) or 0) + 1

    local function create_spectral()
        local ok, spectral = pcall(SMODS.add_card, {
            set = 'Spectral',
            area = G.consumeables,
            soulable = false,
            key_append = 'hnds_dark_pact',
        })
        if G and G.GAME then
            G.GAME.consumeable_buffer = math.max(
                0, (tonumber(G.GAME.consumeable_buffer) or 1) - 1
            )
        end
        if not ok then error(spectral, 0) end
        hnds_dark_pact_mark_unsellable(spectral)
        return true
    end

    if G.E_MANAGER and Event then
        G.E_MANAGER:add_event(Event({ func = create_spectral }))
    else
        create_spectral()
    end
    return true
end

HNDS.install_dark_pact_hooks()

SMODS.Joker {
    key = 'dark_pact',
    prefix_config = { key = { mod = false } },
    atlas = 'Jokers',
    pos = { x = 2, y = 8 },
    rarity = 2,
    cost = 7,
    unlocked = true,
    discovered = false,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    calculate = function(self, card, context)
        local valid_context = context.forcetrigger
            or (context.after and not context.repetition and not context.repetition_only)
        if not valid_context then return end
        if not context.forcetrigger and not hnds_dark_pact_hand_has_three_sixes(context) then
            return
        end

        if not hnds_dark_pact_queue_spectral() then
            return { message = localize('k_no_room_ex'), colour = G.C.RED }
        end
        return {
            message = localize('k_plus_spectral'),
            colour = G.C.SECONDARY_SET.Spectral,
        }
    end,
    attributes = { 'joker', 'rank', 'six', 'spectral', 'generation' },
}
