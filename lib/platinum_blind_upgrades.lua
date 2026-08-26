


HNDS = HNDS or {}

local function ensure_blind_raiser_state()
    if not (G and G.GAME) then return false end
    G.GAME.hnds_upgraded_blinds = G.GAME.hnds_upgraded_blinds or {}
    G.GAME.hnds_platinum_blind_replacements =
        G.GAME.hnds_platinum_blind_replacements or {}
    G.GAME.hnds_blind_upgrades = G.GAME.hnds_blind_upgrades or 0
    return true
end

local function nightmare_active()
    return G and G.GAME and G.GAME.modifiers
        and G.GAME.modifiers.hnds_nightmare_stake == true
end

local function upgraded_blinds()
    if not (G and G.GAME) then return {} end
    G.GAME.hnds_upgraded_blinds = G.GAME.hnds_upgraded_blinds or {}
    return G.GAME.hnds_upgraded_blinds
end

local function current_ante()
    return G
        and G.GAME
        and G.GAME.round_resets
        and G.GAME.round_resets.ante
        or 0
end

local function upgrade_key(blind_choice)
    return tostring(current_ante()) .. ':' .. tostring(blind_choice)
end

local function blind_state(blind_choice)
    return G
        and G.GAME
        and G.GAME.round_resets
        and G.GAME.round_resets.blind_states
        and G.GAME.round_resets.blind_states[blind_choice]
end

local function blind_is_finished(blind_choice)
    local state = blind_state(blind_choice)
    return state == 'Defeated' or state == 'Skipped'
end

local function blind_is_current(blind_choice)
    if not ensure_blind_raiser_state() or blind_is_finished(blind_choice) then
        return false
    end

    local states = G.GAME.round_resets
        and G.GAME.round_resets.blind_states or {}
    local state = states[blind_choice]


    if G.GAME.blind_on_deck == blind_choice
        or state == 'Select'
        or state == 'Current'
    then
        return true
    end


    if blind_choice == 'Big'
        and (states.Small == 'Defeated' or states.Small == 'Skipped')
        and states.Big ~= 'Defeated'
        and states.Big ~= 'Skipped'
    then
        return true
    end

    return false
end

local function blind_was_upgraded(blind_choice)
    return upgraded_blinds()[upgrade_key(blind_choice)] == true
end

local function can_upgrade(blind_choice)
    return blind_is_current(blind_choice)
        and not blind_was_upgraded(blind_choice)
end

local function replacement_records()
    if not (G and G.GAME) then return {} end
    G.GAME.hnds_platinum_blind_replacements =
        G.GAME.hnds_platinum_blind_replacements or {}
    return G.GAME.hnds_platinum_blind_replacements
end

-- Shared upgrade commit used by the manual Upgrade Blind callback and the
-- automatic Nightmare Stake upgrade: persist the replacement record, bump
-- run counters/exponents, swap the Blind choice, and record the stacked
-- Boss effect. All mutations are synchronous table writes, so callers may
-- interleave UI work freely around this call.
function HNDS.commit_platinum_upgrade(blind_choice, boss)
    local choices = G.GAME.round_resets.blind_choices
    local key = upgrade_key(blind_choice)
    local actual_upgrade_count = (G.GAME.hnds_blind_upgrades or 0) + 1
    local upgrade_index = HNDS.platinum_next_upgrade_exponent
        and HNDS.platinum_next_upgrade_exponent() or actual_upgrade_count
    replacement_records()[key] = {
        ante = current_ante(),
        blind_choice = blind_choice,
        original = choices[blind_choice],
        boss = boss,
        upgrade_index = upgrade_index,
    }

    upgraded_blinds()[key] = true
    G.GAME.hnds_blind_upgrades = actual_upgrade_count
    if HNDS.set_platinum_blind_raiser_applied_step then
        HNDS.set_platinum_blind_raiser_applied_step(upgrade_index)
    end
    if HNDS.set_platinum_next_upgrade_exponent then
        HNDS.set_platinum_next_upgrade_exponent(upgrade_index + 1)
    end
    choices[blind_choice] = boss
    if HNDS.record_platinum_boss_effect then
        HNDS.record_platinum_boss_effect(boss, current_ante())
    end
