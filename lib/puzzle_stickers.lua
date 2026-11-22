local unpack_values = table.unpack or unpack
local stripping = setmetatable({}, {__mode = 'k'})
local sticker_keys, sticker_count

local function is_piece(card)
    return card and (card.hnds_sarmenti_component_guard or HNDS.is_sarmenti_piece(card))
end

local function keys()
    local buffer = SMODS.Sticker.obj_buffer or {}
    if not sticker_keys or sticker_count ~= #buffer then
        sticker_count = #buffer
        sticker_keys = {perishable = true, eternal = true, rental = true}
        for _, key in ipairs(buffer) do sticker_keys[key] = true end
        for key in pairs(SMODS.Stickers or {}) do sticker_keys[key] = true end
    end
    return sticker_keys
end

local function dirty(ability, card)
    if not ability then return false end
    if ability.hnds_curse_offer or ability.hnds_curse_price or ability.hnds_cursed then return true end
    if next(ability.stickers or {}) or (card and (next(card.stickers or {}) or card.pinned)) then return true end
    for key in pairs(keys()) do if ability[key] then return true end end
    return false
end

local function clear_current(card)
    local ability = card.ability
    if not dirty(ability, card) then return false end
    if HNDS.sync_curse_bonuses then HNDS.sync_curse_bonuses(card, {remove_from_deck = true}) end
    local remove = {}
    for key in pairs(keys()) do remove[key] = true end
    for key in pairs(card.stickers or {}) do remove[key] = true end
    for key in pairs(ability.stickers or {}) do remove[key] = true end
    for key in pairs(remove) do
        if ability[key] or (card.stickers and card.stickers[key]) or (ability.stickers and ability.stickers[key]) then
            if card.remove_sticker then pcall(card.remove_sticker, card, key) end
        end
        ability[key] = nil
    end
    card.stickers, ability.stickers = nil, nil
    card.pinned, ability.perish_tally = nil, nil
    for key in pairs(ability) do
        if type(key) == 'string' and key:match('^hnds_curse') then ability[key] = nil end
    end
    card.cursed_shake, card.hnds_curse_acquire_triggered, card.hnds_cursed_cost_current = nil, nil, nil
    return true
end

function HNDS.sarmenti_clear_piece_stickers(card)
    if not is_piece(card) or stripping[card] then return false end
    local needs_clear = dirty(card.ability, card)
    local puzzle = card.ability and card.ability.hnds_sarmenti_puzzle
    if not needs_clear then
        for _, snap in ipairs(puzzle and puzzle.components or {}) do
            if dirty(snap.ability) then needs_clear = true; break end
        end
    end
    if not needs_clear then return false end
    stripping[card] = true
    local results = HNDS.pack(pcall(function()
        local changed = clear_current(card)
        local puzzle = card.ability and card.ability.hnds_sarmenti_puzzle
        for _, snap in ipairs(puzzle and puzzle.components or {}) do
            if dirty(snap.ability) then
                HNDS.sarmenti_with_component(card, snap, function() clear_current(card) end)
                changed = true
            end
        end
        if changed then
            if card.set_sticker_display then card:set_sticker_display() end
            if card.set_cost then card:set_cost() end
            if HNDS.refresh_curse_adjacency then HNDS.refresh_curse_adjacency() end
        end
        return changed
    end))
    stripping[card] = nil
    if not results[1] then error(results[2], 0) end
    return unpack_values(results, 2, results.n)
end

local add_ref = Card.add_sticker
function Card:add_sticker(key, ...)
    if is_piece(self) then HNDS.sarmenti_clear_piece_stickers(self); return end
    return add_ref(self, key, ...)
end

for _, method in ipairs({'set_eternal', 'set_perishable', 'set_rental'}) do
    local ref = Card[method]
    Card[method] = function(self, ...)
        if is_piece(self) and not stripping[self] then HNDS.sarmenti_clear_piece_stickers(self); return end
        return ref(self, ...)
    end
end

local function guard_sticker(sticker)
    if sticker.hnds_puzzle_sticker_guard then return end
    sticker.hnds_puzzle_sticker_guard = true
    local apply_ref, should_ref = sticker.apply, sticker.should_apply
    if type(apply_ref) == 'function' then
        sticker.apply = function(self, card, value, ...)
            if value and is_piece(card) then HNDS.sarmenti_clear_piece_stickers(card); return end
            return apply_ref(self, card, value, ...)
        end
    end
    if type(should_ref) == 'function' then
        sticker.should_apply = function(self, card, ...)
            if is_piece(card) then return false end
            return should_ref(self, card, ...)
        end
    end
end

for _, sticker in pairs(SMODS.Stickers or {}) do guard_sticker(sticker) end
local inject_ref = SMODS.Sticker.inject
function SMODS.Sticker:inject(...)
    local results = HNDS.pack(inject_ref(self, ...))
    guard_sticker(self)
    sticker_keys = nil
    return unpack_values(results, 1, results.n)
end

local load_ref, update_ref, copy_ref = Card.load, Card.update, copy_card
function Card:load(...)
    local results = HNDS.pack(load_ref(self, ...))
    HNDS.sarmenti_clear_piece_stickers(self)
    return unpack_values(results, 1, results.n)
end
function Card:update(...)
    HNDS.sarmenti_clear_piece_stickers(self)
    return update_ref(self, ...)
end
function copy_card(...)
    local card = copy_ref(...)
    HNDS.sarmenti_clear_piece_stickers(card)
    return card
end
