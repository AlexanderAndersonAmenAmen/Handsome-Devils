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

local function hnds_order_tracked_hands(tracked)
    local ordered = {}
    local added = {}
    if type(tracked) ~= 'table' then return ordered end

    -- First use Balatro's fixed poker-hand hierarchy (strongest to weakest).
    for _, hand_key in ipairs(HNDS_VANILLA_HAND_HIERARCHY) do
        if tracked[hand_key] then
            ordered[#ordered + 1] = hand_key
            added[hand_key] = true
        end
    end

    -- Keep modded hands deterministic too: follow the live hand list after all
    -- vanilla hierarchy entries, then alphabetically append any unknown keys.
    for _, hand_key in ipairs((G and G.handlist) or {}) do
        if tracked[hand_key] and not added[hand_key] then
            ordered[#ordered + 1] = hand_key
            added[hand_key] = true
        end
    end

    local remaining = {}
    for hand_key in pairs(tracked) do
        if not added[hand_key] then remaining[#remaining + 1] = hand_key end
    end
    table.sort(remaining)
    for _, hand_key in ipairs(remaining) do ordered[#ordered + 1] = hand_key end

    return ordered
end

SMODS.Joker {
    key = "jigsaw_joker",
    atlas = "Jokers",
    pos = { x = 8, y = 4 },
    rarity = 1,
    cost = 4,
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
        local tracked = extra and extra.unique_hands
        local ordered_keys = hnds_order_tracked_hands(tracked)

        local required = extra.required_hands or 8
        local progress = math.min(#ordered_keys, required)

        if info_queue and card then
            if progress == 0 then
                info_queue[#info_queue + 1] = {
                    set = "Other",
                    key = "hnds_jigsaw_progress_empty",
                    vars = { "none", 0, required },
                }
            else
                local vars = {}
                for i = 1, progress do
                    vars[#vars + 1] = localize(ordered_keys[i], "poker_hands")
                end
                vars[#vars + 1] = progress
                vars[#vars + 1] = required

                info_queue[#info_queue + 1] = {
                    set = "Other",
                    key = "hnds_jigsaw_progress_" .. tostring(progress),
                    vars = vars,
                }
            end
        end

        return {
            vars = {
                extra.hands_played or progress,
                required,
                extra.upgrade_levels or 2,
            }
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
