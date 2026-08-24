-- Imposter
--
-- Face cards count as any rank for Joker effects.
--
-- The old implementation brute-forced ranks by recalculating every Joker up to
-- thirteen extra times. Besides being expensive, those probe calculations could
-- consume RNG, queue events, scale Jokers, or otherwise mutate state before the
-- "real" calculation. This implementation never probes/replays a Joker.
--
-- Instead, rank-sensitive Jokers use Steamodded's rank attributes (two, ace,
-- king, etc.) to choose one rank that satisfies that Joker, then that Joker is
-- evaluated exactly once with the relevant face card temporarily presenting that
-- rank. Handsome Devils effects that scan a whole scoring hand use the public
-- HNDS.imposter_rank_match helper below.

local RANK_ATTRIBUTE_IDS = {
    two = 2,
    three = 3,
    four = 4,
    five = 5,
    six = 6,
    seven = 7,
    eight = 8,
    nine = 9,
    ten = 10,
    jack = 11,
    queen = 12,
    king = 13,
    ace = 14,
}

local RANK_ATTRIBUTE_ORDER = {
    'two', 'three', 'four', 'five', 'six', 'seven',
    'eight', 'nine', 'ten', 'jack', 'queen', 'king', 'ace',
}

local RANK_VALUE_BY_ID = {
    [2] = '2', [3] = '3', [4] = '4', [5] = '5', [6] = '6',
    [7] = '7', [8] = '8', [9] = '9', [10] = '10',
    [11] = 'Jack', [12] = 'Queen', [13] = 'King', [14] = 'Ace',
}

local RANK_NOMINAL_BY_ID = {
    [2] = 2, [3] = 3, [4] = 4, [5] = 5, [6] = 6,
    [7] = 7, [8] = 8, [9] = 9, [10] = 10,
    [11] = 10, [12] = 10, [13] = 10, [14] = 11,
}

local RANK_FACE_NOMINAL_BY_ID = {
    [11] = 0.1, [12] = 0.2, [13] = 0.3, [14] = 0.4,
}

local function hnds_table_contains(t, value)
    if type(t) ~= 'table' then return false end
    for i = 1, #t do
        if t[i] == value then return true end
    end
    return false
end

local function hnds_center_key(card)
    return card and card.config and card.config.center and card.config.center.key
end

local function hnds_has_attribute(card, attribute)
    if not card then return false end

    if type(card.has_attribute) == 'function' then
        local ok, value = pcall(card.has_attribute, card, attribute)
        if ok and value == true then return true end
    end

    -- Fallback for load orders / older objects whose runtime helper is missing.
    local attrs = card.config and card.config.center and card.config.center.attributes
    if type(attrs) == 'table' then
        for key, value in pairs(attrs) do
            if value == attribute or (key == attribute and value) then return true end
        end
    end
    return false
end

local function hnds_card_has_no_rank(card)
    if HNDS and HNDS.safe_has_no_rank then return HNDS.safe_has_no_rank(card) end
    if HNDS and HNDS.is_faceless and HNDS.is_faceless(card) then return true end
    if SMODS and type(SMODS.has_no_rank) == 'function' then
        local ok, result = pcall(SMODS.has_no_rank, card)
        return ok and result == true
    end
    return false
end

local function hnds_card_is_face(card)
    if not card or hnds_card_has_no_rank(card) then return false end
    if type(card.is_face) == 'function' then
        local ok, value = pcall(card.is_face, card)
        if ok then return value == true end
    end
    local id = card.base and card.base.id
    return id == 11 or id == 12 or id == 13
end

-- Public because a few Handsome Devils Jokers inspect context.scoring_hand
-- directly instead of receiving one context.other_card at a time.
function HNDS.imposter_effect_active()
    if not (G and G.STAGES and G.STAGE == G.STAGES.RUN and G.jokers and G.jokers.cards) then
        return false
    end

    for i = 1, #G.jokers.cards do
        local joker = G.jokers.cards[i]
        if hnds_center_key(joker) == 'j_hnds_imposter'
            and joker.added_to_deck
            and not joker.debuff
        then
            return true
        end
    end
    return false
