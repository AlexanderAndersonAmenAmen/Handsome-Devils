local RANK_ORDER = {
    { id = 2, key = '2' },
    { id = 3, key = '3' },
    { id = 4, key = '4' },
    { id = 5, key = '5' },
    { id = 6, key = '6' },
    { id = 7, key = '7' },
    { id = 8, key = '8' },
    { id = 9, key = '9' },
    { id = 10, key = '10' },
    { id = 11, key = 'Jack' },
    { id = 12, key = 'Queen' },
    { id = 13, key = 'King' },
    { id = 14, key = 'Ace' },
}

local RANK_KEY_BY_ID = {}
for _, rank in ipairs(RANK_ORDER) do RANK_KEY_BY_ID[rank.id] = rank.key end

local function jodiac_extra(card, center)
    local extra = card and card.ability and card.ability.extra
    if type(extra) ~= 'table' then
        extra = (center and center.config and center.config.extra) or {}
    end
    return extra
end

local function ordered_scored_ranks(extra)
    local scored = type(extra.scored_ranks) == 'table' and extra.scored_ranks or {}
    local out = {}
    for _, rank in ipairs(RANK_ORDER) do
        if scored[rank.id] or scored[tostring(rank.id)] then
            out[#out + 1] = rank
        end
    end
    return out
end

local function reset_ranks(extra)
    extra.scored_ranks = {}
end

SMODS.Joker {
    key = 'jodiac',
    atlas = 'Jokers',
    pos = { x = 5, y = 6 },
    rarity = 1,
    cost = 6,
    unlocked = false,
    discovered = false,
    unlock_condition = { type = "hnds_joker_unlock", key = "jodiac" },
    locked_loc_vars = function(self)
        return HNDS.joker_locked_loc_vars("jodiac")
    end,
    check_for_unlock = function(self, args)
        return HNDS.joker_unlock_condition_met("jodiac", args)
    end,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = false,

    config = {
        extra = {
            mult = 0,
            mult_gain = 1,
            scored_ranks = {},
        },
    },

    loc_vars = function(self, info_queue, card)
        local extra = jodiac_extra(card, self)
        local ranks = ordered_scored_ranks(extra)

        if info_queue and card then
            if #ranks == 0 then
                info_queue[#info_queue + 1] = {
                    set = 'Other',
                    key = 'hnds_jodiac_ranks_empty',
                    vars = {},
                }
            else
                local vars = {}
                for _, rank in ipairs(ranks) do
                    vars[#vars + 1] = localize(rank.key, 'ranks')
                end
                info_queue[#info_queue + 1] = {
                    set = 'Other',
                    key = 'hnds_jodiac_ranks_' .. tostring(#ranks),
                    vars = vars,
                }
            end
        end

        return {
            vars = {
                tonumber(extra.mult_gain) or 1,
                tonumber(extra.mult) or 0,
            },
        }
    end,

    calculate = function(self, card, context)
        local extra = jodiac_extra(card, self)

        if context.individual and context.cardarea == G.play
            and context.other_card and not context.other_card.debuff
            and not context.repetition_only
            and not context.blueprint
        then
            local rank_id = context.other_card:get_id()
            if RANK_KEY_BY_ID[rank_id] then
                extra.scored_ranks = extra.scored_ranks or {}
                if not extra.scored_ranks[rank_id] then
                    extra.scored_ranks[rank_id] = true
                    extra.mult = (tonumber(extra.mult) or 0) + (tonumber(extra.mult_gain) or 1)

                    -- Return the feedback through the normal individual-card
                    -- scoring pipeline. `message_card` anchors the popup/juice to
                    -- Jodiac instead of the playing card, while keeping Balatro's
                    -- native timing: after this eligible card reaches its scoring
                    -- step and before the Joker main-scoring phase begins.
                    return {
                        message = localize('k_upgrade_ex'),
                        colour = G.C.MULT,
                        message_card = card,
                    }
                end
            end
        end

        if context.joker_main and (tonumber(extra.mult) or 0) > 0 then
            return { mult = tonumber(extra.mult) or 0 }
        end

        if context.end_of_round and context.main_eval
            and not context.game_over
            and not context.blueprint
            and not context.retrigger_joker
        then
            local real_boss = HNDS and HNDS.active_blind_is_real_ante_boss
                and HNDS.active_blind_is_real_ante_boss()
            if real_boss then
                reset_ranks(extra)
                return { message = 'Ranks reset!', colour = G.C.FILTER }
            end
        end
    end,

    joker_display_def = function(JokerDisplay)
        return {
            text = {
                { text = '+' },
                { ref_table = 'card.joker_display_values', ref_value = 'mult' },
            },
            text_config = { colour = G.C.MULT },
            calc_function = function(card)
                local extra = card.ability and card.ability.extra or {}
                card.joker_display_values.mult = tonumber(extra.mult) or 0
            end,
        }
    end,

    attributes = { 'mult', 'scaling', 'rank' },
}
