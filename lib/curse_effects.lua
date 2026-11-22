local unpack_values = table.unpack or unpack

local function refresh_slots()
    local area = G and G.consumeables
    if area and area.handle_card_limit then area:handle_card_limit() end
end

function HNDS.change_consumable_slots(delta)
    local area = G and G.consumeables
    if not (area and area.config) or delta == 0 then return end
    area:change_size(delta)
    refresh_slots()
end

local function slot_bonus()
    local total = 0
    for _, card in ipairs(G and G.jokers and G.jokers.cards or {}) do
        local ability = card.ability
        if ability and card.added_to_deck and not (card.removed or card.REMOVED)
            and not (ability.hnds_eternal_copy_created or ability.hnds_curse_preview)
            and ability.hnds_curse_offer == 'offer_consumable_slots' then
            total = total + (ability.hnds_curse_slots_applied or 0)
        end
    end
    return total
end

local count_property_ref = CardArea.count_property
function CardArea:count_property(property, ...)
    local value = count_property_ref(self, property, ...)
    if self == G.consumeables and property == 'card_limit' then value = value + slot_bonus() end
    return value
end

function HNDS.sync_curse_bonuses(card, context)
    local ability = card and card.ability
    if not (ability and G and G.GAME) or ability.hnds_eternal_copy_created then return end
    local active = card.added_to_deck and not (card.removed or card.REMOVED)
        and not (context and context.remove_from_deck)
    local hands = active and ability.hnds_curse_offer == 'offer_extra_hand' and 1 or 0
    local slots = active and ability.hnds_curse_offer == 'offer_consumable_slots' and 2 or 0
    if G.GAME.round_resets then
        local delta = hands - (ability.hnds_curse_hands_applied or 0)
        G.GAME.round_resets.hands = (G.GAME.round_resets.hands or 0) + delta
        ability.hnds_curse_hands_applied = hands ~= 0 and hands or nil
    end
    if G.consumeables and G.consumeables.config then
        ability.hnds_curse_slots_applied = slots ~= 0 and slots or nil
        refresh_slots()
    end
end

local copy_card_ref = copy_card
function copy_card(...)
    local card = copy_card_ref(...)
    if card and card.ability then
        card.ability.hnds_curse_hands_applied = nil
        card.ability.hnds_curse_slots_applied = nil
    end
    return card
end

local states = setmetatable({}, {__mode = 'k'})
local pending = setmetatable({}, {__mode = 'k'})
local refreshing = false

local function source(card)
    local ability = card and card.ability
    return ability and ability.hnds_curse_price == 'price_debuff_adjacent'
        and not (ability.hnds_eternal_copy_created or ability.hnds_curse_preview
            or card.removed or card.REMOVED or card.getting_sliced or card.destroyed) or false
end

local function recalc(card)
    if not card then return end
    if card.removed or card.REMOVED then pending[card] = nil; return end
    local blind = G.GAME and G.GAME.blind
    if not (blind and type(blind.debuff_card) == 'function') then pending[card] = true; return end
    pending[card] = nil
    SMODS.recalc_debuff(card)
end

function HNDS.refresh_curse_adjacency()
    local area = G and G.jokers
    if refreshing or not (area and area.cards) then return end
    refreshing = true
    local previous_recalc = HNDS._curse_adjacency_recalc
    HNDS._curse_adjacency_recalc = true
    local results = HNDS.pack(pcall(function()
        for card in pairs(pending) do recalc(card) end
        local state = states[area]
        local cards = area.cards
        local changed = not state or state.count ~= #cards
        if not changed then
            for i, card in ipairs(cards) do
                if state.order[i] ~= card or state.sources[i] ~= source(card) then changed = true; break end
            end
        end
        if not changed then return end
        state = state or {order = setmetatable({}, {__mode = 'v'}), sources = {}, count = 0}
        local previous = state.adjacent or setmetatable({}, {__mode = 'k'})
        local adjacent = state.spare or setmetatable({}, {__mode = 'k'})
        for card in pairs(adjacent) do adjacent[card] = nil end
        for i, card in ipairs(cards) do
            state.order[i], state.sources[i] = card, source(card)
            if state.sources[i] then
                if cards[i - 1] then adjacent[cards[i - 1]] = true end
                if cards[i + 1] then adjacent[cards[i + 1]] = true end
            end
        end
        for i = #cards + 1, state.count do state.order[i], state.sources[i] = nil, nil end
        state.count, state.adjacent, state.spare = #cards, adjacent, previous
        states[area] = state
        for card in pairs(previous) do if not adjacent[card] then recalc(card) end end
        for card in pairs(adjacent) do if not previous[card] then recalc(card) end end
    end))
    HNDS._curse_adjacency_recalc = previous_recalc
    refreshing = false
    if not results[1] then error(results[2], 0) end
    refresh_slots()
end

local set_debuff_ref = SMODS.current_mod.set_debuff
SMODS.current_mod.set_debuff = function(card)
    if set_debuff_ref then
        local result = set_debuff_ref(card)
        if result == true or result == 'prevent_debuff' then return result end
    end
    local area = G and G.jokers
    local state = area and states[area]
    if card and card.area == area and state and state.adjacent[card] then return true end
end

for _, method in ipairs({'emplace', 'remove_card', 'align_cards'}) do
    local ref = CardArea[method]
    CardArea[method] = function(self, ...)
        local results = HNDS.pack(ref(self, ...))
        if self == G.jokers then HNDS.refresh_curse_adjacency() end
        return unpack_values(results, 1, results.n)
    end
end

local start_run_ref = Game.start_run
function Game:start_run(...)
    local results = HNDS.pack(start_run_ref(self, ...))
    local game, area = G.GAME, G.consumeables
    if game and area and game.hnds_curse_slot_version ~= 2 then
        local legacy, other, affected = 0, 0, false
        if game.used_vouchers and game.used_vouchers.v_crystal_ball then other = 1 end
        for _, card in ipairs(G.jokers and G.jokers.cards or {}) do
            local ability = card.ability or {}
            if ability.hnds_curse_offer == 'offer_consumable_slots' then
                affected = true
                legacy = legacy + (ability.hnds_curse_slots_applied or 0)
            end
            if card.added_to_deck and not card.debuff and card.config.center.key == 'j_hnds_deep_pockets' then
                other = other + (ability.extra and ability.extra.slots or 0)
            end
        end
        local limits = area.config.card_limits
        if affected and limits then limits.mod = math.max(other, (limits.mod or 0) - legacy) end
        game.hnds_curse_slot_version = 2
        refresh_slots()
    end
    return unpack_values(results, 1, results.n)
end
