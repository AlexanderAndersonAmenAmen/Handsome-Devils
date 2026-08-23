-- Joker Reverse
-- Adjacent physical Joker cards are paired with a unique non-Legendary
-- counterpart. Joker TYPE pairings live in G.GAME for the whole run, so once
-- Devious Joker <-> Campfire is assigned, every future copy of either Joker
-- uses that same counterpart. Per-card state still lives on the physical card.

local PAIR_FIELD = 'hnds_joker_reverse_pair'

local function deep_copy(value, seen)
    if type(value) ~= 'table' then return value end
    seen = seen or {}
    if seen[value] then return seen[value] end

    local out = {}
    seen[value] = out
    for k, v in pairs(value) do
        out[deep_copy(k, seen)] = deep_copy(v, seen)
    end
    return out
end

local function snapshot_ability(card)
    local out = {}
    for k, v in pairs((card and card.ability) or {}) do
        if k ~= PAIR_FIELD then
            out[deep_copy(k)] = deep_copy(v)
        end
    end
    return out
end

local function edition_key(card)
    local edition = card and card.edition
    if type(edition) ~= 'table' then return nil end
    if type(edition.key) == 'string' then return edition.key end
    if type(edition.type) == 'string' and edition.type ~= '' then
        return edition.type:sub(1, 2) == 'e_' and edition.type or ('e_' .. edition.type)
    end
    for key, value in pairs(edition) do
        if value == true and type(key) == 'string' then
            return key:sub(1, 2) == 'e_' and key or ('e_' .. key)
        end
    end
    return nil
end

local function normalize_rarity(rarity)
    if type(rarity) == 'table' then
        rarity = rarity.key or rarity.id or rarity.name
    end
    if type(rarity) == 'number' then return rarity end
    if type(rarity) ~= 'string' then return rarity end

    local value = string.lower(rarity)
    if value == 'common' then return 1 end
    if value == 'uncommon' then return 2 end
    if value == 'rare' then return 3 end
    if value == 'legendary' then return 4 end
    return value
end

local function is_legendary(center)
    return center and normalize_rarity(center.rarity) == 4 or false
end

local function current_center_key(card)
    return card and card.config and card.config.center and card.config.center.key or nil
end

local function counterpart_registry()
    if not (G and G.GAME) then return nil end
    if type(G.GAME.hnds_joker_reverse_counterparts) ~= 'table' then
        G.GAME.hnds_joker_reverse_counterparts = {}
    end
    return G.GAME.hnds_joker_reverse_counterparts
end

local function register_counterpart_pair(key_a, key_b)
    if not (key_a and key_b and key_a ~= key_b) then return false end
    local registry = counterpart_registry()
    if not registry then return false end

    -- Pairings are one-to-one for the entire run. Never silently overwrite an
    -- existing relationship, because that would make old pairs stop reversing.
    if registry[key_a] and registry[key_a] ~= key_b then return false end
    if registry[key_b] and registry[key_b] ~= key_a then return false end

    registry[key_a] = key_b
    registry[key_b] = key_a
    return true
end

local function registered_counterpart(key)
    local registry = counterpart_registry()
    return registry and key and registry[key] or nil
end

local function collect_excluded_keys()
    local excluded = {}

    -- Every Joker type already used in a run-wide pairing is reserved. This
    -- keeps counterpart relationships one-to-one even after either card is sold.
    local registry = counterpart_registry()
    if registry then
        for key, counterpart in pairs(registry) do
            if key then excluded[key] = true end
            if counterpart then excluded[counterpart] = true end
        end
    end

    -- A newly-created pairing also cannot choose a Joker currently owned.
    for _, joker in ipairs((G and G.jokers and G.jokers.cards) or {}) do
        local key = current_center_key(joker)
        if key then excluded[key] = true end

        local pair = joker.ability and joker.ability[PAIR_FIELD]
        if type(pair) == 'table' then
            if pair.a and pair.a.key then excluded[pair.a.key] = true end
            if pair.b and pair.b.key then excluded[pair.b.key] = true end
        end
    end
    return excluded
end

local function center_available_for_counterpart(center)
    if not center or center.unlocked == false or center.hidden then return false end

    local pool_flags = G and G.GAME and G.GAME.pool_flags or {}
    if center.no_pool_flag and pool_flags[center.no_pool_flag] then return false end
    if center.yes_pool_flag and not pool_flags[center.yes_pool_flag] then return false end

    -- Preserve custom Steamodded in_pool restrictions even though rarity pools
    -- are read directly. A nil return is treated as "no extra restriction";
    -- an explicit false removes the Joker from this counterpart pool.
    if type(center.in_pool) == 'function' then
        local ok, allowed = pcall(center.in_pool, center, { source = 'hnds_joker_reverse' })
        if ok and allowed == false then return false end
    end

    return true
