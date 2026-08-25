HNDS = HNDS or {}

local function hnds_copy_table(value, seen)
    if type(value) ~= 'table' then return value end
    if type(copy_table) == 'function' then return copy_table(value) end
    seen = seen or {}
    if seen[value] then return seen[value] end
    local copy = {}
    seen[value] = copy
    for k, v in pairs(value) do
        copy[hnds_copy_table(k, seen)] = hnds_copy_table(v, seen)
    end
    return setmetatable(copy, getmetatable(value))
end

local function hnds_tables_equal(a, b, seen)
    if a == b then return true end
    if type(a) ~= 'table' or type(b) ~= 'table' then return false end
    seen = seen or {}
    if seen[a] == b then return true end
    seen[a] = b
    for k, v in pairs(a) do
        if not hnds_tables_equal(v, b[k], seen) then return false end
    end
    for k in pairs(b) do
        if a[k] == nil then return false end
    end
    return true
end


local function hnds_edition_identity(edition)
    if not edition then return false end
    if type(edition) ~= 'table' then return tostring(edition) end
    if edition.key then return tostring(edition.key) end


    local matches = {}
    for flag, value in pairs(edition) do
        if value == true and type(flag) == 'string' then
            local key = flag:sub(1, 2) == 'e_' and flag or ('e_' .. flag)
            local center = G and G.P_CENTERS and G.P_CENTERS[key]
            if center and center.set == 'Edition' then matches[#matches + 1] = key end
        end
    end
    table.sort(matches)
    return matches[1]
end

local function hnds_stone_mask_card_id(card)
    return tostring(card and (card.playing_card or card.sort_id or card.ID) or 'unknown')
end

local function hnds_stone_mask_save_original(card)
    if not (card and card.ability) or card.ability.hnds_stone_mask_temp_active then return end
    card.ability.hnds_stone_mask_temp_active = true
    card.ability.hnds_stone_mask_original_edition = card.edition and hnds_copy_table(card.edition) or false
    card.ability.hnds_stone_mask_original_seal = card.seal or false
end

local function hnds_stone_mask_apply(card, owner)


    if not (card and card.ability and HNDS.card_has_stone and HNDS.card_has_stone(card, true)) then return false end
    hnds_stone_mask_save_original(card)

    card.ability.hnds_stone_mask_rolls = (tonumber(card.ability.hnds_stone_mask_rolls) or 0) + 1
    if G and G.GAME then
        G.GAME.hnds_stone_mask_roll_serial = (tonumber(G.GAME.hnds_stone_mask_roll_serial) or 0) + 1
    end
    local roll = (G and G.GAME and G.GAME.hnds_stone_mask_roll_serial)
        or card.ability.hnds_stone_mask_rolls
    local id = hnds_stone_mask_card_id(card)
    local owner_id = tostring(owner and (owner.sort_id or owner.ID) or 'stone_mask')

    local edition = SMODS.poll_edition({
        key = 'hnds_stone_mask_edition_' .. id .. '_' .. owner_id .. '_' .. tostring(roll),
        guaranteed = true,
    })
    local seal = SMODS.poll_seal({
        key = 'hnds_stone_mask_seal_' .. id .. '_' .. owner_id .. '_' .. tostring(roll),
        guaranteed = true,
    })

    if edition and card.set_edition then card:set_edition(edition, true, true) end
    if seal and card.set_seal then card:set_seal(seal, true) end


    card.ability.hnds_stone_mask_applied_edition = card.edition and hnds_copy_table(card.edition) or false
    card.ability.hnds_stone_mask_applied_edition_key = hnds_edition_identity(card.edition)
    card.ability.hnds_stone_mask_applied_seal = card.seal or false
    return edition ~= nil or seal ~= nil
end

local function hnds_stone_mask_restore(card)
    if not (card and card.ability and card.ability.hnds_stone_mask_temp_active) then return false end
    local ability = card.ability

    local applied_edition = ability.hnds_stone_mask_applied_edition
    local current_edition = card.edition or false
    local applied_key = ability.hnds_stone_mask_applied_edition_key
    local current_key = hnds_edition_identity(card.edition)
    local edition_unchanged = (applied_edition == false and current_edition == false)
        or (applied_key and current_key == applied_key)
        or (not applied_key and hnds_tables_equal(applied_edition, current_edition))
    if edition_unchanged and card.set_edition then
        local original = ability.hnds_stone_mask_original_edition
        card:set_edition(original ~= false and hnds_copy_table(original) or nil, true, true)
    end

    local applied_seal = ability.hnds_stone_mask_applied_seal
    local current_seal = card.seal or false
    if applied_seal == current_seal and card.set_seal then
        local original = ability.hnds_stone_mask_original_seal
        card:set_seal(original ~= false and original or nil, true)
    end

    ability.hnds_stone_mask_temp_active = nil
    ability.hnds_stone_mask_original_edition = nil
    ability.hnds_stone_mask_original_seal = nil
    ability.hnds_stone_mask_applied_edition = nil
    ability.hnds_stone_mask_applied_edition_key = nil
    ability.hnds_stone_mask_applied_seal = nil
    ability.hnds_stone_mask_rolls = nil
    return true
end

function HNDS.restore_stone_mask_cards()
    for _, playing_card in ipairs((G and G.playing_cards) or {}) do
        hnds_stone_mask_restore(playing_card)
    end
end

SMODS.Joker({
    key = 'stone_mask',
    atlas = 'Jokers',
    pos = { x = 5, y = 1 },
    rarity = 2,
    cost = 5,
    unlocked = false,
    discovered = false,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    config = {},
    unlock_condition = { type = 'modify_jokers', extra = 5 },
    loc_vars = function(self, info_queue, card)
        return { vars = {} }
    end,
    check_for_unlock = function(self, args)
        if args.type == 'modify_jokers' then
            local jokers = SMODS.find_card('j_vampire')
            for _, v in ipairs(jokers) do
                if v.ability and v.ability.extra and v.ability.extra.x_mult
                    and v.ability.extra.x_mult >= self.unlock_condition.extra
                then
                    return true
                end
            end
        end
    end,
    in_pool = function(self, args)
        if HNDS.stone_joker_in_pool then return HNDS.stone_joker_in_pool(args) end
		return true
    end,
    calculate = function(self, card, context)
        if type(context) ~= 'table' or context.blueprint then return end
        local drawn = context.hand_drawn
        if type(drawn) ~= 'table' then return end

        local changed = 0
        for _, playing_card in ipairs(drawn) do
            if hnds_stone_mask_apply(playing_card, card) then
                changed = changed + 1
                if playing_card.juice_up then playing_card:juice_up(0.25, 0.2) end
            end
        end

        if changed > 0 then
            return { message = localize('k_hnds_awaken'), colour = G.C.GREY }
        end
    end,
    attributes = { 'modify_card', 'enhancements', 'editions', 'seals' }
})
