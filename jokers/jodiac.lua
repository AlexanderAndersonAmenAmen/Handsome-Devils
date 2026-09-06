local HNDS_VANILLA_HAND_HIERARCHY = {
    'Flush Five', 'Flush House', 'Five of a Kind', 'Straight Flush',
    'Four of a Kind', 'Full House', 'Flush', 'Straight',
    'Three of a Kind', 'Two Pair', 'Pair', 'High Card',
}

local function hnds_all_hand_keys()
    local ordered, added = {}, {}
    local hands = G and G.GAME and G.GAME.hands

    local function add(hand_key)
        if type(hand_key) ~= 'string' or added[hand_key] then return end
        if hands and not hands[hand_key] then return end
        ordered[#ordered + 1] = hand_key
        added[hand_key] = true
    end

    for _, hand_key in ipairs(HNDS_VANILLA_HAND_HIERARCHY) do add(hand_key) end
    for _, hand_key in ipairs((G and G.handlist) or {}) do add(hand_key) end

    if hands then
        local remaining = {}
        for hand_key, hand_data in pairs(hands) do
            if not added[hand_key] then
                remaining[#remaining + 1] = {
                    key = hand_key,
                    order = tonumber(hand_data and hand_data.order) or math.huge,
                }
            end
        end
        table.sort(remaining, function(a, b)
            if a.order == b.order then return a.key < b.key end
            return a.order < b.order
        end)
        for _, entry in ipairs(remaining) do add(entry.key) end
    end

    return ordered
end

local function hnds_jodiac_should_show_hand(hand_key, tracked)
    local hand_data = G and G.GAME and G.GAME.hands and G.GAME.hands[hand_key]
    if hand_data then
        if hand_data.visible == false then
            return (tonumber(hand_data.played) or 0) > 0
                or (type(tracked) == 'table' and tracked[hand_key] == true)
        end
        return true
    end

    if SMODS and type(SMODS.is_poker_hand_visible) == 'function' then
        local ok, visible = pcall(SMODS.is_poker_hand_visible, hand_key)
        if ok then
            return visible == true
                or (type(tracked) == 'table' and tracked[hand_key] == true)
        end
    end

    if hand_key == 'Flush Five' or hand_key == 'Flush House' or hand_key == 'Five of a Kind' then
        return type(tracked) == 'table' and tracked[hand_key] == true
    end
    return true
end

local function hnds_jodiac_queue_checklist(info_queue, tracked)
    if not info_queue or not G or not G.localization then return end
    local descriptions = G.localization.descriptions
    local other = descriptions and descriptions.Other
    local entry = other and other.hnds_jodiac_checklist
    if type(entry) ~= 'table' then return end

    local lines, parsed_lines = {}, {}
    for _, hand_key in ipairs(hnds_all_hand_keys()) do
        if hnds_jodiac_should_show_hand(hand_key, tracked) then
            local hand_name = localize(hand_key, 'poker_hands') or hand_key
            local colour = tracked and tracked[hand_key] and 'attention' or 'inactive'
            lines[#lines + 1] = '{C:' .. colour .. '}' .. hand_name .. '{}'
            parsed_lines[#parsed_lines + 1] = {
                { strings = { hand_name }, control = { C = colour } },
            }
        end
    end
    entry.text = lines
    entry.text_parsed = parsed_lines
    info_queue[#info_queue + 1] = { key = 'hnds_jodiac_checklist', set = 'Other', vars = {} }
end

SMODS.Joker {
    key = 'jodiac',
    prefix_config = { key = { mod = false } },
    atlas = 'Jokers',
    pos = { x = 5, y = 6 },
    rarity = 2,
    cost = 6,
    unlocked = false,
    discovered = false,
    unlock_condition = { type = 'hnds_joker_unlock', key = 'jodiac' },
    locked_loc_vars = function(self) return HNDS.joker_locked_loc_vars('jodiac') end,
    check_for_unlock = function(self, args) return HNDS.joker_unlock_condition_met('jodiac', args) end,
    blueprint_compat = true,
    eternal_compat = false,
    perishable_compat = false,
    config = {
        extra = {
            hands_played = 0,
            required_hands = 8,
            upgrade_levels = 2,
            unique_hands = {},
        },
    },
    loc_vars = function(self, info_queue, card)
        local extra = card and card.ability and card.ability.extra or self.config.extra
        extra.unique_hands = extra.unique_hands or {}
        local tracked_count = 0
        for _ in pairs(extra.unique_hands) do tracked_count = tracked_count + 1 end
        local required = tonumber(extra.required_hands) or 8
        local progress = math.min(tracked_count, required)

        local in_collection = card and card.area and card.area.config and card.area.config.collection
        if info_queue and card and not in_collection then
            hnds_jodiac_queue_checklist(info_queue, extra.unique_hands)
        end
        return { vars = { tonumber(extra.hands_played) or progress, required, tonumber(extra.upgrade_levels) or 2 } }
    end,
    calculate = function(self, card, context)
        local extra = card.ability.extra
        if context.joker_main and not context.repetition and not context.blueprint then
            local hand_type = context.scoring_name
            if hand_type then
                extra.unique_hands = extra.unique_hands or {}
                if not extra.unique_hands[hand_type] then
                    extra.unique_hands[hand_type] = true
                    extra.hands_played = math.min(
                        tonumber(extra.required_hands) or 8,
                        (tonumber(extra.hands_played) or 0) + 1
                    )
                    if extra.hands_played >= (tonumber(extra.required_hands) or 8) then
                        extra.complete = true
                        juice_card_until(card, function(c) return not c.REMOVED end, true)
                        return { message = 'Complete!', colour = G.C.RED }
                    end
                    return {
                        message = extra.hands_played .. '/' .. (tonumber(extra.required_hands) or 8),
                        colour = G.C.BLUE,
                    }
                end
            end
        end

        local selling_this = context.selling_self or (context.selling_card and context.card == card)
        if selling_this and extra.complete and not extra.reward_given and not context.blueprint then
            extra.reward_given = true
            local levels = tonumber(extra.upgrade_levels) or 2
            for _, hand in ipairs(hnds_all_hand_keys()) do
                local hand_data = G.GAME and G.GAME.hands and G.GAME.hands[hand]
                if hand_data and (tonumber(hand_data.level) or 0) > 0 then
                    SMODS.smart_level_up_hand(card, hand, true, levels)
                end
            end
            return { message = localize('k_upgrade_ex'), colour = G.C.CHIPS }
        end
    end,
    joker_display_def = function(JokerDisplay)
        return {
            reminder_text = {
                { text = '(' },
                { ref_table = 'card.joker_display_values', ref_value = 'played' },
                { text = '/' },
                { ref_table = 'card.joker_display_values', ref_value = 'req' },
                { text = ')' },
            },
            calc_function = function(card)
                card.joker_display_values.played = tonumber(card.ability.extra.hands_played) or 0
                card.joker_display_values.req = tonumber(card.ability.extra.required_hands) or 8
            end,
        }
    end,
    attributes = { 'level_up' },
}
