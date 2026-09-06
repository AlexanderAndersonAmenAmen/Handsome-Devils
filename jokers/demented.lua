HNDS = HNDS or {}

local function demented_center_key(card)
    return card and card.config and card.config.center and card.config.center.key
end

function HNDS.demented_chaos_active()
    for _, joker in ipairs((G and G.jokers and G.jokers.cards) or {}) do
        if joker and not joker.REMOVED and not joker.removed and not joker.debuff
            and demented_center_key(joker) == 'j_hnds_demented'
        then
            return true
        end
    end
    return false
end

local function demented_scored_flush_cards(context)
    local flushes = context and context.poker_hands and context.poker_hands.Flush
    if not (type(flushes) == 'table' and type(flushes[1]) == 'table' and #flushes[1] > 0) then
        return
    end
    if type(context.scoring_hand) == 'table' and #context.scoring_hand > 0 then
        return context.scoring_hand
    end
    return flushes[1]
end

local function demented_printed_suit(cards)
    local counts, order = {}, {}
    for _, playing_card in ipairs(cards or {}) do
        local suit = playing_card and playing_card.base and playing_card.base.suit
        if suit then
            if counts[suit] == nil then order[#order + 1] = suit end
            counts[suit] = (counts[suit] or 0) + 1
        end
    end
    local best, best_count
    for _, suit in ipairs(order) do
        if not best or counts[suit] > best_count then
            best, best_count = suit, counts[suit]
        end
    end
    return best
end

local function demented_target_suit(source, card)
    local suits = HNDS.get_pollable_suit_keys
        and HNDS.get_pollable_suit_keys('hnds_demented_swap', source)
        or {}
    if #suits == 0 then
        for _, suit in ipairs({ 'Spades', 'Hearts', 'Diamonds', 'Clubs' }) do
            if suit ~= source then suits[#suits + 1] = suit end
        end
    end
    if #suits == 0 then return nil end
    local round = G and G.GAME and G.GAME.current_round
    local seed = table.concat({
        'hnds_demented_swap',
        tostring(card and (card.sort_id or card.ID) or 0),
        tostring(round and round.round or 0),
        tostring(round and round.hands_played or 0),
    }, '_')
    if pseudorandom_element and pseudoseed then
        return pseudorandom_element(suits, pseudoseed(seed))
    end
    return suits[math.random(#suits)]
end

SMODS.Joker {
    key = 'demented',
    rarity = 3,
    cost = 5,
    blueprint_compat = false,
    atlas = 'Jokers',
    pos = { x = 6, y = 3 },
    unlocked = false,
    discovered = false,
    unlock_condition = { type = 'hnds_joker_unlock', key = 'demented' },
    locked_loc_vars = function(self)
        return HNDS.joker_locked_loc_vars('demented')
    end,
    check_for_unlock = function(self, args)
        return HNDS.joker_unlock_condition_met('demented', args)
    end,
    calculate = function(self, card, context)
        if not (context.before and context.cardarea == G.jokers and not context.blueprint) then
            return
        end

        local flush_cards = demented_scored_flush_cards(context)
        if not flush_cards then return end
        local source = demented_printed_suit(flush_cards)
        local target = demented_target_suit(source, card)
        if not target or target == source then return end

        for _, playing_card in ipairs(flush_cards) do
            if playing_card and SMODS and type(SMODS.change_base) == 'function' then
                SMODS.change_base(playing_card, target, nil)
                if playing_card.juice_up then playing_card:juice_up(0.3, 0.25) end
            end
        end
        if HNDS.refresh_abstract_area then
            if G.hand then HNDS.refresh_abstract_area(G.hand) end
            if G.play then HNDS.refresh_abstract_area(G.play) end
        end
        return { message = 'Swapped!', colour = G.C.SUITS and G.C.SUITS[target] or G.C.FILTER }
    end,
    attributes = { 'suit', 'modify_card' },
}