end

local function valid_counterpart(center, excluded, source_rarity)
    return center
        and center.set == 'Joker'
        and center.key
        and center.key ~= 'UNAVAILABLE'
        and center_available_for_counterpart(center)
        and not is_legendary(center)
        and normalize_rarity(center.rarity) ~= source_rarity
        and not excluded[center.key]
end

local RARITY_TRANSITION_WEIGHTS = {
    -- Joker Reverse uses its own explicit rarity odds. The source rarity is
    -- NEVER eligible, and Legendary is NEVER eligible.
    [1] = { [2] = 80, [3] = 20 }, -- Common   -> 80% Uncommon / 20% Rare
    [2] = { [1] = 60, [3] = 40 }, -- Uncommon -> 60% Common   / 40% Rare
    [3] = { [2] = 80, [1] = 20 }, -- Rare     -> 80% Uncommon / 20% Common
}

local function add_candidate(pool, seen, center, excluded, source_rarity)
    if valid_counterpart(center, excluded, source_rarity) and not seen[center.key] then
        seen[center.key] = true
        pool[#pool + 1] = center
    end
end

local function clean_pool_for_rarity(rarity, excluded, source_rarity)
    local pool, seen = {}, {}

    -- IMPORTANT: read the dedicated rarity pools directly. In some Steamodded
    -- builds, calling get_current_pool('Joker', <numeric rarity>, ...) can yield
    -- an empty pool for one tier, which made Joker Reverse appear to roll only
    -- the other tier (most visibly Common -> Rare). G.P_JOKER_RARITY_POOLS is
    -- already partitioned by Joker rarity, so it cannot collapse the 80/20 or
    -- 60/40 choice this way.
    local rarity_pool = G and G.P_JOKER_RARITY_POOLS and G.P_JOKER_RARITY_POOLS[rarity]
    if type(rarity_pool) == 'table' then
        for _, entry in ipairs(rarity_pool) do
            local center = type(entry) == 'table' and entry
                or (G and G.P_CENTERS and G.P_CENTERS[entry])
            add_candidate(pool, seen, center, excluded, source_rarity)
        end
    end

    -- Compatibility fallback for unusual mod setups that do not populate
    -- G.P_JOKER_RARITY_POOLS. Scan the registered Joker pool and filter by the
    -- center's actual rarity instead of relying on get_current_pool's rarity arg.
    if #pool == 0 then
        for _, center in ipairs((G and G.P_CENTER_POOLS and G.P_CENTER_POOLS.Joker) or {}) do
            if normalize_rarity(center and center.rarity) == rarity
                and center.unlocked ~= false
                and not center.hidden
            then
                add_candidate(pool, seen, center, excluded, source_rarity)
            end
        end
    end

    table.sort(pool, function(a, b) return tostring(a.key) < tostring(b.key) end)
    return pool
end

local function rarity_weights_for_source(source_rarity)
    local configured = RARITY_TRANSITION_WEIGHTS[source_rarity]
    if configured then return configured end

    -- Safety for a modded/custom source rarity: still only choose vanilla
    -- non-Legendary counterpart rarities. (The normal Common/Uncommon/Rare
    -- cases above are the intended Joker Reverse behaviour.)
    return { [1] = 70, [2] = 25, [3] = 5 }
end

local function counterpart_pool(seed, source_rarity)
    local excluded = collect_excluded_keys()
    local pools = {}
    local weights = rarity_weights_for_source(source_rarity)
    local total_weight = 0

    -- Build both permitted rarity pools first. Only a genuinely empty eligible
    -- tier loses its weight; otherwise the exact configured odds are preserved.
    for rarity = 1, 3 do
        local weight = rarity ~= source_rarity and (weights[rarity] or 0) or 0
        if weight > 0 then
            local pool = clean_pool_for_rarity(rarity, excluded, source_rarity)
            if #pool > 0 then
                pools[rarity] = pool
                total_weight = total_weight + weight
            end
        end
    end

    if total_weight <= 0 then return {} end

    local roll = pseudorandom(seed .. '_rarity') * total_weight
    local cumulative = 0
    local chosen_rarity
    for rarity = 1, 3 do
        if pools[rarity] then
            cumulative = cumulative + (weights[rarity] or 0)
            if roll < cumulative then
                chosen_rarity = rarity
                break
            end
        end
    end

    -- Floating-point guard. This does not change normal probabilities.
    if not chosen_rarity then
        for rarity = 3, 1, -1 do
            if pools[rarity] then
                chosen_rarity = rarity
                break
            end
        end
    end

    return chosen_rarity and pools[chosen_rarity] or {}
end

local function next_pair_serial()
    if not (G and G.GAME) then return 1 end
    G.GAME.hnds_joker_reverse_serial = (tonumber(G.GAME.hnds_joker_reverse_serial) or 0) + 1
    return G.GAME.hnds_joker_reverse_serial
end

local function choose_counterpart(serial, source_center)
    local seed = 'hnds_joker_reverse_counterpart_' .. tostring(serial)
    local source_rarity = normalize_rarity(source_center and source_center.rarity)
    local pool = counterpart_pool(seed, source_rarity)
    if #pool == 0 then return nil end
    return pseudorandom_element(pool, pseudoseed(seed))
end

local DEFAULT_EDITION_WEIGHTS = {
    e_foil = 20,
    e_holo = 14,
    e_hnds_vintage = 7,
    e_polychrome = 3,
    e_negative = 3,
}

local function edition_candidates_except(current_key)
    local candidates, seen = {}, {}

    local function add(center)
        local key = center and center.key
        if not key or seen[key] or key == current_key then return end
        -- Steamodded can expose a base/no-edition center in Edition pools. It is
        -- not a real visual Edition and must never be a Joker Reverse result.
        if key == 'e_base' or key == 'e_none' or key == 'e_no_edition' then return end
        if center.set and center.set ~= 'Edition' then return end

        local weight = tonumber(center.weight) or DEFAULT_EDITION_WEIGHTS[key] or 1
        if weight <= 0 then return end

        seen[key] = true
        candidates[#candidates + 1] = { key = key, weight = weight }
    end

    for _, center in ipairs((G and G.P_CENTER_POOLS and G.P_CENTER_POOLS.Edition) or {}) do
        add(center)
    end

    -- Compatibility fallback: use registered Edition centers directly if the
    -- pool is unavailable or contains only the source/base Edition.
    if #candidates == 0 and G and G.P_CENTERS then
        for _, key in ipairs({ 'e_foil', 'e_holo', 'e_hnds_vintage', 'e_polychrome', 'e_negative' }) do
            add(G.P_CENTERS[key])
        end
    end

    table.sort(candidates, function(a, b) return tostring(a.key) < tostring(b.key) end)
    return candidates
end

local function poll_different_edition(current_key, serial)
    if not current_key then return nil end
    local candidates = edition_candidates_except(current_key)
    if #candidates == 0 then return nil end

    local total_weight = 0
    for _, entry in ipairs(candidates) do
        total_weight = total_weight + entry.weight
    end
    if total_weight <= 0 then return nil end

    local seed = 'hnds_joker_reverse_edition_' .. tostring(serial)
    local roll = pseudorandom(seed) * total_weight
    local cumulative = 0
    for _, entry in ipairs(candidates) do
        cumulative = cumulative + entry.weight
        if roll < cumulative then return entry.key end
    end

    -- Floating-point guard; because candidates are all real Editions this is
    -- still guaranteed to return an Edition whenever one is available.
    return candidates[#candidates].key
end

local function collect_sticker_keys(card)
    local keys = {
        perishable = true,
        eternal = true,
        rental = true,
    }

    if SMODS and SMODS.Sticker and SMODS.Sticker.obj_buffer then
        for _, key in ipairs(SMODS.Sticker.obj_buffer) do keys[key] = true end
    end
    if card and type(card.stickers) == 'table' then
        for key in pairs(card.stickers) do keys[key] = true end
    end
    if card and card.ability and type(card.ability.stickers) == 'table' then
        for key in pairs(card.ability.stickers) do keys[key] = true end
    end

    return keys
end

local function strip_all_stickers(card)
    if not card then return end
    local keys = collect_sticker_keys(card)

    for key in pairs(keys) do
        local present = (card.ability and card.ability[key])
            or (card.stickers and card.stickers[key])
            or (card.ability and card.ability.stickers and card.ability.stickers[key])
        if present and card.remove_sticker then
            pcall(card.remove_sticker, card, key)
        end
        if card.stickers then card.stickers[key] = nil end
        if card.ability then card.ability[key] = nil end
        if card.ability and card.ability.stickers then card.ability.stickers[key] = nil end
    end

    if card.ability then
        card.ability.perishable = nil
        card.ability.eternal = nil
        card.ability.rental = nil
        card.ability.perish_tally = nil
    end
    if card.set_sticker_display then pcall(card.set_sticker_display, card) end
end

local function make_side(card, key)
    return {
        key = key,
        ability = snapshot_ability(card),
        stickers = deep_copy(card and card.stickers),
        edition = edition_key(card),
    }
end

local function ensure_pair(card)
    if not (card and card.ability) then return nil end
    local source_key = current_center_key(card)
    if not source_key then return nil end

    local pair = card.ability[PAIR_FIELD]
    if type(pair) == 'table' and pair.a and pair.b and pair.a.key and pair.b.key then
        -- Migrate pre-registry saves: an already-existing physical pair seeds the
        -- run-wide registry, provided neither side conflicts with a newer pair.
        local registered = registered_counterpart(source_key)
        if not registered then
            register_counterpart_pair(pair.a.key, pair.b.key)
            registered = registered_counterpart(source_key)
        end

        -- If this old local pair conflicts with the run registry, rebuild it from
        -- the registry instead of allowing two counterpart answers for one type.
        if registered and ((source_key == pair.a.key and registered == pair.b.key)
            or (source_key == pair.b.key and registered == pair.a.key))
        then
            return pair
        end
        card.ability[PAIR_FIELD] = nil
        pair = nil
    end

    local counterpart_key = registered_counterpart(source_key)
    local serial = next_pair_serial()

    if not counterpart_key then
        local counterpart = choose_counterpart(serial, card.config and card.config.center)
        if not counterpart then return nil end
        counterpart_key = counterpart.key
        if not register_counterpart_pair(source_key, counterpart_key) then return nil end
    end

    local counterpart = G and G.P_CENTERS and G.P_CENTERS[counterpart_key]
    if not counterpart then return nil end

    local source_edition = edition_key(card)
    pair = {
        serial = serial,
        active = 'a',
        -- Side A is always the physical card as it was naturally acquired. Side
        -- B is its run-registered counterpart. This means stickers on a naturally
        -- found Campfire return when Campfire returns, but generated Devious does
        -- not inherit them.
        a = make_side(card, source_key),
        b = {
            key = counterpart_key,
            ability = nil,
            stickers = {},
            edition = source_edition and poll_different_edition(source_edition, serial) or nil,
        },
    }
    card.ability[PAIR_FIELD] = pair
    return pair
end

local function resolve_active_side(pair, card)
    local key = current_center_key(card)
    if pair.a and key == pair.a.key then return 'a' end
    if pair.b and key == pair.b.key then return 'b' end
    return pair.active == 'b' and 'b' or 'a'
end

local function save_current_side(card, pair, side_name)
    local side = pair[side_name]
    if not side then return end

    -- Counterpart Jokers are never allowed to carry stickers into their saved
    -- state. Original-side stickers are retained and restored when flipped back.
    if side_name == 'b' then strip_all_stickers(card) end

    side.ability = snapshot_ability(card)
    side.stickers = side_name == 'b' and {} or deep_copy(card.stickers)
    side.edition = edition_key(card)
end

local function joker_slot(card)
    for i, joker in ipairs((G and G.jokers and G.jokers.cards) or {}) do
        if joker == card then return i end
    end
    return nil
end

local function restore_joker_slot(card, desired_index)
    if not (desired_index and card and G and G.jokers and G.jokers.cards) then return end
    local cards = G.jokers.cards
    local current_index
    for i, joker in ipairs(cards) do
        if joker == card then
            current_index = i
            break
        end
    end
    if not current_index or current_index == desired_index then return end

    table.remove(cards, current_index)
    desired_index = math.max(1, math.min(desired_index, #cards + 1))
    table.insert(cards, desired_index, card)
    card.area = G.jokers

    -- Re-align visuals after restoring the logical order. Never let a Joker's
    -- remove_from_deck/add_to_deck hooks permanently move it to another slot.
    if G.jokers.align_cards then pcall(G.jokers.align_cards, G.jokers) end
end

local function restore_side(card, pair, side_name, desired_index)
    local side = pair[side_name]
    local center = side and G and G.P_CENTERS and G.P_CENTERS[side.key]
    if not (side and center) then return false end

    -- Apply the destination Edition while this physical Joker is still in its
    -- CardArea. This is important for Negative: Steamodded updates the Joker
    -- area's card_limit when an owned Negative gains/loses its slot bonus.
    -- Losing Negative is intentionally allowed to leave #G.jokers.cards above
    -- card_limit (for example 6 Jokers in 5 slots); Joker Reverse is a
    -- transformation, not a fresh acquisition, so there is no "must have room"
    -- check and no Joker should be removed just to make room.
    if edition_key(card) ~= side.edition and card.set_edition then
        card:set_edition(side.edition, true, true)
    end

    if card.remove_from_deck and type(card.remove_from_deck) == 'function' then
        pcall(card.remove_from_deck, card)
    end

    card:set_ability(center, true)

    if side.ability then
        card.ability = deep_copy(side.ability)
    end
    card.ability = card.ability or {}
    card.ability[PAIR_FIELD] = pair

    if side_name == 'b' then
        card.stickers = {}
        strip_all_stickers(card)
    else
        card.stickers = deep_copy(side.stickers)
        if card.set_sticker_display then pcall(card.set_sticker_display, card) end
    end

    -- set_ability/add/remove hooks from unusual Jokers may touch the Edition,
    -- so enforce the saved destination Edition once more without doing any
    -- capacity check. In the normal path this is already a no-op.
    if edition_key(card) ~= side.edition and card.set_edition then
        card:set_edition(side.edition, true, true)
    end
    pair.active = side_name

    -- Suppress the Cursed-sticker sting: flipping is not a new acquisition.
    HNDS._suppress_curse_sound = true
    if card.add_to_deck and type(card.add_to_deck) == 'function' then
        card:add_to_deck()
    end
    HNDS._suppress_curse_sound = nil
    restore_joker_slot(card, desired_index)
    if card.set_sticker_display then pcall(card.set_sticker_display, card) end
    return true
end

local function reverse_card(target, pair)
    if not (target and target.area == G.jokers and pair) then return false end

    -- Capture the exact slot before any Joker remove/add hooks fire. Some Jokers
    -- mutate area order in those hooks, so restoring by index prevents shuffling.
    local slot = joker_slot(target)
    local active = resolve_active_side(pair, target)
    save_current_side(target, pair, active)
    local destination = active == 'a' and 'b' or 'a'

    -- An Editioned Joker must always become an Editioned counterpart with a
    -- different Edition. If the destination side was previously editionless (or
    -- was externally changed to the same Edition), generate and remember a new one.
    local source_edition = pair[active] and pair[active].edition
    local destination_side = pair[destination]
    if source_edition and destination_side
        and (not destination_side.edition or destination_side.edition == source_edition)
    then
        destination_side.edition = poll_different_edition(
            source_edition,
            tostring(pair.serial) .. '_' .. tostring(active) .. '_to_' .. tostring(destination)
        )
        if not destination_side.edition then return false end
    end

    return restore_side(target, pair, destination, slot)
end

local function schedule_reverse(target, sequence)
    if not (target and target.area == G.jokers) or target.hnds_joker_reverse_pending then return false end
    local pair = ensure_pair(target)
    if not pair then return false end

    target.hnds_joker_reverse_pending = true
    local stagger = (sequence - 1) * 0.18

    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0.08 + stagger,
        func = function()
            if target and target.area == G.jokers then
                target:flip()
                play_sound('card1', 1.05, 0.6)
            end
            return true
        end,
    }))

    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0.18,
        func = function()
            if target and target.area == G.jokers then
                reverse_card(target, pair)
            end
            return true
        end,
    }))

    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0.18,
        func = function()
            if target and target.area == G.jokers then
                target:flip()
                target:juice_up(0.5, 0.4)
                play_sound('tarot2', 1.0, 0.6)
            end
            if target then target.hnds_joker_reverse_pending = nil end
            return true
        end,
    }))

    return true
end

SMODS.Joker({
    key = 'joker_reverse',
    atlas = 'Jokers',
    pos = { x = 7, y = 6 },
    rarity = 2,
    cost = 5,
    unlocked = true,
    discovered = true,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,

    calculate = function(self, card, context)
        if not (context.end_of_round and context.main_eval)
            or context.blueprint
            or context.retrigger_joker
            or not (G and G.jokers and G.jokers.cards)
        then
            return
        end

        local index
        for i, joker in ipairs(G.jokers.cards) do
            if joker == card then
                index = i
                break
            end
        end
        if not index then return end

        local adjacent = {}
        if index > 1 then adjacent[#adjacent + 1] = G.jokers.cards[index - 1] end
        if index < #G.jokers.cards then adjacent[#adjacent + 1] = G.jokers.cards[index + 1] end

        local changed = 0
        for _, target in ipairs(adjacent) do
            if target and target ~= card and schedule_reverse(target, changed + 1) then
                changed = changed + 1
            end
        end

        if changed > 0 then
            return { message = 'Reversed!', colour = G.C.FILTER }
        end
    end,

    attributes = { 'joker', 'modify_card' },
})
