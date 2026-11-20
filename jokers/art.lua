local ART_KEY = 'j_hnds_art'

local function art_queue(game)
    if type(game.art_queue) ~= 'table' then
        local count = math.max(0, math.floor(tonumber(game.art_queue) or 0))
        game.art_queue = {}
        for i = 1, count do game.art_queue[i] = {} end
    end
    return game.art_queue
end

local function art_edition_key(card)
    local edition = card.edition
    return edition and (edition.key or (edition.type and 'e_' .. edition.type))
end

local function art_snapshot(card)
    local stickers = {}
    for key in pairs(SMODS.Stickers or {}) do
        local value = card.ability[key]
        if value then stickers[key] = type(value) == 'table' and copy_table(value) or value end
    end
    return {
        edition = art_edition_key(card),
        extra_value = card.ability.extra_value,
        stickers = stickers,
        perish_tally = card.ability.perish_tally,
        pinned = card.pinned,
        seal = card.seal,
    }
end

function HNDS.art_sell_value(card)
    local game = G.GAME
    local bonus = tonumber(card.ability.extra_value) or 0
    if card.edition then
        local inflation = tonumber(game.inflation) or 0
        local discount = (100 - (tonumber(game.discount_percent) or 0)) / 100
        local base_cost = (tonumber(card.base_cost) or 20) + inflation + 0.5
        local extra = math.max(0, (tonumber(card.extra_cost) or inflation) - inflation)
        local plain = math.max(1, math.floor(base_cost * discount / 2))
        local with_edition = math.max(1, math.floor((base_cost + extra) * discount / 2))
        bonus = bonus + with_edition - plain
    end
    return -5 + bonus
end

local function art_tag_seed(card)
    return 'hnds_art_tag_' .. tostring(card.sort_id or card.ID or 0)
end

local function art_tag_key(card)
    local key = card.ability.hnds_art_tag
    if key then key = HNDS.conjuring_tag_key and HNDS.conjuring_tag_key(key) or key end
    if not (key and G.P_TAGS[key] and not HNDS.is_tag_banned(key)) then
        key = HNDS.poll_registered_tag_key(art_tag_seed(card))
    end
    card.ability.hnds_art_tag = key
    return key
end

local function art_collection_tag_key(card)
    local pool, seen = {}, {}
    local previous = card.hnds_art_collection_tag
    for _, key in ipairs(HNDS.get_registered_tag_pool()) do
        key = HNDS.conjuring_tag_key and HNDS.conjuring_tag_key(key) or key
        if key ~= previous and not seen[key] then
            pool[#pool + 1] = key
            seen[key] = true
        end
    end
    local key = #pool > 0 and pool[math.random(#pool)] or previous
    if key and (not G.P_TAGS[key] or HNDS.is_tag_banned(key)) then key = nil end
    card.hnds_art_collection_tag = key
    return key
end

local function queue_art_copy(card, sold)
    if card.hnds_art_queued or card.removed or card.REMOVED or SMODS.no_resolve then return end
    card.hnds_art_queued = true
    local game = G.GAME
    local queue = art_queue(game)
    queue[#queue + 1] = art_snapshot(card)
    if not sold then return end

    local tag_key = art_tag_key(card)
    if not tag_key then return end
    local seed = art_tag_seed(card) .. '_reward'
    G.E_MANAGER:add_event(Event({
        func = function()
            if G.GAME == game and G.P_TAGS[tag_key] and not HNDS.is_tag_banned(tag_key) then
                local tag = HNDS.poll_tag(seed, { tag_key })
                if tag then
                    add_tag(tag)
                    play_sound('holo1', 1.2 + math.random() * 0.1, 0.4)
                end
            end
            return true
        end,
    }))
end

local end_consumeable_ref = G.FUNCS.end_consumeable
function G.FUNCS.end_consumeable(...)
    local pack = G.pack_cards
    if G.GAME and G.GAME.PACK_INTERRUPT ~= nil and pack then
        for _, card in ipairs(pack.cards) do
            if card.area == pack and card.config and card.config.center and card.config.center.key == ART_KEY then
                queue_art_copy(card)
            end
        end
    end
    return end_consumeable_ref(...)
end

function HNDS.prepare_art_booster(booster)
    local ability = booster.ability
    if not (G and G.GAME and ability and ability.set == 'Booster') or booster.hnds_art_copies then return end
    local size = tonumber(ability.extra)
    if not size then return end
    local queue = art_queue(G.GAME)
    if #queue == 0 then return end

    local size_mod = tonumber(G.GAME.modifiers and G.GAME.modifiers.booster_size_mod) or 0
    local pack_size = math.max(1, size + size_mod)
    booster.hnds_art_copies = {}
    for index, snapshot in ipairs(queue) do booster.hnds_art_copies[pack_size + index] = snapshot end
    ability.extra = pack_size + #queue - size_mod
end

function HNDS.art_booster_card(context)
    local booster = context.booster
    local copies = booster and booster.hnds_art_copies
    local snapshot = copies and copies[context.index]
    if not snapshot then return end
    if context.create_booster_card then
        return { booster_create_flags = { key = ART_KEY, area = G.pack_cards, no_edition = true, stickers = {} } }
    end

    local card = context.card
    if not (card and card.config and card.config.center and card.config.center.key == ART_KEY) then return end
    if snapshot.edition and G.P_CENTERS[snapshot.edition] then
        card:set_edition(snapshot.edition, true, true)
    elseif card.edition then
        card:set_edition(nil, true, true)
    end

    local stickers = snapshot.stickers or {}
    for key in pairs(SMODS.Stickers or {}) do
        local value = stickers[key]
        if value then
            if not card.ability[key] then card:add_sticker(key, true) end
            card.ability[key] = value
        elseif card.ability[key] then
            card:remove_sticker(key)
        end
    end
    card.ability.extra_value = snapshot.extra_value
    card.ability.perish_tally = snapshot.perish_tally
    card.pinned = snapshot.pinned
    if snapshot.seal then card:set_seal(snapshot.seal, true, true) end
    card:set_cost()

    copies[context.index] = nil
    local queue = art_queue(G.GAME)
    for index, pending in ipairs(queue) do
        if pending == snapshot then
            table.remove(queue, index)
            break
        end
    end
end

SMODS.Joker {
    key = 'art',
    unlocked = false,
    unlock_condition = { type = '', extra = '', hidden = true },
    locked_loc_vars = function()
        return { key = 'joker_locked_legendary', set = 'Other', vars = {} }
    end,
    discovered = false,
    rarity = 4,
    cost = 20,
    atlas = 'Jokers',
    pos = { x = 6, y = 2 },
    soul_pos = { x = 1, y = 3 },
    load = function(self, card)
        card:set_cost()
    end,
    loc_vars = function(self, info_queue, card)
        local name = localize('k_hnds_art_random_tag')
        local article = localize('k_hnds_art_article')
        local area = card and card.area
        if G.STAGE == G.STAGES.RUN and area and area.config then
            local key = area.config.collection and art_collection_tag_key(card) or art_tag_key(card)
            if key then
                name = localize { type = 'name_text', set = 'Tag', key = key, nodes = {} }
                if name:match('^[AEIOUaeiou]') then article = localize('k_hnds_art_article_vowel') end
            end
        end
        return { vars = { name, article } }
    end,
    calculate = function(self, card, context)
        if context.selling_self and not context.blueprint and not context.retrigger_joker then
            queue_art_copy(card, true)
            return nil, true
        end
    end,
    attributes = { 'generation', 'on_sell', 'tag' },
}
