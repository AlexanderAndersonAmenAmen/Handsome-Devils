-------------------------------------------------------------------
-- GLOBAL BLIND RAISER: BOSS STACKING + SCORE PREVIEWS
-------------------------------------------------------------------

HNDS = HNDS or {}

local VANILLA_TO_HOOK = {
    bl_hook = "bl_hook_the_hook",
    bl_ox = "bl_hook_the_ox",
    bl_house = "bl_hook_the_house",
    bl_wall = "bl_hook_the_wall",
    bl_wheel = "bl_hook_the_wheel",
    bl_arm = "bl_hook_the_arm",
    bl_club = "bl_hook_the_club",
    bl_fish = "bl_hook_the_fish",
    bl_psychic = "bl_hook_the_psychic",
    bl_goad = "bl_hook_the_goad",
    bl_window = "bl_hook_the_window",
    bl_manacle = "bl_hook_the_manacle",
    bl_eye = "bl_hook_the_eye",
    bl_mouth = "bl_hook_the_mouth",
    bl_plant = "bl_hook_the_plant",
    bl_serpent = "bl_hook_the_serpent",
    bl_pillar = "bl_hook_the_pillar",
    bl_needle = "bl_hook_the_needle",
    bl_head = "bl_hook_the_head",
    bl_mark = "bl_hook_the_mark",
    bl_flint = "bl_hook_the_flint",
    bl_water = "bl_hook_the_water",
    bl_tooth = "bl_hook_the_tooth",
}

local HOOK_TO_VANILLA = {}
for blind_key, hook_key in pairs(VANILLA_TO_HOOK) do
    HOOK_TO_VANILLA[hook_key] = blind_key
end


local function blind_raiser_active()
    return hnds_config and hnds_config.enableBlindUpgradeButton ~= false
        and G and G.GAME ~= nil
end

local function current_ante()
    return G and G.GAME and G.GAME.round_resets
        and tonumber(G.GAME.round_resets.ante) or 0
end

local function current_slot_ante()
    return G and G.GAME and G.GAME.round_resets
        and (tonumber(G.GAME.round_resets.blind_ante)
            or tonumber(G.GAME.round_resets.ante)) or 0
end

local function stack_records()
    if not (G and G.GAME) then return {} end
    G.GAME.hnds_platinum_boss_stacks = G.GAME.hnds_platinum_boss_stacks or {}
    return G.GAME.hnds_platinum_boss_stacks
end

local function stack_record(ante, create)
    local records = stack_records()
    local key = tostring(tonumber(ante) or current_ante())
    if create and type(records[key]) ~= "table" then
        records[key] = { effects = {} }
    end
    local record = records[key]
    if type(record) == "table" then
        record.effects = record.effects or {}
    end
    return record
end

-- Boss+ records and reservation tables are Ante-scoped. Keeping every finished
-- Ante forever is unnecessary and makes Endless runs grow these tables without
-- bound. Preserve only the current Ante; cumulative upgrade count lives in the
-- scalar hnds_blind_upgrades and Conquest has its own defeat tracker.
function HNDS.prune_platinum_boss_stack_records(ante)
    if not (G and G.GAME) then return end
    local keep = tostring(tonumber(ante) or current_ante())

    local records = G.GAME.hnds_platinum_boss_stacks
    if type(records) == 'table' then
        for key in pairs(records) do
            if tostring(key) ~= keep then records[key] = nil end
        end
    end

    local reservations = G.GAME.hnds_platinum_upgrade_reservations
    if type(reservations) == 'table' then
        for key in pairs(reservations) do
            if tostring(key) ~= keep then reservations[key] = nil end
        end
    end
end

local function boss_choice()
    return G and G.GAME and G.GAME.round_resets
        and G.GAME.round_resets.blind_choices
        and G.GAME.round_resets.blind_choices.Boss or nil
end

local function is_devil_blind_key(key)
    return key == "bl_hnds_blind_devil" or key == "blind_devil"
end

local function prepare_devil_components_for_upgrade()
    if not (G and G.GAME and is_devil_blind_key(boss_choice())) then return end
    local rolled = G.GAME.hnds_devil_bosses
    if type(rolled) == "table" and #rolled >= 3 then return end
    if HNDS.prepare_devil_encounter then
        HNDS.prepare_devil_encounter()
    end
end

function HNDS.platinum_boss_effects_for_ante(ante)
    local record = stack_record(ante, false)
    return record and record.effects or {}
end

local function platinum_upgraded_slot_count(ante)
    if not (G and G.GAME) then return 0 end
    ante = tonumber(ante) or current_ante()
    local count = 0
    local upgraded = G.GAME.hnds_upgraded_blinds or {}
    local replacements = G.GAME.hnds_platinum_blind_replacements or {}

    for _, blind_choice in ipairs({ "Small", "Big" }) do
        local key = tostring(ante) .. ":" .. blind_choice
        if upgraded[key] == true or type(replacements[key]) == "table" then
            count = count + 1
        end
    end

    return count
end

function HNDS.platinum_boss_upgrade_count_for_ante(ante)
    ante = tonumber(ante) or current_ante()
    local record = stack_record(ante, false)
    local recorded_count = record and math.max(
        0,
        tonumber(record.upgrade_count) or 0,
        type(record.effects) == "table" and #record.effects or 0
    ) or 0

    -- The physical Small/Big upgrade locks are the authoritative source for
    -- Boss score/name scaling. Effect records exist for delegation/tooltips,
    -- but must never be able to lose the second upgrade because of a rebuild,
    -- duplicate guard, save migration, or a component such as The Manacle.
    return math.max(recorded_count, platinum_upgraded_slot_count(ante))
end