end

function HNDS.imposter_card_is_wild_rank(card, context)
    -- This helper is only consumed from Joker-effect code paths. Do not hook
    -- global rank/poker-hand evaluation: Imposter changes Joker interpretation,
    -- not the card's actual rank for forming hands.
    return HNDS.imposter_effect_active() and hnds_card_is_face(card)
end

-- Return true when `card` satisfies a required rank for a Joker effect.
-- The caller controls the Joker context; poker-hand formation itself is never
-- routed through this helper.
function HNDS.imposter_rank_match(card, required_id, context)
    if not card or type(required_id) ~= 'number' then return false end

    local real_id = card._hnds_imposter_real_id
    if real_id == nil and type(card.get_id) == 'function' then
        real_id = card:get_id()
    end
    if real_id == required_id then return true end

    return HNDS.imposter_card_is_wild_rank(card, context)
end

local function hnds_dynamic_required_rank(joker)
    local key = hnds_center_key(joker)
    if key == 'j_idol' then
        local idol = G and G.GAME and G.GAME.current_round and G.GAME.current_round.idol_card
        if idol then
            if type(idol.id) == 'number' then return idol.id end
            if idol.rank then
                for id, value in pairs(RANK_VALUE_BY_ID) do
                    if value == idol.rank then return id end
                end
            end
        end
    elseif key == 'j_hnds_dark_idol' then
        local idol = G and G.GAME and G.GAME.current_round and G.GAME.current_round.dark_idol
        if idol and type(idol.id) == 'number' then return idol.id end
    end
    return nil
end

local function hnds_rank_for_joker(joker, target)
    if not hnds_has_attribute(joker, 'rank') then return nil end

    local dynamic = hnds_dynamic_required_rank(joker)
    if dynamic then return dynamic end

    local real_id = target and target.base and target.base.id
    local first
    for i = 1, #RANK_ATTRIBUTE_ORDER do
        local attribute = RANK_ATTRIBUTE_ORDER[i]
        if hnds_has_attribute(joker, attribute) then
            local id = RANK_ATTRIBUTE_IDS[attribute]
            if id == real_id then return id end
            first = first or id
        end
    end
    return first
end

local function hnds_pack(...)
    return { n = select('#', ...), ... }
end

local hnds_unpack = (table and table.unpack) or unpack

local function hnds_call_with_rank(card, rank_id, fn)
    if not (card and card.base and RANK_VALUE_BY_ID[rank_id]) then
        return fn()
    end

    -- Preserve every field/method we temporarily expose differently. The
    -- _hnds_imposter_real_id marker also lets helper-based Jokers see the true
    -- physical rank while a nested copied-Joker calculation is in progress.
    -- Preserve the raw instance fields, not only the resolved methods. If a
    -- method normally comes from Card's metatable, restoring the resolved
    -- function onto the instance would freeze that playing card to an old hook
    -- and bypass wrappers installed later by other mods.
    local old_get_id_raw = rawget(card, 'get_id')
    local old_is_face_raw = rawget(card, 'is_face')
    local old_get_original_rank_raw = rawget(card, 'get_original_rank')
    local old_real_id = card._hnds_imposter_real_id
    local old_spoof_id = card._hnds_imposter_spoof_id

    local base = card.base
    local old_base_id = base.id
    local old_base_value = base.value
    local old_base_nominal = base.nominal
    local old_face_nominal = base.face_nominal

    card._hnds_imposter_real_id = old_real_id or old_base_id
    card._hnds_imposter_spoof_id = rank_id
    base.id = rank_id
    base.value = RANK_VALUE_BY_ID[rank_id]
    base.nominal = RANK_NOMINAL_BY_ID[rank_id] or base.nominal
    base.face_nominal = RANK_FACE_NOMINAL_BY_ID[rank_id] or 0

    card.get_id = function() return rank_id end
    -- The card remains a face card while also counting as the required rank.
    card.is_face = function() return true end
    card.get_original_rank = function() return RANK_VALUE_BY_ID[rank_id] end

    local results
    local traceback = (debug and debug.traceback) or function(err) return err end
    local ok, err = xpcall(function()
        results = hnds_pack(fn())
    end, traceback)

    base.id = old_base_id
    base.value = old_base_value
    base.nominal = old_base_nominal
    base.face_nominal = old_face_nominal
    card.get_id = old_get_id_raw
    card.is_face = old_is_face_raw
    card.get_original_rank = old_get_original_rank_raw
    card._hnds_imposter_real_id = old_real_id
    card._hnds_imposter_spoof_id = old_spoof_id

    if not ok then error(err, 0) end
    return hnds_unpack(results, 1, results.n)
