--[[
Handsome Devils - Cross Mod Compatibility Layer

Purpose
- This module contains targeted interop patches for other SMODS mods.

Currently supported integrations
1. Ortalab: Now we have a fix for the Bottle and The Harp, making them work properly
And yes this are almost 200 lines of code to make 2 consumables and a Joker work properly together

Other stuff we should add later
1. Cursed offer for other mods' consumables
2. New tables for Pennywise Boss Soul effect
3. Other food jokers from other mods
--]]

HNDS = HNDS or {}
HNDS.XMOD = HNDS.XMOD or {}

HNDS.XMOD._ortalab_wrapped = HNDS.XMOD._ortalab_wrapped or false
HNDS.XMOD._active_consumable_key = HNDS.XMOD._active_consumable_key or nil
HNDS.XMOD._perfectionist_seen = HNDS.XMOD._perfectionist_seen or setmetatable({}, { __mode = 'k' })
HNDS.XMOD._transfer_list = HNDS.XMOD._transfer_list or nil
HNDS.XMOD._transfer_i = HNDS.XMOD._transfer_i or 1
HNDS.XMOD._bottle_end_scheduled = HNDS.XMOD._bottle_end_scheduled or false
HNDS.XMOD._ortalab_prefix = HNDS.XMOD._ortalab_prefix or nil

local function _get_ortalab_prefix()
    if HNDS and HNDS.XMOD and HNDS.XMOD._ortalab_prefix then
        return HNDS.XMOD._ortalab_prefix
    end
    if not (SMODS and SMODS.find_mod) then return nil end
    local mods = SMODS.find_mod('ortalab')
    if mods and mods[1] then
        local p = mods[1].prefix or 'ortalab'
        if HNDS and HNDS.XMOD then
            HNDS.XMOD._ortalab_prefix = p
        end
        return p
    end
    return nil
end

local function _ortalab_consumable_center_key(suffix)
    local p = _get_ortalab_prefix()
    if not p then return nil end
    return 'c_' .. p .. '_' .. suffix
end

local function _is_ortalab_bottle_center_key(k)
    local target = _ortalab_consumable_center_key('lot_bottle')
    return target and k == target
end

local function _is_ortalab_harp_center_key(k)
    local target = _ortalab_consumable_center_key('lot_harp')
    return target and k == target
end

local function _card_bonus_snapshot(c)
    if not (c and c.ability) then return { perma_mult = 0, perma_bonus = 0 } end
    return {
        perma_mult = c.ability.perma_mult or 0,
        perma_bonus = c.ability.perma_bonus or 0
    }
end

local function _apply_bonus_snapshot(dst, snap)
    if not (dst and dst.ability and snap) then return end
    dst.ability.perma_mult = (dst.ability.perma_mult or 0) + (snap.perma_mult or 0)
    dst.ability.perma_bonus = (dst.ability.perma_bonus or 0) + (snap.perma_bonus or 0)
end

