local function hnds_fun_pilled_index(owner)
    for index, joker in ipairs((G and G.jokers and G.jokers.cards) or {}) do
        if joker == owner then return index end
    end
end

local function hnds_fun_pilled_adjacent(owner)
    local cards = G and G.jokers and G.jokers.cards or {}
    local index = hnds_fun_pilled_index(owner)
    if not index then return {} end

    local targets = {}
    if cards[index - 1] then targets[#targets + 1] = cards[index - 1] end
    if cards[index + 1] then targets[#targets + 1] = cards[index + 1] end
    return targets
end

local function hnds_fun_pilled_extra(card, fallback)
    fallback = fallback or { rounds = 0, required = 2 }
    if not card then return fallback end
    card.ability = card.ability or {}
    card.ability.extra = type(card.ability.extra) == 'table' and card.ability.extra or {}
    local extra = card.ability.extra
    extra.rounds = math.max(0, tonumber(extra.rounds) or tonumber(fallback.rounds) or 0)
    extra.required = math.max(1, tonumber(extra.required) or tonumber(fallback.required) or 2)
    return extra
end

local function hnds_fun_pilled_start_ready_jiggle(card)
    if not card or card.hnds_fun_pilled_ready_jiggle then return end
    local extra = hnds_fun_pilled_extra(card)
    if (tonumber(extra.rounds) or 0) < (tonumber(extra.required) or 2) then return end

    if type(juice_card_until) == 'function' then
        card.hnds_fun_pilled_ready_jiggle = true
        local eval = function(target)
            return target and not target.REMOVED and not target.removed
        end
        juice_card_until(card, eval, true)
    elseif card.juice_up then
        card:juice_up(0.1, 0.1)
    end
end

local function hnds_fun_pilled_apply_editions(owner, targets)
    local applied = 0
    local owner_id = tostring(owner and (owner.sort_id or owner.ID) or 'fun_pilled')

    for index, target in ipairs(targets or {}) do
        if target and not target.REMOVED and not target.removed
            and G and G.jokers and target.area == G.jokers
            and target.set_edition and SMODS and type(SMODS.poll_edition) == 'function'
        then
            local edition = SMODS.poll_edition({
                key = 'hnds_fun_pilled_edition_' .. owner_id .. '_' .. tostring(index),
                guaranteed = true,
            })
            if edition then
                target:set_edition(edition, true, true)
                if target.juice_up then target:juice_up(0.5, 0.4) end
                applied = applied + 1
            end
        end
    end
    return applied
end

SMODS.Joker {
    key = 'fun_pilled',
    atlas = 'Jokers',
    pos = { x = 0, y = 7 },
    rarity = 2,
    cost = 7,
    unlocked = true,
    discovered = false,
    blueprint_compat = false,
    eternal_compat = false,
    perishable_compat = true,
    config = { extra = { rounds = 0, required = 2 } },
    loc_vars = function(self, info_queue, card)
        local extra = hnds_fun_pilled_extra(card, self.config.extra)
        local required = math.max(1, tonumber(extra.required) or 2)
        return { vars = { math.min(tonumber(extra.rounds) or 0, required), required } }
    end,
    calculate = function(self, card, context)
        local extra = hnds_fun_pilled_extra(card, self.config.extra)
        local required = math.max(1, tonumber(extra.required) or 2)

        if context.end_of_round and context.main_eval
            and not context.blueprint and not context.repetition
            and not context.game_over
        then
            local previous = tonumber(extra.rounds) or 0
            extra.rounds = math.min(required, previous + 1)
            if extra.rounds >= required then
                hnds_fun_pilled_start_ready_jiggle(card)
            end
            if extra.rounds ~= previous then
                return {
                    message = extra.rounds >= required and localize('k_active_ex')
                        or (tostring(extra.rounds) .. '/' .. tostring(required)),
                    colour = extra.rounds >= required and G.C.GREEN or G.C.FILTER,
                }
            end
        end

        local selling_this = context.selling_self
            or (context.selling_card and context.card == card)
        if not selling_this or context.blueprint or card.hnds_fun_pilled_triggered then
            return
        end

        card.hnds_fun_pilled_triggered = true
        if (tonumber(extra.rounds) or 0) < required then return end

        local targets = hnds_fun_pilled_adjacent(card)
        if #targets == 0 then
            return { message = localize('k_nope_ex'), colour = G.C.RED }
        end

        local function apply_editions()
            hnds_fun_pilled_apply_editions(card, targets)
            return true
        end
        if G and G.E_MANAGER and Event then
            G.E_MANAGER:add_event(Event {
                trigger = 'after', delay = 0.1, blockable = false, func = apply_editions,
            })
        else
            apply_editions()
        end
        return { message = localize('k_upgrade_ex'), colour = G.C.DARK_EDITION }
    end,
    update = function(self, card, dt)
        if card and G and G.jokers and card.area == G.jokers
            and not card.REMOVED and not card.removed
        then
            hnds_fun_pilled_start_ready_jiggle(card)
        end
    end,
    joker_display_def = function(JokerDisplay)
        return {
            reminder_text = {
                { text = '(' },
                { ref_table = 'card.joker_display_values', ref_value = 'rounds' },
                { text = '/' },
                { ref_table = 'card.joker_display_values', ref_value = 'required' },
                { text = ')' },
            },
            calc_function = function(card)
                local extra = hnds_fun_pilled_extra(card, { rounds = 0, required = 2 })
                local required = math.max(1, tonumber(extra.required) or 2)
                card.joker_display_values.rounds = math.min(tonumber(extra.rounds) or 0, required)
                card.joker_display_values.required = required
            end,
        }
    end,
    attributes = { 'joker', 'on_sell', 'edition' },
}
