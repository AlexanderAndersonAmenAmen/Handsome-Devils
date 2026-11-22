HNDS = HNDS or {}

local BIZARRE_BANNED_KEYS = {
    j_hnds_bizzare_joker = true,
    j_hnds_ms_fortune = true,
}

local function hnds_bizarre_key_allowed(key)
    if HNDS.mp_active and HNDS.mp_active() and G.GAME and G.GAME.banned_keys and G.GAME.banned_keys[key] then return false end
    return key and key ~= "UNAVAILABLE" and not BIZARRE_BANNED_KEYS[key]
end

SMODS.Sticker {
    key = 'fighting_spirit',
    atlas = 'Stickers',
    pos = { x = 5, y = 4 },
    badge_colour = (G.C and G.C.RED) or G.C.PURPLE,
    rate = 0,
    no_collection = true,
    default_compat = true,
    sets = { Joker = true },
}

local function hnds_bizarre_strip_child_stickers(child)
    if not child then return end
    child.ability = child.ability or {}

    local keys = {
        perishable = true,
        eternal = true,
        rental = true,
    }
    if SMODS and SMODS.Sticker and SMODS.Sticker.obj_buffer then
        for _, key in ipairs(SMODS.Sticker.obj_buffer) do keys[key] = true end
    end
    if type(child.stickers) == 'table' then
        for key in pairs(child.stickers) do keys[key] = true end
    end
    if type(child.ability.stickers) == 'table' then
        for key in pairs(child.ability.stickers) do keys[key] = true end
    end


    keys.hnds_fighting_spirit = nil
    local any_removed = false
    for key in pairs(keys) do
        local present = child.ability[key]
            or (child.stickers and child.stickers[key])
            or (child.ability.stickers and child.ability.stickers[key])
        if present then
            any_removed = true
            if child.remove_sticker then
                pcall(child.remove_sticker, child, key)
            end
            if child.stickers then child.stickers[key] = nil end
            child.ability[key] = nil
            if child.ability.stickers then child.ability.stickers[key] = nil end
        end
    end

    child.ability.perishable = nil
    child.ability.eternal = nil
    child.ability.rental = nil
    child.ability.perish_tally = nil
    if any_removed and child.set_sticker_display then
        pcall(child.set_sticker_display, child)
    end
end


HNDS.strip_bizarre_child_stickers = hnds_bizarre_strip_child_stickers

local function hnds_bizarre_mark_child(child, owner_token)
    if not child then return nil end
    child.ability = child.ability or {}


    hnds_bizarre_strip_child_stickers(child)
    child.ability.hnds_bizarre_owner = owner_token

    if not child.ability.hnds_fighting_spirit then
        if child.add_sticker then
            child:add_sticker('hnds_fighting_spirit', true)
        else
            child.ability.hnds_fighting_spirit = true
        end
    end
    if child.set_sticker_display then pcall(child.set_sticker_display, child) end
    return child
end

local function hnds_bizarre_rarity(center)
    local rarity = center and center.rarity
    if type(rarity) == "table" then rarity = rarity.id or rarity.key or rarity.name end
    if rarity == 2 or rarity == "2" or rarity == "Uncommon" or rarity == "uncommon" then return 2 end
    if rarity == 3 or rarity == "3" or rarity == "Rare" or rarity == "rare" then return 3 end
    return nil
end

