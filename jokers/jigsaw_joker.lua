local HNDS_VANILLA_HAND_HIERARCHY = {
    'Flush Five',
    'Flush House',
    'Five of a Kind',
    'Straight Flush',
    'Four of a Kind',
    'Full House',
    'Flush',
    'Straight',
    'Three of a Kind',
    'Two Pair',
    'Pair',
    'High Card',
}

local function hnds_all_hand_keys()
    local ordered = {}
    local added = {}
    local hands = G and G.GAME and G.GAME.hands

    local function add(hand_key)
        if type(hand_key) ~= 'string' or added[hand_key] then return end
        -- When a run exists, only list real poker hands present in that run.
        if hands and not hands[hand_key] then return end
        ordered[#ordered + 1] = hand_key
        added[hand_key] = true
    end

    -- Preserve Balatro's normal strongest-to-weakest hierarchy first.
    for _, hand_key in ipairs(HNDS_VANILLA_HAND_HIERARCHY) do
        add(hand_key)
    end

    -- Then include custom hands in Steamodded's live ordering.
    for _, hand_key in ipairs((G and G.handlist) or {}) do
        add(hand_key)
    end

    -- Compatibility fallback for custom hands missing from G.handlist.
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

local function hnds_jigsaw_should_show_hand(hand_key, tracked)
    local hand_data = G and G.GAME and G.GAME.hands and G.GAME.hands[hand_key]
    if hand_data then
        -- Secret poker hands are hidden until they have actually been played in
        -- this run. `played` is run-scoped, so a secret discovered in an older
        -- run does not leak into this checklist.
        if hand_data.visible == false then
            return (tonumber(hand_data.played) or 0) > 0
                or (type(tracked) == 'table' and tracked[hand_key] == true)
        end
        return true
    end

    -- Collection/title-screen fallback where the live run hand table may not
    -- exist. Ask Steamodded for the hand's current visibility if possible.
    if SMODS and type(SMODS.is_poker_hand_visible) == 'function' then
        local ok, visible = pcall(SMODS.is_poker_hand_visible, hand_key)
        if ok then
            return visible == true
                or (type(tracked) == 'table' and tracked[hand_key] == true)
        end
    end

    -- Vanilla secret hands are the only hidden hands we can identify safely
    -- without a live run/Steamodded visibility result.
    if hand_key == 'Flush Five'
        or hand_key == 'Flush House'
        or hand_key == 'Five of a Kind'
    then
        return type(tracked) == 'table' and tracked[hand_key] == true
    end

    return true
end

local function hnds_jigsaw_checklist_text(tracked)
    local lines = {}
    local parsed_lines = {}

    for _, hand_key in ipairs(hnds_all_hand_keys()) do
        if hnds_jigsaw_should_show_hand(hand_key, tracked) then
            local hand_name = localize(hand_key, 'poker_hands') or hand_key
            local completed = type(tracked) == 'table' and tracked[hand_key] == true
            local colour = completed and 'attention' or 'inactive'

            -- Keep both the raw localization text and the already-parsed form
            -- in sync. Localization is initialized before a run begins, so
            -- replacing this entry at hover time leaves text_parsed nil and
            -- crashes localize(type = 'other'). Building the parsed line here
            -- lets the normal info_queue renderer remain fully dynamic.
            lines[#lines + 1] = '{C:' .. colour .. '}' .. hand_name .. '{}'
            parsed_lines[#parsed_lines + 1] = {
                { strings = { hand_name }, control = { C = colour } },
            }
        end
    end

    return lines, parsed_lines
end

local function hnds_jigsaw_queue_checklist(info_queue, tracked)
    if not info_queue or not G or not G.localization then return end

    local descriptions = G.localization.descriptions
    local other = descriptions and descriptions.Other
    local entry = other and other.hnds_jigsaw_checklist
    if type(entry) ~= 'table' then return end

    local lines, parsed_lines = hnds_jigsaw_checklist_text(tracked)
    entry.text = lines
    entry.text_parsed = parsed_lines

    -- Use Balatro's normal auxiliary-tooltip path. The localization object
    -- itself stays intact (including its parsed name), so this works with
    -- 1.0.1o/Steamodded BETA-1620a instead of creating a transient broken
    -- localization entry.
    info_queue[#info_queue + 1] = {
        key = 'hnds_jigsaw_checklist',
        set = 'Other',
        vars = {},
    }
end

SMODS.Joker {
    key = "jigsaw_joker",
    atlas = "Jokers",
    pos = { x = 8, y = 4 },
    rarity = 2,
    cost = 5,
    unlocked = false,
    discovered = false,
    unlock_condition = { type = "hnds_joker_unlock", key = "jigsaw_joker" },
    locked_loc_vars = function(self)
        return HNDS.joker_locked_loc_vars("jigsaw_joker")
    end,
    check_for_unlock = function(self, args)
        return HNDS.joker_unlock_condition_met("jigsaw_joker", args)
    end,
    blueprint_compat = true,
    eternal_compat = false,
    perishable_compat = false,
    config = {
        extra = {
            hands_played = 0,
            required_hands = 8,
            upgrade_levels = 2,
            unique_hands = {},
        }
    },
    loc_vars = function(self, info_queue, card)
        local extra = card and card.ability and card.ability.extra or self.config.extra
        extra.unique_hands = extra.unique_hands or {}

        local tracked_count = 0
        for _ in pairs(extra.unique_hands) do tracked_count = tracked_count + 1 end
        local required = extra.required_hands or 8
        local progress = math.min(tracked_count, required)

        -- Keep the poker-hand checklist in its own tooltip. Collection cards
        -- intentionally show only Jigsaw's normal description, with no list.
        local in_collection = card and card.area and card.area.config
            and card.area.config.collection
        if info_queue and card and not in_collection then
            hnds_jigsaw_queue_checklist(info_queue, extra.unique_hands)
        end

        return {
            vars = {
                extra.hands_played or progress,
                required,
                extra.upgrade_levels or 2,
            },
        }
    end,
    calculate = function(self, card, context)
        local extra = card.ability.extra

        -- Count each poker hand only once for this copy of Jigsaw.
        if context.joker_main and not context.repetition and not context.blueprint then
            local hand_type = context.scoring_name
            if hand_type then
                extra.unique_hands = extra.unique_hands or {}
                if not extra.unique_hands[hand_type] then
                    extra.unique_hands[hand_type] = true
                    extra.hands_played = math.min(
                        extra.required_hands,
                        (extra.hands_played or 0) + 1
                    )

                    if extra.hands_played >= extra.required_hands then
                        extra.complete = true
                        local eval = function(c) return not c.REMOVED end
                        juice_card_until(card, eval, true)
                        return { message = "Complete!", colour = G.C.RED }
                    end

                    return {
                        message = extra.hands_played .. "/" .. extra.required_hands,
                        colour = G.C.BLUE,
                    }
                end
            end
        end

        -- The reward belongs specifically to selling this Jigsaw, not selling
        -- some other card while a completed Jigsaw is present.
        local selling_this = context.selling_self
            or (context.selling_card and context.card == card)

        if selling_this
            and extra.complete
            and not extra.reward_given
            and not context.blueprint
        then
            extra.reward_given = true
            local levels = extra.upgrade_levels or 2

            for _, hand in ipairs(G.handlist or {}) do
                local hand_data = G.GAME and G.GAME.hands and G.GAME.hands[hand]
                if hand_data and hand_data.level and hand_data.level > 0 then
                    SMODS.smart_level_up_hand(card, hand, true, levels)
                end
            end

            return {
                message = localize('k_upgrade_ex'),
                colour = G.C.CHIPS,
            }
        end
    end,
    joker_display_def = function(JokerDisplay)
        return {
            reminder_text = {
                { text = "(" },
                { ref_table = "card.joker_display_values", ref_value = "played" },
                { text = "/" },
                { ref_table = "card.joker_display_values", ref_value = "req" },
                { text = ")" }
            },
            calc_function = function(card)
                card.joker_display_values.played = card.ability.extra.hands_played or 0
                card.joker_display_values.req = card.ability.extra.required_hands or 8
            end
        }
    end,
    attributes = { "level_up" }
}
