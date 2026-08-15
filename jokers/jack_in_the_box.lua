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


local function enhanced_cards_in_full_deck()
    local count = 0
    for _, playing_card in ipairs((G and G.playing_cards) or {}) do
        local center = playing_card and playing_card.config and playing_card.config.center
        local key = center and center.key
        -- Editions and Seals do not change config.center. Any real Enhancement
        -- does; support both vanilla m_* centers and Steamodded Enhanced centers.
        if center and key ~= 'c_base' and key ~= 'm_base'
            and (center.set == 'Enhanced' or (type(key) == 'string' and key:sub(1, 2) == 'm_'))
        then
            count = count + 1
        end
    end
    return count
end

local function drivers_license_tooltip_vars()
    local center = G and G.P_CENTERS and G.P_CENTERS.j_drivers_license
    local xmult = center and center.config and tonumber(center.config.extra) or 3
    local threshold = center and center.unlock_condition and center.unlock_condition.extra
        and tonumber(center.unlock_condition.extra.count) or 16
    return xmult, threshold, enhanced_cards_in_full_deck()
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
    if not card then return end
    local proxy = card.hnds_jack_box_proxy
    card.hnds_jack_box_proxy = nil
    if not proxy then return end

    -- Borrowed runtime cards are deliberately never emplaced/add_to_deck'd.
    -- They still own Card/Sprite objects, though, so explicitly destroy them
    -- when Jack closes/rerolls/is removed instead of leaving headless Card
    -- instances in the engine registries.
    proxy.area = nil
    proxy.added_to_deck = false
    if type(proxy.remove) == 'function' then
        pcall(proxy.remove, proxy)
    end
end

local function hit_the_road_gain()
    local center = G and G.P_CENTERS and G.P_CENTERS.j_hit_the_road
    local cfg = center and center.config or {}
    local extra = cfg.extra
    if type(extra) == 'number' then return extra end
    if type(extra) == 'table' then
        return tonumber(extra.gain or extra.scaling or extra.xmult_gain or extra.x_mult_gain) or 0.5
    end
    return tonumber(cfg.scaling or cfg.xmult_gain or cfg.x_mult_gain) or 0.5
end

local function run_hit_the_road(card, extra, context)
    local state = extra.rare_state
    if type(state) ~= 'table' then
        local center = G and G.P_CENTERS and G.P_CENTERS.j_hit_the_road
        state = deep_copy((center and center.config) or {})
        extra.rare_state = state
    end

    state.x_mult = tonumber(state.x_mult or state.xmult) or 1

    -- Hit the Road scales only from real discards. Blueprint/retriggers may
    -- copy the current multiplier, but must never increment Jack's stored state.
    if context.discard and context.other_card and not context.blueprint
        and not context.retrigger_joker
    then
        local ok, id = pcall(context.other_card.get_id, context.other_card)
        if ok and id == 11 then
            state.x_mult = state.x_mult + hit_the_road_gain()
            state.xmult = state.x_mult
            return {
                message = localize({ type = 'variable', key = 'a_xmult', vars = { state.x_mult } }),
                colour = G.C.MULT,
                card = card,
            }
        end
    end

    if context.joker_main then
        return { xmult = state.x_mult }
    end
end

local function merge_saved_rare_state(initialized, saved)
    if type(initialized) ~= 'table' then initialized = {} end
    if type(saved) == 'table' then
        -- A real Card constructor supplies compatibility/runtime aliases that do
        -- not necessarily exist in center.config (notably vanilla x_mult). Keep
        -- those initialized fields and overlay only state that actually changed
        -- while Jack was borrowing the Rare.
        for k, v in pairs(saved) do
            initialized[k] = v
        end
    end
    return initialized
end

local function hide_proxy(proxy)
    if not (proxy and proxy.states) then return end
    if proxy.states.visible then proxy.states.visible = false end
    if proxy.states.hover then proxy.states.hover.can = false end
    if proxy.states.click then proxy.states.click.can = false end
    if proxy.states.drag then proxy.states.drag.can = false end
    if proxy.states.collide then proxy.states.collide.can = false end
end

