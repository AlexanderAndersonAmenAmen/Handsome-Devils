HNDS = HNDS or {}

local BIG_D_CENTER_KEY = 'j_hnds_big_d'
local STOLEN_SELL_FIELD = 'hnds_big_d_stolen_sell_value'
local BIG_D_NAME_KEYS = {
    'default',
    'legion',
    'old_nick',
    'deceiver',
    'tempter',
    'adversary',
    'prince_of_darkness',
    'belial',
    'apollyon',
    'lucifer',
    'abaddon',
    'leviathan',
}
local BIG_D_NAME_SET = {}
for _, key in ipairs(BIG_D_NAME_KEYS) do BIG_D_NAME_SET[key] = true end

local BIG_D_TOOLTIP_ORDER = {
    'e_foil',
    'e_holo',
    'e_polychrome',
    'e_negative',
    'e_hnds_vintage',
}
local BIG_D_TOOLTIP_KEYS = {
    e_foil = 'e_hnds_big_d_foil',
    e_holo = 'e_hnds_big_d_holo',
    e_polychrome = 'e_hnds_big_d_polychrome',
    e_negative = 'e_hnds_big_d_negative',
    e_hnds_vintage = 'e_hnds_big_d_vintage',
}

local function big_d_is_card(card)
    local config = card and card.config
    return config and (config.center_key == BIG_D_CENTER_KEY
        or (config.center and config.center.key == BIG_D_CENTER_KEY))
end

local function big_d_pack(...)
    return { n = select('#', ...), ... }
end

local function big_d_copy(value, seen)
    if type(value) ~= 'table' then return value end
    seen = seen or {}
    if seen[value] then return seen[value] end
    local out = {}
    seen[value] = out
    for key, entry in pairs(value) do
        out[big_d_copy(key, seen)] = big_d_copy(entry, seen)
    end
    return out
end

local function big_d_edition_key(edition)
    if type(edition) ~= 'table' then return nil end
    if type(edition.key) == 'string' and edition.key ~= '' then return edition.key end
    if type(edition.type) == 'string' and edition.type ~= '' then
        return edition.type:sub(1, 2) == 'e_' and edition.type or ('e_' .. edition.type)
    end
    for key, value in pairs(edition) do
        if value == true and type(key) == 'string' then
            return key:sub(1, 2) == 'e_' and key or ('e_' .. key)
        end
    end
end

local function big_d_config_number(config, key, allow_numeric_extra)
    if type(config) ~= 'table' then return nil end
    if tonumber(config[key]) then return tonumber(config[key]) end
    local extra = config.extra
    if type(extra) == 'table' and tonumber(extra[key]) then return tonumber(extra[key]) end
    if allow_numeric_extra and tonumber(extra) then return tonumber(extra) end
end

local function big_d_edition_effects(edition, key)
    local center = key and G and G.P_CENTERS and G.P_CENTERS[key]
    local config = center and center.config or {}
    local effects = {
        chips = tonumber(edition and edition.chips) or big_d_config_number(config, 'chips', key == 'e_foil') or 0,
        mult = tonumber(edition and edition.mult) or big_d_config_number(config, 'mult', key == 'e_holo') or 0,
        x_mult = tonumber(edition and (edition.x_mult or edition.xmult))
            or big_d_config_number(config, 'x_mult', key == 'e_polychrome')
            or big_d_config_number(config, 'xmult', false)
            or 0,
        card_limit = tonumber(edition and edition.card_limit)
            or big_d_config_number(config, 'card_limit', false)
            or 0,
        vintage_gain = key == 'e_hnds_vintage' and 2 or 0,
    }

    if key == 'e_foil' and effects.chips == 0 then effects.chips = 50 end
    if key == 'e_holo' and effects.mult == 0 then effects.mult = 10 end
    if key == 'e_polychrome' and effects.x_mult == 0 then effects.x_mult = 1.5 end
    if key == 'e_negative' and effects.card_limit == 0 then effects.card_limit = 1 end
    return effects
end

local function big_d_extra(card)
    if not card then return nil end
    card.ability = card.ability or {}
    if type(card.ability.extra) ~= 'table' then card.ability.extra = {} end
    local extra = card.ability.extra
    if type(extra.edition_stacks) ~= 'table' then extra.edition_stacks = {} end
    return extra
end

