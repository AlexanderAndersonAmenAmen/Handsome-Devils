-------------------------------------------------------------------
-- PLATINUM STAKE: BOSS STACKING + SCORE PREVIEWS
-------------------------------------------------------------------

HNDS = HNDS or {}

local VANILLA_TO_HOOK = {
    bl_house = "bl_hook_the_house",
    bl_wall = "bl_hook_the_wall",
    bl_wheel = "bl_hook_the_wheel",
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

HNDS.PLATINUM_STACKABLE_BLINDS = VANILLA_TO_HOOK
HNDS.PLATINUM_HOOK_TO_BLIND = HOOK_TO_VANILLA

local function platinum_active()
    return G and G.GAME and G.GAME.hnds_platinum_active
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

local function candidate_is_ante_eligible(blind)
    local boss = blind and blind.boss
    if not boss then return false end
    local ante = current_ante()
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
    -- The Wall and The Needle are never valid Small/Big Blind upgrade results.
    if blind_key == 'bl_wall' or blind_key == 'bl_needle' then return false end
    -- The Pillar is excessively punishing as the very first upgraded Blind and
    -- is explicitly excluded only from Ante 1 Small Blind upgrades.
    if tonumber(ante) == 1 and blind_choice == 'Small' and blind_key == 'bl_pillar' then
        return false
    end
    if G.GAME.banned_keys and G.GAME.banned_keys[blind_key] then return false end
    if blind_key == boss_choice() then return false end
    if upgraded_replacement_bosses_for_ante(ante)[blind_key] then return false end
    if not relaxed_pool
        and (not candidate_is_ante_eligible(blind) or not blind_is_in_pool(blind))
    then
        return false
    end

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

    -- Some vanilla in_pool/min-Ante predicates are evaluated against the real
    -- Boss slot and can leave the second Ante 1 upgrade with no candidates even
    -- though several non-showdown Bosses are valid as replacement components.
    -- Retry only the pool/Ante eligibility layer; duplicate and combination
    -- restrictions remain fully enforced.
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
    local exact = records[tostring(tonumber(ante) or current_slot_ante()) .. ":" .. tostring(blind_choice)]
    if type(exact) == "table" then return exact end

    local best, best_ante = nil, -math.huge
    for key, record in pairs(records) do
        if type(record) == "table" then
            local key_ante, key_choice = key:match("^(-?%d+):([%a_]+)$")
            local record_ante = tonumber(record.ante) or tonumber(key_ante)
            local record_choice = record.blind_choice or key_choice
            if record_choice == blind_choice and record_ante and record_ante >= best_ante then
                best, best_ante = record, record_ante
            end
        end
    end
    return best
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

function HNDS.platinum_next_upgrade_score(blind_choice)
    local base = regular_score_for_slot(blind_choice, current_ante())
    if not base then return nil end
    -- Every upgraded Small/Big Blind is exactly twice that slot's normal
    -- requirement. The run-wide upgrade count affects only the real Boss.
    return base * 2
end

function HNDS.platinum_boss_score_for_ante(ante, extra_upgrades)
    if not (G and G.GAME and G.P_BLINDS and type(get_blind_amount) == "function") then return nil end
    ante = tonumber(ante) or current_ante()
    local boss_key = boss_choice()
    local boss = boss_key and G.P_BLINDS[boss_key]
    local mult = boss and tonumber(boss.mult)
    if not mult then return nil end
    local count = HNDS.platinum_boss_upgrade_count_for_ante(ante)
        + math.max(0, tonumber(extra_upgrades) or 0)
    local scaling = G.GAME.starting_params and G.GAME.starting_params.ante_scaling or 1
    return get_blind_amount(ante) * (mult + count) * scaling
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
    return {
        title = dictionary_text(
            "hnds_blind_raiser_tooltip_title",
            nil,
            "Score if upgraded"
        ),
        text = {
            dictionary_text(
                "hnds_blind_raiser_tooltip_current_blind",
                { formatted_blind },
                "Current Blind: " .. tostring(formatted_blind)
            ),
            dictionary_text(
                "hnds_blind_raiser_tooltip_boss_blind",
                { formatted_boss },
                "Boss Blind: " .. tostring(formatted_boss)
            ),
        },
    }
end

function HNDS.adjust_platinum_blind_preview_amount(blind_choice, vanilla_amount, blind_config)
    if not platinum_active() then return vanilla_amount end

    if blind_choice == "Small" or blind_choice == "Big" then
        local record = replacement_record(blind_choice, current_ante())
        if type(record) == "table" then
            local base = regular_score_for_slot(blind_choice, record.ante or current_ante())
            if base then return base * 2 end
        end
    elseif blind_choice == "Boss" then
        local score = HNDS.platinum_boss_score_for_ante(current_ante(), 0)
        if score then return score end
    end

    return vanilla_amount
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
function localize(args, misc_cat, misc_loc, silent)
    local result = localize_platinum_ref(args, misc_cat, misc_loc, silent)
    if type(args) == "table"
        and args.type == "name_text"
        and args.set == "Blind"
        and platinum_active()
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

function HNDS.create_platinum_upgrade_effect_boxes(ante)
    local nodes = {}
    for _, blind_key in ipairs(HNDS.platinum_boss_effects_for_ante(ante or current_ante())) do
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

function HNDS.attach_platinum_boss_tooltip(sprite, blind_config)
    if not (sprite and blind_config and G and G.GAME and G.GAME.round_resets) then return end
    if blind_config.key ~= boss_choice() then return end
    -- The Devil's handler preserves its three original individual effect boxes
    -- and appends upgrade boxes. The generic Boss+ handler must not overwrite it.
    if is_devil_blind_key(blind_config.key) then return end
    if HNDS.platinum_boss_upgrade_count_for_ante(current_ante()) < 1 then return end

    sprite.states.hover.can = true
    sprite.states.drag.can = false
    sprite.states.collide.can = true
    sprite.config = sprite.config or {}
    sprite.config.force_focus = true
    sprite.config.hnds_platinum_boss_tooltip_ante = current_ante()

    sprite.hover = function(_self)
        if (not G.CONTROLLER.dragging.target or G.CONTROLLER.using_touch)
            and not _self.hovering and _self.states.visible
        then
            local popup = HNDS.create_platinum_boss_tooltip(
                _self.config.hnds_platinum_boss_tooltip_ante or current_ante()
            )
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

local function boss_stack_active(blind)
    return platinum_active()
        and G and G.GAME
        and (G.GAME.blind_on_deck == "Boss" or (blind and blind.boss))
        and HNDS.platinum_boss_upgrade_count_for_ante(current_ante()) > 0
end

function HNDS.start_platinum_boss_stack(blind)
    if not boss_stack_active(blind) then
        if G and G.GAME then G.GAME.hnds_platinum_boss_stack_active = nil end
        return
    end

    G.GAME.hnds_platinum_boss_stack_active = true
    G.GAME.hnds_platinum_boss_stack_ante = current_ante()

    -- Fish/Serpent drawing contexts are gated by Steamodded's active-Blind
    -- registry. Temporarily mark the real Boss as draw-modifying while Boss+
    -- carries either effect, then restore its original flag on cleanup.
    local base_key = blind.config and blind.config.blind and blind.config.blind.key
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
            if component.debuff then
                blind.debuff = blind.debuff or {}
                if component.debuff.suit then blind.debuff.suit = component.debuff.suit end
                if component.debuff.is_face then blind.debuff.is_face = true end
                if component.debuff.h_size_ge then blind.debuff.h_size_ge = component.debuff.h_size_ge end
            end
            -- The original setting_blind context fired before this wrapper could
            -- activate Boss+. Replay it once for components such as The Needle.
            if component.calculate then component:calculate(blind, { setting_blind = true }) end
        end
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
    local blind = G.GAME.blind
    if not blind then return nil end

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

function HNDS.stop_platinum_boss_stack()
    if not (G and G.GAME and G.GAME.hnds_platinum_boss_stack_active) then return end
    for _, hook_key in ipairs(active_effect_hooks()) do
        local component = HNDS.DEVIL_BOSSES and HNDS.DEVIL_BOSSES[hook_key]
        if component and component.disable then component:disable() end
    end
    local draw_key = G.GAME.hnds_platinum_boss_draw_key
    if draw_key and SMODS and SMODS.Blinds and SMODS.Blinds.modifies_draw then
        SMODS.Blinds.modifies_draw[draw_key] = G.GAME.hnds_platinum_boss_draw_original
    end
    G.GAME.hnds_platinum_boss_draw_key = nil
    G.GAME.hnds_platinum_boss_draw_original = nil
    G.GAME.hnds_platinum_boss_stack_active = nil
    G.GAME.hnds_platinum_boss_stack_ante = nil
end

local Blind_set_text_ref = Blind.set_text
function Blind:set_text(...)
    local result = Blind_set_text_ref(self, ...)
    if platinum_active()
        and G and G.GAME and G.GAME.blind_on_deck == "Boss"
        and HNDS.platinum_boss_upgrade_count_for_ante(current_ante()) > 0
    then
        self.loc_name = append_plus_to_name(self.loc_name)
    end
    return result
end

function HNDS.sync_live_platinum_blind_score(blind)
    if not (platinum_active() and G and G.GAME and blind) then return false end
    local slot = G.GAME.blind_on_deck
    local score = nil

    if slot == "Small" or slot == "Big" then
        local record = replacement_record(slot, current_ante())
        if type(record) == "table" then
            local base = regular_score_for_slot(slot, record.ante or current_ante())
            if base then score = base * 2 end
        end
    elseif slot == "Boss" then
        score = HNDS.platinum_boss_score_for_ante(current_ante(), 0)
    end

    if not score then return false end
    blind.chips = score
    blind.chip_text = number_format(score)
    return true
end

local Blind_set_blind_ref = Blind.set_blind
function Blind:set_blind(blind, reset, silent)
    local result = Blind_set_blind_ref(self, blind, reset, silent)
    if platinum_active() and G and G.GAME then
        local slot = G.GAME.blind_on_deck
        HNDS.sync_live_platinum_blind_score(self)
        if slot == "Boss" then HNDS.start_platinum_boss_stack(self) end
        if G.HUD_blind and G.HUD_blind.recalculate then
            G.HUD_blind:recalculate(false)
        end
    end
    return result
end

local Blind_disable_ref = Blind.disable
function Blind:disable(...)
    local stacked = G and G.GAME and G.GAME.hnds_platinum_boss_stack_active
    local result = Blind_disable_ref(self, ...)
    if stacked then HNDS.stop_platinum_boss_stack() end
    return result
end