function HNDS.XMOD._begin_session(consumable_key)
    HNDS.XMOD._active_consumable_key = consumable_key
    HNDS.XMOD._perfectionist_seen = setmetatable({}, { __mode = 'k' })
    HNDS.XMOD._transfer_list = nil
    HNDS.XMOD._transfer_i = 1
    HNDS.XMOD._bottle_end_scheduled = false

    if consumable_key == 'lot_harp' then
        local snaps = {}
        if G and G.hand and G.hand.highlighted then
            for _, c in ipairs(G.hand.highlighted) do
                snaps[#snaps + 1] = _card_bonus_snapshot(c)
            end
        end
        HNDS.XMOD._transfer_list = { { perma_mult = 0, perma_bonus = 0 } }
        for _, s in ipairs(snaps) do
            HNDS.XMOD._transfer_list[1].perma_mult = HNDS.XMOD._transfer_list[1].perma_mult + (s.perma_mult or 0)
            HNDS.XMOD._transfer_list[1].perma_bonus = HNDS.XMOD._transfer_list[1].perma_bonus + (s.perma_bonus or 0)
        end
    end
end

function HNDS.XMOD._end_session()
    HNDS.XMOD._active_consumable_key = nil
    HNDS.XMOD._transfer_list = nil
    HNDS.XMOD._transfer_i = 1
    HNDS.XMOD._perfectionist_seen = setmetatable({}, { __mode = 'k' })
    HNDS.XMOD._bottle_end_scheduled = false
end

function HNDS.XMOD.perfectionist_should_apply(context)
    if not (context and context.other_card) then return true end

    local active = HNDS.XMOD._active_consumable_key
    if active == 'lot_bottle' or active == 'lot_harp' then
        if HNDS.XMOD._perfectionist_seen[context.other_card] then
            return false
        end
        HNDS.XMOD._perfectionist_seen[context.other_card] = true
        return true
    end

    return true
end

function HNDS.XMOD.try_wrap_ortalab()
    if HNDS.XMOD._ortalab_wrapped then return end
    if not (SMODS and SMODS.find_mod and next(SMODS.find_mod('ortalab'))) then return end
    if type(_G.track_usage) ~= 'function' then return end

    HNDS.XMOD._ortalab_wrapped = true

    local track_usage_ref = _G.track_usage
    _G.track_usage = function(t, key)
        -- Ortalab uses prefixed center_keys; normalize to stable session names
        if _is_ortalab_bottle_center_key(key) then
            HNDS.XMOD._begin_session('lot_bottle')
        elseif _is_ortalab_harp_center_key(key) then
            HNDS.XMOD._begin_session('lot_harp')
        end
        return track_usage_ref(t, key)
    end

    if SMODS and SMODS.calculate_context and not SMODS._hnds_xmod_wrapped_calculate_context then
        SMODS._hnds_xmod_wrapped_calculate_context = true
        local calc_ref = SMODS.calculate_context
        function SMODS.calculate_context(context, ...)
            if HNDS.XMOD._active_consumable_key == 'lot_bottle' and context and context.remove_playing_cards and context.removed then
                local snaps = {}
                for _, c in ipairs(context.removed) do
                    snaps[#snaps + 1] = _card_bonus_snapshot(c)
                end
                HNDS.XMOD._transfer_list = snaps
                HNDS.XMOD._transfer_i = 1
            end
            return calc_ref(context, ...)
        end
    end

    if type(_G.create_playing_card) == 'function' and not _G._hnds_xmod_wrapped_create_playing_card then
        _G._hnds_xmod_wrapped_create_playing_card = true
        local create_ref = _G.create_playing_card
        _G.create_playing_card = function(...)
            local c = create_ref(...)

            local active = HNDS.XMOD._active_consumable_key
            if (active == 'lot_bottle' or active == 'lot_harp') and HNDS.XMOD._transfer_list then
                local snap = HNDS.XMOD._transfer_list[HNDS.XMOD._transfer_i]
                if snap then
                    _apply_bonus_snapshot(c, snap)
                    HNDS.XMOD._transfer_i = HNDS.XMOD._transfer_i + 1

                    if active == 'lot_harp' then
                        HNDS.XMOD._end_session()
                    end
                end
            end

            return c
        end
    end

    -- End bottle session only once Ortalab starts drawing the created cards to hand
    if type(_G.draw_card) == 'function' and not _G._hnds_xmod_wrapped_draw_card then
        _G._hnds_xmod_wrapped_draw_card = true
        local draw_ref = _G.draw_card
        _G.draw_card = function(from, to, ...)
            local ret = draw_ref(from, to, ...)
            if HNDS and HNDS.XMOD and HNDS.XMOD._active_consumable_key == 'lot_bottle'
                and from == G.play and to == G.hand and not HNDS.XMOD._bottle_end_scheduled then
                HNDS.XMOD._bottle_end_scheduled = true
                if G and G.E_MANAGER and Event then
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0,
                        func = function()
                            if HNDS and HNDS.XMOD and HNDS.XMOD._active_consumable_key == 'lot_bottle' then
                                HNDS.XMOD._end_session()
                            end
                            return true
                        end
                    }))
                else
                    HNDS.XMOD._end_session()
                end
            end
            return ret
        end
    end
end

if Game and Game.init_game_object and not Game._hnds_xmod_wrapped_init_game_object then
    Game._hnds_xmod_wrapped_init_game_object = true
    local init_ref = Game.init_game_object
    function Game.init_game_object(self)
        local ret = init_ref(self)
        HNDS.XMOD.try_wrap_ortalab()
        return ret
    end
end

HNDS.XMOD.try_wrap_ortalab()