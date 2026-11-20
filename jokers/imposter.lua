


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

local VANILLA_RANKS = {
    j_8_ball = {8},
    j_baron = {13},
    j_even_steven = {2, 4, 6, 8, 10},
    j_fibonacci = {2, 3, 5, 8, 14},
    j_hack = {2, 3, 4, 5},
    j_hit_the_road = {11},
    j_odd_todd = {3, 5, 7, 9, 14},
    j_scholar = {14},
    j_shoot_the_moon = {12},
    j_sixth_sense = {6},
    j_superposition = {14},
    j_triboulet = {12, 13},
    j_walkie_talkie = {4, 10},
    j_wee = {2},
}

local function hnds_center_key(card)
    return card and card.config and card.config.center and card.config.center.key
end

local function hnds_has_attribute(card, attribute)
    if not card then return false end

    if type(card.has_attribute) == 'function' then
        local ok, value = pcall(card.has_attribute, card, attribute)
        if ok and value == true then return true end
    end


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


    return HNDS.imposter_effect_active() and hnds_card_is_face(card)
end

function HNDS.card_has_wild_rank(card, context)
    return HNDS.imposter_card_is_wild_rank(card, context)
end

function HNDS.imposter_rank_match(card, required_id, context)
    if not card or type(required_id) ~= 'number' then return false end

    local real_id = card._hnds_imposter_real_id
    if real_id == nil and type(card.get_id) == 'function' then
        real_id = card:get_id()
    end
    if real_id == required_id then return true end

    return HNDS.card_has_wild_rank(card, context)
end

local DYNAMIC_RANK_FIELDS = { j_idol = 'idol_card', j_mail = 'mail_card', j_hnds_dark_idol = 'dark_idol' }

local function hnds_dynamic_required_rank(field)
    local round = G and G.GAME and G.GAME.current_round
    local choice = field and round and round[field]
    if not choice then return end
    local rank = choice.rank and SMODS.Ranks[choice.rank]
    return tonumber(choice.id) or (rank and rank.id)
end

local function hnds_rank_for_joker(joker, target, key)
    if DYNAMIC_RANK_FIELDS[key] then return hnds_dynamic_required_rank(DYNAMIC_RANK_FIELDS[key]) end
    local real_id = target._hnds_imposter_real_id or target.base.id
    local vanilla = VANILLA_RANKS[key]
    if vanilla then
        for _, rank in ipairs(vanilla) do
            if rank == real_id then return rank end
        end
        return vanilla[1]
    end
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

local hnds_unpack = (table and table.unpack) or unpack

local function hnds_rank_definition(id)
    local name = RANK_VALUE_BY_ID[id]
    if name then return SMODS.Ranks[name] end
    for _, key in ipairs(SMODS.Rank.obj_buffer) do
        local rank = SMODS.Ranks[key]
        if rank.id == id then return rank end
    end
end

local function hnds_call_with_rank(card, rank_id, fn)
    local rank = hnds_rank_definition(rank_id)
    if not (card and card.base and rank) then
        return fn()
    end


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
    base.value = rank.key
    base.nominal = rank.nominal or RANK_NOMINAL_BY_ID[rank_id] or base.nominal
    base.face_nominal = rank.face_nominal or RANK_FACE_NOMINAL_BY_ID[rank_id] or 0

    card.get_id = function() return rank_id end

    card.is_face = function() return true end
    card.get_original_rank = function() return rank.key end

    local results
    local traceback = (debug and debug.traceback) or function(err) return err end
    local ok, err = xpcall(function()
        results = HNDS.pack(fn())
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

local function hnds_wild_cards(cards, context)
    local out = {}
    for _, playing_card in ipairs(cards) do
        if HNDS.card_has_wild_rank(playing_card, context) then
            out[#out + 1] = playing_card
        end
    end
    return out
end

if Card and type(Card.calculate_joker) == 'function' and not Card._hnds_imposter_rank_wrapper then
    Card._hnds_imposter_rank_wrapper = true
    local calculate_joker_ref = Card.calculate_joker

    function Card:calculate_joker(context, ...)
        local key = hnds_center_key(self)
        if type(context) ~= 'table'
            or not (self.ability and self.ability.set == 'Joker')
            or key == 'j_hnds_imposter'


            or context.check_enhancement
            or context.extra_enhancement
            or (SMODS and SMODS.extra_enhancement_calc_in_progress)
        then
            return calculate_joker_ref(self, context, ...)
        end

        local target = context.other_card or context.destroy_card or context.destroying_card
        if type(target) ~= 'table' or not target.base then target = nil end
        local cards = ((context.before or context.after or context.joker_main) and context.scoring_hand)
            or (context.pre_discard and context.full_hand) or context.hand_drawn
        if type(cards) ~= 'table' then cards = nil end

        local check_ranks = (target or cards)
            and (VANILLA_RANKS[key] or DYNAMIC_RANK_FIELDS[key] or hnds_has_attribute(self, 'rank'))
        if not check_ranks then return calculate_joker_ref(self, context, ...) end

        local args = HNDS.pack(...)
        local function run_original()
            return calculate_joker_ref(self, context, hnds_unpack(args, 1, args.n))
        end

        local function run_with_rank()
            if check_ranks and target and HNDS.card_has_wild_rank(target, context) then
                local rank_id = hnds_rank_for_joker(self, target, key)
                if rank_id then return hnds_call_with_rank(target, rank_id, run_original) end
            end
            if check_ranks and cards then
                local wild_cards = hnds_wild_cards(cards, context)
                if wild_cards[1] then
                    local rank_id = hnds_rank_for_joker(self, wild_cards[1], key)
                    if rank_id then return hnds_call_with_rank_cards(wild_cards, rank_id, run_original) end
                end
            end
            return run_original()
        end

        return run_with_rank()
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

    end,
    attributes = { "passive", "face" }
}
