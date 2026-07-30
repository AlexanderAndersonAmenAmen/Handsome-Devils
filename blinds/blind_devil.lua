-------------------------------------------------------------------
-- THE DEVIL
-- Container Boss Blind
--
-- Rolls 3 recreated vanilla boss blinds.
-- Their logic is stored in lib/devil_bosses.lua.
-------------------------------------------------------------------

HNDS = HNDS or {}

local DEVIL_KEY = "bl_hnds_blind_devil"
local DEVIL_KEYS = {"bl_hnds_blind_devil", "blind_devil"}


-- The Devil recreates vanilla Boss Blind effects under internal hook keys.
-- These map back to Balatro's native Blind localization entries so the hover
-- popup always uses the player's language and the exact vanilla wording.
local devil_vanilla_blind_keys = {
    bl_hook_the_house = "bl_house",
    bl_hook_the_wall = "bl_wall",
    bl_hook_the_wheel = "bl_wheel",
    bl_hook_the_club = "bl_club",
    bl_hook_the_fish = "bl_fish",
    bl_hook_the_psychic = "bl_psychic",
    bl_hook_the_goad = "bl_goad",
    bl_hook_the_window = "bl_window",
    bl_hook_the_manacle = "bl_manacle",
    bl_hook_the_eye = "bl_eye",
    bl_hook_the_mouth = "bl_mouth",
    bl_hook_the_plant = "bl_plant",
    bl_hook_the_serpent = "bl_serpent",
    bl_hook_the_pillar = "bl_pillar",
    bl_hook_the_needle = "bl_needle",
    bl_hook_the_head = "bl_head",
    bl_hook_the_mark = "bl_mark",
    bl_hook_the_flint = "bl_flint",
    bl_hook_the_water = "bl_water",
}

local function is_devil_key(key)
    for _, devil_key in ipairs(DEVIL_KEYS) do
        if key == devil_key then return true end
    end
    return false
end

local function devil_tooltip_vars(vanilla_key, blind_config)
    if vanilla_key == "bl_wheel" and SMODS and SMODS.get_probability_vars then
        local numerator, denominator = SMODS.get_probability_vars(
            blind_config or (G.P_BLINDS and G.P_BLINDS[vanilla_key]),
            1,
            7,
            "hnds_devil_tooltip_wheel"
        )
        return { numerator, denominator }
    end

    return {}
end