local function hnds_bizarre_pool(rarity)
    local pool, seen = {}, {}


    if get_current_pool then
        local ok, current = pcall(get_current_pool, "Joker", rarity, nil, "hnds_bizarre_spawn")
        if ok and type(current) == "table" then
            for _, entry in ipairs(current) do
                local key = type(entry) == "table" and entry.key or entry
                local center = key and G and G.P_CENTERS and G.P_CENTERS[key]
                if hnds_bizarre_key_allowed(key)
                    and center and hnds_bizarre_rarity(center) == rarity
                    and center.unlocked ~= false and not center.hidden and not seen[key]
                then
                    seen[key] = true
                    pool[#pool + 1] = key
                end
            end
        end
    end

    if #pool == 0 then
        local source = G and G.P_JOKER_RARITY_POOLS and G.P_JOKER_RARITY_POOLS[rarity]
            or (G and G.P_CENTER_POOLS and G.P_CENTER_POOLS.Joker) or {}
        for _, entry in ipairs(source) do
            local center = type(entry) == "table" and entry
                or (G and G.P_CENTERS and G.P_CENTERS[entry])
            local key = center and center.key
            if hnds_bizarre_key_allowed(key)
                and hnds_bizarre_rarity(center) == rarity
                and center.unlocked ~= false and not center.hidden and not seen[key]
            then
                seen[key] = true
                pool[#pool + 1] = key
            end
        end
    end

    table.sort(pool)
    return pool
end

local function hnds_bizarre_is_live_child(joker, owner_token)
    return joker.ability and joker.ability.hnds_bizarre_owner == owner_token
        and not (joker.removed or joker.REMOVED or joker.getting_sliced or joker.destroyed
            or joker.shattered or joker.hnds_bizarre_destroying)
end

local function hnds_bizarre_find_child(owner_token)
    if not owner_token or not (G and G.jokers and G.jokers.cards) then return nil end
    for _, joker in ipairs(G.jokers.cards) do
        if hnds_bizarre_is_live_child(joker, owner_token) then
            return joker
        end
    end
    return nil
end

local function hnds_bizarre_destroy_children(children)
    if #children == 0 then return end
    local game, area = G.GAME, G.jokers
    local pending = {}
    for _, child in ipairs(children) do
        if child and child.area == area and not (child.removed or child.REMOVED
            or child.getting_sliced or child.destroyed or child.shattered or child.hnds_bizarre_destroying)
        then
            child.hnds_bizarre_destroying = true
            pending[#pending + 1] = child
        end
    end
    if #pending == 0 then return end

    local function destroy()
        if G.GAME ~= game or G.jokers ~= area then
            for _, child in ipairs(pending) do child.hnds_bizarre_destroying = nil end
            return true
        end
        local targets = {}
        for _, child in ipairs(pending) do
            if child.area == area and not (child.removed or child.REMOVED
                or child.getting_sliced or child.destroyed or child.shattered)
            then
                targets[#targets + 1] = child
            end
        end
        if #targets > 0 then
            if SMODS and type(SMODS.destroy_cards) == 'function' then
                if type(SMODS.is_playing_card) == 'function' then
                    SMODS.destroy_cards(targets, { immediate = true, bypass_eternal = true })
                else
                    SMODS.destroy_cards(targets, true, true)
                end
            else
                for _, child in ipairs(targets) do
                    child.getting_sliced, child.destroyed = true, true
                    if child.start_dissolve then child:start_dissolve() end
                end
            end
        end
        return true
    end

    if G.E_MANAGER and Event then
        G.E_MANAGER:add_event(Event({
            trigger = 'after', delay = 0, blocking = false, blockable = false, func = destroy,
        }))
    else
        destroy()
    end
end

local function hnds_bizarre_owner_token(card)
    local extra = card and card.ability and card.ability.extra
    if not extra then return nil end
    if not extra.owner_token then
        if G and G.GAME then
            G.GAME.hnds_bizarre_owner_counter = math.max(0, tonumber(G.GAME.hnds_bizarre_owner_counter) or 0) + 1
        end
        extra.owner_token = table.concat({
            "hnds_bizarre",
            tostring(card.sort_id or card.ID or 0),
            tostring(G and G.GAME and G.GAME.hnds_bizarre_owner_counter or 0),
        }, ":")
    end
    return extra.owner_token
end

local function hnds_bizarre_create_child(card, additional)
    if not (card and card.ability and card.ability.extra and G and G.jokers and SMODS and SMODS.add_card) then
        return nil
    end

    local extra = card.ability.extra
    if extra.dismissed then return nil end
    local owner_token = hnds_bizarre_owner_token(card)
    local existing = not additional and hnds_bizarre_find_child(owner_token)
    if existing then
        local existing_key = existing.config and existing.config.center and existing.config.center.key
        if hnds_bizarre_key_allowed(existing_key) then
            hnds_bizarre_mark_child(existing, owner_token)
            extra.child_id = existing.sort_id or existing.ID
            return existing
        end


        hnds_bizarre_destroy_children({ existing })
        extra.child_id = nil
    end

    extra.rolls = (tonumber(extra.rolls) or 0) + 1

    local rarity = 3
    local pool = hnds_bizarre_pool(rarity)
    if #pool == 0 then return nil end

    local key = pseudorandom_element(pool, pseudoseed(
        "hnds_bizarre_joker_" .. owner_token .. "_" .. tostring(extra.rolls)
    ))
    if not key then return nil end

    local child = SMODS.add_card({
        set = "Joker",
        area = G.jokers,
        key = key,
        key_append = "hnds_bizarre_spawn",
        no_edition = true,
    })
    if child then
        hnds_bizarre_mark_child(child, owner_token)
        extra.child_id = child.sort_id or child.ID
    end
    return child
end

HNDS.bizarre_extra_child = function(card)
    if #G.jokers.cards + (G.GAME.joker_buffer or 0) >= G.jokers.config.card_limit then return end
    return hnds_bizarre_create_child(card, true)
end

local function hnds_bizarre_on_removed(card)
    local extra = card and card.ability and card.ability.extra
    if not extra or extra.dismissed then return end
    extra.dismissed = true
    extra.child_id = nil
    local owner_token = extra.owner_token
    if not (owner_token and G and G.jokers and G.jokers.cards) then return end

    local children = {}
    for _, joker in ipairs(G.jokers.cards) do
        if hnds_bizarre_is_live_child(joker, owner_token) then
            children[#children + 1] = joker
        end
    end
    hnds_bizarre_destroy_children(children)
end

SMODS.Joker({
    key = "bizzare_joker",
    unlocked = false,
    discovered = false,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    config = { extra = { owner_token = nil, child_id = nil, rolls = 0, dismissed = false } },
    unlock_condition = { type = 'modify_deck' },
    loc_vars = function(self, info_queue, card)
        return { key = self.key, vars = {} }
    end,
    check_for_unlock = function(self, args)
        if args.type == 'modify_deck' then
            if not (G.GAME and G.GAME.blind and G.GAME.blind.in_blind) then return false end
            local cards = G.playing_cards or {}
            if #cards < 5 then return false end
            local suit = nil
            for _, v in ipairs(cards) do
                if v and v.base and v.base.suit then
                    if not suit then
                        suit = v.base.suit
                    elseif suit ~= v.base.suit then
                        return false
                    end
                end
            end
            return suit ~= nil
        end
    end,
    rarity = 1,
    cost = 5,
    atlas = "Jokers",
    pos = { x = 7, y = 1 },
    demicoloncompat = true,

    add_to_deck = function(self, card, from_debuff)
        if from_debuff then return end
        local extra = card.ability.extra
        extra.dismissed = false
        hnds_bizarre_owner_token(card)


        if G and G.E_MANAGER and Event then
            G.E_MANAGER:add_event(Event({
                trigger = "after",
                delay = 0,
                func = function()
                    if card and card.added_to_deck
                        and card.ability and card.ability.extra
                        and not card.ability.extra.dismissed
                    then
                        local child = hnds_bizarre_create_child(card)
                        if child and HNDS.queue_acquisition_retrigger then HNDS.queue_acquisition_retrigger(card) end
                    end
                    return true
                end,
            }))
        else
            local child = hnds_bizarre_create_child(card)
            if child and HNDS.queue_acquisition_retrigger then HNDS.queue_acquisition_retrigger(card) end
        end
    end,

    remove_from_deck = function(self, card, from_debuff)
        if from_debuff then return end
        hnds_bizarre_on_removed(card)
    end,

    attributes = { "joker", "generation" },
})
