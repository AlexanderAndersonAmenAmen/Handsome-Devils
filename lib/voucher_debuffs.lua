local unpack_values = table.unpack or unpack
local legacy_wish = HNDS.set_wasted_wish_active
local game_fields = {'discount_percent', 'edition_rate', 'tarot_rate', 'planet_rate', 'playing_card_rate', 'interest_cap'}
local reset_fields = {'hands', 'discards', 'reroll_cost'}
local area_fields = {'hand', 'jokers', 'consumeables'}

local function copy_flags(value)
    local result = {}
    for key, entry in pairs(value or {}) do result[key] = entry end
    return result
end

local function snapshot()
    local game = G.GAME
    local result = {game = {}, resets = {}, areas = {}, shop = game.shop and game.shop.joker_max}
    for _, field in ipairs(game_fields) do result.game[field] = game[field] end
    for _, field in ipairs(reset_fields) do result.resets[field] = game.round_resets and game.round_resets[field] end
    for _, field in ipairs(area_fields) do
        local area = G[field]
        result.areas[field] = area and area.config and area.config.card_limits and (area.config.card_limits.mod or 0)
    end
    return result
end

local function differences(before, after)
    local result = {game = {}, resets = {}, areas = {}}
    for _, group in ipairs({'game', 'resets', 'areas'}) do
        for key, value in pairs(before[group]) do
            if type(value) == 'number' and type(after[group][key]) == 'number' then
                local delta = value - after[group][key]
                if delta ~= 0 then result[group][key] = delta end
            end
        end
    end
    result.shop = before.shop and after.shop and before.shop - after.shop or 0
    return result
end

local function voucher_for(key)
    for _, card in ipairs(G.vouchers and G.vouchers.cards or {}) do
        if card.config.center.key == key then return card end
    end
    local center = G.P_CENTERS[key]
    return {config = {center = center, center_key = key}, ability = copy_table(center.config or {})}
end

local function sync_cards(active, initial)
    for _, card in ipairs(G.vouchers and G.vouchers.cards or {}) do
        local ability = card.ability
        if active then
            if ability.hnds_wish_debuff_before == nil then
                ability.hnds_wish_debuff_before = initial and card.debuff == true
                    or HNDS.voucher_permanently_debuffed(card.config.center.key) == true
            end
            if not card.debuff then card:set_debuff(true) end
        elseif ability.hnds_wish_debuff_before ~= nil then
            local before = ability.hnds_wish_debuff_before
            ability.hnds_wish_debuff_before = nil
            card:set_debuff(before)
        end
    end
end

local function install_proxy()
    local game = G.GAME
    local owned = game.hnds_wasted_wish_used_vouchers or {}
    game.hnds_wasted_wish_used_vouchers = owned
    for key, value in pairs(game.used_vouchers or {}) do owned[key] = value end
    game.used_vouchers = setmetatable({}, {__newindex = function(_, key, value) owned[key] = value end})
end

local function refresh_areas()
    for _, name in ipairs(area_fields) do
        local area = G[name]
        if area and area.handle_card_limit then area:handle_card_limit() end
    end
    if calculate_reroll_cost then calculate_reroll_cost(true) end
    for _, card in pairs(G.I and G.I.CARD or {}) do if card.set_cost then card:set_cost() end end
end

function HNDS.refresh_wasted_wish()
    if not (G and G.GAME and G.GAME.hnds_wasted_wish_active) then return end
    if not G.GAME.hnds_wish_voucher_effects then HNDS.set_wasted_wish_active(true); return end
    local mt = getmetatable(G.GAME.used_vouchers or {})
    if not (mt and mt.__newindex) then install_proxy() end
    sync_cards(true)
end

function HNDS.set_wasted_wish_active(active)
    local game = G and G.GAME
    if not game then return end
    if game.hnds_wasted_wish_active and not game.hnds_wish_voucher_effects then legacy_wish(false) end
    if active then
        if game.hnds_wasted_wish_active then HNDS.refresh_wasted_wish(); return end
        local owned = copy_flags(game.used_vouchers)
        local keys, effects = {}, {}
        for key, value in pairs(owned) do
            if value and G.P_CENTERS[key] and not HNDS.voucher_permanently_debuffed(key) then keys[#keys + 1] = key end
        end
        table.sort(keys)
        game.hnds_wasted_wish_used_vouchers = owned
        game.hnds_wasted_wish_active = true
        game.hnds_wasted_wish_ante = game.round_resets and game.round_resets.ante
        for _, key in ipairs(keys) do
            local center, voucher = G.P_CENTERS[key], voucher_for(key)
            local before_flags, before = copy_flags(game.used_vouchers), snapshot()
            game.used_vouchers[key] = nil
            HNDS.undo_voucher_effect(key, voucher, before_flags)
            if type(center.unredeem) == 'function' then
                effects[#effects + 1] = {key = key, custom = true, ability = copy_table(voucher.ability)}
            else
                effects[#effects + 1] = {key = key, delta = differences(before, snapshot())}
            end
        end
        game.hnds_wish_voucher_effects = effects
        install_proxy()
        sync_cards(true, true)
    elseif game.hnds_wasted_wish_active then
        local owned = copy_flags(game.hnds_wasted_wish_used_vouchers)
        for key in pairs(game.hnds_debuffed_vouchers or {}) do owned[key] = nil end
        game.used_vouchers = owned
        game.hnds_wasted_wish_active = nil
        local effects = game.hnds_wish_voucher_effects or {}
        for i = #effects, 1, -1 do
            local effect = effects[i]
            if owned[effect.key] and not HNDS.voucher_permanently_debuffed(effect.key) then
                local center = G.P_CENTERS[effect.key]
                if effect.custom then
                    if center and center.redeem then center:redeem({config = {center = center, center_key = effect.key}, ability = effect.ability}) end
                else
                    local delta = effect.delta
                    for key, value in pairs(delta.game) do game[key] = (game[key] or 0) + value end
                    for key, value in pairs(delta.resets) do game.round_resets[key] = (game.round_resets[key] or 0) + value end
                    for key, value in pairs(delta.areas) do if G[key] then G[key]:change_size(value) end end
                    HNDS.change_voucher_shop_size(delta.shop or 0)
                end
            end
        end
        sync_cards(false)
        game.hnds_wish_voucher_effects = nil
        game.hnds_wasted_wish_used_vouchers = nil
        game.hnds_wasted_wish_ante = nil
    end
    game.hnds_wasted_wish_adjustments, game.hnds_wasted_wish_overrides = nil, nil
    game.hnds_wasted_wish_unredeemed, game.hnds_wasted_wish_slot_state = nil, nil
    refresh_areas()
    if HNDS.refresh_unbought_curse_prices then HNDS.refresh_unbought_curse_prices() end
end

local start_run_ref = Game.start_run
function Game:start_run(...)
    local results = HNDS.pack(start_run_ref(self, ...))
    HNDS.refresh_wasted_wish()
    return unpack_values(results, 1, results.n)
end
