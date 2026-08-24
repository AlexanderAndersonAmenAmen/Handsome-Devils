local function hnds_plague_copy_list(list)
    if type(list) ~= 'table' then return nil end
    local out = {}
    for i, v in ipairs(list) do out[i] = v end
    return out
end

local function hnds_plague_next_scoring_card(context)
    local scoring_hand = context and context.scoring_hand
    local source = context and context.other_card
    if type(scoring_hand) ~= 'table' or not source then return nil end

    for i, c in ipairs(scoring_hand) do
        if c == source then return scoring_hand[i + 1] end
    end
end

local function hnds_plague_snapshot(source)
    -- If this card is itself waiting to receive a Plague spread, that pending
    -- Enhancement is what it will score as and therefore what it should spread
    -- onward. This keeps A -> B -> C chains correct without changing B early.
    local pending = source and source.hnds_plague_pending
    if pending and pending.center and pending.center.set == 'Enhanced' then
        return {
            center = pending.center,
            center_key = pending.center_key or pending.center.key,
            aberrant_fusions = hnds_plague_copy_list(pending.aberrant_fusions),
        }
    end

    local center = source and source.config and source.config.center
    if not center or center.set ~= 'Enhanced' then return nil end

    return {
        center = center,
        center_key = center.key,
        aberrant_fusions = center.key == 'm_hnds_aberrant'
            and hnds_plague_copy_list(source.ability and source.ability.hnds_aberrant_fusions)
            or nil,
    }
end

local function hnds_plague_write_enh_cache(card)
    if SMODS and SMODS.enh_cache and SMODS.enh_cache.write then
        SMODS.enh_cache:write(card, nil)
    end
end

local function hnds_plague_set_ability(card, snapshot, delay_sprites)
    if not (card and snapshot and snapshot.center) then return false end

    -- Plague is an outright replacement, never an Aberrant fusion attempt.
    local old_internal = HNDS and HNDS._aberrant_internal_center_swap
    if HNDS then HNDS._aberrant_internal_center_swap = true end
    local ok, err = pcall(function()
        card:set_ability(snapshot.center, nil, delay_sprites and true or nil)
    end)
    if HNDS then HNDS._aberrant_internal_center_swap = old_internal end
    if not ok then error(err) end

    if card.ability then
        if snapshot.center_key == 'm_hnds_aberrant' then
            card.ability.hnds_aberrant_fusions = hnds_plague_copy_list(snapshot.aberrant_fusions) or {}
        else
            card.ability.hnds_aberrant_fusions = nil
        end
    end

    hnds_plague_write_enh_cache(card)
    return true
end

local function hnds_plague_refresh_visual(card)
    if not card or card.removed then return end
    if card.set_sprites and card.config and card.config.center then
        card:set_sprites(card.config.center)
    end
    if card.should_hide_front then card.front_hidden = card:should_hide_front() end
end

local function hnds_plague_apply_visible(source, target, snapshot)
    if not target or target.removed then
        if target then target.hnds_plague_pending = nil end
        return true
    end

    -- The status text and the *real* permanent Enhancement change intentionally
    -- live in the same Event. Nothing on the physical card is changed before
    -- this point; only a private pending snapshot is used for score calculation.
    if source and not source.removed and card_eval_status_text then
        card_eval_status_text(source, 'extra', nil, nil, nil, {
            message = localize('k_hnds_spread'),
            colour = G.C.GREEN,
            instant = true,
        })
    end

    hnds_plague_set_ability(target, snapshot, true)
    hnds_plague_refresh_visual(target)
    if target.juice_up then target:juice_up(0.35, 0.35) end

    -- Only clear this exact pending spread. A later scoring pass/mod may have
    -- queued a newer snapshot for the same physical card.
    if target.hnds_plague_pending == snapshot then
        target.hnds_plague_pending = nil
    end
    return true
end

local function hnds_plague_queue_visible_spread(source, target, snapshot)
    if not (G and G.E_MANAGER and Event) then
        return hnds_plague_apply_visible(source, target, snapshot)
    end

    -- IMPORTANT: use an AFTER event, not an IMMEDIATE event.
    -- Steamodded calculates the whole hand synchronously and queues its visual
    -- scoring work. An immediate Event jumps ahead of that queue, which caused
    -- every Plague proc/message to appear before the first card visibly scored.
    --
    -- This event is added only AFTER the source card's complete SMODS.score_card
    -- call has finished, so it sits in the event queue between the source card's
    -- scoring visuals and the next card's visuals. Zero delay keeps it snappy and
    -- avoids the old post-scoring hitch.
    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0,
        -- This MUST remain blockable (the default). Earlier scoring events need
        -- to finish before Spread may run. Setting blockable=false lets this
        -- event jump the scoring queue and was the cause of the batched pre-score
        -- Spread messages. It also blocks later events for this zero-delay call,
        -- giving strict source-score -> Spread -> target-score ordering.
        blockable = true,
        blocking = true,
        func = function()
            return hnds_plague_apply_visible(source, target, snapshot)
        end,
    }))
    return true
end

local function hnds_plague_record_proc(source, target, snapshot)
    if not (source and target and snapshot) then return end

    -- The target needs a private pending Enhancement immediately so its later
    -- synchronous score calculation can use the spread Enhancement. This field
    -- has NO sprite/UI effect and does not alter the physical card.
    target.hnds_plague_pending = snapshot

    source.hnds_plague_proc_queue = source.hnds_plague_proc_queue or {}
    source.hnds_plague_proc_queue[#source.hnds_plague_proc_queue + 1] = {
        source = source,
        target = target,
        snapshot = snapshot,
    }
