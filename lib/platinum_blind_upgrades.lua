-------------------------------------------------------------------
-- GLOBAL BLIND RAISER: BLIND UPGRADES
--
-- Adds an "Upgrade Blind" alternative below the vanilla Skip Blind
-- button during every run, regardless of stake.
-- Upgrading grants the displayed skip tag, then replaces the selected
-- Small/Big Blind with a random non-showdown Boss Blind without
-- skipping the slot.
--
-- Steamodded target: 1.0.0~BETA-1620a
--
-- UI compatibility notes:
--   * The blind-select callback expects the tag panel's children to be
--     [1] tag description, [2] Skip Blind. Do not wrap or move them.
--   * Upgrade Blind is added as child [3], preserving vanilla's fixed
--     child-index assumptions.
--   * Button activation self-synchronizes every UI update from
--     round_resets.blind_states[slot] == 'Select'. The action rows use
--     insta_func because beta-1620a does not run a normal `func` callback
--     while config.button is nil (the initial state of future slots).
--   * A handler-level skip guard prevents stale controller/UI input
--     from skipping a Blind after it has been upgraded.
--   * Platinum replacements are recorded and restored before the next
--     Ante's blind-select UI is built; vanilla does not regenerate the
--     Small/Big choice keys on its own.
-------------------------------------------------------------------

HNDS = HNDS or {}

local function blind_raiser_active()
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
    if not blind_raiser_active() or blind_is_finished(blind_choice) then
        return false
    end

    local states = G.GAME.round_resets
        and G.GAME.round_resets.blind_states or {}
    local state = states[blind_choice]

    -- Normal vanilla path.
    if G.GAME.blind_on_deck == blind_choice
        or state == 'Select'
        or state == 'Current'
    then
        return true
    end

    -- Boss definitions placed in Small/Big slots can leave blind_on_deck and
    -- blind_states one step behind after the fight. The completed slots are the
    -- reliable progression source: once Small is finished and Big is not, Big
    -- is the current playable slot even if it still says `Upcoming`.
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

local function parse_upgrade_key(key)
    if type(key) ~= 'string' then return nil, nil end
    local ante, blind_choice = key:match('^(-?%d+):([%a_]+)$')
    return tonumber(ante), blind_choice
end

local function excommunicado_active()
    if not (SMODS and SMODS.find_card) then return false end
    local cards = SMODS.find_card('j_hnds_excommunicado')
    return cards and next(cards) ~= nil
end

-- Small and Big are normally static keys in vanilla. Replacing one in
-- round_resets.blind_choices therefore persists until somebody restores it.
-- Run this before create_UIBox_blind_select builds the next Ante's badges,
-- effects and score requirements.
HNDS.restore_stale_platinum_blind_slots = function()
    if not blind_raiser_active() then return end
    if not (G.GAME.round_resets and G.GAME.round_resets.blind_choices) then return end

    local ante = current_ante()
    local choices = G.GAME.round_resets.blind_choices
    local upgrades = upgraded_blinds()
    local records = replacement_records()
    local stale_slots = {}

    -- Gather old locks first. They are useful for migrating saves made by
    -- earlier hotfixes, which stored only booleans and no replacement record.
    for key, was_upgraded in pairs(upgrades) do
        local key_ante, blind_choice = parse_upgrade_key(key)
        if was_upgraded and key_ante and key_ante ~= ante
            and (blind_choice == 'Small' or blind_choice == 'Big')
        then
            stale_slots[blind_choice] = true
        end
    end

    local excom = excommunicado_active()

    -- New saves have enough data to restore exactly what occupied the slot
    -- before Platinum upgraded it. Do not overwrite Excommunicado's freshly
    -- generated bosses for the new Ante.
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

    -- Migration for runs created with the prior builds. If a stale Platinum
    -- lock exists and the slot is still a Boss Blind, it is the persisted
    -- replacement reported by the player. Restore the vanilla slot.
    if not excom then
        for _, blind_choice in ipairs({ 'Small', 'Big' }) do
            local choice = choices[blind_choice]
            local blind = choice and G.P_BLINDS and G.P_BLINDS[choice]
            if stale_slots[blind_choice] and blind and blind.boss then
                choices[blind_choice] = 'bl_' .. blind_choice:lower()
            end
        end
    end

    -- Locks are per Ante, so old entries have no purpose after restoration.
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
end