end

local function hnds_call_with_rank_cards(cards, rank_id, fn, index)
    index = index or 1
    if type(cards) ~= 'table' or index > #cards then return fn() end
    return hnds_call_with_rank(cards[index], rank_id, function()
        return hnds_call_with_rank_cards(cards, rank_id, fn, index + 1)
    end)
end

local function hnds_wild_scoring_cards(context)
    local out = {}
    if type(context) ~= 'table' or type(context.scoring_hand) ~= 'table' then return out end
    for i = 1, #context.scoring_hand do
        local playing_card = context.scoring_hand[i]
        if HNDS.imposter_card_is_wild_rank(playing_card, context) then
            out[#out + 1] = playing_card
        end
    end
    return out
end

-- Generic compatibility layer for vanilla / Steamodded / third-party Jokers.
-- Standard per-card rank checks spoof context.other_card; Joker-main effects
-- that scan context.scoring_hand get every face card presented as the
-- Joker's required rank. In both cases the Joker evaluates exactly ONCE.
if Card and type(Card.calculate_joker) == 'function' and not Card._hnds_imposter_rank_wrapper then
    Card._hnds_imposter_rank_wrapper = true
    local calculate_joker_ref = Card.calculate_joker

    function Card:calculate_joker(context, ...)
        if type(context) ~= 'table'
            or not (self.ability and self.ability.set == 'Joker')
            or hnds_center_key(self) == 'j_hnds_imposter'
            -- Quantum-enhancement discovery may itself calculate Jokers. Never
            -- spoof ranks during that introspection or a third-party enhancement
            -- can recurse back into SMODS.has_no_rank/has_enhancement indefinitely.
            or context.check_enhancement
            or context.extra_enhancement
            or (SMODS and SMODS.extra_enhancement_calc_in_progress)
        then
            return calculate_joker_ref(self, context, ...)
        end

        local args = hnds_pack(...)
        local function run_original()
            return calculate_joker_ref(self, context, hnds_unpack(args, 1, args.n))
        end

        local target = context.other_card
        if target and HNDS.imposter_card_is_wild_rank(target, context) then
            local rank_id = hnds_rank_for_joker(self, target)
            if rank_id then return hnds_call_with_rank(target, rank_id, run_original) end
        end

        -- Some rank Jokers (for example Superposition and modded hand-wide
        -- effects) inspect the scoring hand during joker_main instead of using
        -- context.other_card. Present every scored face card as the same valid
        -- rank for that Joker, still with only one Joker calculation.
        if context.joker_main or context.before or context.after then
            local wild_cards = hnds_wild_scoring_cards(context)
            if #wild_cards > 0 then
                local rank_id = hnds_rank_for_joker(self, wild_cards[1])
                if rank_id then return hnds_call_with_rank_cards(wild_cards, rank_id, run_original) end
            end
        end

        return run_original()
    end
end

SMODS.Joker {
    key = "imposter",
    atlas = "Jokers",
    pos = { x = 6, y = 4 },
    rarity = 2,
    cost = 6,
    unlocked = false,
    discovered = false,
    unlock_condition = { type = "hnds_joker_unlock", key = "imposter" },
    locked_loc_vars = function(self)
        return HNDS.joker_locked_loc_vars("imposter")
    end,
    check_for_unlock = function(self, args)
        return HNDS.joker_unlock_condition_met("imposter", args)
    end,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    config = { extra = {} },
    calculate = function(self, card, context)
        -- Passive effect is provided by the scoped rank compatibility layer.
    end,
    attributes = { "passive", "face" }
}