local function big_d_record(extra, key)
    local record = extra.edition_stacks[key]
    if type(record) == 'number' then record = { count = record } end
    if type(record) ~= 'table' then record = {} end
    record.count = math.max(0, tonumber(record.count) or 0)
    record.chips = tonumber(record.chips) or 0
    record.mult = tonumber(record.mult) or 0
    record.x_mult = tonumber(record.x_mult) or 0
    record.card_limit = tonumber(record.card_limit) or 0
    record.vintage_gain = tonumber(record.vintage_gain) or 0
    extra.edition_stacks[key] = record
    return record
end

local function big_d_add_edition(card, edition)
    local key = big_d_edition_key(edition)
    local extra = big_d_extra(card)
    if not (key and extra) then return nil end
    local effects = big_d_edition_effects(edition, key)
    local record = big_d_record(extra, key)
    record.count = record.count + 1
    record.chips = record.chips + effects.chips
    record.mult = record.mult + effects.mult
    record.x_mult = record.x_mult + effects.x_mult
    record.card_limit = record.card_limit + effects.card_limit
    record.vintage_gain = record.vintage_gain + effects.vintage_gain
    return key
end

local function big_d_totals(card)
    local extra = big_d_extra(card)
    local totals = { chips = 0, mult = 0, x_mult = 0, card_limit = 0, vintage_gain = 0 }
    if not extra then return totals end
    for key in pairs(extra.edition_stacks) do
        local record = big_d_record(extra, key)
        totals.chips = totals.chips + record.chips
        totals.mult = totals.mult + record.mult
        totals.x_mult = totals.x_mult + record.x_mult
        totals.card_limit = totals.card_limit + record.card_limit
        totals.vintage_gain = totals.vintage_gain + record.vintage_gain
    end
    return totals
end

local function big_d_is_collection_card(card)
    return card and card.area and card.area.config and card.area.config.collection == true
end