HNDS.platinum_skip_is_locked = function(blind_choice)
    return blind_raiser_active()
        and blind_choice ~= nil
        and blind_was_upgraded(blind_choice)
end

local function set_runtime_button(button, active, callback)
    if not (button and button.config) then return end

    button.config.button = active and callback or nil
    button.config.hover = active
    button.config.colour = active and G.C.RED or G.C.UI.BACKGROUND_INACTIVE
    if active then button.disable_button = nil end

    -- UIElement:set_values only enables collision/click states when a
    -- button exists during construction. Future Blind actions are built
    -- inactive, so changing config.button later is not enough by itself.
    -- Keep the runtime states synchronized with the callback assignment.
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

-- Upgrade rows are constructed before a future Blind becomes current. On
-- beta-1620a, assigning config.button only later can leave the UIElement's
-- internal click handler unbound even though it looks and animates like a
-- button. Keep the callback permanently bound and toggle only collision,
-- click eligibility, and visuals. The handler still validates the slot.
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

-- UIBox.parent can briefly be nil after returning from an upgraded Blind and
-- while the remaining Blind choices are being reattached. The UIBox alignment
-- major still points at the owning UIElement, so use it as the authoritative
-- fallback instead of silently aborting the next upgrade callback.
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

    -- After a Blind is played, vanilla can rebuild/reparent the remaining
    -- selection objects without repopulating UIBox.parent. Locate the wrapper
    -- UIElement by object identity so the Big Blind upgrade does not abort.
    return find_ui_object_parent(G and G.blind_select, blind_option)
end

-- Called by a Lovely injection immediately after vanilla updates the
-- selected Blind's tag/skip UI. This touches only our Upgrade row unless
-- the current slot was already upgraded, in which case Skip is also
-- forcibly disabled.
HNDS.sync_platinum_blind_tag_ui = function(e)
    if not (blind_raiser_active() and e and e.config) then return end

    -- Final fallback: if another mod replaced create_UIBox_blind_select after
    -- our wrapper, consume the queued shop effect when vanilla activates the
    -- current Blind panel. A guard prevents recursion while the panel rebuilds.
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

-- UI `func` callbacks run continuously. They make activation independent of
-- the precise frame in which vanilla changes Small/Big from Upcoming to
-- Select, while preserving the normal tag hover proxy.
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
    -- Cache the last live eligibility result. On beta-1620a the button click can
    -- be dispatched in the same frame that the Big panel is reparented, after
    -- blind_states briefly stops reporting Select. The visible/clickable button
    -- is authoritative for that one transition frame.
    set_upgrade_runtime_button(e, active)

    -- Unlike Skip, Upgrade owns a live Blind Raiser tooltip instead of
    -- proxying hover to the Tag reward. Keep hover collision enabled even while
    -- the future slot is inactive so its preview can still be inspected.
    e.config.hover = true
    if e.states and e.states.hover then e.states.hover.can = true end
    e.config.tooltip = HNDS.platinum_upgrade_button_tooltip
        and HNDS.platinum_upgrade_button_tooltip(blind_choice)
        or nil
end

-------------------------------------------------------------------
-- Ante transition cleanup
-------------------------------------------------------------------

