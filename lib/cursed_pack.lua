HNDS = HNDS or {}
local opening = setmetatable({}, {__mode = 'k'})

function HNDS.cursed_booster_is_unskippable(booster)
    if not booster then return false end
    if booster.hnds_forced_no_skip then return true end
    local modifiers = G and G.GAME and G.GAME.modifiers
    if not (modifiers and modifiers.hnds_cursed_deck_unskippable_boosters) then return false end
    local center = booster.config and booster.config.center
    local kind = booster.kind or (center and center.kind)
    local group_key = booster.group_key or (center and center.group_key)
    local joker_pack = kind == 'Joker' or kind == 'Buffoon' or group_key == 'k_buffoon_pack'
    if joker_pack
        and HNDS.joker_slots_full_of_unmovables
        and HNDS.joker_slots_full_of_unmovables()
    then
        return false
    end
    return true
end


function HNDS.open_cursed_pack(opts)
    opts = opts or {}
    if not (G and G.GAME and G.P_CENTERS and G.P_CENTERS.p_hnds_cursed_pack
        and G.FUNCS and type(G.FUNCS.use_card) == 'function'
        and SMODS and type(SMODS.create_card) == 'function')
    then
        return false
    end


    local area = G.play or G.hand or G.jokers
    local booster = SMODS.create_card({
        key = 'p_hnds_cursed_pack',
        area = area,
        bypass_discovery_center = true,
        bypass_discovery_ui = true,
    })
    if not booster then return false end

    if area and area.T then
        booster.T.x = area.T.x + area.T.w / 2 - G.CARD_W * 1.27 / 2
        booster.T.y = area.T.y + area.T.h / 2 - G.CARD_H * 1.27 / 2
        booster.T.w = G.CARD_W * 1.27
        booster.T.h = G.CARD_H * 1.27
    end

    booster.cost = 0
    booster.from_tag = opts.from_tag == true
    booster.hnds_cursed_pack_source = opts.source or (booster.from_tag and 'tag' or 'direct')


    booster.hnds_forced_no_skip = opts.forced == true
        and not (HNDS.joker_slots_full_of_unmovables and HNDS.joker_slots_full_of_unmovables())

    -- If another UI transition still owns card use, preserve the reward.
    if booster.check_use and booster:check_use() then
        if booster.remove then booster:remove() end
        return false
    end
    G.FUNCS.use_card({ config = { ref_table = booster } })
    booster:start_materialize()
    return true
end


function HNDS.queue_cursed_pack(opts)
    if not (G and G.GAME) then return false end
    opts = opts or {}
    local pending = {
        forced = opts.forced == true,
        source = opts.source or 'direct',
        from_tag = false,
    }
    if G.GAME.hnds_cursed_pack_pending then
        G.GAME.hnds_cursed_pack_queue = G.GAME.hnds_cursed_pack_queue or {}
        table.insert(G.GAME.hnds_cursed_pack_queue, pending)
    else
        G.GAME.hnds_cursed_pack_pending = pending
    end
    return true
end

function HNDS.open_pending_cursed_pack_at_shop()
    if not (G and G.GAME and G.E_MANAGER) then return false end
    local game = G.GAME
    local pending = game.hnds_cursed_pack_pending
    if not pending or opening[game] then return false end


    opening[game] = true
    G.E_MANAGER:add_event(Event({
        trigger = 'immediate',
        blocking = false,
        func = function()
            opening[game] = nil
            if G.GAME ~= game then return true end
            -- Retry from the next shop update rather than leave a blocking
            -- event waiting on a pack that needs player input to close.
            if game.PACK_INTERRUPT or (G.STATES and G.STATE ~= G.STATES.SHOP) then return true end
            if HNDS.open_cursed_pack(pending) then
                game.hnds_cursed_pack_pending = table.remove(game.hnds_cursed_pack_queue or {}, 1)
            end
            return true
        end,
    }))
    return true
end