local function create_devil_effect_box(hook_key)
    local vanilla_key = devil_vanilla_blind_keys[hook_key]
    local blind_config = vanilla_key and G.P_BLINDS and G.P_BLINDS[vanilla_key]

    if not (vanilla_key and blind_config) then return nil end

    local name_nodes = localize {
        type = "name",
        key = vanilla_key,
        set = "Blind",
    }
    local desc_nodes = {}
    localize {
        type = "descriptions",
        key = vanilla_key,
        set = "Blind",
        nodes = desc_nodes,
        vars = devil_tooltip_vars(vanilla_key, blind_config),
    }

    local boss_colour = blind_config.boss_colour or G.C.RED

    return {
        n = G.UIT.R,
        config = { align = "cm", padding = 0.025 },
        nodes = {
            {
                n = G.UIT.R,
                config = {
                    align = "cm",
                    minw = 3.45,
                    maxw = 3.45,
                    padding = 0.055,
                    r = 0.1,
                    colour = lighten(G.C.JOKER_GREY, 0.5),
                    emboss = 0.05,
                },
                nodes = {
                    {
                        n = G.UIT.C,
                        config = {
                            align = "cm",
                            minw = 3.3,
                            maxw = 3.3,
                            padding = 0.07,
                            r = 0.08,
                            colour = adjust_alpha(darken(boss_colour, 0.2), 0.96),
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

HNDS.create_devil_blind_tooltip = function(ante)
    local nodes = {}
    local rolled = G and G.GAME and G.GAME.hnds_devil_bosses or {}

    -- Preserve The Devil's three original tooltips as three independent boxes.
    for i = 1, 3 do
        local box = create_devil_effect_box(rolled[i])
        if box then nodes[#nodes + 1] = box end
    end

    -- Platinum upgrades add more independent Blind boxes after the original
    -- three; they never collapse The Devil into its normal one-line list.
    if HNDS.create_platinum_upgrade_effect_boxes then
        for _, box in ipairs(HNDS.create_platinum_upgrade_effect_boxes(ante)) do
            nodes[#nodes + 1] = box
        end
    end

    if #nodes == 0 then return nil end

    return {
        n = G.UIT.ROOT,
        config = {
            align = "cm",
            colour = G.C.CLEAR,
            padding = 0.04,
        },
        nodes = nodes,
    }
end

-- Called from a narrow Lovely injection immediately after Balatro creates the
-- blind-choice AnimatedSprite. This changes only the Devil badge itself; the
-- surrounding blind-selection UI hierarchy and button hitboxes are untouched.
HNDS.attach_devil_blind_tooltip = function(sprite, blind_config)
    local key = blind_config and blind_config.key
    if not (sprite and is_devil_key(key)) then return end

    sprite.states.hover.can = true
    sprite.states.drag.can = false
    sprite.states.collide.can = true
    sprite.config = sprite.config or {}
    sprite.config.force_focus = true

    sprite.hover = function(_self)
        if (not G.CONTROLLER.dragging.target or G.CONTROLLER.using_touch)
            and not _self.hovering
            and _self.states.visible
        then
            local popup = HNDS.create_devil_blind_tooltip()
            if not popup then return end

            _self.hovering = true
            _self.hover_tilt = 3
            _self:juice_up(0.05, 0.02)
            play_sound("chips1", math.random() * 0.1 + 0.55, 0.12)

            _self.config.h_popup = popup
            _self.config.h_popup_config = {
                -- Keep the three effect boxes inside the game window by always
                -- opening them outside the badge's right edge.
                align = "cr",
                offset = { x = 0.1, y = 0 },
                parent = _self,
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

local devil_name_keys = {
    "hnds_devil_name_default",
    "hnds_devil_name_legion",
    "hnds_devil_name_old_nick",
    "hnds_devil_name_deceiver",
    "hnds_devil_name_tempter",
    "hnds_devil_name_adversary",
    "hnds_devil_name_prince_of_darkness",
    "hnds_devil_name_belial",
    "hnds_devil_name_apollyon",
    "hnds_devil_name_lucifer",
    "hnds_devil_name_abaddon",
    "hnds_devil_name_leviathan",
}

local function devil_localized_name(key)
    return (G.localization
        and G.localization.misc
        and G.localization.misc.dictionary
        and G.localization.misc.dictionary[key])
        or "The Devil"
end

local function apply_devil_name(key)
    if not key then return end
    local name = devil_localized_name(key)

    -- loc_vars runs before Steamodded renders a Blind's name. Updating the
    -- localization entry here makes the blind-select name use the nickname.
    if G.localization
        and G.localization.descriptions
        and G.localization.descriptions.Blind
    then
        for _, k in ipairs(DEVIL_KEYS) do
            if G.localization.descriptions.Blind[k] then
                G.localization.descriptions.Blind[k].name = name
            end
        end
    end

    if G.P_BLINDS then
        for _, k in ipairs(DEVIL_KEYS) do
            if G.P_BLINDS[k] then
                G.P_BLINDS[k].name = name
            end
        end
    end

    if G.GAME and G.GAME.blind then
        local active_key = G.GAME.blind.config
            and G.GAME.blind.config.blind
            and G.GAME.blind.config.blind.key

        if active_key == DEVIL_KEY then
            G.GAME.blind.loc_name = name
        end
    end
end

local function ensure_devil_name()
    if not (G and G.GAME) then
        return "The Devil"
    end

    if not G.GAME.hnds_devil_name_key then
        local ante = G.GAME.round_resets and G.GAME.round_resets.ante or 0
        G.GAME.hnds_devil_name_key = pseudorandom_element(
            devil_name_keys,
            pseudoseed("hnds_devil_name_" .. tostring(ante))
        ) or "hnds_devil_name_default"
    end

    apply_devil_name(G.GAME.hnds_devil_name_key)
    return devil_localized_name(G.GAME.hnds_devil_name_key)
end

local function ensure_devil_roll()
    if not (G and G.GAME) then return end

    if not G.GAME.hnds_devil_bosses then
        G.GAME.hnds_devil_bosses = HNDS.roll_devil_bosses()
    end
end

-- Called by the boss-selection hook so the nickname exists before the
-- blind-select UI is constructed.
HNDS.prepare_devil_encounter = function()
    ensure_devil_roll()
    return ensure_devil_name()
end

local function devil_get_names()
    local names = {}
    local bosses = G.GAME and G.GAME.hnds_devil_bosses or {}

    for i = 1, 3 do
        local key = bosses[i]
        local vk = key and devil_vanilla_blind_keys[key]
        if vk and G.localization and G.localization.descriptions
            and G.localization.descriptions.Blind
            and G.localization.descriptions.Blind[vk]
        then
            names[i] = G.localization.descriptions.Blind[vk].name
        else
            names[i] = "???"
        end
    end

    return names
end

SMODS.Blind {
    key = "blind_devil",

    boss = {
        min = 99,
    },

    mult = 2,

    atlas_table = "ANIMATION_ATLAS",
    atlas = "ante_10_atlas",
    pos = { x = 0, y = 0 },

    boss_colour = HEX("FD5F55"),
    discovered = false,
    unlocked = true,

    -- The Fish and The Serpent use the drawing_cards context.
    modifies_draw = true,

    loc_vars = function(self)
        ensure_devil_roll()
        ensure_devil_name()

        return {
            vars = devil_get_names(),
        }
    end,

    collection_loc_vars = function(self)
        local names = {}
        local rolled = HNDS.roll_devil_bosses("collection", 0)

        for i = 1, 3 do
            local key = rolled[i]
            local vk = key and devil_vanilla_blind_keys[key]
            if vk and G.localization and G.localization.descriptions
                and G.localization.descriptions.Blind
                and G.localization.descriptions.Blind[vk]
            then
                names[i] = G.localization.descriptions.Blind[vk].name
            else
                names[i] = "???"
            end
        end

        return {
            vars = { names[1], names[2], names[3] },
        }
    end,

    set_blind = function(self)
        ensure_devil_roll()
        ensure_devil_name()
        G.GAME.hnds_devil_active = true

        -- Play once when the encounter is actually selected. Collection/preview
        -- rendering never calls set_blind.
        if hnds_config and hnds_config.enableCustomSounds then
            play_sound("hnds_curse_used", 1, 0.75)
        end

        for _, key in ipairs(G.GAME.hnds_devil_bosses or {}) do
            local boss = HNDS.DEVIL_BOSSES[key]

            if boss then
                if boss.set_blind then
                    boss:set_blind()
                end

                if boss.debuff then
                    G.GAME.blind.debuff = G.GAME.blind.debuff or {}

                    if boss.debuff.suit then
                        G.GAME.blind.debuff.suit = boss.debuff.suit
                    end

                    if boss.debuff.is_face then
                        G.GAME.blind.debuff.is_face = true
                    end

                    if boss.debuff.h_size_ge then
                        G.GAME.blind.debuff.h_size_ge = boss.debuff.h_size_ge
                    end
                end
            end
        end

        -- The Blind-select badge is wired by Lovely, but the fight HUD uses the
        -- active Blind object (and sometimes its AnimatedSprite) as the hover
        -- target. Attach the same popup to both, then repeat after vanilla's
        -- delayed badge reveal so the hook survives the HUD refresh.
        local function attach_live_devil_tooltip()
            local active_blind = G and G.GAME and G.GAME.blind
            if not active_blind then return end
            local active_config = active_blind.config and active_blind.config.blind or self
            HNDS.attach_devil_blind_tooltip(active_blind, active_config)
            if active_blind.children and active_blind.children.animatedSprite then
                HNDS.attach_devil_blind_tooltip(active_blind.children.animatedSprite, active_config)
            end
        end

        attach_live_devil_tooltip()
        if G.E_MANAGER and Event then
            G.E_MANAGER:add_event(Event({
                trigger = "after",
                delay = 0.2,
                blockable = false,
                blocking = false,
                func = function()
                    attach_live_devil_tooltip()
                    return true
                end,
            }))
        end
    end,

    calculate = function(self, blind, context)
        -- Cleanup contexts are sent after a Blind has been marked disabled.
        -- Let the component effects see those contexts before returning.
        local cleanup_context = context.blind_disabled or context.blind_defeated
        if blind.disabled and not cleanup_context then return end

        for _, key in ipairs(G.GAME.hnds_devil_bosses or {}) do
            local boss = HNDS.DEVIL_BOSSES[key]

            if boss and boss.calculate then
                local result = boss:calculate(blind, context)
                if result then return result end
            end
        end
    end,

    disable = function(self)
        for _, key in ipairs(G.GAME.hnds_devil_bosses or {}) do
            local boss = HNDS.DEVIL_BOSSES[key]
            if boss and boss.disable then
                boss:disable()
            end
        end

        G.GAME.hnds_devil_bosses = nil
        G.GAME.hnds_devil_active = nil
        G.GAME.hnds_devil_name_key = nil

        -- Restore the default localization after the encounter. The next
        -- selection will apply its newly rolled nickname before rendering.
        apply_devil_name("hnds_devil_name_default")
    end,
}