end

-- Grant the Skip Tag reward and return only the newly granted Tags,
-- including copies produced synchronously by Double Tags.
function HNDS.grant_platinum_reward_tags(reward_tag)
    local preexisting_tags = {}
    for _, tag in ipairs(G.GAME.tags or {}) do
        preexisting_tags[tag] = true
    end

    add_tag(reward_tag)

    local granted_tags = {}
    for _, tag in ipairs(G.GAME.tags or {}) do
        if not preexisting_tags[tag] then
            granted_tags[#granted_tags + 1] = tag
        end
    end
    return granted_tags
end

-- Trigger immediate effects for every granted Tag, then let exactly one
-- Tag consume the new-blind-choice event.
function HNDS.apply_platinum_reward_tags(granted_tags)
    for _, tag in ipairs(granted_tags) do
        tag:apply_to_run({ type = 'immediate' })
    end
    for _, tag in ipairs(granted_tags) do
        if tag:apply_to_run({ type = 'new_blind_choice' }) then
            break
        end
    end
end

local function parse_upgrade_key(key)
    if type(key) ~= 'string' then return nil, nil end
    local ante, blind_choice = key:match('^(-?%d+):([%a_]+)$')
    return tonumber(ante), blind_choice
end

local function excommunicado_active()
    if HNDS and HNDS.excommunicado_effect_active then
        return HNDS.excommunicado_effect_active()
    end
    if not (SMODS and SMODS.find_card) then return false end
    local cards = SMODS.find_card('j_hnds_excommunicado')
    return cards and next(cards) ~= nil
end


HNDS.restore_stale_platinum_blind_slots = function()
    if not ensure_blind_raiser_state() then return end
    if not (G.GAME.round_resets and G.GAME.round_resets.blind_choices) then return end

    local ante = current_ante()


    if G.GAME.hnds_platinum_boss_stack_active
        and tonumber(G.GAME.hnds_platinum_boss_stack_ante) ~= ante
        and HNDS.stop_platinum_boss_stack
    then
        HNDS.stop_platinum_boss_stack({
            blind_defeated = true,
            hnds_scope_cleanup = true,
        })
    end

    local choices = G.GAME.round_resets.blind_choices
    local upgrades = upgraded_blinds()
    local records = replacement_records()
    local stale_slots = {}


    for key, was_upgraded in pairs(upgrades) do
        local key_ante, blind_choice = parse_upgrade_key(key)
        if was_upgraded and key_ante and key_ante ~= ante
            and (blind_choice == 'Small' or blind_choice == 'Big')
        then
            stale_slots[blind_choice] = true
        end
    end

    local excom = excommunicado_active()


    local stale_record_keys = {}
    for key, record in pairs(records) do
        local key_ante, key_choice = parse_upgrade_key(key)
        local blind_choice = type(record) == 'table' and record.blind_choice or key_choice
        local record_ante = type(record) == 'table' and tonumber(record.ante) or key_ante

        if record_ante and record_ante ~= ante
            and (blind_choice == 'Small' or blind_choice == 'Big')
        then
            if not excom and type(record) == 'table'
                and choices[blind_choice] == record.boss
            then
                choices[blind_choice] = record.original
                    or ('bl_' .. blind_choice:lower())
            end
            stale_record_keys[#stale_record_keys + 1] = key
        end
    end
    for _, key in ipairs(stale_record_keys) do
        records[key] = nil
    end


    if not excom then
        for _, blind_choice in ipairs({ 'Small', 'Big' }) do
            local choice = choices[blind_choice]
            local blind = choice and G.P_BLINDS and G.P_BLINDS[choice]
            if stale_slots[blind_choice] and blind and blind.boss then
                choices[blind_choice] = 'bl_' .. blind_choice:lower()
            end
        end
    end


    local stale_upgrade_keys = {}
    for key in pairs(upgrades) do
        local key_ante = parse_upgrade_key(key)
        if key_ante and key_ante ~= ante then
            stale_upgrade_keys[#stale_upgrade_keys + 1] = key
        end
    end
    for _, key in ipairs(stale_upgrade_keys) do
        upgrades[key] = nil
    end

    if HNDS.prune_platinum_boss_stack_records then
        HNDS.prune_platinum_boss_stack_records(ante)
    end
end

HNDS.platinum_skip_is_locked = function(blind_choice)
    return ensure_blind_raiser_state()
        and blind_choice ~= nil
        and blind_was_upgraded(blind_choice)
end

local function set_runtime_button(button, active, callback)
    if not (button and button.config) then return end

    button.config.button = active and callback or nil
    button.config.hover = active
    button.config.colour = active and G.C.RED or G.C.UI.BACKGROUND_INACTIVE
    if active then button.disable_button = nil end


    if button.states then
        if button.states.collide then button.states.collide.can = active end
        if button.states.click then button.states.click.can = active end
        if button.states.hover then button.states.hover.can = active end
    end

    local label = button.children and button.children[1]
    if label and label.config then
        label.config.colour = active and G.C.UI.TEXT_LIGHT or G.C.UI.TEXT_INACTIVE
    end
end


local function set_upgrade_runtime_button(button, active)
    if not (button and button.config) then return end

    button.config.button = 'hnds_upgrade_blind'
    button.config.hnds_upgrade_ready = active == true
    button.config.hover = true
    button.config.colour = active and G.C.RED or G.C.UI.BACKGROUND_INACTIVE
    button.disable_button = nil

    if button.states then
        if button.states.collide then button.states.collide.can = active end
        if button.states.click then button.states.click.can = active end
        if button.states.hover then button.states.hover.can = true end
    end

    local label = button.children and button.children[1]
    if label and label.config then
        label.config.colour = active and G.C.UI.TEXT_LIGHT or G.C.UI.TEXT_INACTIVE
    end
end

local function ui_root_candidates(e, blind_choice)
    local roots = {}

    if e and e.UIBox then
        roots[#roots + 1] = e.UIBox
    end

    local blind_option = G
        and G.blind_select_opts
        and blind_choice
        and G.blind_select_opts[blind_choice:lower()]

    if blind_option then
        roots[#roots + 1] = blind_option
        if blind_option.parent then
            roots[#roots + 1] = blind_option.parent
            if blind_option.parent.config and blind_option.parent.config.object then
                roots[#roots + 1] = blind_option.parent.config.object
            end
        end
    end

    return roots
end

local function get_runtime_element(e, blind_choice, id)
    for _, root in ipairs(ui_root_candidates(e, blind_choice)) do
        if root and root.get_UIE_by_ID then
            local element = root:get_UIE_by_ID(id)
            if element then return element end
        end
    end
    return nil
end


local function find_ui_object_parent(root, object)
    if not (root and object) then return nil end
    local node = root.UIRoot or root
    if node.config and node.config.object == object then return node end
    for _, child in pairs(node.children or {}) do
        local found = find_ui_object_parent(child, object)
        if found then return found end
    end
    return nil
end

local function blind_option_parent(blind_option)
    if not blind_option then return nil end
    local parent = blind_option.parent
        or (blind_option.config and blind_option.config.major)
    if parent and parent ~= blind_option then return parent end


    return find_ui_object_parent(G and G.blind_select, blind_option)
end


HNDS.sync_platinum_blind_tag_ui = function(e)
    if not (ensure_blind_raiser_state() and e and e.config) then return end


    if HNDS.apply_pending_nightmare_shop_upgrade
        and G and G.GAME
        and not G.GAME.hnds_nightmare_shop_upgrade_applying
        and HNDS.apply_pending_nightmare_shop_upgrade()
    then
        return
    end

    local blind_choice = e.config.id
    if not blind_choice then return end

    local upgrade_button = get_runtime_element(
        e,
        blind_choice,
        'hnds_upgrade_blind_button_' .. blind_choice
    )

    local upgraded = blind_was_upgraded(blind_choice)
    local current = blind_is_current(blind_choice)

    set_upgrade_runtime_button(upgrade_button, current and not upgraded)

    local skip_button = get_runtime_element(
        e,
        blind_choice,
        'hnds_skip_blind_button_' .. blind_choice
    )
    set_runtime_button(skip_button, current and not upgraded, 'skip_blind')
end


G.FUNCS.hnds_update_skip_blind_button = function(e)
    if not (e and e.config) then return end

    local blind_choice = e.config.hnds_blind_choice
    local active = blind_choice
        and blind_is_current(blind_choice)
        and not blind_was_upgraded(blind_choice)
    set_runtime_button(e, active, 'skip_blind')
    if G.FUNCS.hover_tag_proxy then G.FUNCS.hover_tag_proxy(e) end
end

G.FUNCS.hnds_update_upgrade_blind_button = function(e)
    if not (e and e.config) then return end

    local blind_choice = e.config.hnds_blind_choice
    local active = blind_choice and can_upgrade(blind_choice) or false


    set_upgrade_runtime_button(e, active)


    e.config.hover = true
    if e.states and e.states.hover then e.states.hover.can = true end
    e.config.tooltip = HNDS.platinum_upgrade_button_tooltip
        and HNDS.platinum_upgrade_button_tooltip(blind_choice)
        or nil
end


local function hnds_valid_blind_choice(key)
    return type(key) == 'string' and G and G.P_BLINDS and G.P_BLINDS[key] ~= nil
end

local function hnds_emergency_boss_choice()
    if not (G and G.P_BLINDS) then return nil end
    local banned = G.GAME and G.GAME.banned_keys or {}
    local normal, showdown = {}, {}
    for key, blind in pairs(G.P_BLINDS) do
        if blind and blind.boss and not banned[key] then
            if blind.boss.showdown then
                showdown[#showdown + 1] = key
            else
                normal[#normal + 1] = key
            end
        end
    end
    table.sort(normal)
    table.sort(showdown)
    return normal[1] or showdown[1]
end

local function hnds_repair_blind_choices_for_ui()
    if not (G and G.GAME and G.GAME.round_resets and G.P_BLINDS) then return end
    local choices = G.GAME.round_resets.blind_choices
    if type(choices) ~= 'table' then return end

    if not hnds_valid_blind_choice(choices.Small) and G.P_BLINDS.bl_small then
        choices.Small = 'bl_small'
    end
    if not hnds_valid_blind_choice(choices.Big) and G.P_BLINDS.bl_big then
        choices.Big = 'bl_big'
    end

    if not hnds_valid_blind_choice(choices.Boss) then
        local previous = G.GAME.hnds_bypass_platinum_reroll_bans
        G.GAME.hnds_bypass_platinum_reroll_bans = true
        local ok, boss = pcall(get_new_boss)
        G.GAME.hnds_bypass_platinum_reroll_bans = previous
        if ok and hnds_valid_blind_choice(boss) then
            choices.Boss = boss
        else
            choices.Boss = hnds_emergency_boss_choice()
        end
    end
end

if type(create_UIBox_blind_select) == 'function' then
    local create_UIBox_blind_select_ref = create_UIBox_blind_select
    function create_UIBox_blind_select(...)
        HNDS.restore_stale_platinum_blind_slots()
        hnds_repair_blind_choices_for_ui()


        if HNDS.apply_pending_nightmare_shop_upgrade then
            HNDS.apply_pending_nightmare_shop_upgrade()
        end


        hnds_repair_blind_choices_for_ui()
        local result = create_UIBox_blind_select_ref(...)


        if HNDS.apply_pending_nightmare_shop_upgrade then
            HNDS.apply_pending_nightmare_shop_upgrade()
        end

        return result
    end
end


if CardArea and CardArea.align_cards and not HNDS._platinum_cardarea_guard then
    HNDS._platinum_cardarea_guard = true
    local hnds_cardarea_align_cards_ref = CardArea.align_cards
    function CardArea:align_cards(...)
        if self.cards == nil then return end
        return hnds_cardarea_align_cards_ref(self, ...)
    end
end

local create_UIBox_blind_tag_ref = create_UIBox_blind_tag

function create_UIBox_blind_tag(blind_choice, run_info, ...)
    if run_info or not ensure_blind_raiser_state() then
        return create_UIBox_blind_tag_ref(blind_choice, run_info, ...)
    end

    G.GAME.round_resets.blind_tags = G.GAME.round_resets.blind_tags or {}
    local tag_key = G.GAME.round_resets.blind_tags[blind_choice]
    if not tag_key then return nil end

    local reward_tag = Tag(tag_key, nil, blind_choice)
    local tag_ui, tag_sprite = reward_tag:generate_UI()


    if tag_sprite and tag_sprite.states and tag_sprite.states.collide then
        tag_sprite.states.collide.can = false
    end

    local upgrade_active = can_upgrade(blind_choice)
    local skip_active = blind_is_current(blind_choice)
        and not blind_was_upgraded(blind_choice)


    return {
        n = G.UIT.R,
        config = {
            id = 'tag_container',
            ref_table = reward_tag,
            align = 'cm',
        },
        nodes = {
            {
                n = G.UIT.R,
                config = { align = 'tm', minh = 0.65 },
                nodes = {
                    {
                        n = G.UIT.T,
                        config = {
                            text = localize('k_or'),
                            scale = 0.55,
                            colour = G.C.WHITE,
                            shadow = true,
                        },
                    },
                },
            },
            {
                n = G.UIT.R,
                config = {
                    id = 'tag_' .. blind_choice,
                    align = 'cm',
                    r = 0.1,
                    padding = 0.1,
                    minw = 2.2,
                    can_collide = true,
                    ref_table = tag_sprite,
                },
                nodes = {
                    {
                        n = G.UIT.R,
                        config = {
                            id = 'tag_desc',
                            align = 'cm',
                            minh = 1,
                        },
                        nodes = { tag_ui },
                    },
                    {
                        n = G.UIT.R,
                        config = {
                            id = 'hnds_skip_blind_button_' .. blind_choice,
                            align = 'cm',
                            colour = skip_active and G.C.RED or G.C.UI.BACKGROUND_INACTIVE,
                            minh = 0.6,
                            minw = 2,
                            maxw = 2,
                            padding = 0.07,
                            r = 0.1,
                            shadow = true,
                            hover = skip_active,
                            one_press = true,
                            button = skip_active and 'skip_blind' or nil,
                            func = 'hnds_update_skip_blind_button',
                            insta_func = true,
                            ref_table = reward_tag,
                            hnds_blind_choice = blind_choice,
                        },
                        nodes = {
                            {
                                n = G.UIT.T,
                                config = {
                                    text = localize('b_skip_blind'),
                                    scale = 0.4,
                                    colour = skip_active and G.C.UI.TEXT_LIGHT or G.C.UI.TEXT_INACTIVE,
                                },
                            },
                        },
                    },
                    {
                        n = G.UIT.R,
                        config = {
                            id = 'hnds_upgrade_blind_button_' .. blind_choice,
                            align = 'cm',
                            colour = upgrade_active and G.C.RED or G.C.UI.BACKGROUND_INACTIVE,
                            minh = 0.6,
                            minw = 2,
                            maxw = 2,
                            padding = 0.07,
                            r = 0.1,
                            shadow = true,
                            hover = true,


                            one_press = false,
                            button = 'hnds_upgrade_blind',
                            func = 'hnds_update_upgrade_blind_button',
                            insta_func = true,
                            ref_table = reward_tag,
                            hnds_blind_choice = blind_choice,
                            tooltip = HNDS.platinum_upgrade_button_tooltip
                                and HNDS.platinum_upgrade_button_tooltip(blind_choice)
                                or nil,
                        },
                        nodes = {
                            {
                                n = G.UIT.T,
                                config = {
                                    text = localize('hnds_upgrade_blind'),
                                    scale = 0.4,
                                    colour = upgrade_active and G.C.UI.TEXT_LIGHT or G.C.UI.TEXT_INACTIVE,
                                },
                            },
                        },
                    },
                },
            },
        },
    }
end


-- Shared Blind Select option rebuild: removes the live option UIBox and
-- recreates it from the current blind choice, recoloured for `colour_key`.
-- Returns the new UIBox so callers can run their own follow-up syncs.
function HNDS.rebuild_platinum_blind_option(blind_choice, colour_key, parent)
    local current_option = G.blind_select_opts and G.blind_select_opts[blind_choice:lower()]
    if not (current_option and parent) then return nil end

    current_option:remove()
    G.blind_select_opts[blind_choice:lower()] = UIBox({
        T = { parent.T.x, 0, 0, 0 },
        definition = {
            n = G.UIT.ROOT,
            config = { align = 'cm', colour = G.C.CLEAR },
            nodes = {
                UIBox_dyn_container(
                    { create_UIBox_blind_choice(blind_choice) },
                    false,
                    get_blind_main_colour(colour_key),
                    mix_colours(G.C.BLACK, get_blind_main_colour(colour_key), 0.8)
                ),
            },
        },
        config = {
            align = 'bmi',
            offset = { x = 0, y = G.ROOM.T.y + 9 },
            major = parent,
            xy_bond = 'Weak',
        },
    })

    local new_option = G.blind_select_opts[blind_choice:lower()]
    parent.config.object = new_option
    parent.config.object:recalculate()
    new_option.parent = parent
    new_option.alignment.offset.y = 0
    return new_option
end

local function hnds_rebuild_upgraded_blind_option(blind_choice, boss)


    if not (G and G.blind_select) then return end

    local current_option = G.blind_select_opts
        and G.blind_select_opts[blind_choice:lower()]
    local current_parent = blind_option_parent(current_option)
    if not (current_option and current_parent) then return end

    local new_option = HNDS.rebuild_platinum_blind_option(blind_choice, boss, current_parent)

    HNDS.sync_platinum_blind_tag_ui({
        config = { id = blind_choice },
        UIBox = new_option,
    })
end


local function hnds_rebuild_remaining_blind_score_option(blind_choice)
    if not (G and G.blind_select and G.GAME and G.GAME.round_resets) then return end
    local state = G.GAME.round_resets.blind_states
        and G.GAME.round_resets.blind_states[blind_choice]
    if state == 'Defeated' or state == 'Skipped' then return end

    local blind_key = G.GAME.round_resets.blind_choices
        and G.GAME.round_resets.blind_choices[blind_choice]
    if not (blind_key and G.P_BLINDS and G.P_BLINDS[blind_key]) then return end

    local current_option = G.blind_select_opts
        and G.blind_select_opts[blind_choice:lower()]
    local current_parent = blind_option_parent(current_option)
    if not (current_option and current_parent) then return end

    local new_option = HNDS.rebuild_platinum_blind_option(blind_choice, blind_key, current_parent)

    HNDS.sync_platinum_blind_tag_ui({
        config = { id = blind_choice },
        UIBox = new_option,
    })
end

local function hnds_refresh_undefeated_blind_scores(except_choice)
    for _, choice in ipairs({ 'Small', 'Big' }) do
        if choice ~= except_choice then
            hnds_rebuild_remaining_blind_score_option(choice)
        end
    end
    if HNDS.rebuild_platinum_boss_option then HNDS.rebuild_platinum_boss_option() end
end


HNDS.upgrade_next_blind_from_nightmare = function(requested_blind_choice)
    if not (G and G.GAME and G.GAME.round_resets) then return nil end

    if not ensure_blind_raiser_state() then
        return "not_upgradable"
    end

    local states = G.GAME.round_resets.blind_states or {}
    local blind_choice

    if requested_blind_choice == "Small"
        or requested_blind_choice == "Big"
    then
        blind_choice = requested_blind_choice
    else
        for _, choice in ipairs({ 'Small', 'Big' }) do
            if states[choice] == 'Select' then
                blind_choice = choice
                break
            end
        end

        if not blind_choice then
            local on_deck = G.GAME.blind_on_deck
            if on_deck == 'Small' or on_deck == 'Big' then
                blind_choice = on_deck
            elseif on_deck == 'Boss' or states.Boss == 'Select' then
                return "not_upgradable"
            else
                for _, choice in ipairs({ 'Small', 'Big' }) do
                    if states[choice] ~= 'Defeated'
                        and states[choice] ~= 'Skipped'
                    then
                        blind_choice = choice
                        break
                    end
                end
            end
        end
    end

    if not blind_choice then return nil end
    if blind_choice ~= 'Small' and blind_choice ~= 'Big' then
        return "not_upgradable"
    end
    if blind_was_upgraded(blind_choice) or blind_is_finished(blind_choice) then
        return "not_upgradable"
    end

    local choices = G.GAME.round_resets.blind_choices
    if not choices or not choices[blind_choice] then return nil end


    local blind_tags = G.GAME.round_resets.blind_tags or {}
    local reward_tag_key = blind_tags[blind_choice]
    if not reward_tag_key then return nil end

    local reward_tag = Tag(reward_tag_key, nil, blind_choice)
    if not (reward_tag and reward_tag.key) then return nil end

    local boss
    if HNDS.choose_platinum_upgrade_boss then
        boss = HNDS.choose_platinum_upgrade_boss(blind_choice)
    else
        boss = (HNDS.get_new_boss_unforced or get_new_boss)()
    end


    if not (boss and G.P_BLINDS and G.P_BLINDS[boss]) then return nil end


    local preexisting_tags = {}
    for _, tag in ipairs(G.GAME.tags or {}) do
        preexisting_tags[tag] = true
    end
    if reward_tag and reward_tag.key then
        add_tag(reward_tag)
    end

    HNDS.commit_platinum_upgrade(blind_choice, boss)

    hnds_rebuild_upgraded_blind_option(blind_choice, boss)
    hnds_refresh_undefeated_blind_scores(blind_choice)

    if SMODS and SMODS.calculate_context then
        SMODS.calculate_context({
            hnds_upgrade_blind = true,
            hnds_nightmare_stake_upgrade = true,
            blind_type = blind_choice,
            blind_key = boss,
        })
    end


    for _, tag in ipairs(granted_tags) do
        tag:apply_to_run({ type = 'immediate' })
    end
    for _, tag in ipairs(granted_tags) do
        if tag:apply_to_run({ type = 'new_blind_choice' }) then
            break
        end
    end

    save_run()
    return true
end


HNDS.apply_pending_nightmare_shop_upgrade = function()
    if not (G and G.GAME and G.GAME.hnds_nightmare_shop_upgrade_pending) then
        return false
    end

    if not nightmare_active() then
        G.GAME.hnds_nightmare_shop_upgrade_pending = nil
        G.GAME.hnds_nightmare_shop_upgrade_target = nil
        G.GAME.hnds_nightmare_shop_upgrade_source_ante = nil
        return false
    end

    if G.GAME.hnds_nightmare_shop_upgrade_applying then return false end
    G.GAME.hnds_nightmare_shop_upgrade_applying = true

    local requested_blind_choice = G.GAME.hnds_nightmare_shop_upgrade_target
    local ok, status = pcall(
        HNDS.upgrade_next_blind_from_nightmare,
        requested_blind_choice
    )
    G.GAME.hnds_nightmare_shop_upgrade_applying = nil
    if not ok then error(status) end

    if status == true then
        G.GAME.hnds_nightmare_shop_upgrade_pending = nil
        G.GAME.hnds_nightmare_shop_upgrade_target = nil
        G.GAME.hnds_nightmare_shop_upgrade_source_ante = nil
        play_sound("hnds_curse_used", 1, 0.75)
        return true
    end

    if status == "not_upgradable" then
        G.GAME.hnds_nightmare_shop_upgrade_pending = nil
        G.GAME.hnds_nightmare_shop_upgrade_target = nil
        G.GAME.hnds_nightmare_shop_upgrade_source_ante = nil
    end

    return false
end


G.FUNCS.hnds_upgrade_blind = function(e)
    if not (e and e.config and G and G.GAME) then return end

    local blind_choice = e.config.hnds_blind_choice
    if not blind_choice and type(e.config.id) == 'string' then
        blind_choice = e.config.id:match('hnds_upgrade_blind_button_(Small)')
            or e.config.id:match('hnds_upgrade_blind_button_(Big)')
    end
    if not blind_choice then
        local states = G.GAME.round_resets and G.GAME.round_resets.blind_states or {}
        if states.Small == 'Select' then blind_choice = 'Small'
        elseif states.Big == 'Select' then blind_choice = 'Big'
        elseif G.GAME.blind_on_deck == 'Small' or G.GAME.blind_on_deck == 'Big' then
            blind_choice = G.GAME.blind_on_deck
        end
    end


    local slot_is_current = blind_is_current(blind_choice)
        or (G.GAME.blind_on_deck == blind_choice)
        or (e.config.hnds_upgrade_ready == true)
    if not ensure_blind_raiser_state()
        or not blind_choice
        or (blind_choice ~= 'Small' and blind_choice ~= 'Big')
        or blind_is_finished(blind_choice)
        or blind_was_upgraded(blind_choice)
        or not slot_is_current
    then
        return
    end

    local reward_tag = e.config.ref_table
    if not (reward_tag and reward_tag.key) then
        local tag_key = G.GAME.round_resets
            and G.GAME.round_resets.blind_tags
            and G.GAME.round_resets.blind_tags[blind_choice]
        if tag_key then reward_tag = Tag(tag_key, nil, blind_choice) end
    end

    local blind_option = G.blind_select_opts and G.blind_select_opts[blind_choice:lower()]


    local boss
    if HNDS.choose_platinum_upgrade_boss then
        boss = HNDS.choose_platinum_upgrade_boss(blind_choice)
    else
        boss = (HNDS.get_new_boss_unforced or get_new_boss)()
    end


    if not (boss and G.P_BLINDS and G.P_BLINDS[boss]) then return end

    local current_upgrade_key = upgrade_key(blind_choice)
    local actual_upgrade_count = (G.GAME.hnds_blind_upgrades or 0) + 1
    local upgrade_index = HNDS.platinum_next_upgrade_exponent
        and HNDS.platinum_next_upgrade_exponent() or actual_upgrade_count
    replacement_records()[current_upgrade_key] = {
        ante = current_ante(),
        blind_choice = blind_choice,
        original = G.GAME.round_resets.blind_choices[blind_choice],
        boss = boss,
        upgrade_index = upgrade_index,
    }


    G.GAME.round_resets.blind_choices[blind_choice] = boss

    stop_use()

    upgraded_blinds()[current_upgrade_key] = true
    G.GAME.hnds_blind_upgrades = actual_upgrade_count
    if HNDS.set_platinum_blind_raiser_applied_step then
        HNDS.set_platinum_blind_raiser_applied_step(upgrade_index)
    end
    if HNDS.set_platinum_next_upgrade_exponent then
        HNDS.set_platinum_next_upgrade_exponent(upgrade_index + 1)
    end
    if HNDS.record_platinum_boss_effect then
        HNDS.record_platinum_boss_effect(boss, current_ante())
    end


    set_upgrade_runtime_button(e, false)
    local skip_button = get_runtime_element(
        e,
        blind_choice,
        'hnds_skip_blind_button_' .. blind_choice
    )
    set_runtime_button(skip_button, false, 'skip_blind')


    local preexisting_tags = {}
    for _, tag in ipairs(G.GAME.tags or {}) do
        preexisting_tags[tag] = true
    end

    add_tag(reward_tag)

    local granted_tags = {}
    for _, tag in ipairs(G.GAME.tags or {}) do
        if not preexisting_tags[tag] then
            granted_tags[#granted_tags + 1] = tag
        end
    end

    G.E_MANAGER:add_event(Event({
        trigger = 'immediate',
        func = function()
            play_sound('other1')

            if blind_option and blind_option.set_role and blind_option.alignment then
                blind_option:set_role({ xy_bond = 'Weak' })
                blind_option.alignment.offset.y = 20
            end

            return true
        end,
    }))

    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0.3,
        func = function()
            local current_option = G.blind_select_opts
                and G.blind_select_opts[blind_choice:lower()]
            local current_parent = blind_option_parent(current_option)

            if current_option and current_parent then
                local new_option = HNDS.rebuild_platinum_blind_option(blind_choice, boss, current_parent)


                HNDS.sync_platinum_blind_tag_ui({
                    config = { id = blind_choice },
                    UIBox = new_option,
                })
            else


                hnds_rebuild_upgraded_blind_option(blind_choice, boss)
            end
            hnds_refresh_undefeated_blind_scores(blind_choice)

            if SMODS and SMODS.calculate_context then
                SMODS.calculate_context({
                    hnds_upgrade_blind = true,
                    blind_type = blind_choice,
                    blind_key = boss,
                })
            end

            HNDS.apply_platinum_reward_tags(granted_tags)

            save_run()
            return true
        end,
    }))
end
