local HOVER_X = { 2, 3, 4, 5, 6, 7, 8, 9 }

-- Rare Jokers whose effect is fundamentally a scaler, a self-replacement,
-- positional copier, or an add_to_deck passive do not have a stable standalone
-- ability to lend to Jack-in-the-Box. Keep them out of the roll pool.
local NON_TRANSFERABLE_RARES = {
    -- True self-scaling/self-replacement cases remain excluded. Explicitly
    -- supported stateful/positional Rare Jokers are handled below.
    j_campfire = true,
    j_wee = true,
    j_obelisk = true,
    j_invisible = true,

    j_hnds_jack_in_the_box = true,
    j_hnds_meme = true,
    j_hnds_last_laugh = true,
}

-- Hit the Road is intentionally allowed even though it is a scaler: the user
-- explicitly wants it in Jack's pool and Jack serialises the borrowed ability
-- state between calculations/rounds.
local SCALING_WHITELIST = {
    j_hit_the_road = true,
}

local function deep_copy(value, seen)
    if type(value) ~= 'table' then return value end
    seen = seen or {}
    if seen[value] then return seen[value] end
    local out = {}
    seen[value] = out
    for k, v in pairs(value) do
        out[deep_copy(k, seen)] = deep_copy(v, seen)
    end
    return out
end

local function jack_extra(card, center)
    local extra = card and card.ability and card.ability.extra
    if type(extra) ~= 'table' then
        extra = (center and center.config and center.config.extra) or {}
    end
    return extra
end

local function has_scaling_attribute(center)
    if not center or type(center.attributes) ~= 'table' then return false end
    for _, attribute in pairs(center.attributes) do
        if attribute == 'scaling' then return true end
    end
    return false
end

local function transferable_rare(key, center)
    if not key or not center or key == 'UNAVAILABLE' then return false end
    if NON_TRANSFERABLE_RARES[key] then return false end
    if center.set ~= 'Joker' or center.rarity ~= 3 then return false end
    if center.unlocked == false then return false end
    if has_scaling_attribute(center) and not SCALING_WHITELIST[key] then return false end
    return true
end

