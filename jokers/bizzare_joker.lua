local function hnds_bizarre_rarity(center)
    local rarity = center and center.rarity
    if type(rarity) == "table" then rarity = rarity.id or rarity.key or rarity.name end
    if rarity == 2 or rarity == "2" or rarity == "Uncommon" or rarity == "uncommon" then return 2 end
    if rarity == 3 or rarity == "3" or rarity == "Rare" or rarity == "rare" then return 3 end
    return nil
end

local function hnds_bizarre_pool(rarity)
    local pool, seen = {}, {}

    -- Prefer the live Steamodded pool so bans, unlocks and other pool rules are
    -- respected. Fall back to registered rarity pools for compatibility.
    if get_current_pool then
        local ok, current = pcall(get_current_pool, "Joker", rarity, nil, "hnds_bizarre_spawn")
        if ok and type(current) == "table" then
            for _, entry in ipairs(current) do
                local key = type(entry) == "table" and entry.key or entry
                local center = key and G and G.P_CENTERS and G.P_CENTERS[key]
                if key and key ~= "UNAVAILABLE" and key ~= "j_hnds_bizzare_joker"
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
            if key and key ~= "j_hnds_bizzare_joker"
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

local function hnds_bizarre_find_child(owner_token)
    if not owner_token or not (G and G.jokers and G.jokers.cards) then return nil end
    for _, joker in ipairs(G.jokers.cards) do
        if joker and joker.ability and joker.ability.hnds_bizarre_owner == owner_token then
            return joker
        end
    end
    return nil
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

local function hnds_bizarre_create_child(card)
    if not (card and card.ability and card.ability.extra and G and G.jokers and SMODS and SMODS.add_card) then
        return nil
    end

    local extra = card.ability.extra
    if extra.dismissed then return nil end
    local owner_token = hnds_bizarre_owner_token(card)
    local existing = hnds_bizarre_find_child(owner_token)
    if existing then
        extra.child_id = existing.sort_id or existing.ID
        return existing
    end

    extra.rolls = (tonumber(extra.rolls) or 0) + 1
    -- Bizarre Joker only creates Rare Jokers. Never fall back to Uncommon.
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
    })
    if child then
        child.ability = child.ability or {}
        child.ability.hnds_bizarre_owner = owner_token
        extra.child_id = child.sort_id or child.ID
    end
    return child
end

local function hnds_bizarre_remove_child(card)
    local extra = card and card.ability and card.ability.extra
    if not extra then return end
    extra.dismissed = true
    local child = hnds_bizarre_find_child(extra.owner_token)
    if not child then return end

    -- This is a linked temporary Joker, so losing Bizarre must remove it even
    -- if another effect happened to make the child Eternal.
    if SMODS and type(SMODS.destroy_cards) == "function" then
        SMODS.destroy_cards(child, { immediate = true, bypass_eternal = true })
    elseif child.start_dissolve then
        child:start_dissolve()
    elseif child.remove then
        child:remove()
    end
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

        -- Defer one tick so save/load reconstruction can restore an already
        -- linked child before we decide whether a replacement must be created.
        if G and G.E_MANAGER and Event then
            G.E_MANAGER:add_event(Event({
                trigger = "after",
                delay = 0,
                func = function()
                    if card and card.added_to_deck
                        and card.ability and card.ability.extra
                        and not card.ability.extra.dismissed
                    then
                        hnds_bizarre_create_child(card)
                    end
                    return true
                end,
            }))
        else
            hnds_bizarre_create_child(card)
        end
    end,

    remove_from_deck = function(self, card, from_debuff)
        if from_debuff then return end
        hnds_bizarre_remove_child(card)
    end,

    attributes = { "joker", "generation" },
})
