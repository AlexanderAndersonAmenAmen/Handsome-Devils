local unpack_values = table.unpack or unpack

local function disabled(key)
    local game = G and G.GAME
    return game and game.hnds_debuffed_vouchers and game.hnds_debuffed_vouchers[key] == true
end

function HNDS.curse_voucher_pool()
    local game = G and G.GAME
    if not game or game.hnds_wasted_wish_active then return {} end
    local pool, debuffed = {}, {}
    for _, card in ipairs(G.vouchers and G.vouchers.cards or {}) do
        if card.debuff then debuffed[card.config.center.key] = true end
    end
    for key, owned in pairs(game.used_vouchers or {}) do
        local center = G.P_CENTERS[key]
        if owned and center and center.set == 'Voucher' and not disabled(key) and not debuffed[key] then
            pool[#pool + 1] = key
        end
    end
    table.sort(pool)
    return pool
end

local function extra(key, fallback)
    local center = G.P_CENTERS[key]
    local value = center and center.config and center.config.extra
    return type(value) == 'number' and value or fallback
end

local tiers = {
    {field = 'discount_percent', base = 0, keys = {'v_clearance_sale', 'v_liquidation'}, values = {25, 50}},
    {field = 'edition_rate', base = 1, keys = {'v_hone', 'v_glow_up'}, values = {2, 4}},
    {field = 'tarot_rate', base = 4, scale = 4, keys = {'v_tarot_merchant', 'v_tarot_tycoon'}, values = {2.4, 9.6}},
    {field = 'planet_rate', base = 4, scale = 4, keys = {'v_planet_merchant', 'v_planet_tycoon'}, values = {2.4, 9.6}},
    {field = 'playing_card_rate', base = 0, keys = {'v_magic_trick', 'v_illusion'}, values = {4, 4}},
    {field = 'interest_cap', base = 25, keys = {'v_seed_money', 'v_money_tree'}, values = {50, 100}},
}

local function tier_value(group, owned)
    local value = group.base
    for i, key in ipairs(group.keys) do
        if owned[key] then value = extra(key, group.values[i]) * (group.scale or 1) end
    end
    return value
end

function HNDS.change_voucher_shop_size(delta)
    local game = G and G.GAME
    if not game or delta == 0 then return end
    game.shop = game.shop or {joker_max = 2}
    game.shop.joker_max = math.max(0, (game.shop.joker_max or 2) + delta)
    local area = G.shop_jokers
    if not (G.shop and area and area.cards) then return end
    local limit = game.shop.joker_max
    for i = #area.cards, limit + 1, -1 do area.cards[i]:remove() end
    area.config.card_limit = limit
    if area.handle_card_limit then area:handle_card_limit() end
    area.T.w = math.min(limit * 1.02 * G.CARD_W, 4.08 * G.CARD_W)
    G.shop:recalculate()
    if delta > 0 then
        for i = #area.cards + 1, limit do area:emplace(create_card_for_shop(area)) end
    end
end

local function undo_voucher(key, voucher, before)
    local center = G.P_CENTERS[key]
    if type(center.unredeem) == 'function' then center:unredeem(voucher); return end
    local game, resets, round = G.GAME, G.GAME.round_resets, G.GAME.current_round
    local hands, discards = 0, 0
    if key == 'v_grabber' or key == 'v_nacho_tong' then hands = -extra(key, 1) end
    if key == 'v_wasteful' or key == 'v_recyclomancy' then discards = -extra(key, 1) end
    if key == 'v_hieroglyph' then hands = extra(key, 1) end
    if key == 'v_petroglyph' then discards = extra(key, 1) end
    if resets then
        resets.hands = math.max(0, (resets.hands or 0) + hands)
        resets.discards = math.max(0, (resets.discards or 0) + discards)
    end
    if round and not game.hnds_wasted_wish_active then
        if hands < 0 and round.hands_left then round.hands_left = math.max(0, round.hands_left + hands) end
        if discards < 0 and round.discards_left then round.discards_left = math.max(0, round.discards_left + discards) end
    end
    if key == 'v_paint_brush' or key == 'v_palette' then
        if G.hand then
            G.hand:change_size(-1)
            if G.hand.handle_card_limit then G.hand:handle_card_limit() end
        end
    end
    if key == 'v_crystal_ball' and G.consumeables then HNDS.change_consumable_slots(-1) end
    if key == 'v_antimatter' and G.jokers then
        G.jokers:change_size(-1)
        if G.jokers.handle_card_limit then G.jokers:handle_card_limit() end
    end
    if key == 'v_overstock_norm' or key == 'v_overstock_plus' then HNDS.change_voucher_shop_size(-1) end
    if key == 'v_reroll_surplus' or key == 'v_reroll_glut' then
        if resets then resets.reroll_cost = (resets.reroll_cost or 0) + extra(key, 2) end
        if calculate_reroll_cost then calculate_reroll_cost(true) end
    end
    for _, group in ipairs(tiers) do
        for _, candidate in ipairs(group.keys) do
            if key == candidate then
                game[group.field] = (game[group.field] or group.base)
                    + tier_value(group, game.used_vouchers) - tier_value(group, before)
            end
        end
    end
    if key == 'v_clearance_sale' or key == 'v_liquidation' then
        for _, card in pairs(G.I and G.I.CARD or {}) do if card.set_cost then card:set_cost() end end
    end
end

HNDS.undo_voucher_effect = undo_voucher
HNDS.voucher_permanently_debuffed = disabled

function HNDS.permanently_debuff_voucher(key)
    local game = G and G.GAME
    if not game or game.hnds_wasted_wish_active or disabled(key) or not game.used_vouchers[key] then return false end
    local center = G.P_CENTERS[key]
    if not center or center.set ~= 'Voucher' then return false end
    local before = {}
    for owned_key, value in pairs(game.used_vouchers) do before[owned_key] = value end
    local voucher
    for _, card in ipairs(G.vouchers and G.vouchers.cards or {}) do
        if card.config.center.key == key then voucher = card; break end
    end
    voucher = voucher or {config = {center = center, center_key = key}, ability = copy_table(center.config or {})}
    game.hnds_debuffed_vouchers = game.hnds_debuffed_vouchers or {}
    game.hnds_debuffed_vouchers[key] = true
    game.used_vouchers[key] = nil
    undo_voucher(key, voucher, before)
    for _, card in ipairs(G.vouchers and G.vouchers.cards or {}) do if card.config.center.key == key then card:set_debuff(true) end end
    if HNDS.refresh_unbought_curse_prices then HNDS.refresh_unbought_curse_prices() end
    if SMODS.enh_cache then SMODS.enh_cache:clear() end
    return true
end

local set_debuff_ref = SMODS.current_mod.set_debuff
SMODS.current_mod.set_debuff = function(card)
    local center = card and card.config and card.config.center
    if center and center.set == 'Voucher' and card.area == G.vouchers
        and (disabled(center.key) or (G.GAME and G.GAME.hnds_wasted_wish_active)) then return true end
    if set_debuff_ref then return set_debuff_ref(card) end
end

local get_pool_ref = get_current_pool
function get_current_pool(object_type, ...)
    local game = G and G.GAME
    if object_type ~= 'Voucher' or not (game and next(game.hnds_debuffed_vouchers or {})) then
        return get_pool_ref(object_type, ...)
    end
    local original, owned = game.used_vouchers, {}
    for key, value in pairs(original or {}) do owned[key] = value end
    for key in pairs(game.hnds_debuffed_vouchers) do owned[key] = true end
    game.used_vouchers = owned
    local results = HNDS.pack(pcall(get_pool_ref, object_type, ...))
    game.used_vouchers = original
    if not results[1] then error(results[2], 0) end
    return unpack_values(results, 2, results.n)
end

local apply_ref = Card.apply_to_run
function Card:apply_to_run(center, ...)
    local key = (center or self.config.center).key
    if disabled(key) then G.GAME.used_vouchers[key] = nil; return end
    return apply_ref(self, center, ...)
end

local load_ref = Card.load
function Card:load(...)
    local results = HNDS.pack(load_ref(self, ...))
    local center = self.config and self.config.center
    if center and center.set == 'Voucher' and disabled(center.key) then self.debuff = true end
    return unpack_values(results, 1, results.n)
end