-- Build one real, fully initialized Rare Joker Card for the active Jack round.
--
-- This is intentionally NOT an emplaced Joker and never calls add_to_deck(), so
-- it cannot consume a slot, enter find_card(), grant an edition/sticker, or run
-- a passive twice. Its only job is to carry the exact runtime `ability` table a
-- real Rare receives from Card:set_ability and to execute calculate_joker on
-- that state. This is the same basic model Blueprint uses (calculate another
-- real Card), without marking the ordinary Jack calculation as a blueprint.
local function borrowed_runtime(card, extra, center)
    if not (card and extra and center and SMODS and type(SMODS.create_card) == 'function') then
        return nil
    end

    local proxy = card.hnds_jack_box_proxy
    if proxy and proxy.config and proxy.config.center == center then
        proxy.area = card.area or (G and G.jokers) or proxy.area
        proxy.added_to_deck = true
        return proxy
    end

    clear_proxy(card)

    local ok, created = pcall(SMODS.create_card, {
        set = 'Joker',
        key = center.key,
        area = G and G.jokers or nil,
        no_edition = true,
        skip_materialize = true,
        discover = false,
        bypass_discovery_center = true,
        allow_duplicates = true,
        key_append = 'hnds_jack_runtime',
    })
    if not ok or not created then return nil end
    proxy = created

    proxy.config = proxy.config or {}
    proxy.config.center = center
    proxy.config.center_key = center.key
    proxy.area = card.area or (G and G.jokers) or proxy.area
    -- Some compatibility wrappers require this flag, but do NOT call
    -- add_to_deck(): Jack handles the few transferable add_to_deck passives
    -- (currently Stuntman/Excommunicado) explicitly.
    proxy.added_to_deck = true
    proxy.edition = nil
    proxy.seal = nil
    proxy.debuff = false
    proxy.hnds_jack_box_runtime = true
    hide_proxy(proxy)

    proxy.ability = merge_saved_rare_state(proxy.ability, extra.rare_state)
    proxy.ability.set = 'Joker'
    proxy.ability.name = center.name or proxy.ability.name
    proxy.ability.effect = center.effect or proxy.ability.effect
    -- Never borrow Jack's/another card's stickers through serialized state.
    proxy.ability.eternal = nil
    proxy.ability.perishable = nil
    proxy.ability.rental = nil
    proxy.ability.hnds_cursed = nil
    proxy.ability.hnds_jester_temp_negative = nil
    proxy.stickers = nil

    -- Store the actual initialized ability table, not a deep-copy. It is plain
    -- serializable card state and therefore survives save/load through Jack's
    -- own ability.extra without allocating a new clone on every calculation.
    extra.rare_state = proxy.ability
    card.hnds_jack_box_proxy = proxy
    return proxy
end

local function rebind_proxy_effect_source(value, proxy, jack, seen)
    if type(value) ~= 'table' then return end
    seen = seen or {}
    if seen[value] then return end
    seen[value] = true
    for k, v in pairs(value) do
        if (k == 'card' or k == 'juice_card') and v == proxy then
            value[k] = jack
        elseif type(v) == 'table' and v ~= G
            and not (v.config and v.T)
        then
            rebind_proxy_effect_source(v, proxy, jack, seen)
        end
    end
end

local function run_borrowed_card_dispatch(card, extra, center, context)
    local proxy = borrowed_runtime(card, extra, center)
    if not (proxy and type(proxy.calculate_joker) == 'function') then return nil end

    -- Match Jack's live area/debuff state on every evaluation. The runtime card
    -- is not in area.cards; assigning area is only so vanilla/mod compatibility
    -- checks see the same Joker context as the owner.
    proxy.area = card.area or (G and G.jokers) or proxy.area
    proxy.debuff = card.debuff or false

    local ok, ret, post = pcall(proxy.calculate_joker, proxy, context)
    extra.rare_state = proxy.ability
    if not ok then
        -- A third-party Rare may require lifecycle state that cannot be borrowed.
        -- Drop the bad runtime so the next context can rebuild cleanly; never let
        -- it corrupt Jack or the actual Joker area.
        clear_proxy(card)
        return nil
    end

    -- Effects that explicitly carry their source Card must resolve visually and
    -- mechanically to Jack, not to the invisible runtime object.
    rebind_proxy_effect_source(ret, proxy, card)
    rebind_proxy_effect_source(post, proxy, card)
    return ret, post
end

local function run_rare_ability(card, extra, context)
    local key = extra and extra.rare_key

    -- Hit the Road needs persistent per-round state but does not need a physical
    -- card. Handle it explicitly so its XMult gain is exact and cannot be reset
    -- or double-counted by compatibility wrappers around Card:calculate_joker.
    if key == 'j_hit_the_road' then
        return run_hit_the_road(card, extra, context)
    end

    -- Blueprint/Brainstorm need Jack's real position in G.jokers and have their
    -- own copier semantics, so keep the explicit implementation.
    if key == 'j_blueprint' or key == 'j_brainstorm' then
        return run_copy_rare(card, key, context)
    end
    if key == 'j_hnds_walking_joke' then
        return run_walking_joke(card, context)
    end
    if key == 'j_hnds_jester_in_yellow' then
        return run_jester_in_yellow(card, context)
    end

    local center = key and G and G.P_CENTERS and G.P_CENTERS[key]
    if not center then return nil end

    -- IMPORTANT: do not normalize legacy scoring keys here. Steamodded
    -- BETA-1620a natively registers chip_mod/mult_mod/Xmult_mod alongside
    -- chips/mult/xmult in SMODS.scoring_parameter_keys. Returning the exact
    -- result of Card:calculate_joker preserves vanilla and modded Rare behavior.
    return run_borrowed_card_dispatch(card, extra, center, context)
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
            if key == 'j_drivers_license' then
                local xmult, threshold, enhanced_count = drivers_license_tooltip_vars()
                info_queue[#info_queue + 1] = {
                    set = 'Other',
                    key = 'hnds_jack_drivers_license',
                    vars = { xmult, threshold, enhanced_count },
                }
            else
                info_queue[#info_queue + 1] = G.P_CENTERS[key]
            end
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
        clear_proxy(card)
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

        -- While active, evaluate the rolled Rare through one fully initialized,
        -- non-emplaced runtime Card and retain its ability state for save/load.
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