end

local function hnds_plague_drain_source_procs(source)
    local queue = source and source.hnds_plague_proc_queue
    if type(queue) ~= 'table' or #queue == 0 then return end

    -- Clear first so callbacks/re-entrancy cannot drain the same proc twice.
    source.hnds_plague_proc_queue = nil
    for i = 1, #queue do
        local proc = queue[i]
        if proc and proc.target and proc.snapshot then
            hnds_plague_queue_visible_spread(proc.source or source, proc.target, proc.snapshot)
        end
    end
end

-- Steamodded's score_card() performs one physical card's base scoring, Joker
-- individual contexts, and all of that card's retriggers before returning. The
-- visible scoring work is queued as it goes. We use that exact boundary to put
-- Plague *after this card* and *before the next card*.
--
-- A pending target Enhancement is only borrowed temporarily for calculation;
-- the physical card is restored before score_card() returns. Its permanent
-- Enhancement changes later in the queued Spread event.
HNDS = HNDS or {}
if SMODS and type(SMODS.score_card) == 'function' and not HNDS._plague_score_card_wrapped then
    HNDS._plague_score_card_wrapped = true
    local hnds_plague_score_card_ref = SMODS.score_card
    local unpack_values = (table and table.unpack) or unpack

    function SMODS.score_card(scored_card, context, ...)
        local trailing = HNDS.pack(...)
        local pending = scored_card and scored_card.hnds_plague_pending
        local old_ability, old_center, old_center_key
        local prepared = false

        local function restore_real_card()
            if not prepared then return end
            scored_card.ability = old_ability
            if scored_card.config then
                scored_card.config.center = old_center
                scored_card.config.center_key = old_center_key
            end
            hnds_plague_write_enh_cache(scored_card)
            prepared = false
        end

        local traceback = (debug and debug.traceback) or function(err) return err end
        local results
        local ok, err = xpcall(function()
            if pending and pending.center then
                old_ability = copy_table(scored_card.ability or {})
                old_center = scored_card.config and scored_card.config.center
                old_center_key = scored_card.config and scored_card.config.center_key
                prepared = true

                if scored_card.quantum_set_ability then
                    scored_card:quantum_set_ability(pending.center)
                else
                    hnds_plague_set_ability(scored_card, pending, true)
                end

                if scored_card.ability then
                    if pending.center_key == 'm_hnds_aberrant' then
                        scored_card.ability.hnds_aberrant_fusions = hnds_plague_copy_list(pending.aberrant_fusions) or {}
                    else
                        scored_card.ability.hnds_aberrant_fusions = nil
                    end
                end
                hnds_plague_write_enh_cache(scored_card)
            end

            results = HNDS.pack(hnds_plague_score_card_ref(scored_card, context, unpack_values(trailing, 1, trailing.n)))
        end, traceback)

        restore_real_card()
        if not ok then error(err, 0) end

        -- This is the critical timing boundary. Do not queue Spread from
        -- Joker:calculate(); doing so batches it into pre-animation hand calc.
        hnds_plague_drain_source_procs(scored_card)
        return unpack_values(results, 1, results.n)
    end
end

SMODS.Joker {
    key = 'plague',
    atlas = 'Jokers',
    pos = { x = 2, y = 6 },
    rarity = 2,
    cost = 6,
    unlocked = false,
    discovered = false,
    unlock_condition = { type = "hnds_joker_unlock", key = "plague" },
    locked_loc_vars = function(self)
        return HNDS.joker_locked_loc_vars("plague")
    end,
    check_for_unlock = function(self, args)
        return HNDS.joker_unlock_condition_met("plague", args)
    end,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,

    config = { extra = { odds = 4 } },

    loc_vars = function(self, info_queue, card)
        local extra = card and card.ability and card.ability.extra or self.config.extra
        local numerator, denominator = SMODS.get_probability_vars(
            card, 1, tonumber(extra.odds) or 4, 'hnds_plague'
        )
        return { vars = { numerator, denominator } }
    end,

    calculate = function(self, card, context)
        if not (context.individual and context.cardarea == G.play and context.other_card)
            or context.repetition_only then
            return
        end

        local source = context.other_card
        local next_card = hnds_plague_next_scoring_card(context)
        local snapshot = hnds_plague_snapshot(source)
        if not (next_card and snapshot) then return end

        -- context.individual is evaluated once per actual scoring pass, including
        -- retriggers. Record the proc only; NEVER return a normal effect/message
        -- here, because Steamodded is still synchronously calculating the hand.
        if not SMODS.pseudorandom_probability(
            card, 'hnds_plague', 1, tonumber(card.ability.extra.odds) or 4, 'hnds_plague'
        ) then
            return
        end

        hnds_plague_record_proc(source, next_card, snapshot)
    end,

    joker_display_def = function(JokerDisplay)
        return {
            reminder_text = {
                { text = '(' },
                { ref_table = 'card.joker_display_values', ref_value = 'odds' },
                { text = ')' },
            },
            calc_function = function(card)
                local normal = G.GAME and G.GAME.probabilities and G.GAME.probabilities.normal or 1
                card.joker_display_values.odds = localize {
                    type = 'variable', key = 'jdis_odds',
                    vars = { normal, tonumber(card.ability.extra.odds) or 4 },
                }
            end,
        }
    end,

    attributes = { 'enhancements', 'chance', 'modify_card' },
}