local function rare_pool()
    local pool = {}
    local seen = {}

    -- Prefer Balatro/Steamodded's live Joker pool so unlocks and ordinary pool
    -- restrictions are respected. If a compatibility mod returns no usable
    -- entries, fall back to registered unlocked Rare Jokers.
    if get_current_pool then
        local ok, current_pool = pcall(get_current_pool, 'Joker', 3, nil, 'hnds_jack_in_the_box')
        if ok and type(current_pool) == 'table' then
            for _, key in ipairs(current_pool) do
                local center = G and G.P_CENTERS and G.P_CENTERS[key]
                if not seen[key] and transferable_rare(key, center) then
                    seen[key] = true
                    pool[#pool + 1] = key
                end
            end
        end
    end

    if #pool == 0 then
        for key, center in pairs((G and G.P_CENTERS) or {}) do
            if not seen[key] and transferable_rare(key, center) then
                seen[key] = true
                pool[#pool + 1] = key
            end
        end
        table.sort(pool)
    end

    return pool
end

local function choose_rare(card, extra)
    local pool = rare_pool()
    if #pool == 0 then return nil end
    extra.rolls = (tonumber(extra.rolls) or 0) + 1
    local seed = table.concat({
        'hnds_jack_in_the_box_rare',
        tostring(card and card.sort_id or 0),
        tostring(extra.rolls),
    }, '_')
    return pseudorandom_element(pool, pseudoseed(seed))
end

local function rare_name(key)
    if not key then return 'none' end
    local center = G and G.P_CENTERS and G.P_CENTERS[key]
    if not center then return 'none' end
    local ok, name = pcall(localize, {
        key = key,
        type = 'name_text',
        set = 'Joker',
    })
    return ok and name or key
end

local function rolled_center(extra)
    local key = extra and extra.active and extra.rare_key
    return key and G and G.P_CENTERS and G.P_CENTERS[key] or nil
end

local function rolled_blueprint_compatible(extra)
    local center = rolled_center(extra)
    return not center or center.blueprint_compat ~= false
end

local function joker_index(card)
    if not (card and G and G.jokers and G.jokers.cards) then return nil end
    for i, joker in ipairs(G.jokers.cards) do
        if joker == card then return i end
    end
    return nil
end

local function run_copy_rare(card, key, context)
    if not (SMODS and SMODS.blueprint_effect and G and G.jokers and G.jokers.cards) then return nil end
    local target
    if key == 'j_blueprint' then
        local i = joker_index(card)
        target = i and G.jokers.cards[i + 1] or nil
    elseif key == 'j_brainstorm' then
        target = G.jokers.cards[1]
    end
    if not target or target == card then return nil end
    return SMODS.blueprint_effect(card, target, context)
end

local function run_walking_joke(card, context)
    if not (context.retrigger_joker_check and not context.retrigger_joker
        and context.other_card and context.other_card ~= card
        and G and G.jokers and G.jokers.cards)
    then
        return nil
    end
    local i = joker_index(card)
    if not i then return nil end
    local adjacent = (i > 1 and G.jokers.cards[i - 1] == context.other_card)
        or (i < #G.jokers.cards and G.jokers.cards[i + 1] == context.other_card)
    local center = context.other_card.config and context.other_card.config.center
    if adjacent and center and center.rarity == 1 then
        return { repetitions = 1 }
    end
end

local function run_jester_in_yellow(card, context)
    if not (context.setting_blind and G and G.jokers and G.jokers.cards and #G.jokers.cards > 0) then
        return nil
    end
    local target = G.jokers.cards[1]
    if not target or target == card
        or (target.ability and target.ability.hnds_jester_negative_rounds)
        or (target.edition and target.edition.negative)
    then
        return nil
    end
    local rounds = 6
    local center = G.P_CENTERS and G.P_CENTERS.j_hnds_jester_in_yellow
    if center and center.config and center.config.extra then
        rounds = tonumber(center.config.extra.rounds) or rounds
    end
    target:set_edition('e_negative')
    target:juice_up(0.3, 0.5)
    target.ability.hnds_jester_negative_rounds = rounds
    if target.add_sticker then target:add_sticker('hnds_jester_temp_negative', true) end
    if hnds_config and hnds_config.enableCustomSounds then
        local sound_key = pseudorandom('hnds_jiy_sfx') < (1 / 3)
            and 'hnds_jiy_superrare_sfx' or 'hnds_jiy_common_sfx'
        play_sound(sound_key, 1, 0.75)
    end
    return nil, true
end

local function change_stuntman_hand_size(delta)
    if delta == 0 then return end
    if G and G.hand and G.hand.change_size then
        G.hand:change_size(delta)
    end
end

local function on_borrowed_ability_changed(card, old_key, new_key)
    if old_key == new_key then return end

    if old_key == 'j_stuntman' then
        change_stuntman_hand_size(2)
    elseif old_key == 'j_hnds_excommunicado' and HNDS and HNDS.update_excom then
        HNDS.update_excom()
    end

    if new_key == 'j_stuntman' then
        change_stuntman_hand_size(-2)
    elseif new_key == 'j_hnds_excommunicado' and HNDS and HNDS.replace_current_blinds_with_bosses then
        HNDS.replace_current_blinds_with_bosses()
    end
end

local function apply_jack_art(center, card)
    if not card or not card.children then return end

    local extra = jack_extra(card, center)
    local active = extra.active == true

    if card.children.center and card.children.center.set_sprite_pos then
        card.children.center:set_sprite_pos(active and { x = 1, y = 5 } or { x = 0, y = 5 })
    end

    if active then
        local hover_x = tonumber(extra.hover_x) or 2
        if card.children.floating_sprite and card.children.floating_sprite.set_sprite_pos then
            card.children.floating_sprite:set_sprite_pos({ x = hover_x, y = 5 })
        end
        card.hnds_jack_box_art_state = 'active_' .. tostring(hover_x)
    else
        if card.children.floating_sprite then
            card.children.floating_sprite:remove()
            card.children.floating_sprite = nil
        end
        card.hnds_jack_box_art_state = 'closed'
    end
end

local function clear_proxy(card)
    if card then card.hnds_jack_box_proxy = nil end
end

-- Build a virtual Joker state table instead of a real Card object. The old
-- implementation used SMODS.create_card(), which registered a genuine card/UI
-- node even though it was intended to be hidden. That ghost card could render,
-- be dragged and even expose sell controls. This proxy is plain Lua data only.
local function make_proxy(card, extra)
    if not (card and extra and extra.active and extra.rare_key and G and G.P_CENTERS) then
        return nil
    end

    local center = G.P_CENTERS[extra.rare_key]
    if not center then return nil end

    local existing = card.hnds_jack_box_proxy
    if existing and existing.config and existing.config.center == center then
        return existing
    end

    local ability
    if type(extra.rare_state) == 'table' then
        ability = deep_copy(extra.rare_state)
    else
        ability = deep_copy(center.config or {})
    end

    -- Card:calculate_joker's vanilla fallback keys off these fields. Modded
    -- Joker calculate functions generally only need ability.extra/config.center.
    ability.set = 'Joker'
    ability.name = center.name or ability.name or center.key
    ability.effect = center.effect or ability.effect
    ability.eternal = nil
    ability.perishable = nil
    ability.rental = nil
    ability.hnds_cursed = nil
    ability.hnds_jester_temp_negative = nil

    local proxy = {
        config = { center = center },
        ability = ability,
        edition = nil,
        seal = nil,
        area = G.jokers,
        added_to_deck = true,
        debuff = card.debuff,
        sort_id = card.sort_id,
        cost = 0,
        sell_cost = 0,
        hnds_jack_box_virtual = true,
    }

    -- Missing Card fields/methods fall through to Jack itself. Methods are still
    -- invoked with the virtual proxy as `self`, so ability/config mutations stay
    -- isolated while harmless visual feedback (juice/status effects) can target
    -- Jack's existing sprites. No Node/Card constructor is ever called.
    setmetatable(proxy, { __index = card })

    card.hnds_jack_box_proxy = proxy
    return proxy
end

local function retarget_effect(value, proxy, card, seen)
    if type(value) ~= 'table' then return end
    seen = seen or {}
    if seen[value] then return end
    seen[value] = true
    for k, v in pairs(value) do
        if k == 'card' and v == proxy then
            value[k] = card
        elseif type(v) == 'table' then
            retarget_effect(v, proxy, card, seen)
        end
    end
end

local function run_rare_ability(card, extra, context)
    local key = extra and extra.rare_key

    -- Blueprint/Brainstorm need Jack's real position in G.jokers; a virtual
    -- proxy cannot represent positional copying correctly.
    if key == 'j_blueprint' or key == 'j_brainstorm' then
        return run_copy_rare(card, key, context)
    end
    if key == 'j_hnds_walking_joke' then
        return run_walking_joke(card, context)
    end
    if key == 'j_hnds_jester_in_yellow' then
        return run_jester_in_yellow(card, context)
    end

    local proxy = make_proxy(card, extra)
    if not proxy then return nil end

    local center = proxy.config and proxy.config.center
    local ok, ret, post

    -- Steamodded Jokers expose their native calculate function on the center.
    -- Vanilla/compatibility centers without one still go through the normal
    -- Card:calculate_joker dispatcher, but with our plain virtual table as self.
    if center and type(center.calculate) == 'function' then
        ok, ret, post = pcall(center.calculate, center, proxy, context)
    elseif Card and type(Card.calculate_joker) == 'function' then
        ok, ret, post = pcall(Card.calculate_joker, proxy, context)
    else
        return nil
    end

    if not ok then
        -- A Rare Joker can still make assumptions that require its own physical
        -- card in G.jokers. Fail closed instead of crashing or spawning a ghost.
        clear_proxy(card)
        return nil
    end

    if proxy.ability then
        extra.rare_state = deep_copy(proxy.ability)
    end
    retarget_effect(ret, proxy, card)
    retarget_effect(post, proxy, card)
    return ret, post
end

local function schedule_transition(center, card, activate)
    if not card or card.hnds_jack_box_transitioning then return end
    card.hnds_jack_box_transitioning = true

    local extra = jack_extra(card, center)
    local next_key
    local next_hover
    if activate then
        next_key = choose_rare(card, extra)
        if not next_key then
            card.hnds_jack_box_transitioning = nil
            return
        end
        next_hover = pseudorandom_element(
            HOVER_X,
            pseudoseed('hnds_jack_in_the_box_hover_' .. tostring(extra.rolls or 0))
        ) or 2
    end

    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0.05,
        func = function()
            if card and card.area then
                card:flip()
                play_sound('card1', 1.0, 0.6)
            end
            return true
        end,
    }))

    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0.18,
        func = function()
            if card and card.ability and card.ability.extra then
                local state = card.ability.extra
                local old_key = state.active and state.rare_key or nil
                local new_key = activate and next_key or nil
                clear_proxy(card)
                state.rare_state = nil
                state.active = activate and true or false
                state.rare_key = new_key
                state.hover_x = activate and next_hover or nil
                on_borrowed_ability_changed(card, old_key, new_key)
                if card.set_sprites and card.config and card.config.center then
                    card:set_sprites(card.config.center)
                end
            end
            return true
        end,
    }))

    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0.18,
        func = function()
            if card and card.area then
                card:flip()
                card:juice_up(0.5, 0.5)
                play_sound('tarot2', 1.0, 0.6)
            end
            card.hnds_jack_box_transitioning = nil
            return true
        end,
    }))
