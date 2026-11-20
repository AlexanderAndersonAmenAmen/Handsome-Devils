HNDS = HNDS or {}

local KRUSTY_SUITS = {
    'hnds_smiles',
    'hnds_bananas',
    'hnds_dices',
    'hnds_rubies',
    'hnds_flowers',
    'hnds_petals',
    'hnds_free_parking_spots',
    'hnds_wraiths',
    'hnds_beans',
}
local KRUSTY_DEFAULT_SUIT = 'hnds_bananas'
local KRUSTY_SUIT_SET = {}
for _, suit in ipairs(KRUSTY_SUITS) do KRUSTY_SUIT_SET[suit] = true end

local function krusty_center_key(card)
    return card and card.config and card.config.center and card.config.center.key
end

function HNDS.krusty_chaos_active()
    for _, joker in ipairs((G and G.jokers and G.jokers.cards) or {}) do
        if joker and not joker.REMOVED and not joker.removed and not joker.debuff
            and krusty_center_key(joker) == 'j_hnds_krusty'
        then
            return true
        end
    end
    return false
end

local function krusty_scored_flush_cards(context)
    local flushes = context and context.poker_hands and context.poker_hands.Flush
    if not (type(flushes) == 'table' and type(flushes[1]) == 'table' and #flushes[1] > 0) then
        return
    end
    if type(context.scoring_hand) == 'table' and #context.scoring_hand > 0 then
        return context.scoring_hand
    end
    return flushes[1]
end

local function krusty_extra(card)
    if not card then return nil end
    card.ability = card.ability or {}
    if type(card.ability.extra) ~= 'table' then card.ability.extra = {} end
    return card.ability.extra
end

local function krusty_current_suit(card)
    local extra = card and card.ability and card.ability.extra
    return KRUSTY_SUIT_SET[type(extra) == 'table' and extra.suit or false]
        and extra.suit or KRUSTY_DEFAULT_SUIT
end

local function krusty_clear_tooltip(card)
    if not card then return end
    card.ability_UIBox_table = nil
    if card.config then
        card.config.h_popup = nil
        card.config.h_popup_config = nil
    end
end

local function krusty_roll_suit(card)
    local extra = krusty_extra(card)
    if not extra then return KRUSTY_DEFAULT_SUIT end
    local current = KRUSTY_SUIT_SET[extra.suit] and extra.suit or nil
    local suits = {}
    for _, suit in ipairs(KRUSTY_SUITS) do
        if suit ~= current then suits[#suits + 1] = suit end
    end

    local round = G and G.GAME and G.GAME.current_round
    local roll = math.max(0, tonumber(extra.suit_roll) or 0) + 1
    extra.suit_roll = roll
    local seed = table.concat({
        'hnds_krusty_suit',
        tostring(card and (card.sort_id or card.ID) or 0),
        tostring(G and G.GAME and G.GAME.round_resets and G.GAME.round_resets.ante or 0),
        tostring(round and round.round or 0),
        tostring(round and round.hands_played or 0),
        tostring(roll),
    }, '_')
    if pseudorandom_element and pseudoseed then
        extra.suit = pseudorandom_element(suits, pseudoseed(seed))
    else
        extra.suit = suits[math.random(#suits)]
    end
    extra.suit = extra.suit or KRUSTY_DEFAULT_SUIT
    krusty_clear_tooltip(card)
    return extra.suit
end

SMODS.Joker {
    key = 'krusty',
    unlocked = false,
    unlock_condition = { type = '', extra = '', hidden = true },
    locked_loc_vars = function(self, info_queue, card)
        return { key = 'joker_locked_legendary', set = 'Other', vars = {} }
    end,
    discovered = false,
    blueprint_compat = false,
    eternal_compat = false,
    rarity = 4,
    cost = 20,
    atlas = 'Jokers',
    pos = { x = 7, y = 2 },
    soul_pos = { x = 2, y = 3 },
    config = { extra = { suit = false, suit_roll = 0 } },
    loc_vars = function(self, info_queue, card)
        local suit = krusty_current_suit(card)
        if card and card.area and card.area.config and card.area.config.collection then
            local choices = {}
            for _, key in ipairs(KRUSTY_SUITS) do
                if key ~= card.hnds_krusty_collection_suit then choices[#choices + 1] = key end
            end
            suit = choices[math.random(#choices)]
            card.hnds_krusty_collection_suit = suit
        end
        local suit_center = SMODS and SMODS.Suits and SMODS.Suits[suit]
        if info_queue and suit_center and type(suit_center.loc_vars) == 'function' then
            suit_center:loc_vars(info_queue, card)
        end
        local suit_name = localize and localize(suit, 'suits_plural') or suit
        local suit_colour = G and G.C and G.C.SUITS and G.C.SUITS[suit]
            or (G and G.C and G.C.FILTER)
        return { vars = { suit_name, colours = { suit_colour } } }
    end,
    add_to_deck = function(self, card, from_debuff)
        local extra = krusty_extra(card)
        if extra and not KRUSTY_SUIT_SET[extra.suit] then krusty_roll_suit(card) end
    end,
    load = function(self, card, card_table, other_card)
        local extra = krusty_extra(card)
        if extra and not KRUSTY_SUIT_SET[extra.suit] then
            extra.suit = KRUSTY_DEFAULT_SUIT
        end
        krusty_clear_tooltip(card)
    end,
    calculate = function(self, card, context)
        if context.end_of_round and context.main_eval and not context.blueprint
            and not context.individual and not context.repetition
        then
            krusty_roll_suit(card)
            return
        end

        if not (context.before and context.cardarea == G.jokers and not context.blueprint) then return end

        local flush_cards = krusty_scored_flush_cards(context)
        if not flush_cards then return end
        local target = krusty_current_suit(card)
        if not KRUSTY_SUIT_SET[target] then target = krusty_roll_suit(card) end

        for _, playing_card in ipairs(flush_cards) do
            if playing_card and SMODS and type(SMODS.change_base) == 'function' then
                SMODS.change_base(playing_card, target, nil)
            end
        end
        if HNDS.refresh_abstract_area then
            if G.hand then HNDS.refresh_abstract_area(G.hand) end
            if G.play then HNDS.refresh_abstract_area(G.play) end
        end
        return {
            message = localize('k_hnds_converted'),
            colour = G.C.SUITS and G.C.SUITS[target] or G.C.FILTER,
            no_juice = true,
        }
    end,
    attributes = { 'suit', 'modify_card' },
}