-- Blind Select hardening. A failed/over-filtered Boss roll leaves the Boss
-- choice nil, and vanilla then creates an empty blind_choice table before
-- immediately indexing blind_choice.config. Repair only invalid slots, leaving
-- every valid vanilla/modded selection untouched.
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

        -- Apply the Nightmare Stake shop effect only after vanilla has prepared the
        -- upcoming Blind slot. Doing this before constructing the UI makes the
        -- upgraded Boss badge, score and debuff text correct on the first frame.
        if HNDS.apply_pending_nightmare_shop_upgrade then
            HNDS.apply_pending_nightmare_shop_upgrade()
        end

        -- Tag rewards and compatibility hooks can reroll the real Boss while the
        -- pending upgrade is consumed. Validate once more immediately before the
        -- vanilla UI dereferences the selected Blind center.
        hnds_repair_blind_choices_for_ui()
        local result = create_UIBox_blind_select_ref(...)

        -- Compatibility fallback for unusual load orders that finalize
        -- blind_on_deck during UI construction rather than before it.
        if HNDS.apply_pending_nightmare_shop_upgrade then
            HNDS.apply_pending_nightmare_shop_upgrade()
        end

        return result
    end
end

-------------------------------------------------------------------
-- Blind tag UI
-------------------------------------------------------------------

-- Keep the complete skip/upgrade group centered through the UI tree itself.
-- Manual x offsets are intentionally avoided: the lower panel must be a Row
-- child so its height stacks beneath the "or" row instead of overlapping it.
-- Rebuilt Blind options can be removed while the UI tree is still completing
-- its current movement pass. Vanilla CardArea:remove clears `cards` first, so
-- a one-frame orphan would otherwise crash inside align_cards/ipairs.
if CardArea and CardArea.align_cards and not HNDS._platinum_cardarea_guard then
    HNDS._platinum_cardarea_guard = true
    local hnds_cardarea_align_cards_ref = CardArea.align_cards
    function CardArea:align_cards(...)
        if self.cards == nil then return end
        return hnds_cardarea_align_cards_ref(self, ...)
    end
end

local create_UIBox_blind_tag_ref = create_UIBox_blind_tag

function create_UIBox_blind_tag(blind_choice, run_info)
    if run_info or not blind_raiser_active() then
        return create_UIBox_blind_tag_ref(blind_choice, run_info)
    end

    G.GAME.round_resets.blind_tags = G.GAME.round_resets.blind_tags or {}
    local tag_key = G.GAME.round_resets.blind_tags[blind_choice]
    if not tag_key then return nil end

    local reward_tag = Tag(tag_key, nil, blind_choice)
    local tag_ui, tag_sprite = reward_tag:generate_UI()

    -- The icon itself must not consume clicks on the blind-select screen.
    if tag_sprite and tag_sprite.states and tag_sprite.states.collide then
        tag_sprite.states.collide.can = false
    end

    local upgrade_active = can_upgrade(blind_choice)
    local skip_active = blind_is_current(blind_choice)
        and not blind_was_upgraded(blind_choice)

    -- This mirrors the beta-1620a/BlindRaiser tag hierarchy exactly:
    -- tag panel child 1 = reward description
    -- tag panel child 2 = Skip Blind
    -- tag panel child 3 = Upgrade Blind
    -- Vanilla's select_blind code relies on the first two positions.
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
                            -- Keep the callback bound even while this is a future slot.
                            -- Collision/click state is toggled by the live func below.
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

-------------------------------------------------------------------
-- Nightmare Stake automatic upgrade
-------------------------------------------------------------------

local function hnds_rebuild_upgraded_blind_option(blind_choice, boss)
    -- During shop exit G.blind_select_opts can still contain removed objects
    -- from the previous selection screen. Rebuild only a live Blind Select UI.
    if not (G and G.blind_select) then return end

    local current_option = G.blind_select_opts
        and G.blind_select_opts[blind_choice:lower()]
    local current_parent = blind_option_parent(current_option)
    if not (current_option and current_parent) then return end

    current_option:remove()
    G.blind_select_opts[blind_choice:lower()] = UIBox({
        T = { current_parent.T.x, 0, 0, 0 },
        definition = {
            n = G.UIT.ROOT,
            config = { align = 'cm', colour = G.C.CLEAR },
            nodes = {
                UIBox_dyn_container(
                    { create_UIBox_blind_choice(blind_choice) },
                    false,
                    get_blind_main_colour(boss),
                    mix_colours(G.C.BLACK, get_blind_main_colour(boss), 0.8)
                ),
            },
        },
        config = {
            align = 'bmi',
            offset = { x = 0, y = G.ROOM.T.y + 9 },
            major = current_parent,
            xy_bond = 'Weak',
        },
    })

    local new_option = G.blind_select_opts[blind_choice:lower()]
    current_parent.config.object = new_option
    current_parent.config.object:recalculate()
    new_option.parent = current_parent
    new_option.alignment.offset.y = 0

    HNDS.sync_platinum_blind_tag_ui({
        config = { id = blind_choice },
        UIBox = new_option,
    })