end

SMODS.Joker {
    key = 'jack_in_the_box',
    atlas = 'Jokers',
    pos = { x = 0, y = 5 },
    soul_pos = { x = 2, y = 5 },

    rarity = 1,
    cost = 4,
    unlocked = true,
    discovered = true,
    -- Mechanically compatible while closed or while borrowing a compatible
    -- Rare. calculate() suppresses Blueprint/Brainstorm when the borrowed Rare
    -- itself has blueprint_compat = false.
    blueprint_compat = true,
    demicoloncompat = false,
    eternal_compat = true,
    perishable_compat = true,

    config = {
        extra = {
            active = false,
            rare_key = nil,
            rare_state = nil,
            hover_x = nil,
            rolls = 0,
        },
    },

    loc_vars = function(self, info_queue, card)
        local extra = jack_extra(card, self)
        local key = extra.active and extra.rare_key or nil
        if info_queue and key and G and G.P_CENTERS and G.P_CENTERS[key] then
            info_queue[#info_queue + 1] = G.P_CENTERS[key]
        end
        return {
            vars = { rare_name(key) },
        }
    end,

    set_sprites = function(self, card, front)
        apply_jack_art(self, card)
    end,

    update = function(self, card, dt)
        local extra = jack_extra(card, self)
        local desired = extra.active
            and ('active_' .. tostring(tonumber(extra.hover_x) or 2))
            or 'closed'
        if card.hnds_jack_box_art_state ~= desired
            and card.set_sprites and card.config and card.config.center
        then
            card:set_sprites(card.config.center)
        end
    end,

    load = function(self, card, card_table, other_card)
        local extra = jack_extra(card, self)
        if extra.active and extra.rare_key then
            -- The base game reconstructs hand size separately during load; defer
            -- the borrowed passive until CardAreas exist.
            G.E_MANAGER:add_event(Event({
                trigger = 'after', delay = 0,
                func = function()
                    if card and card.area and card.ability and card.ability.extra
                        and card.ability.extra.active
                    then
                        on_borrowed_ability_changed(card, nil, card.ability.extra.rare_key)
                    end
                    return true
                end,
            }))
        end
    end,

    remove_from_deck = function(self, card, from_debuff)
        if from_debuff then return end
        local extra = jack_extra(card, self)
        if extra.active and extra.rare_key then
            on_borrowed_ability_changed(card, extra.rare_key, nil)
        end
    end,

    calculate = function(self, card, context)
        local extra = jack_extra(card, self)
        local ret, post

        -- If the borrowed Rare is Blueprint/Brainstorm-incompatible, Jack is
        -- mechanically incompatible for the duration of that active round.
        if context.blueprint and extra.active and extra.rare_key
            and not rolled_blueprint_compatible(extra)
        then
            return nil
        end

        -- While active, evaluate the rolled Rare Joker through Jack's virtual
        -- non-rendered proxy and serialise its ability state for save/load safety.
        if extra.active and extra.rare_key then
            ret, post = run_rare_ability(card, extra, context)
        end

        -- Closed -> active -> closed, toggling only after a completed round.
        -- The active Rare gets its own end-of-round calculation before closing.
        if context.end_of_round and context.main_eval
            and not context.game_over
            and not context.blueprint
            and not context.retrigger_joker
        then
            schedule_transition(self, card, not extra.active)
        end

        return ret, post
    end,

    joker_display_def = function(JokerDisplay)
        return {
            reminder_text = {
                { text = '(' },
                { ref_table = 'card.joker_display_values', ref_value = 'rare_name' },
                { text = ')' },
            },
            calc_function = function(card)
                local extra = card.ability and card.ability.extra or {}
                card.joker_display_values.rare_name = rare_name(extra.active and extra.rare_key or nil)
            end,
        }
    end,

    attributes = { 'joker', 'copying', 'round' },
}
