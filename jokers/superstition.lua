HNDS = HNDS or {}

local SUPERSTITION_KEY = 'j_hnds_superstition'
local PUZZLE_KEY = 'hnds_sarmenti_puzzle'

local active_cache_stamp
local active_cache_value = false

local function superstition_is_center(card)
    local config = card and card.config
    return config and (config.center_key == SUPERSTITION_KEY
        or (config.center and config.center.key == SUPERSTITION_KEY))
end

local function superstition_puzzle_contains(card)
    local puzzle = card and card.ability and card.ability[PUZZLE_KEY]
    if type(puzzle) ~= 'table' then return false end
    if puzzle.primary_center_key == SUPERSTITION_KEY then return true end
    for _, component in ipairs(puzzle.components or {}) do
        if component and component.center_key == SUPERSTITION_KEY then return true end
    end
    return false
end

local function superstition_invalidate_active_cache()
    active_cache_stamp = nil
end

function HNDS.superstition_effect_active()
    if not (G and G.STAGES and G.STAGE == G.STAGES.RUN
        and G.jokers and type(G.jokers.cards) == 'table')
    then
        active_cache_stamp = nil
        active_cache_value = false
        return false
    end

    local timers = G.TIMERS
    local stamp = timers and (timers.REAL or timers.TOTAL)
    if stamp ~= nil and active_cache_stamp == stamp then
        return active_cache_value
    end

    local active = false
    for _, joker in ipairs(G.jokers.cards) do
        if joker and joker.added_to_deck and not joker.debuff
            and not joker.REMOVED and not joker.removed
            and (superstition_is_center(joker) or superstition_puzzle_contains(joker))
        then
            active = true
            break
        end
    end

    active_cache_stamp = stamp
    active_cache_value = active
    return active
end

local function superstition_card_id(card)
    if not card then return nil end
    local real_id = type(card) == 'table' and rawget(card, '_hnds_imposter_real_id') or nil
    if type(real_id) == 'number' then return real_id end

    if HNDS.is_faceless and HNDS.is_faceless(card) and type(card.get_id) == 'function' then
        local ok, value = pcall(card.get_id, card)
        if ok and type(value) == 'number' then return value end
    end

    local base_id = card.base and tonumber(card.base.id) or nil
    if base_id then return base_id end
    if type(card.get_id) == 'function' then
        local ok, value = pcall(card.get_id, card)
        if ok and type(value) == 'number' then return value end
    end
end

local function superstition_rank_matches(card, rank)
    if not card or type(rank) ~= 'number' then return false end
    if HNDS.card_has_stone and HNDS.card_has_stone(card, false) then return false end

    local id = superstition_card_id(card)
    if id == rank then return true end
    return (id == 11 or id == 12 or id == 13)
        and HNDS.imposter_effect_active
        and HNDS.imposter_effect_active()
        or false
end

HNDS.superstition_rank_matches = superstition_rank_matches

if SMODS and type(SMODS.get_enhancements) == 'function'
    and not HNDS._superstition_get_enhancements_hook
then
    HNDS._superstition_get_enhancements_hook = true
    local get_enhancements_ref = SMODS.get_enhancements

    function SMODS.get_enhancements(card, ...)
        local enhancements = get_enhancements_ref(card, ...)
        if not HNDS.superstition_effect_active() then return enhancements end

        local wild = superstition_rank_matches(card, 6)
        local lucky = superstition_rank_matches(card, 7)
        if not wild and not lucky then return enhancements end

        local result = {}
        if type(enhancements) == 'table' then
            for key, value in pairs(enhancements) do result[key] = value end
        end
        if wild then result.m_wild = true end
        if lucky then result.m_lucky = true end
        return result
    end
end

if SMODS and type(SMODS.has_enhancement) == 'function'
    and not HNDS._superstition_has_enhancement_hook
then
    HNDS._superstition_has_enhancement_hook = true
    local has_enhancement_ref = SMODS.has_enhancement

    function SMODS.has_enhancement(card, key, ...)
        if HNDS.superstition_effect_active()
            and ((key == 'm_wild' and superstition_rank_matches(card, 6))
                or (key == 'm_lucky' and superstition_rank_matches(card, 7)))
        then
            return true
        end
        return has_enhancement_ref(card, key, ...)
    end
end

if SMODS and type(SMODS.has_any_suit) == 'function'
    and not HNDS._superstition_has_any_suit_hook
then
    HNDS._superstition_has_any_suit_hook = true
    local has_any_suit_ref = SMODS.has_any_suit

    function SMODS.has_any_suit(card, ...)
        if HNDS.superstition_effect_active() and superstition_rank_matches(card, 6) then
            return true
        end
        return has_any_suit_ref(card, ...)
    end
end

if Card and type(Card.is_suit) == 'function' and not HNDS._superstition_is_suit_hook then
    HNDS._superstition_is_suit_hook = true
    local is_suit_ref = Card.is_suit

    function Card:is_suit(suit, bypass_debuff, flush_calc, ...)
        if suit ~= nil and (bypass_debuff or flush_calc or not self.debuff)
            and HNDS.superstition_effect_active()
            and superstition_rank_matches(self, 6)
        then
            return true
        end
        return is_suit_ref(self, suit, bypass_debuff, flush_calc, ...)
    end
end

local function superstition_played_cards(context)
    if type(context) == 'table' and type(context.full_hand) == 'table'
        and #context.full_hand > 0
    then
        return context.full_hand
    end
    if G and G.play and type(G.play.cards) == 'table' and #G.play.cards > 0 then
        return G.play.cards
    end
    return type(context) == 'table' and context.scoring_hand or nil
end

local function superstition_adjacent_eights(context)
    local target = context and context.other_card
    local played = superstition_played_cards(context)
    if not target or type(played) ~= 'table' then return 0 end

    for index, playing_card in ipairs(played) do
        if playing_card == target then
            local repetitions = 0
            if index > 1 and superstition_rank_matches(played[index - 1], 8) then
                repetitions = repetitions + 1
            end
            if index < #played and superstition_rank_matches(played[index + 1], 8) then
                repetitions = repetitions + 1
            end
            return repetitions
        end
    end
    return 0
end

SMODS.Joker {
    key = 'superstition',
    atlas = 'Jokers',
    pos = { x = 5, y = 8 },
    rarity = 3,
    cost = 8,
    unlocked = true,
    discovered = false,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    config = { extra = {} },

    loc_vars = function(self, info_queue, card)
        if info_queue then
            info_queue[#info_queue + 1] = G.P_CENTERS.m_wild
            info_queue[#info_queue + 1] = G.P_CENTERS.m_lucky
        end
        return { vars = {} }
    end,

    add_to_deck = function(self, card, from_debuff)
        superstition_invalidate_active_cache()
    end,

    remove_from_deck = function(self, card, from_debuff)
        superstition_invalidate_active_cache()
    end,

    calculate = function(self, card, context)
        if not (context and context.repetition and context.cardarea == G.play
            and context.other_card)
        then
            return
        end

        local repetitions = superstition_adjacent_eights(context)
        if repetitions > 0 then return { repetitions = repetitions } end
    end,

    attributes = {
        'passive', 'rank', 'six', 'seven', 'eight',
        'suit', 'enhancements', 'retrigger',
    },
}
