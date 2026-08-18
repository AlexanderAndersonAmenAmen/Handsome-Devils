HNDS = HNDS or {}

local JOL_RANK_KEY = 'hnds_jack_of_lanterns'
local JOL_SUIT_KEY = 'hnds_lanterns'
local JOL_OWNER_FIELD = 'hnds_jack_of_lanterns_owner'

local function hnds_jol_owner(card)
    return card and card.ability and card.ability[JOL_OWNER_FIELD] or nil
end

function HNDS.is_jack_of_lanterns(card)
    return hnds_jol_owner(card) ~= nil
end

local function hnds_card_identity(card)
    if not card then return nil end
    return tostring(card.playing_card or card.sort_id or card.ID or card)
end

function HNDS.is_jevil_wild(card)
    if not card then return false end
    if card.ability and card.ability.hnds_jevil_wild then return true end
    if not (G and G.GAME) then return false end
    local id = hnds_card_identity(card)
    if not id then return false end
    if type(G.GAME.hnds_jevil_round_cards) == 'table' and G.GAME.hnds_jevil_round_cards[id] then
        return true
    end
    -- Save compatibility with the older per-owner representation.
    if type(G.GAME.hnds_jevil_wild_cards) == 'table' then
        for _, marked in pairs(G.GAME.hnds_jevil_wild_cards) do
            if type(marked) == 'table' and marked[id] then return true end
        end
    end
    return false
end

local function hnds_no_suit(card)
    return SMODS and SMODS.has_no_suit and SMODS.has_no_suit(card) or false
end

local function hnds_no_rank(card)
    return SMODS and SMODS.has_no_rank and SMODS.has_no_rank(card) or false
end

-- Jack of Lanterns is a true custom Rank + a private custom Suit rather
-- than an Enhancement, so it can still be enhanced normally. The visible
-- card name is therefore naturally "Jack of Lanterns": rank "Jack" +
-- orange suit "Lanterns". Both objects are excluded from normal pools.
-- The Jack of Lanterns playing card uses its dedicated JackOfLanterns atlas.
-- That atlas is a single-rank strip; x=0/y=0 is the Lanterns face used by this
-- private rank+suit combination.
if SMODS and SMODS.Suit and SMODS.Suits and not SMODS.Suits[JOL_SUIT_KEY] then
    SMODS.Suit {
        key = 'lanterns',
        card_key = 'L',
        pos = { y = 0 },
        ui_pos = { x = 0, y = 0 },
        lc_atlas = 'JackOfLanterns',
        hc_atlas = 'JackOfLanterns',
        lc_colour = (G.C and G.C.ORANGE) or HEX('F5A623'),
        hc_colour = (G.C and G.C.ORANGE) or HEX('F5A623'),
        in_pool = function(self, args) return false end,
    }
end