end

-- Returns true after upgrading, "not_upgradable" when the actual next Blind is
-- the Boss, and nil while vanilla is still transitioning out of the shop.
HNDS.upgrade_next_blind_from_nightmare = function(requested_blind_choice)
    if not (G and G.GAME and G.GAME.round_resets) then return nil end

    if not blind_raiser_active() then
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

    -- Automatic Nightmare Stake upgrades grant exactly the same Skip Tag reward
    -- as pressing Upgrade Blind manually. Build the reward before mutating the
    -- slot so an unusually early call can retry instead of upgrading tagless.
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
    -- Never fall back to an unrestricted roll after the compatibility/no-dupe
    -- selector returns nil; aborting is safer than creating a duplicate Boss.
    if not (boss and G.P_BLINDS and G.P_BLINDS[boss]) then return nil end

    -- Record the tags that already existed, then add the displayed reward.
    -- This also captures any copies created synchronously by Double Tags.
    local preexisting_tags = {}
    for _, tag in ipairs(G.GAME.tags or {}) do
        preexisting_tags[tag] = true
    end
    if reward_tag and reward_tag.key then
        add_tag(reward_tag)
    end

    local granted_tags = {}
    for _, tag in ipairs(G.GAME.tags or {}) do
        if not preexisting_tags[tag] then
            granted_tags[#granted_tags + 1] = tag
        end
    end

    local current_upgrade_key = upgrade_key(blind_choice)
    local actual_upgrade_count = (G.GAME.hnds_blind_upgrades or 0) + 1
    local upgrade_index = HNDS.platinum_next_upgrade_exponent
        and HNDS.platinum_next_upgrade_exponent() or actual_upgrade_count
    replacement_records()[current_upgrade_key] = {
        ante = current_ante(),
        blind_choice = blind_choice,
        original = choices[blind_choice],
        boss = boss,
        upgrade_index = upgrade_index,
    }

    upgraded_blinds()[current_upgrade_key] = true
    G.GAME.hnds_blind_upgrades = actual_upgrade_count
    if HNDS.set_platinum_next_upgrade_exponent then
        HNDS.set_platinum_next_upgrade_exponent(upgrade_index + 1)
    end
    choices[blind_choice] = boss
    if HNDS.record_platinum_boss_effect then
        HNDS.record_platinum_boss_effect(boss, current_ante())
    end

    hnds_rebuild_upgraded_blind_option(blind_choice, boss)
    if HNDS.rebuild_platinum_boss_option then HNDS.rebuild_platinum_boss_option() end

    if SMODS and SMODS.calculate_context then
        SMODS.calculate_context({
            hnds_upgrade_blind = true,
            hnds_nightmare_stake_upgrade = true,
            blind_type = blind_choice,
            blind_key = boss,
        })
    end

    -- Match the manual Upgrade Blind callback: trigger immediate tag effects,
    -- then the first new-blind-choice effect that consumes a granted tag.
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

-- Consume the queued Cursed-shop effect when an eligible Small/Big Blind is
-- about to be shown. The pending flag is intentionally cleared when the next
-- slot is a Boss: Nightmare Stake upgrades only the immediately upcoming
-- Small/Big Blind and never skips across a Boss encounter.
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

-------------------------------------------------------------------
-- Upgrade callback
-------------------------------------------------------------------

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

    -- `one_press` may clear config.button before this callback executes, so
    -- never use the button's post-click config as proof that the action was
    -- enabled. The callback is attached only to the slot's own Upgrade row;
    -- validate against the real gameplay slot instead.
    local slot_is_current = blind_is_current(blind_choice)
        or (G.GAME.blind_on_deck == blind_choice)
        or (e.config.hnds_upgrade_ready == true)
    if not blind_raiser_active()
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
    -- The option wrapper and reward Tag are presentation/reward details only.
    -- Never discard the actual Blind upgrade because either object became stale
    -- while returning from the upgraded Small Blind.

    -- Temporarily bypass only Handsome Devils' Ante 10 Devil override.
    -- The real Ante 10 Boss remains The Devil, while upgraded Small/Big
    -- slots use the ordinary non-showdown Boss pool.
    local boss
    if HNDS.choose_platinum_upgrade_boss then
        boss = HNDS.choose_platinum_upgrade_boss(blind_choice)
    else
        boss = (HNDS.get_new_boss_unforced or get_new_boss)()
    end
    -- Do not bypass the compatibility/no-duplicates selector with a generic
    -- fallback roll. If no legal Boss exists, leave the Blind unchanged.
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

    -- Commit the replacement before the animation. Previously the choice was
    -- changed only inside the delayed UI rebuild; if the Big Blind UIBox was
    -- reparented after playing the upgraded Small Blind, that event returned
    -- early and left a recorded upgrade that appeared to do nothing.
    G.GAME.round_resets.blind_choices[blind_choice] = boss

    stop_use()

    upgraded_blinds()[current_upgrade_key] = true
    G.GAME.hnds_blind_upgrades = actual_upgrade_count
    if HNDS.set_platinum_next_upgrade_exponent then
        HNDS.set_platinum_next_upgrade_exponent(upgrade_index + 1)
    end
    if HNDS.record_platinum_boss_effect then
        HNDS.record_platinum_boss_effect(boss, current_ante())
    end

    -- Disable both actions before any animation/event begins. The skip
    -- callback also has a handler-level Lovely guard for stale inputs.
    set_upgrade_runtime_button(e, false)
    local skip_button = get_runtime_element(
        e,
        blind_choice,
        'hnds_skip_blind_button_' .. blind_choice
    )
    set_runtime_button(skip_button, false, 'skip_blind')

    -- Record which tags existed before the reward is granted. Process
    -- only newly granted tags, including copies produced by Double Tags.
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
                current_option:remove()
                G.blind_select_opts[blind_choice:lower()] = UIBox({
                    T = { current_parent.T.x, 0, 0, 0 },
                    definition = {
                        n = G.UIT.ROOT,
                        config = { align = 'cm', colour = G.C.CLEAR },
                        nodes = {
                            UIBox_dyn_container(
                                { create_UIBox_blind_choice(blind_choice) },
                                false,
                                get_blind_main_colour(boss),
                                mix_colours(G.C.BLACK, get_blind_main_colour(boss), 0.8)
                            ),
                        },
                    },
                    config = {
                        align = 'bmi',
                        offset = { x = 0, y = G.ROOM.T.y + 9 },
                        major = current_parent,
                        xy_bond = 'Weak',
                    },
                })

                local new_option = G.blind_select_opts[blind_choice:lower()]
                current_parent.config.object = new_option
                current_parent.config.object:recalculate()
                new_option.parent = current_parent
                new_option.alignment.offset.y = 0

                -- The rebuilt UI starts inactive by construction. Sync once
                -- more so both Skip and Upgrade stay locked for this slot.
                HNDS.sync_platinum_blind_tag_ui({
                    config = { id = blind_choice },
                    UIBox = new_option,
                })
            else
                -- The gameplay state is already committed. Best-effort rebuild
                -- the option through the shared helper rather than discarding
                -- the remaining tag/context work for this upgrade.
                hnds_rebuild_upgraded_blind_option(blind_choice, boss)
            end
            if HNDS.rebuild_platinum_boss_option then HNDS.rebuild_platinum_boss_option() end

            if SMODS and SMODS.calculate_context then
                SMODS.calculate_context({
                    hnds_upgrade_blind = true,
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
        end,
    }))
end