local function big_d_ensure_name(card)
    if not card or big_d_is_collection_card(card) then return nil end
    local extra = big_d_extra(card)
    if BIG_D_NAME_SET[extra.name_key] then return extra.name_key end

    local serial = 1
    if G and G.GAME then
        G.GAME.hnds_big_d_name_serial = (tonumber(G.GAME.hnds_big_d_name_serial) or 0) + 1
        serial = G.GAME.hnds_big_d_name_serial
    end
    local seed = table.concat({
        'hnds_big_d_name',
        tostring(G and G.GAME and G.GAME.round_resets and G.GAME.round_resets.ante or 0),
        tostring(serial),
        tostring(card.ID or card.sort_id or 0),
    }, '_')
    if pseudorandom_element and pseudoseed and G and G.GAME then
        extra.name_key = pseudorandom_element(BIG_D_NAME_KEYS, pseudoseed(seed))
    else
        extra.name_key = BIG_D_NAME_KEYS[math.random(#BIG_D_NAME_KEYS)]
    end
    extra.name_key = extra.name_key or 'default'
    return extra.name_key
end

local function big_d_localization_key(card)
    if not card or big_d_is_collection_card(card) then return BIG_D_CENTER_KEY end
    local name_key = big_d_ensure_name(card)
    return name_key and (BIG_D_CENTER_KEY .. '_' .. name_key) or BIG_D_CENTER_KEY
end

local function big_d_adopt_visual_edition(card)
    local extra = big_d_extra(card)
    if not extra then return end
    local key = big_d_edition_key(card.edition)
    if not key then
        extra.visual_edition_key = false
        return
    end
    local record = extra.edition_stacks[key]
    if extra.visual_edition_key ~= key or type(record) ~= 'table'
        or (tonumber(record.count) or 0) <= 0
    then
        big_d_add_edition(card, card.edition)
    end
    extra.visual_edition_key = key
end

local function big_d_queue_edition_tooltips(info_queue, card)
    if not (info_queue and big_d_is_card(card)) then return end
    big_d_adopt_visual_edition(card)
    local extra = big_d_extra(card)
    if not extra then return end

    for _, edition_key in ipairs(BIG_D_TOOLTIP_ORDER) do
        local record = extra.edition_stacks[edition_key]
        local count = type(record) == 'table' and math.max(0, tonumber(record.count) or 0) or 0
        if count > 0 then
            local value = 0
            if edition_key == 'e_foil' then
                value = tonumber(record.chips) or 0
            elseif edition_key == 'e_holo' then
                value = tonumber(record.mult) or 0
            elseif edition_key == 'e_polychrome' then
                value = tonumber(record.x_mult) or 0
            elseif edition_key == 'e_negative' then
                value = tonumber(record.card_limit) or 0
            elseif edition_key == 'e_hnds_vintage' then
                value = tonumber(record.vintage_gain) or 0
            end
            info_queue[#info_queue + 1] = {
                set = 'Edition',
                key = BIG_D_TOOLTIP_KEYS[edition_key],
                config = {},
                vars = { count, value },
            }
        end
    end
end

function HNDS.big_d_uses_stacked_tooltips(card)
    if not big_d_is_card(card) then return false end
    big_d_adopt_visual_edition(card)
    local extra = big_d_extra(card)
    if not extra then return false end
    for _, record in pairs(extra.edition_stacks) do
        if type(record) == 'table' and (tonumber(record.count) or 0) > 0 then
            return true
        end
    end
    return false
end

function HNDS.big_d_filter_stacked_tooltips(info_queue, card)
    if not (info_queue and HNDS.big_d_uses_stacked_tooltips(card)) then return end
    local extra = big_d_extra(card)
    for index = #info_queue, 1, -1 do
        local tooltip = info_queue[index]
        local key = type(tooltip) == 'table' and tooltip.key or nil
        if key and tooltip.set == 'Edition' and extra.edition_stacks[key] then
            table.remove(info_queue, index)
        end
    end
end

local function big_d_sync_negative_slots(card, reset_applied)
    if not (G and G.jokers and G.jokers.config
        and tonumber(G.jokers.config.card_limit))
    then
        return
    end
    if reset_applied then card.hnds_big_d_applied_negative_slots = 0 end

    local totals = big_d_totals(card)
    local physical = big_d_edition_effects(card and card.edition, big_d_edition_key(card and card.edition))
    local desired = math.max(0, math.floor(totals.card_limit - physical.card_limit + 0.00001))
    local applied = math.max(0, tonumber(card.hnds_big_d_applied_negative_slots) or 0)
    if desired ~= applied then
        G.jokers.config.card_limit = G.jokers.config.card_limit + desired - applied
        card.hnds_big_d_applied_negative_slots = desired
    end
end

local function big_d_remove_manual_slots(card)
    local applied = math.max(0, tonumber(card and card.hnds_big_d_applied_negative_slots) or 0)
    if applied > 0 and G and G.jokers and G.jokers.config
        and tonumber(G.jokers.config.card_limit)
    then
        G.jokers.config.card_limit = G.jokers.config.card_limit - applied
    end
    if card then card.hnds_big_d_applied_negative_slots = 0 end
end

local function big_d_right_joker(card)
    local jokers = G and G.jokers and G.jokers.cards
    if type(jokers) ~= 'table' then return nil end
    for index, joker in ipairs(jokers) do
        if joker == card then return jokers[index + 1] end
    end
end

local function big_d_zero_sell_value(target)
    if not target then return end
    if type(target.set_cost) == 'function' then target:set_cost() end
    target.sell_cost = 0
    target.sell_cost_label = 0
end

local function big_d_steal(card, target)
    if not (card and target and target ~= card and not target.removed and not target.REMOVED) then
        return false
    end

    big_d_adopt_visual_edition(card)
    local stolen_value = math.max(0, tonumber(target.sell_cost) or 0)
    local stolen_edition = big_d_copy(target.edition)
    local stolen_edition_key = big_d_edition_key(stolen_edition)
    local previous_stolen = math.max(0,
        tonumber(target.ability and target.ability[STOLEN_SELL_FIELD]) or 0)

    target.ability = target.ability or {}
    if stolen_edition_key then
        if type(target.set_edition) == 'function' then
            target:set_edition(nil, true, true)
        else
            target.edition = nil
        end
    end
    if type(target.set_cost) == 'function' then target:set_cost() end
    local remaining_sell_value = math.max(0, tonumber(target.sell_cost) or 0)
    target.ability[STOLEN_SELL_FIELD] = previous_stolen + remaining_sell_value
    big_d_zero_sell_value(target)

    if stolen_value > 0 then
        card.ability.extra_value = (tonumber(card.ability.extra_value) or 0) + stolen_value
    end
    if stolen_edition_key then
        big_d_add_edition(card, stolen_edition)
        if type(card.set_edition) == 'function' then
            card:set_edition(big_d_copy(stolen_edition), true, true)
        else
            card.edition = big_d_copy(stolen_edition)
        end
        big_d_extra(card).visual_edition_key = stolen_edition_key
    end
    if type(card.set_cost) == 'function' then card:set_cost() end
    big_d_sync_negative_slots(card, false)
    return true, stolen_value, stolen_edition_key
end

local function big_d_calculate_stacked_edition(card, context)
    context = context or {}
    big_d_adopt_visual_edition(card)
    big_d_sync_negative_slots(card, false)
    local totals = big_d_totals(card)

    if context.pre_joker and (totals.chips ~= 0 or totals.mult ~= 0) then
        local result = { card = card }
        if totals.chips ~= 0 then result.chips = totals.chips end
        if totals.mult ~= 0 then result.mult = totals.mult end
        return true, result
    end

    if context.post_joker and totals.x_mult > 0 then
        return true, { x_mult = totals.x_mult, card = card }
    end

    local visual_key = big_d_edition_key(card and card.edition)
    if visual_key == 'e_hnds_vintage' and context.end_of_round and context.main_eval
        and G and context.cardarea == G.jokers
    then
        -- Big D awards the combined Vintage amount in its Joker calculation.
        return true, nil
    end

    return false, nil
end

function HNDS.install_big_d_hooks()
    if not Card then return end

    if type(Card.set_cost) == 'function' and not Card._hnds_big_d_cost_wrapped then
        Card._hnds_big_d_cost_wrapped = true
        local set_cost_ref = Card.set_cost
        function Card:set_cost(...)
            local result = big_d_pack(set_cost_ref(self, ...))
            local stolen = math.max(0, tonumber(self and self.ability and self.ability[STOLEN_SELL_FIELD]) or 0)
            local puzzle_piece = HNDS.is_sarmenti_piece and HNDS.is_sarmenti_piece(self)
            if stolen > 0 and not puzzle_piece then
                self.sell_cost = math.max(0, (tonumber(self.sell_cost) or 0) - stolen)
                if self.sell_cost_label ~= '?' then self.sell_cost_label = self.sell_cost end
            end
            return ((table and table.unpack) or unpack)(result, 1, result.n)
        end
    end

    if type(Card.calculate_edition) == 'function' and not Card._hnds_big_d_edition_wrapped then
        Card._hnds_big_d_edition_wrapped = true
        local calculate_edition_ref = Card.calculate_edition
        function Card:calculate_edition(context)
            if big_d_is_card(self) then
                local handled, result = big_d_calculate_stacked_edition(self, context)
                if handled then return result end
            end
            return calculate_edition_ref(self, context)
        end
    end
end

SMODS.Joker {
    key = 'big_d',
    atlas = 'Jokers',
    pos = { x = 4, y = 8 },
    rarity = 3,
    cost = 9,
    unlocked = true,
    discovered = false,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    config = {
        extra = {
            name_key = false,
            visual_edition_key = false,
            edition_stacks = {},
        },
    },

    loc_vars = function(self, info_queue, card)
        big_d_queue_edition_tooltips(info_queue, card)
        return { key = big_d_localization_key(card), vars = {} }
    end,

    load = function(self, card, card_table, other_card)
        local extra = big_d_extra(card)
        if extra and not BIG_D_NAME_SET[extra.name_key] then extra.name_key = false end
    end,

    add_to_deck = function(self, card, from_debuff)
        big_d_ensure_name(card)
        if from_debuff then return end
        big_d_adopt_visual_edition(card)
        big_d_sync_negative_slots(card, true)
    end,

    remove_from_deck = function(self, card, from_debuff)
        if not from_debuff then big_d_remove_manual_slots(card) end
    end,

    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            big_d_ensure_name(card)
            local target = big_d_right_joker(card)
            local stolen, _, edition_key = big_d_steal(card, target)
            if stolen then
                return {
                    message = localize('k_hnds_big_d_stolen'),
                    colour = edition_key and G.C.DARK_EDITION or G.C.MONEY,
                    card = card,
                }
            end
            return
        end

        if context.end_of_round and context.main_eval and context.cardarea == G.jokers
            and not context.blueprint
        then
            big_d_adopt_visual_edition(card)
            local totals = big_d_totals(card)
            if totals.vintage_gain > 0 then
                card.ability.extra_value = (tonumber(card.ability.extra_value) or 0) + totals.vintage_gain
                if type(card.set_cost) == 'function' then card:set_cost() end
                return { message = localize('k_val_up'), colour = G.C.MONEY, card = card }
            end
        end
    end,

    attributes = { 'economy', 'edition', 'scaling', 'modify_joker' },
}