if SMODS and SMODS.Rank and SMODS.Ranks and not SMODS.Ranks[JOL_RANK_KEY] then
    SMODS.Rank {
        key = 'jack_of_lanterns',
        card_key = 'JOL',
        pos = { x = 0 },
        nominal = 50,
        shorthand = 'J',
        face = true,
        -- Treat the custom Jack rank like a normal Jack for Strength: the next
        -- rank is Queen. Once changed, vanilla ranks take over the normal
        -- Queen -> King -> Ace progression while the owner marker keeps this
        -- physical card tied to Headless Joker.
        next = { 'Queen' },
        strength_effect = { fixed = 1 },
        lc_atlas = 'JackOfLanterns',
        hc_atlas = 'JackOfLanterns',
        suit_map = { [JOL_SUIT_KEY] = 0 },
        in_pool = function(self, args) return false end,
        loc_vars = function(self, info_queue, card)
            info_queue[#info_queue + 1] = { set = 'Other', key = 'hnds_jack_of_lanterns' }
        end,
    }
end

-- Both Jevil's marked starting-hand cards and Jack of Lanterns count as Wild
-- for suit checks. Stone/no-suit effects remain dominant.
if Card and Card.is_suit and not HNDS._special_any_suit_card_hook then
    local is_suit_ref = Card.is_suit
    function Card:is_suit(suit, ...)
        if (HNDS.is_jack_of_lanterns(self) or HNDS.is_jevil_wild(self)) and not hnds_no_suit(self) then
            return true
        end
        return is_suit_ref(self, suit, ...)
    end
    HNDS._special_any_suit_card_hook = true
end

if SMODS and SMODS.has_any_suit and not HNDS._special_any_suit_smods_hook then
    local has_any_suit_ref = SMODS.has_any_suit
    function SMODS.has_any_suit(card, ...)
        if (HNDS.is_jack_of_lanterns(card) or HNDS.is_jevil_wild(card)) and not hnds_no_suit(card) then
            return true
        end
        return has_any_suit_ref(card, ...)
    end
    HNDS._special_any_suit_smods_hook = true
end

-- Preserve Jack-of-Lantern identity through Enhancement changes. Playing-card
-- set_ability normally rebuilds ability, so a custom field would otherwise be
-- lost when the user applies Gold/Steel/Stone/etc.
if Card and Card.set_ability and not HNDS._jol_set_ability_hook then
    local set_ability_ref = Card.set_ability
    function Card:set_ability(...)
        local owner = hnds_jol_owner(self)
        local results = { set_ability_ref(self, ...) }
        if owner and self.ability then self.ability[JOL_OWNER_FIELD] = owner end
        return unpack(results)
    end
    HNDS._jol_set_ability_hook = true
end

-- Death/Cryptid/other copy effects should produce real copies of the head. If a
-- Jack of Lanterns is overwritten by a non-head source, its identity is cleared.
if type(copy_card) == 'function' and not HNDS._jol_copy_card_hook then
    local copy_card_ref = copy_card
    function copy_card(source, ...)
        local copied = copy_card_ref(source, ...)
        if copied and copied.ability then
            copied.ability[JOL_OWNER_FIELD] = hnds_jol_owner(source)
        end
        return copied
    end
    HNDS._jol_copy_card_hook = true
end

function HNDS.add_jack_of_lanterns(source_joker, owner)
    if source_joker and (source_joker.removed or not source_joker.config
        or not source_joker.config.center or source_joker.config.center.key ~= 'j_hnds_headless_joker')
    then
        return nil
    end
    if not (G and G.deck and G.playing_cards and SMODS and SMODS.create_card) then return nil end
    local new_card = SMODS.create_card({
        set = 'Base',
        area = G.deck,
        rank = JOL_RANK_KEY,
        suit = JOL_SUIT_KEY,
        key_append = 'hnds_headless',
        skip_materialize = true,
    })
    if not new_card then return nil end

    new_card.ability = new_card.ability or {}
    new_card.ability[JOL_OWNER_FIELD] = owner
    G.playing_card = (tonumber(G.playing_card) or 0) + 1
    new_card.playing_card = G.playing_card
    if new_card.add_to_deck then new_card:add_to_deck() end
    G.deck.config.card_limit = (G.deck.config.card_limit or #G.deck.cards) + 1
    table.insert(G.playing_cards, new_card)
    G.deck:emplace(new_card)
    if new_card.start_materialize then new_card:start_materialize() end
    if playing_card_joker_effects then playing_card_joker_effects({ new_card }) end
    if source_joker and source_joker.juice_up then source_joker:juice_up(0.4, 0.4) end
    return new_card
end

function HNDS.remove_jack_of_lanterns(owner)
    if not (owner and G and G.playing_cards) then return end
    local targets = {}
    for _, playing_card in ipairs(G.playing_cards) do
        if hnds_jol_owner(playing_card) == owner then
            targets[#targets + 1] = playing_card
        end
    end
    if #targets == 0 then return end

    if SMODS and SMODS.destroy_cards then
        SMODS.destroy_cards(targets)
    else
        for _, playing_card in ipairs(targets) do
            if playing_card.start_dissolve then playing_card:start_dissolve() end
        end
    end
end

-- Deck preview helpers -------------------------------------------------------
-- Steamodded beta-1620a paginates visible suits four at a time. The Lovely
-- patch calls this helper only to pin Lanterns into position 5, making it the
-- first suit on page 2 while preserving normal 4-row pages.
function HNDS.prepare_jol_deck_preview(visible_suit)
    if type(visible_suit) ~= 'table' then return 4 end

    local lanterns_index = nil
    for i, suit_key in ipairs(visible_suit) do
        if suit_key == JOL_SUIT_KEY then
            lanterns_index = i
            break
        end
    end
    if not lanterns_index then return 4 end

    table.remove(visible_suit, lanterns_index)
    table.insert(visible_suit, math.min(5, #visible_suit + 1), JOL_SUIT_KEY)
    return 4
end

function HNDS.hide_jol_suit_tally(hidden_suits)
    if type(hidden_suits) == 'table' then
        hidden_suits[JOL_SUIT_KEY] = true
    end
end

-- Deck-preview only: an untouched Jack of Lanterns contributes to the vanilla
-- Jack (J) tally rather than rendering a separate custom-rank count. Strength-
-- changed Lanterns cards contribute to their real Queen/King/Ace rank instead.
function HNDS.jol_preview_rank_key(card)
    if card and HNDS.is_jack_of_lanterns(card)
        and card.base and card.base.value == JOL_RANK_KEY
    then
        return 'Jack'
    end
    return card and card.base and card.base.value or nil
end

-- Rank wildcard support -------------------------------------------------------
-- Suit wildness is handled by Card:is_suit above. For rank-based poker hands,
-- evaluate the hand across all *distinct* rank assignments of Jack of Lanterns
-- and keep the strongest coherent assignment. Hands contain at most five cards;
-- using nondecreasing assignments means even five copied heads require only
-- C(17,5)=6188 evaluations instead of 13^5 permutations.
if type(evaluate_poker_hand) == 'function' and not HNDS._jol_poker_eval_hook then
    local evaluate_poker_hand_ref = evaluate_poker_hand
    local fallback_order = {
        'Flush Five', 'Flush House', 'Five of a Kind', 'Straight Flush',
        'Four of a Kind', 'Full House', 'Flush', 'Straight',
        'Three of a Kind', 'Two Pair', 'Pair', 'High Card',
    }

    local function result_priority(result)
        local order = (G and G.handlist) or fallback_order
        for i, name in ipairs(order) do
            local bucket = result and result[name]
            if type(bucket) == 'table' and next(bucket) then return i end
        end
        return math.huge
    end

    local function enumerate_assignments(count, callback)
        local values = {}
        local function rec(depth, minimum)
            if depth > count then
                callback(values)
                return
            end
            for rank = minimum, 14 do
                values[depth] = rank
                rec(depth + 1, rank)
            end
        end
        rec(1, 2)
    end

    local last_signature, last_result

    local function hand_signature(hand)
        local parts = {}
        for i, c in ipairs(hand or {}) do
            local owner = hnds_jol_owner(c) or ''
            local id = c and (c.playing_card or c.sort_id or c.ID) or i
            local base = c and c.base or {}
            parts[#parts + 1] = table.concat({ tostring(id), tostring(owner), tostring(base.id), tostring(base.suit), tostring(c and c.config and c.config.center_key) }, ':')
        end
        return table.concat(parts, '|')
    end

    function evaluate_poker_hand(hand, ...)
        local eval_args = { ... }
        local wilds = {}
        for _, playing_card in ipairs(hand or {}) do
            if HNDS.is_jack_of_lanterns(playing_card) and not hnds_no_rank(playing_card) then
                wilds[#wilds + 1] = playing_card
            end
        end
        if #wilds == 0 then return evaluate_poker_hand_ref(hand, unpack(eval_args)) end

        local signature = hand_signature(hand)
        if signature == last_signature and last_result then return last_result end

        local best, best_priority
        local original_get_id = {}
        for i, playing_card in ipairs(wilds) do original_get_id[i] = rawget(playing_card, 'get_id') end

        local function restore()
            for i, playing_card in ipairs(wilds) do playing_card.get_id = original_get_id[i] end
        end

        local ok, err = pcall(function()
            enumerate_assignments(#wilds, function(values)
                for i, playing_card in ipairs(wilds) do
                    local assigned = values[i]
                    playing_card.get_id = function() return assigned end
                end
                local candidate = evaluate_poker_hand_ref(hand, unpack(eval_args))
                local priority = result_priority(candidate)
                if not best or priority < best_priority then
                    best, best_priority = candidate, priority
                end
            end)
        end)
        restore()
        if not ok then error(err) end
        best = best or evaluate_poker_hand_ref(hand, unpack(eval_args))
        last_signature, last_result = signature, best
        return best
    end
    HNDS._jol_poker_eval_hook = true
end
