local function hnds_is_handicap_placard(card)
    local center = card and card.config and card.config.center
    return center and center.key == 'j_hnds_handicap_placard'
end

local function hnds_joker_index(card)
    for index, joker in ipairs((G and G.jokers and G.jokers.cards) or {}) do
        if joker == card then return index end
    end
end

local function hnds_handicap_count_right(card)
    local cards = G and G.jokers and G.jokers.cards or {}
    local index = hnds_joker_index(card)
    return index and math.max(0, #cards - index) or 0
end

local function hnds_handicap_debuffs(target)
    local target_index = hnds_joker_index(target)
    if not target_index then return false end

    local cards = G.jokers.cards
    for index = 1, target_index - 1 do
        local source = cards[index]
        if hnds_is_handicap_placard(source) and not source.debuff then
            return true
        end
    end
    return false
end

local function hnds_handicap_refresh()
    if not (G and G.jokers and type(G.jokers.cards) == 'table'
        and SMODS and type(SMODS.recalc_debuff) == 'function')
    then
        return true
    end

    for _, joker in ipairs(G.jokers.cards) do
        SMODS.recalc_debuff(joker)
    end
    return true
end

local function hnds_schedule_handicap_refresh()
    if HNDS._handicap_refresh_pending or HNDS._handicap_refresh_running then return end
    HNDS._handicap_refresh_pending = true

    local function refresh()
        HNDS._handicap_refresh_pending = nil
        HNDS._handicap_refresh_running = true
        local result = hnds_handicap_refresh()
        HNDS._handicap_refresh_running = nil
        return result
    end
    if G and G.E_MANAGER and Event then
        G.E_MANAGER:add_event(Event {
            trigger = 'immediate', blockable = false, func = refresh,
        })
    else
        refresh()
    end
end

local function hnds_handicap_signature(card)
    local parts = { card.debuff and '1' or '0' }
    for index, joker in ipairs((G and G.jokers and G.jokers.cards) or {}) do
        parts[index + 1] = tostring(joker and (joker.sort_id or joker.ID) or index)
    end
    return table.concat(parts, '|')
end

local previous_set_debuff = SMODS.current_mod.set_debuff
SMODS.current_mod.set_debuff = function(card)
    if previous_set_debuff then
        local result = previous_set_debuff(card)
        if result == true or result == 'prevent_debuff' then return result end
    end
    if card and G and G.jokers and card.area == G.jokers
        and hnds_handicap_debuffs(card)
    then
        return true
    end
end

SMODS.Joker {
    key = 'handicap_placard',
    atlas = 'Jokers',
    pos = { x = 1, y = 8 },
    rarity = 2,
    cost = 5,
    unlocked = true,
    discovered = false,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    config = { extra = { chips_per_joker = 75, order_signature = '' } },
    loc_vars = function(self, info_queue, card)
        local extra = card and card.ability and card.ability.extra or self.config.extra
        local gain = tonumber(extra.chips_per_joker) or 75
        return { vars = { gain, gain * hnds_handicap_count_right(card) } }
    end,
    add_to_deck = function(self, card, from_debuff)
        hnds_schedule_handicap_refresh()
    end,
    remove_from_deck = function(self, card, from_debuff)
        hnds_schedule_handicap_refresh()
    end,
    update = function(self, card, dt)
        if not (card and card.ability and card.ability.extra
            and G and G.jokers and card.area == G.jokers)
        then
            return
        end
        local signature = hnds_handicap_signature(card)
        if card.ability.extra.order_signature ~= signature then
            card.ability.extra.order_signature = signature
            hnds_schedule_handicap_refresh()
        end
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local chips = (tonumber(card.ability.extra.chips_per_joker) or 75)
                * hnds_handicap_count_right(card)
            if chips > 0 then return { chips = chips } end
        end
    end,
    joker_display_def = function(JokerDisplay)
        return {
            text = {
                { text = '+' },
                { ref_table = 'card.joker_display_values', ref_value = 'chips' },
            },
            text_config = { colour = G.C.CHIPS },
            calc_function = function(card)
                card.joker_display_values.chips =
                    (tonumber(card.ability.extra.chips_per_joker) or 75)
                    * hnds_handicap_count_right(card)
            end,
        }
    end,
    attributes = { 'chips', 'passive', 'joker' },
}