function HNDS.record_platinum_boss_effect(blind_key, ante)
    local hook_key = VANILLA_TO_HOOK[blind_key]
    if not hook_key then return false end

    local record = stack_record(ante, true)
    record.base_boss = record.base_boss or boss_choice()
    for _, existing in ipairs(record.effects) do
        if existing == blind_key then return false end
    end
    record.effects[#record.effects + 1] = blind_key
    record.upgrade_count = math.max(0, tonumber(record.upgrade_count) or (#record.effects - 1)) + 1
    return true
end

local function existing_combo_hooks(ante)
    local hooks = {}
    local seen = {}
    local function add(hook_key)
        if hook_key and not seen[hook_key] then
            seen[hook_key] = true
            hooks[#hooks + 1] = hook_key
        end
    end

    add(VANILLA_TO_HOOK[boss_choice()])
    for _, blind_key in ipairs(HNDS.platinum_boss_effects_for_ante(ante)) do
        add(VANILLA_TO_HOOK[blind_key])
    end

    -- The Devil already contains three component effects. Ensure the roll
    -- exists before Small/Big upgrade candidates are evaluated, then treat all
    -- three as part of the real Boss's combo. This also covers continued runs
    -- where the Boss choice loaded before its encounter state was restored.
    local base = boss_choice()
    if is_devil_blind_key(base) then
        prepare_devil_components_for_upgrade()
        for _, hook_key in ipairs(G.GAME.hnds_devil_bosses or {}) do add(hook_key) end
    end

    return hooks
end

local function blind_is_in_pool(blind)
    if type(blind.in_pool) ~= "function" then return true end
    local ok, result = pcall(blind.in_pool, blind)
    return ok and result ~= false
end

local function candidate_is_ante_eligible(blind, ante)
    local boss = blind and blind.boss
    if not boss then return false end
    ante = tonumber(ante) or current_ante()
    if boss.min and ante < boss.min then return false end
    if boss.max and ante > boss.max then return false end
    return true
end

local function platinum_upgrade_reservations_for_ante(ante)
    if not (G and G.GAME) then return {} end
    ante = tonumber(ante) or current_ante()
    G.GAME.hnds_platinum_upgrade_reservations =
        G.GAME.hnds_platinum_upgrade_reservations or {}
    local key = tostring(ante)
    if type(G.GAME.hnds_platinum_upgrade_reservations[key]) ~= "table" then
        G.GAME.hnds_platinum_upgrade_reservations[key] = {}
    end
    return G.GAME.hnds_platinum_upgrade_reservations[key]
end

local function upgraded_replacement_bosses_for_ante(ante)
    local used = {}
    if not (G and G.GAME) then return used end
    ante = tonumber(ante) or current_ante()

    -- A choice is reserved the instant it is rolled, before the upgrade
    -- animation or Blind-option rebuild starts. This closes the transition
    -- window where a second upgrade could roll the same Boss before the first
    -- replacement record became visible to every UI/state path.
    for _, blind_key in pairs(platinum_upgrade_reservations_for_ante(ante)) do
        if type(blind_key) == "string" then used[blind_key] = true end
    end

    local replacements = G.GAME.hnds_platinum_blind_replacements or {}
    for _, blind_choice in ipairs({ "Small", "Big" }) do
        local record = replacements[tostring(ante) .. ":" .. blind_choice]
        if type(record) == "table" and record.boss then used[record.boss] = true end
    end

    -- Also read the physical choices. This covers old saves and the short
    -- interval after a replacement is committed but before its effect record
    -- is rebuilt.
    local choices = G.GAME.round_resets and G.GAME.round_resets.blind_choices or {}
    for _, blind_choice in ipairs({ "Small", "Big" }) do
        local key = choices and choices[blind_choice]
        if key and VANILLA_TO_HOOK[key] then
            local replacement = replacements[tostring(ante) .. ":" .. blind_choice]
            if type(replacement) == "table" or (G.GAME.hnds_upgraded_blinds or {})[tostring(ante) .. ":" .. blind_choice] then
                used[key] = true
            end
        end
    end
    return used
end

function HNDS.platinum_boss_candidate_is_compatible(blind_key, ante, blind_choice, relaxed_pool)
    local hook_key = VANILLA_TO_HOOK[blind_key]
    local blind = blind_key and G.P_BLINDS and G.P_BLINDS[blind_key]
    if not (hook_key and blind and blind.boss) then return false end
    if blind.boss.showdown then return false end
    -- These are the only Boss Blinds globally excluded from Small/Big upgrades.
    if blind_key == 'bl_wall' or blind_key == 'bl_needle' then return false end
    if G.GAME.banned_keys and G.GAME.banned_keys[blind_key] then return false end
    if blind_key == boss_choice() then return false end
    if upgraded_replacement_bosses_for_ante(ante)[blind_key] then return false end
    -- Ante restrictions are never relaxed. The fallback may ignore only a
    -- transient in_pool result so it cannot roll, for example, The Ox before
    -- its minimum Ante.
    if not candidate_is_ante_eligible(blind, ante) then return false end
    if not relaxed_pool and not blind_is_in_pool(blind) then return false end

    for _, existing in ipairs(HNDS.platinum_boss_effects_for_ante(ante)) do
        if existing == blind_key then return false end
    end

    local existing_hooks = existing_combo_hooks(ante)
    -- A Platinum component may not duplicate one of The Devil's three rolled
    -- effects (or another upgraded component), even when that duplicate would
    -- not independently trip a debuffer/flipper/pair restriction.
    for _, existing_hook in ipairs(existing_hooks) do
        if existing_hook == hook_key then return false end
    end
    if HNDS.devil_combo_invalid and HNDS.devil_combo_invalid(existing_hooks, hook_key) then
        return false
    end
    return true
end

-- Boss Reroll vouchers/tags must obey the exact same stack-combination
-- rules as the Small/Big upgrade picker. Unlike an upgrade candidate, the
-- rerolled Boss replaces the current real Boss, so only the already-upgraded
-- Small/Big components are included in the compatibility test.
function HNDS.platinum_reroll_boss_candidate_is_compatible(blind_key, ante)
    if not (G and G.GAME and G.P_BLINDS) then return true end
    ante = tonumber(ante) or current_ante()

    local upgraded = upgraded_replacement_bosses_for_ante(ante)
    if not next(upgraded) then return true end
    if upgraded[blind_key] then return false end

    local candidate_hook = VANILLA_TO_HOOK[blind_key]
    -- Unknown/modded Bosses do not expose a Handsome Devils component hook, so
    -- there is no safe generic effect classification to apply to them.
    if not candidate_hook then return true end

    local existing_hooks = {}
    local seen_hooks = {}
    for upgraded_key in pairs(upgraded) do
        local hook_key = VANILLA_TO_HOOK[upgraded_key]
        if hook_key and not seen_hooks[hook_key] then
            seen_hooks[hook_key] = true
            existing_hooks[#existing_hooks + 1] = hook_key
        end
    end

    if seen_hooks[candidate_hook] then return false end
    if HNDS.devil_combo_invalid and HNDS.devil_combo_invalid(existing_hooks, candidate_hook) then
        return false
    end
    return true
end

-- Temporarily extend banned_keys while vanilla/Steamodded chooses a rerolled
-- real Boss. This preserves the original picker, its seeded randomness,
-- min/max Ante rules, in_pool callbacks and boss-use weighting; it merely
-- removes candidates that would duplicate or invalidate the current stack.
function HNDS.call_with_platinum_reroll_bans(selector)
    if type(selector) ~= "function" then return nil end
    if not blind_raiser_active() or not (G and G.GAME and G.P_BLINDS)
        or G.GAME.hnds_bypass_platinum_reroll_bans
    then
        return selector()
    end

    local ante = current_ante()
    local upgraded = upgraded_replacement_bosses_for_ante(ante)
    if not next(upgraded) then return selector() end

    local had_banned_table = type(G.GAME.banned_keys) == "table"
    local banned = had_banned_table and G.GAME.banned_keys or {}
    G.GAME.banned_keys = banned
    local temporarily_banned = {}

    for key, blind in pairs(G.P_BLINDS) do
        if blind and blind.boss
            and VANILLA_TO_HOOK[key]
            and not banned[key]
            and not HNDS.platinum_reroll_boss_candidate_is_compatible(key, ante)
        then
            banned[key] = true
            temporarily_banned[#temporarily_banned + 1] = key
        end
    end

    local ok, result = pcall(selector)
    for _, key in ipairs(temporarily_banned) do banned[key] = nil end
    if not had_banned_table and next(banned) == nil then G.GAME.banned_keys = nil end
    if not ok then error(result) end

    -- The compatibility mask can legitimately empty the vanilla Boss pool on
    -- some Antes/mod combinations. Returning nil here corrupts
    -- round_resets.blind_choices.Boss and crashes create_UIBox_blind_choice.
    -- Prefer a normal unmasked Boss roll over an invalid Blind Select state.
    if not (type(result) == "string" and G.P_BLINDS[result]) then
        local previous = G.GAME.hnds_bypass_platinum_reroll_bans
        G.GAME.hnds_bypass_platinum_reroll_bans = true
        local fallback_ok, fallback = pcall(selector)
        G.GAME.hnds_bypass_platinum_reroll_bans = previous
        if not fallback_ok then error(fallback) end
        return fallback
    end

    return result
end

function HNDS.choose_platinum_upgrade_boss(blind_choice)
    if not (G and G.GAME and G.P_BLINDS) then return nil end
    prepare_devil_components_for_upgrade()
    local ante = current_ante()
    local candidates = {}
    local minimum_uses = nil

    for blind_key in pairs(VANILLA_TO_HOOK) do
        if HNDS.platinum_boss_candidate_is_compatible(blind_key, ante, blind_choice, false) then
            local uses = (G.GAME.bosses_used and G.GAME.bosses_used[blind_key]) or 0
            if minimum_uses == nil or uses < minimum_uses then minimum_uses = uses end
            candidates[#candidates + 1] = { key = blind_key, uses = uses }
        end
    end

    -- Some in_pool predicates are evaluated against the real Boss slot and can
    -- transiently empty the replacement pool. Retry only that predicate; the
    -- Boss's min/max Ante limits remain mandatory in the relaxed pass.
    if #candidates == 0 then
        for blind_key in pairs(VANILLA_TO_HOOK) do
            if HNDS.platinum_boss_candidate_is_compatible(blind_key, ante, blind_choice, true) then
                local uses = (G.GAME.bosses_used and G.GAME.bosses_used[blind_key]) or 0
                if minimum_uses == nil or uses < minimum_uses then minimum_uses = uses end
                candidates[#candidates + 1] = { key = blind_key, uses = uses }
            end
        end
    end

    local filtered = {}
    for _, candidate in ipairs(candidates) do
        if candidate.uses == minimum_uses then filtered[#filtered + 1] = candidate.key end
    end
    table.sort(filtered)
    if #filtered == 0 then return nil end

    local selected = pseudorandom_element(
        filtered,
        pseudoseed(
            "hnds_platinum_upgrade_" .. tostring(ante)
                .. "_" .. tostring(blind_choice)
                .. "_" .. tostring(HNDS.platinum_boss_upgrade_count_for_ante(ante) + 1)
        )
    )

    -- Reserve before returning. The manual and Blood-Stake upgrade callbacks
    -- both commit their records immediately afterwards, but this reservation
    -- is the authoritative no-duplicates guard during animated UI rebuilds.
    if selected then
        platinum_upgrade_reservations_for_ante(ante)[tostring(blind_choice)] = selected
    end
    return selected
end

-------------------------------------------------------------------
-- Upgraded Small/Big score scaling and Upgrade-button preview
-------------------------------------------------------------------

local function replacement_record(blind_choice, ante)
    if not (G and G.GAME) then return nil end
    local records = G.GAME.hnds_platinum_blind_replacements or {}
    -- Replacement records are strictly Ante-scoped. Never fall back to the
    -- latest record for the same physical slot: doing so makes an upgraded
    -- Small/Big Blind from an older Ante leak its score/effect state into a
    -- later Ante after the slot has already been regenerated.
    local key = tostring(tonumber(ante) or current_slot_ante())
        .. ":" .. tostring(blind_choice)
    local exact = records[key]
    return type(exact) == "table" and exact or nil
end

local function regular_score_for_slot(blind_choice, ante)
    if blind_choice ~= "Small" and blind_choice ~= "Big" then return nil end
    local base = G.P_BLINDS and G.P_BLINDS["bl_" .. blind_choice:lower()]
    if not (base and base.mult and type(get_blind_amount) == "function") then return nil end
    local scaling = G.GAME.starting_params and G.GAME.starting_params.ante_scaling or 1
    return get_blind_amount(tonumber(ante) or current_slot_ante()) * base.mult * scaling
end

function HNDS.platinum_run_upgrade_count()
    return G and G.GAME and math.max(0, tonumber(G.GAME.hnds_blind_upgrades) or 0) or 0
end

function HNDS.platinum_next_upgrade_exponent()
    if not (G and G.GAME) then return HNDS.platinum_run_upgrade_count() + 1 end
    local minimum = HNDS.platinum_run_upgrade_count() + 1
    local stored = math.floor(tonumber(G.GAME.hnds_blind_raiser_next_exponent) or minimum)
    stored = math.max(1, minimum, stored)
    G.GAME.hnds_blind_raiser_next_exponent = stored
    return stored
end

function HNDS.set_platinum_next_upgrade_exponent(step)
    if not (G and G.GAME) then return end
    local minimum = HNDS.platinum_run_upgrade_count() + 1
    G.GAME.hnds_blind_raiser_next_exponent = math.max(
        1, minimum, math.floor(tonumber(step) or minimum)
    )
end

-- Blind Raiser score scaling is global for the whole run. Each committed
-- upgrade step adds +20% to the natural/base score of every undefeated and
-- future Blind. Keep the old save-field name for the next step so existing
-- runs remain compatible, but store the last actually-applied step separately
-- from record-hand catch-up (which may advance the *next* step without buying
-- an upgrade).
local function derive_applied_blind_raiser_step()
    if not (G and G.GAME) then return 0 end

    local applied = math.max(0, math.floor(tonumber(G.GAME.hnds_blind_raiser_applied_step) or 0))
    local records = G.GAME.hnds_platinum_blind_replacements or {}
    for _, record in pairs(records) do
        if type(record) == "table" then
            applied = math.max(applied, math.max(0, math.floor(tonumber(record.upgrade_index) or 0)))
        end
    end

    -- Migration fallback for very old saves that tracked only the count.
    if applied == 0 then
        applied = math.max(0, math.floor(tonumber(G.GAME.hnds_blind_upgrades) or 0))
    end

    G.GAME.hnds_blind_raiser_applied_step = applied
    return applied
end

function HNDS.set_platinum_blind_raiser_applied_step(step)
    if not (G and G.GAME) then return end
    G.GAME.hnds_blind_raiser_applied_step = math.max(
        derive_applied_blind_raiser_step(),
        math.max(0, math.floor(tonumber(step) or 0))
    )
end

function HNDS.platinum_blind_raiser_multiplier(step)
    step = math.max(0, tonumber(step) or derive_applied_blind_raiser_step())
    return 1 + (0.2 * step)
end


-- Record-hand catch-up for the global Blind Raiser. The next upgrade exponent
-- is independent from the number of upgrades actually bought: clearing score
-- thresholds never grants a Tag reward or adds a stacked Boss effect.
--
-- Catch-up remains atomic in groups of three. Each step is now +20% Blind
-- size instead of a power of two: starting at step 1, a hand must reach the
-- step-3 threshold (base x 1.6) to advance the next upgrade to step 4.
local function normalized_blind_raiser_score(value)
    if value == nil then return nil end

    if type(value) == "table"
        and value.coefficient ~= nil
        and value.exponent ~= nil
        and value.e_count ~= nil
    then
        return {
            coefficient = tonumber(value.coefficient) or 0,
            exponent = tonumber(value.exponent) or 0,
            e_count = tonumber(value.e_count) or 0,
        }
    end

    local raw = tostring(value):lower():gsub(",", ""):gsub("%s+", "")
    if raw == "" then return nil end

    -- Talisman-style values can contain leading e's. Preserve that magnitude
    -- tier, then normalize the remaining value into scientific notation so
    -- plain 10000 and 1e4 compare identically.
    local e_count = 0
    while raw:sub(1, 1) == "e" do
        e_count = e_count + 1
        raw = raw:sub(2)
    end

    local coefficient_text, explicit_exponent = raw:match("^([%+%-]?[%d%.]+)e([%+%-]?%d+)$")
    if not coefficient_text then
        coefficient_text = raw
        explicit_exponent = 0
    else
        explicit_exponent = tonumber(explicit_exponent) or 0
    end

    local sign = 1
    if coefficient_text:sub(1, 1) == "-" then
        sign = -1
        coefficient_text = coefficient_text:sub(2)
    elseif coefficient_text:sub(1, 1) == "+" then
        coefficient_text = coefficient_text:sub(2)
    end

    local integer, fraction = coefficient_text:match("^(%d*)%.?(%d*)$")
    if integer == nil then return nil end
    integer, fraction = integer or "", fraction or ""

    local nonzero_integer = integer:match("^0*(%d.*)$")
    local significant, exponent
    if nonzero_integer and nonzero_integer:find("[1-9]") then
        nonzero_integer = nonzero_integer:gsub("^0+", "")
        significant = nonzero_integer .. fraction
        exponent = #nonzero_integer - 1 + explicit_exponent
    else
        local first_nonzero = fraction:find("[1-9]")
        if not first_nonzero then
            return { coefficient = 0, exponent = 0, e_count = 0 }
        end
        significant = fraction:sub(first_nonzero)
        exponent = explicit_exponent - first_nonzero
    end

    local head = significant:sub(1, 1)
    local tail = significant:sub(2, 15)
    local coefficient = tonumber(head .. (tail ~= "" and ("." .. tail) or "")) or 0
    return {
        coefficient = sign * coefficient,
        exponent = exponent,
        e_count = e_count,
    }
end

local function normalized_score_compare(left, right)
    if not (left and right) then return nil end
    local lc, rc = tonumber(left.coefficient) or 0, tonumber(right.coefficient) or 0
    if lc == rc and lc == 0 then return 0 end
    if lc < 0 and rc >= 0 then return -1 end
    if lc >= 0 and rc < 0 then return 1 end

    local sign = lc < 0 and -1 or 1
    local le, re = tonumber(left.e_count) or 0, tonumber(right.e_count) or 0
    if le ~= re then return (le > re and 1 or -1) * sign end

    local lx, rx = tonumber(left.exponent) or 0, tonumber(right.exponent) or 0
    if lx ~= rx then return (lx > rx and 1 or -1) * sign end

    local la, ra = math.abs(lc), math.abs(rc)
    if la == ra then return 0 end
    return (la > ra and 1 or -1) * sign
end

local function normalized_score_at_least(left, right)
    local comparison = normalized_score_compare(left, right)
    return comparison ~= nil and comparison >= 0
end

local function blind_raiser_step_threshold(base_score, step)
    step = math.max(0, tonumber(step) or 0)
    local multiplier = 1 + (0.2 * step)

    -- Prefer the active Big-number implementation when available.
    if type(to_big) == "function" then
        local ok, threshold = pcall(function()
            return to_big(base_score) * multiplier
        end)
        if ok then
            local normalized = normalized_blind_raiser_score(threshold)
            if normalized then return normalized end
        end
    end

    local base = normalized_blind_raiser_score(base_score)
    if not base or base.coefficient <= 0 then return nil end

    -- Linear multipliers are safe to apply in normalized scientific form and
    -- do not require evaluating an exponentially growing power.
    local coefficient = base.coefficient * multiplier
    local exponent = base.exponent
    while math.abs(coefficient) >= 10 do
        coefficient = coefficient / 10
        exponent = exponent + 1
    end
    return {
        coefficient = coefficient,
        exponent = exponent,
        e_count = base.e_count or 0,
    }
end

local function stored_blind_raiser_highest_hand()
    if not (G and G.GAME) then return nil end
    return normalized_blind_raiser_score(G.GAME.hnds_blind_raiser_highest_hand_score)
end

function HNDS.on_blind_raiser_hand_scored(hand_score)
    if not blind_raiser_active() or hand_score == nil or not (G and G.GAME) then return end

    local normalized_score = normalized_blind_raiser_score(hand_score)
    if not normalized_score or normalized_score.coefficient <= 0 then return end

    local previous = stored_blind_raiser_highest_hand()
        or { coefficient = 0, exponent = 0, e_count = 0 }
    local highest = previous
    if (normalized_score_compare(normalized_score, previous) or -1) > 0 then
        highest = normalized_score
        -- Store a plain serializable table rather than a Big-number userdata.
        G.GAME.hnds_blind_raiser_highest_hand_score = normalized_score
    end

    -- A hand scored during Ante N is compared with the natural Small Blind of
    -- Ante N+1, before any Blind Raiser multiplier is applied.
    local next_ante = math.max(1, current_ante() + 1)
    local base_score = regular_score_for_slot("Small", next_ante)
    if not base_score then return end

    local step = HNDS.platinum_next_upgrade_exponent()
    local original_step = step

    local function full_groups_pass(group_count)
        if group_count < 1 then return true end
        local final_step = step + (group_count * 3) - 1
        local threshold = blind_raiser_step_threshold(base_score, final_step)
        return threshold ~= nil and normalized_score_at_least(highest, threshold)
    end

    local passed_groups = 0
    if full_groups_pass(1) then
        -- Find the first failing group exponentially, then binary-search the
        -- exact number of complete groups. This stays fast for enormous hands.
        local lower, upper = 1, 2
        local max_safe_groups = 1073741824 -- 2^30 complete groups

        while upper < max_safe_groups and full_groups_pass(upper) do
            lower = upper
            upper = upper * 2
        end

        if upper >= max_safe_groups and full_groups_pass(max_safe_groups) then
            passed_groups = max_safe_groups
        else
            local lo = lower + 1
            local hi = math.min(upper - 1, max_safe_groups)
            passed_groups = lower
            while lo <= hi do
                local mid = math.floor((lo + hi) / 2)
                if full_groups_pass(mid) then
                    passed_groups = mid
                    lo = mid + 1
                else
                    hi = mid - 1
                end
            end
        end
    end

    if passed_groups > 0 then step = step + (passed_groups * 3) end
    if step > original_step then HNDS.set_platinum_next_upgrade_exponent(step) end
end

-- Hook both completed-hand score signals. The operation is idempotent: the
-- first call advances through every full group the highest hand can clear, and
-- the duplicate signal immediately encounters the same first failing group.
local function install_blind_raiser_hand_score_hooks()
    local installed = false

    if type(check_and_set_high_score) == "function"
        and check_and_set_high_score ~= HNDS._blind_raiser_high_score_hook
    then
        local previous_high_score = check_and_set_high_score
        local wrapper
        wrapper = function(score_type, amount, ...)
            local result = previous_high_score(score_type, amount, ...)
            if score_type == "hand" and HNDS.on_blind_raiser_hand_scored then
                HNDS.on_blind_raiser_hand_scored(amount)
            end
            return result
        end
        HNDS._blind_raiser_high_score_hook = wrapper
        check_and_set_high_score = wrapper
        installed = true
    elseif check_and_set_high_score == HNDS._blind_raiser_high_score_hook then
        installed = true
    end

    if type(check_for_unlock) == "function"
        and check_for_unlock ~= HNDS._blind_raiser_chip_score_hook
    then
        local previous_check_for_unlock = check_for_unlock
        local wrapper
        wrapper = function(args, ...)
            local result = previous_check_for_unlock(args, ...)
            if type(args) == "table" and args.type == "chip_score"
                and args.chips ~= nil and HNDS.on_blind_raiser_hand_scored
            then
                HNDS.on_blind_raiser_hand_scored(args.chips)
            end
            return result
        end
        HNDS._blind_raiser_chip_score_hook = wrapper
        check_for_unlock = wrapper
        installed = true
    elseif check_for_unlock == HNDS._blind_raiser_chip_score_hook then
        installed = true
    end

    return installed
end

install_blind_raiser_hand_score_hooks()

if Game and type(Game.start_run) == "function"
    and not HNDS._blind_raiser_start_run_score_hook_installed
then
    HNDS._blind_raiser_start_run_score_hook_installed = true
    local game_start_run_ref = Game.start_run
    function Game:start_run(...)
        install_blind_raiser_hand_score_hooks()
        local pack = HNDS.pack
        local unpack_values = table.unpack or unpack
        local result = pack(game_start_run_ref(self, ...))
        install_blind_raiser_hand_score_hooks()
        return unpack_values(result, 1, result.n)
    end
end

local function score_from_replacement_record(blind_choice, record)
    if type(record) ~= "table" then return nil end
    local base = tonumber(record.base_score)
        or regular_score_for_slot(blind_choice, record.ante or current_ante())
    if not base then return nil end
    record.base_score = base

    local step = derive_applied_blind_raiser_step()
    return base * HNDS.platinum_blind_raiser_multiplier(step)
end

function HNDS.platinum_next_upgrade_score(blind_choice)
    local base = regular_score_for_slot(blind_choice, current_ante())
    if not base then return nil end
    return base * HNDS.platinum_blind_raiser_multiplier(HNDS.platinum_next_upgrade_exponent())
end

function HNDS.platinum_boss_score_for_ante(ante, extra_upgrades)
    if not (G and G.GAME and G.P_BLINDS and type(get_blind_amount) == "function") then return nil end
    ante = tonumber(ante) or current_ante()
    local boss_key = boss_choice()
    local boss = boss_key and G.P_BLINDS[boss_key]
    local mult = boss and tonumber(boss.mult)
    if not mult then return nil end

    local step = derive_applied_blind_raiser_step()
    if math.max(0, tonumber(extra_upgrades) or 0) > 0 then
        -- Preview the run-wide +20% step that will be committed by the next
        -- upgrade. Catch-up can move this step forward in groups of three.
        step = HNDS.platinum_next_upgrade_exponent()
            + math.max(0, tonumber(extra_upgrades) or 0) - 1
    end

    local scaling = G.GAME.starting_params and G.GAME.starting_params.ante_scaling or 1
    local natural_score = get_blind_amount(ante) * mult * scaling
    return natural_score * HNDS.platinum_blind_raiser_multiplier(step)
end

local function dictionary_text(key, vars, fallback)
    local text = localize(key)
    if type(text) == "table" then text = text[1] end
    if type(text) ~= "string" or text == "" or text == key then text = fallback end
    for i, value in ipairs(vars or {}) do
        text = text:gsub("#" .. tostring(i) .. "#", tostring(value))
    end
    return text
end

function HNDS.platinum_upgrade_button_tooltip(blind_choice)
    local blind_score = HNDS.platinum_next_upgrade_score(blind_choice)
    local boss_score = HNDS.platinum_boss_score_for_ante(current_ante(), 1)
    local formatted_blind = blind_score and number_format(blind_score) or "?"
    local formatted_boss = boss_score and number_format(boss_score) or "?"
    local text = {
        dictionary_text(
            "hnds_blind_raiser_tooltip_current_blind",
            { formatted_blind },
            "Current Blind: " .. tostring(formatted_blind)
        ),
    }

    -- Upgrading Small immediately advances the run-wide Blind Raiser score
    -- multiplier, so preview the Big Blind at that same post-upgrade step too.
    if blind_choice == "Small" then
        local big_score = HNDS.platinum_next_upgrade_score("Big")
        local formatted_big = big_score and number_format(big_score) or "?"
        text[#text + 1] = dictionary_text(
            "hnds_blind_raiser_tooltip_big_blind",
            { formatted_big },
            "Big Blind: " .. tostring(formatted_big)
        )
    end

    text[#text + 1] = dictionary_text(
        "hnds_blind_raiser_tooltip_boss_blind",
        { formatted_boss },
        "Boss Blind: " .. tostring(formatted_boss)
    )

    return {
        title = dictionary_text(
            "hnds_blind_raiser_tooltip_title",
            nil,
            "Score if upgraded"
        ),
        text = text,
    }
end

function HNDS.adjust_platinum_blind_preview_amount(blind_choice, vanilla_amount, blind_config)
    if not blind_raiser_active() then return vanilla_amount end

    -- An upgraded Small/Big uses that physical slot's ordinary base score even
    -- though its visible/effect center is a Boss Blind. It still receives the
    -- same run-wide +20%-per-step multiplier as every other Blind.
    if blind_choice == "Small" or blind_choice == "Big" then
        local record = replacement_record(blind_choice, current_ante())
        if type(record) == "table" then
            local score = score_from_replacement_record(blind_choice, record)
            if score then return score end
        end
    end

    local amount = tonumber(vanilla_amount)
    if not amount then return vanilla_amount end
    return amount * HNDS.platinum_blind_raiser_multiplier()
end

local function append_plus_to_name(loc_name)
    if type(loc_name) == "string" then
        return loc_name:match("%+$") and loc_name or (loc_name .. "+")
    end
    if type(loc_name) == "table" then
        local copy = {}
        for key, value in pairs(loc_name) do copy[key] = value end

        -- name_text normally returns a string, but some localization layers
        -- return a one-element or nested string table. Append to the last
        -- reachable string so the Boss badge remains compatible with both.
        local function append_last_string(node)
            local last_numeric = nil
            for key in pairs(node) do
                if type(key) == "number" and (not last_numeric or key > last_numeric) then
                    last_numeric = key
                end
            end
            if last_numeric then
                local value = node[last_numeric]
                if type(value) == "string" then
                    node[last_numeric] = value:match("%+$") and value or (value .. "+")
                    return true
                elseif type(value) == "table" then
                    local nested = {}
                    for key, nested_value in pairs(value) do nested[key] = nested_value end
                    node[last_numeric] = nested
                    return append_last_string(nested)
                end
            end
            return false
        end

        append_last_string(copy)
        return copy
    end
    return loc_name
end

function HNDS.platinum_blind_display_name(blind_choice, loc_name)
    if blind_choice == "Boss"
        and HNDS.platinum_boss_upgrade_count_for_ante(current_ante()) > 0
    then
        return append_plus_to_name(loc_name)
    end
    return loc_name
end

-- Apply the plus at the localization source used by both the Blind-select badge
-- and the active Blind HUD. This does not rely on a single UI-definition patch
-- or on Blind:set_text load order, and append_plus_to_name is idempotent.
local localize_platinum_ref = localize
function localize(args, misc_cat, misc_loc, silent, ...)
    local result = localize_platinum_ref(args, misc_cat, misc_loc, silent, ...)
    if type(args) == "table"
        and args.type == "name_text"
        and args.set == "Blind"
        and blind_raiser_active()
        and args.key == boss_choice()
        and HNDS.platinum_boss_upgrade_count_for_ante(current_ante()) > 0
    then
        return append_plus_to_name(result)
    end
    return result
end

-------------------------------------------------------------------
-- Boss+ tooltip
-------------------------------------------------------------------

local function tooltip_vars(blind_key, blind_config)
    if blind_key == "bl_wheel" and SMODS and SMODS.get_probability_vars then
        local numerator, denominator = SMODS.get_probability_vars(
            blind_config or G.P_BLINDS[blind_key], 1, 7, "hnds_platinum_wheel_tooltip"
        )
        return { numerator, denominator }
    end
    if blind_key == "bl_ox" then
        local hand = G.GAME.current_round and G.GAME.current_round.most_played_poker_hand
        return { hand and localize(hand, "poker_hands") or "?" }
    end
    if blind_config and type(blind_config.loc_vars) == "function" then
        local ok, result = pcall(blind_config.loc_vars, blind_config)
        if ok and type(result) == "table" and type(result.vars) == "table" then
            return result.vars
        end
    end
    return {}
end

local function create_effect_box(blind_key)
    local blind_config = blind_key and G.P_BLINDS and G.P_BLINDS[blind_key]
    if not blind_config then return nil end

    local name_nodes = localize { type = "name", key = blind_key, set = "Blind" }
    local desc_nodes = {}
    localize {
        type = "descriptions",
        key = blind_key,
        set = "Blind",
        nodes = desc_nodes,
        vars = tooltip_vars(blind_key, blind_config),
    }

    local colour = blind_config.boss_colour or G.C.RED
    return {
        n = G.UIT.R,
        config = { align = "cm", padding = 0.025 },
        nodes = {
            {
                n = G.UIT.R,
                config = {
                    align = "cm", minw = 3.45, maxw = 3.45,
                    padding = 0.055, r = 0.1,
                    colour = lighten(G.C.JOKER_GREY, 0.5), emboss = 0.05,
                },
                nodes = {
                    {
                        n = G.UIT.C,
                        config = {
                            align = "cm", minw = 3.3, maxw = 3.3,
                            padding = 0.07, r = 0.08,
                            colour = adjust_alpha(darken(colour, 0.2), 0.96),
                        },
                        nodes = {
                            name_from_rows(name_nodes),
                            desc_from_rows(desc_nodes),
                        },
                    },
                },
            },
        },
    }
end

local function platinum_tooltip_effects_for_ante(ante)
    -- UI is intentionally derived from the exact physical Small/Big replacement
    -- records for the visible Ante, not from the historical Boss-stack registry.
    -- The latter is retained for encounter logic/save compatibility and therefore
    -- may still contain older Antes. It must never be allowed to populate a new
    -- Ante's hover popup.
    if not (G and G.GAME) then return {} end
    ante = tonumber(ante) or current_ante()
    if ante ~= current_ante() then return {} end

    local records = G.GAME.hnds_platinum_blind_replacements or {}
    local effects = {}
    local seen = {}
    for _, blind_choice in ipairs({ "Small", "Big" }) do
        local record = records[tostring(ante) .. ":" .. blind_choice]
        local key = type(record) == "table" and record.boss or nil
        if tonumber(type(record) == "table" and record.ante or ante) == ante
            and type(key) == "string"
            and G.P_BLINDS and G.P_BLINDS[key]
            and not seen[key]
        then
            seen[key] = true
            effects[#effects + 1] = key
        end
    end
    return effects
end

function HNDS.create_platinum_upgrade_effect_boxes(ante)
    local nodes = {}
    for _, blind_key in ipairs(platinum_tooltip_effects_for_ante(ante or current_ante())) do
        local box = create_effect_box(blind_key)
        if box then nodes[#nodes + 1] = box end
    end
    return nodes
end

function HNDS.create_platinum_boss_tooltip(ante)
    local base = boss_choice()

    -- The Devil owns a bespoke popup made from three separate vanilla Blind
    -- boxes. Never replace it with a single Devil description that lists those
    -- effects; ask the Devil tooltip builder to append the upgraded Blind boxes
    -- instead.
    if is_devil_blind_key(base) and HNDS.create_devil_blind_tooltip then
        return HNDS.create_devil_blind_tooltip(ante or current_ante())
    end

    local nodes = {}
    local base_box = create_effect_box(base)
    if base_box then nodes[#nodes + 1] = base_box end
    for _, box in ipairs(HNDS.create_platinum_upgrade_effect_boxes(ante)) do
        nodes[#nodes + 1] = box
    end
    if #nodes == 0 then return nil end
    return {
        n = G.UIT.ROOT,
        config = { align = "cm", colour = G.C.CLEAR, padding = 0.04 },
        nodes = nodes,
    }
end

function HNDS.clear_platinum_boss_tooltip(sprite)
    if not sprite then return end

    if sprite.hnds_platinum_boss_tooltip_attached then
        sprite.hover = sprite.hnds_platinum_boss_native_hover
        sprite.stop_hover = sprite.hnds_platinum_boss_native_stop_hover
    end

    sprite.hovering = false
    sprite.hover_tilt = 0
    sprite.hnds_platinum_boss_tooltip_attached = nil
    sprite.hnds_platinum_boss_native_hover = nil
    sprite.hnds_platinum_boss_native_stop_hover = nil
    if sprite.config then
        sprite.config.hnds_platinum_boss_tooltip_ante = nil
        sprite.config.hnds_platinum_boss_tooltip_key = nil
        sprite.config.h_popup = nil
        sprite.config.h_popup_config = nil
    end
end

function HNDS.attach_platinum_boss_tooltip(sprite, blind_config)
    if not sprite then return end

    local ante = current_ante()
    local key = blind_config and blind_config.key
    local qualifies = blind_config
        and G and G.GAME and G.GAME.round_resets
        and key == boss_choice()
        and not is_devil_blind_key(key)
        and HNDS.platinum_boss_upgrade_count_for_ante(ante) > 0

    -- Blind/AnimatedSprite objects can be reused between encounters. Restore
    -- their native hover handlers as soon as the new physical Blind does not
    -- qualify for Boss+, otherwise the previous Ante's popup can survive even
    -- though none of its gameplay effects are active.
    if not qualifies then
        HNDS.clear_platinum_boss_tooltip(sprite)
        return
    end

    if not sprite.hnds_platinum_boss_tooltip_attached then
        sprite.hnds_platinum_boss_native_hover = sprite.hover
        sprite.hnds_platinum_boss_native_stop_hover = sprite.stop_hover
        sprite.hnds_platinum_boss_tooltip_attached = true
    end

    sprite.states.hover.can = true
    sprite.states.drag.can = false
    sprite.states.collide.can = true
    sprite.config = sprite.config or {}
    sprite.config.force_focus = true
    sprite.config.hnds_platinum_boss_tooltip_ante = ante
    sprite.config.hnds_platinum_boss_tooltip_key = key

    sprite.hover = function(_self)
        local stored_ante = _self.config and tonumber(_self.config.hnds_platinum_boss_tooltip_ante)
        local stored_key = _self.config and _self.config.hnds_platinum_boss_tooltip_key
        local still_current = stored_ante == current_ante()
            and stored_key == boss_choice()
            and HNDS.platinum_boss_upgrade_count_for_ante(current_ante()) > 0

        if not still_current then
            HNDS.clear_platinum_boss_tooltip(_self)
            return
        end

        if (not G.CONTROLLER.dragging.target or G.CONTROLLER.using_touch)
            and not _self.hovering and _self.states.visible
        then
            local popup = HNDS.create_platinum_boss_tooltip(stored_ante)
            if not popup then return end
            _self.hovering = true
            _self.hover_tilt = 3
            _self:juice_up(0.05, 0.02)
            play_sound("chips1", math.random() * 0.1 + 0.55, 0.12)
            _self.config.h_popup = popup
            _self.config.h_popup_config = {
                -- Attach outside the badge's right edge. The live Boss badge sits
                -- near the left side of the play HUD, so the old left anchor could
                -- place the popup beyond the game window and clip its contents.
                align = "cr", offset = { x = 0.1, y = 0 }, parent = _self,
            }
            Node.hover(_self)
        end
    end

    sprite.stop_hover = function(_self)
        _self.hovering = false
        _self.hover_tilt = 0
        Node.stop_hover(_self)
    end
end

-------------------------------------------------------------------
-- Boss UI rebuild after each upgrade
-------------------------------------------------------------------

function HNDS.rebuild_platinum_boss_option()
    if not (G and G.blind_select and G.blind_select_opts and G.blind_select_opts.boss) then return end
    local current_option = G.blind_select_opts.boss
    local parent = current_option.parent
    local boss = boss_choice()
    if not (parent and boss) then return end

    current_option:remove()
    G.blind_select_opts.boss = UIBox({
        T = { parent.T.x, 0, 0, 0 },
        definition = {
            n = G.UIT.ROOT,
            config = { align = "cm", colour = G.C.CLEAR },
            nodes = {
                UIBox_dyn_container(
                    { create_UIBox_blind_choice("Boss") },
                    false,
                    get_blind_main_colour(boss),
                    mix_colours(G.C.BLACK, get_blind_main_colour(boss), 0.8)
                ),
            },
        },
        config = {
            align = "bmi", offset = { x = 0, y = G.ROOM.T.y + 9 },
            major = parent, xy_bond = "Weak",
        },
    })

    local new_option = G.blind_select_opts.boss
    parent.config.object = new_option
    parent.config.object:recalculate()
    new_option.parent = parent
    new_option.alignment.offset.y = 0
end

-------------------------------------------------------------------
-- Active Boss+ effect delegation
-------------------------------------------------------------------

local function active_effect_hooks()
    local hooks = {}
    local ante = G and G.GAME and G.GAME.hnds_platinum_boss_stack_ante or current_ante()
    for _, blind_key in ipairs(HNDS.platinum_boss_effects_for_ante(ante)) do
        local hook_key = VANILLA_TO_HOOK[blind_key]
        if hook_key then hooks[#hooks + 1] = hook_key end
    end
    return hooks
end

local STACK_DEBUFF_FIELDS = { "h_size_ge", "h_size_le", "hand" }

local function restore_stacked_hand_debuff_fields(blind)
    local snapshot = blind and blind.hnds_platinum_debuff_snapshot
    if not (blind and type(snapshot) == "table") then return end
    blind.debuff = blind.debuff or {}
    for _, field in ipairs(STACK_DEBUFF_FIELDS) do
        local saved = snapshot[field]
        if saved and saved.present then
            blind.debuff[field] = saved.value
        else
            blind.debuff[field] = nil
        end
    end
    blind.hnds_platinum_debuff_snapshot = nil
end

local function apply_stacked_hand_debuff_fields(blind)
    if not blind then return end
    -- Snapshot the natural Blind values before adding delegated fields so a
    -- refresh/Ante transition can restore them exactly.
    restore_stacked_hand_debuff_fields(blind)
    blind.debuff = blind.debuff or {}
    local snapshot = {}
    for _, field in ipairs(STACK_DEBUFF_FIELDS) do
        snapshot[field] = {
            present = blind.debuff[field] ~= nil,
            value = blind.debuff[field],
        }
    end
    blind.hnds_platinum_debuff_snapshot = snapshot

    for _, hook_key in ipairs(active_effect_hooks()) do
        local component = HNDS.DEVIL_BOSSES and HNDS.DEVIL_BOSSES[hook_key]
        local debuff = component and component.debuff
        if debuff then
            for _, field in ipairs(STACK_DEBUFF_FIELDS) do
                if debuff[field] ~= nil then blind.debuff[field] = debuff[field] end
            end
        end
    end
end

local function live_stack_matches(blind)
    if not (G and G.GAME and blind) then return false end
    local center = blind.config and blind.config.blind
    local key = center and center.key
    return G.GAME.hnds_platinum_boss_stack_active == true
        and blind.hnds_platinum_boss_stack_active == true
        and tonumber(G.GAME.hnds_platinum_boss_stack_ante) == current_ante()
        and G.GAME.hnds_platinum_boss_stack_key == key
end

local function boss_stack_active()
    return blind_raiser_active()
        and G and G.GAME
        and G.GAME.blind_on_deck == "Boss"
        and HNDS.platinum_boss_upgrade_count_for_ante(current_ante()) > 0
end

function HNDS.start_platinum_boss_stack(blind)
    if not boss_stack_active() then
        if G and G.GAME and G.GAME.hnds_platinum_boss_stack_active
            and HNDS.stop_platinum_boss_stack
        then
            HNDS.stop_platinum_boss_stack({
                blind_defeated = true,
                hnds_scope_cleanup = true,
            })
        end
        return
    end

    -- `set_blind(nil, true, ...)` is a runtime refresh used by vanilla/SMODS
    -- when cards are sold/removed. Never restart the component lifecycle for
    -- the same live Boss: effects such as Needle/Water/Manacle are stateful.
    if live_stack_matches(blind) then return end

    if G.GAME.hnds_platinum_boss_stack_active and HNDS.stop_platinum_boss_stack then
        HNDS.stop_platinum_boss_stack({
            blind_defeated = true,
            hnds_scope_cleanup = true,
        })
    end

    local base_key = blind.config and blind.config.blind and blind.config.blind.key
    G.GAME.hnds_platinum_boss_stack_active = true
    G.GAME.hnds_platinum_boss_stack_ante = current_ante()
    G.GAME.hnds_platinum_boss_stack_key = base_key
    blind.hnds_platinum_boss_stack_active = true
    blind.hnds_platinum_boss_stack_ante = current_ante()

    -- Fish/Serpent drawing contexts are gated by Steamodded's active-Blind
    -- registry. Temporarily mark the real Boss as draw-modifying while Boss+
    -- carries either effect, then restore its original flag on cleanup.
    local needs_draw_context = false
    for _, hook_key in ipairs(active_effect_hooks()) do
        if hook_key == "bl_hook_the_fish" or hook_key == "bl_hook_the_serpent" then
            needs_draw_context = true
            break
        end
    end
    if needs_draw_context and base_key and SMODS and SMODS.Blinds and SMODS.Blinds.modifies_draw then
        G.GAME.hnds_platinum_boss_draw_key = base_key
        G.GAME.hnds_platinum_boss_draw_original = SMODS.Blinds.modifies_draw[base_key]
        SMODS.Blinds.modifies_draw[base_key] = true
    end

    for _, hook_key in ipairs(active_effect_hooks()) do
        local component = HNDS.DEVIL_BOSSES and HNDS.DEVIL_BOSSES[hook_key]
        if component then
            if component.set_blind then component:set_blind() end
            -- The original setting_blind context fired before this wrapper could
            -- activate Boss+. Replay it once for components such as The Needle.
            if component.calculate then component:calculate(blind, { setting_blind = true }) end
        end
    end

    -- Hand-validation fields (e.g. Psychic) must be merged onto the live
    -- Blind, but are snapshotted so they can never leak into the next Blind.
    apply_stacked_hand_debuff_fields(blind)

    -- Blind:set_blind evaluated the deck before Boss+ was active. Re-run card
    -- debuff evaluation now so The Club/Goad/Window/Head, Plant and Pillar are
    -- visible immediately rather than only after a later draw or hand.
    for _, card in ipairs(G.playing_cards or {}) do
        blind:debuff_card(card)
    end

    blind.loc_name = append_plus_to_name(blind.loc_name)

    -- The Blind-select badge receives this popup through Lovely. During the
    -- fight controller hover normally resolves to the active Blind object, not
    -- necessarily its child AnimatedSprite. Attach to both targets and repeat
    -- once after the badge's delayed reveal so neither vanilla's reveal event
    -- nor another UI layer can leave the live Boss badge without its tooltip.
    local function attach_live_tooltip()
        if not (G and G.GAME and G.GAME.blind == blind) then return end
        local blind_config = blind.config and blind.config.blind
        HNDS.attach_platinum_boss_tooltip(blind, blind_config)
        if blind.children and blind.children.animatedSprite then
            HNDS.attach_platinum_boss_tooltip(blind.children.animatedSprite, blind_config)
        end
    end

    attach_live_tooltip()
    if G.E_MANAGER and Event then
        G.E_MANAGER:add_event(Event({
            trigger = "after",
            delay = 0.2,
            blockable = false,
            blocking = false,
            func = function()
                attach_live_tooltip()
                return true
            end,
        }))
    end
end

function HNDS.calculate_platinum_boss_stack(context)
    if not (G and G.GAME and G.GAME.hnds_platinum_boss_stack_active and context) then return nil end
    local live_blind = G.GAME.blind
    if not live_stack_matches(live_blind) then return nil end
    -- Steamodded versions differ in how mod-level {debuff = true} results are
    -- consumed. Blind:debuff_card below is the single authoritative path.
    if context.debuff_card then return nil end
    local blind = live_blind
    if not blind then return nil end

    -- Luchador and Chicot mark the live Blind disabled. Once that happens no
    -- delegated Boss+ effect may continue firing. Cleanup contexts are still
    -- allowed through for compatibility with Steamodded's normal lifecycle.
    local cleanup_context = context.blind_disabled or context.blind_defeated
    if blind.disabled and not cleanup_context then return nil end

    local first_result = nil
    for _, hook_key in ipairs(active_effect_hooks()) do
        local component = HNDS.DEVIL_BOSSES and HNDS.DEVIL_BOSSES[hook_key]
        if component and component.calculate then
            local result = component:calculate(blind, context)
            if result and not first_result then first_result = result end
        end
    end
    return first_result
end

local function component_debuffs_card(component, blind, card)
    if not (component and blind and card) then return false end
    if G and G.jokers and card.area == G.jokers then return false end

    -- Declarative fallback covers suit-debuff components that use a vanilla-style
    -- debuff table. The calculate call covers Plant/Pillar and all suit Bosses.
    local debuff = component.debuff
    if debuff then
        if debuff.suit and card.is_suit and card:is_suit(debuff.suit, true) then return true end
    end

    if component.calculate then
        local result = component:calculate(blind, {
            debuff_card = card,
            debuff_source = blind,
        })
        return result == true or (type(result) == "table" and result.debuff == true)
    end
    return false
end

local function active_stacked_components_debuff_card(blind, card)
    if not (G and G.GAME and blind and card) or blind.disabled then return false end

    -- Effects added by Blind Raiser upgrades. The per-Blind marker prevents
    -- a stale global flag from affecting a Small/Big/new-Ante Blind.
    if live_stack_matches(blind) then
        for _, hook_key in ipairs(active_effect_hooks()) do
            local component = HNDS.DEVIL_BOSSES and HNDS.DEVIL_BOSSES[hook_key]
            if component_debuffs_card(component, blind, card) then return true end
        end
    end

    -- The Devil is itself a component stack. Include its rolled effects so a
    -- Devil+ fight uses the same reliable card-debuff path for both sources.
    if G.GAME.hnds_devil_active then
        for _, hook_key in ipairs(G.GAME.hnds_devil_bosses or {}) do
            local component = HNDS.DEVIL_BOSSES and HNDS.DEVIL_BOSSES[hook_key]
            if component_debuffs_card(component, blind, card) then return true end
        end
    end

    return false
end

local Blind_debuff_card_ref = Blind.debuff_card
function Blind:debuff_card(card, from_blind, ...)
    -- Let the natural Boss and every other mod resolve first. A stacked card
    -- debuffer then ORs its own result on top; it never replaces the natural
    -- Boss's suit/type and cannot accidentally clear another debuff source.
    local result = Blind_debuff_card_ref(self, card, from_blind, ...)
    if active_stacked_components_debuff_card(self, card) then
        card:set_debuff(true)
    end
    return result
end

function HNDS.stop_platinum_boss_stack(cleanup_context)
    if not (G and G.GAME and G.GAME.hnds_platinum_boss_stack_active) then return end

    local blind = G.GAME.blind
    local hooks = active_effect_hooks()
    local context = type(cleanup_context) == "table"
        and cleanup_context
        or { blind_disabled = true }

    -- Disable delegation before invoking cleanup. Blind:disable() itself emits
    -- a blind_disabled context on some Steamodded versions; clearing this first
    -- prevents the same component cleanup from running twice.
    G.GAME.hnds_platinum_boss_stack_active = nil
    if blind then
        blind.hnds_platinum_boss_stack_active = nil
        blind.hnds_platinum_boss_stack_ante = nil
        restore_stacked_hand_debuff_fields(blind)
    end

    for _, hook_key in ipairs(hooks) do
        local component = HNDS.DEVIL_BOSSES and HNDS.DEVIL_BOSSES[hook_key]
        if component then
            if component.calculate then component:calculate(blind, context) end
            if component.disable then component:disable() end
        end
    end

    local draw_key = G.GAME.hnds_platinum_boss_draw_key
    if draw_key and SMODS and SMODS.Blinds and SMODS.Blinds.modifies_draw then
        SMODS.Blinds.modifies_draw[draw_key] = G.GAME.hnds_platinum_boss_draw_original
    end
    G.GAME.hnds_platinum_boss_draw_key = nil
    G.GAME.hnds_platinum_boss_draw_original = nil
    G.GAME.hnds_platinum_boss_stack_ante = nil
    G.GAME.hnds_platinum_boss_stack_key = nil
end

local Blind_set_text_ref = Blind.set_text
function Blind:set_text(...)
    local result = Blind_set_text_ref(self, ...)
    if blind_raiser_active()
        and G and G.GAME and G.GAME.blind_on_deck == "Boss"
        and HNDS.platinum_boss_upgrade_count_for_ante(current_ante()) > 0
    then
        self.loc_name = append_plus_to_name(self.loc_name)
    end
    return result
end

function HNDS.sync_live_platinum_blind_score(blind, capture_base)
    if not (blind_raiser_active() and G and G.GAME and blind) then return false end
    local slot = G.GAME.blind_on_deck
    local ante = current_ante()
    local score = nil

    if slot == "Small" or slot == "Big" then
        local record = replacement_record(slot, ante)
        if type(record) == "table" then
            score = score_from_replacement_record(slot, record)
        end
    end

    -- Keep a stable *unscaled* score for the physical encounter. Vanilla/SMODS
    -- may call set_blind(nil, true, ...) while selling/removing a card. On that
    -- refresh path blind.chips can already contain our +20% multiplier, so
    -- multiplying the live value again causes the requirement to climb on
    -- every sale. Capture only when a genuinely new Blind is installed (or
    -- when recovering an old save with no cached base), then always recompute
    -- from that same base.
    if not score then
        local center = blind.config and blind.config.blind
        local center_key = center and center.key
        local cache_matches = blind.hnds_platinum_score_base ~= nil
            and blind.hnds_platinum_score_ante == ante
            and blind.hnds_platinum_score_slot == slot
            and blind.hnds_platinum_score_key == center_key

        if capture_base or not cache_matches then
            blind.hnds_platinum_score_base = blind.chips
            blind.hnds_platinum_score_ante = ante
            blind.hnds_platinum_score_slot = slot
            blind.hnds_platinum_score_key = center_key
        end

        local base = blind.hnds_platinum_score_base
        if base ~= nil then
            local ok, scaled = pcall(function()
                return base * HNDS.platinum_blind_raiser_multiplier()
            end)
            if ok then score = scaled end
        end
    end

    if score == nil then return false end
    blind.chips = score
    blind.chip_text = number_format(score)
    return true
end

local Blind_set_blind_ref = Blind.set_blind
function Blind:set_blind(blind, reset, silent, ...)
    local slot_before = G and G.GAME and G.GAME.blind_on_deck
    local ante_before = current_ante()
    local incoming_key = blind and blind.key
    local stack_key = G and G.GAME and G.GAME.hnds_platinum_boss_stack_key
    local same_boss_refresh = blind == nil
        and slot_before == "Boss"
        and G and G.GAME
        and G.GAME.hnds_platinum_boss_stack_active == true
        and tonumber(G.GAME.hnds_platinum_boss_stack_ante) == ante_before
        and self.hnds_platinum_boss_stack_active == true

    -- A new physical Blind (especially the next Ante's Small/Big) is a hard
    -- scope boundary. Clean any stale Boss+ runtime before vanilla configures
    -- the new Blind so previous-Ante component state cannot bleed into it.
    if G and G.GAME and G.GAME.hnds_platinum_boss_stack_active then
        local stale_scope = slot_before ~= "Boss"
            or tonumber(G.GAME.hnds_platinum_boss_stack_ante) ~= ante_before
            or (blind ~= nil and stack_key ~= nil and incoming_key ~= stack_key)
        if stale_scope then
            HNDS.stop_platinum_boss_stack({
                blind_defeated = true,
                hnds_scope_cleanup = true,
            })
            same_boss_refresh = false
        elseif same_boss_refresh then
            -- Remove only fields injected by Boss+ before vanilla refreshes the
            -- same Boss; they will be merged back afterwards without replaying
            -- any setting_blind/set_blind component side effects.
            restore_stacked_hand_debuff_fields(self)
        end
    end

    local new_physical_blind = blind ~= nil
    if new_physical_blind then
        -- The live Blind object (and sometimes its child sprite) is reused for
        -- the next encounter. Remove any custom Boss+/Devil hover handlers before
        -- vanilla installs the new center so old Ante popup state cannot survive.
        if HNDS.clear_platinum_boss_tooltip then
            HNDS.clear_platinum_boss_tooltip(self)
            if self.children and self.children.animatedSprite then
                HNDS.clear_platinum_boss_tooltip(self.children.animatedSprite)
            end
        end
        if HNDS.clear_devil_blind_tooltip then
            HNDS.clear_devil_blind_tooltip(self)
            if self.children and self.children.animatedSprite then
                HNDS.clear_devil_blind_tooltip(self.children.animatedSprite)
            end
        end

        self.hnds_platinum_score_base = nil
        self.hnds_platinum_score_ante = nil
        self.hnds_platinum_score_slot = nil
        self.hnds_platinum_score_key = nil
    end

    local result = Blind_set_blind_ref(self, blind, reset, silent, ...)

    -- Persist the physical slot on the live Blind. This remains reliable during
    -- end-of-round transitions where blind_on_deck may already be advancing.
    self.hnds_platinum_replacement_slot = nil
    self.hnds_platinum_replacement_ante = nil
    if blind_raiser_active() and G and G.GAME then
        local slot = G.GAME.blind_on_deck
        if (slot == "Small" or slot == "Big")
            and type(replacement_record(slot, current_ante())) == "table"
        then
            self.hnds_platinum_replacement_slot = slot
            self.hnds_platinum_replacement_ante = current_ante()
        end

        HNDS.sync_live_platinum_blind_score(self, new_physical_blind)

        if slot == "Boss" then
            if same_boss_refresh and live_stack_matches(self) then
                -- Refresh only the declarative/debuff presentation. Stateful
                -- component setup (Needle/Water/Manacle/etc.) must run once.
                apply_stacked_hand_debuff_fields(self)
                for _, card in ipairs(G.playing_cards or {}) do
                    self:debuff_card(card)
                end
                self.loc_name = append_plus_to_name(self.loc_name)
            else
                HNDS.start_platinum_boss_stack(self)
            end
        else
            self.hnds_platinum_boss_stack_active = nil
            self.hnds_platinum_boss_stack_ante = nil
            restore_stacked_hand_debuff_fields(self)
        end

        if G.HUD_blind and G.HUD_blind.recalculate then
            G.HUD_blind:recalculate(false)
        end
    end
    return result
end

local Blind_disable_ref = Blind.disable
function Blind:disable(...)
    -- Luchador/Chicot must disable the complete Boss+, not only the natural
    -- Blind. Tear down delegated effects first, then let vanilla disable and
    -- clean up the natural Boss effect.
    if G and G.GAME and G.GAME.hnds_platinum_boss_stack_active then
        HNDS.stop_platinum_boss_stack({ blind_disabled = true })
    end
    return Blind_disable_ref(self, ...)
end

local Blind_defeat_ref = Blind.defeat
function Blind:defeat(...)
    -- Normal victory uses the same explicit cleanup path. This is especially
    -- important for The Manacle if the stack was disabled earlier by Chicot.
    if G and G.GAME and G.GAME.hnds_platinum_boss_stack_active then
        HNDS.stop_platinum_boss_stack({ blind_defeated = true })
    end
    return Blind_defeat_ref(self, ...)
end
