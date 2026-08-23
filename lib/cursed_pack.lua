HNDS = HNDS or {}

-- Shared Cursed Pack opener. The Cursed Deck/Sleeve and the Cursed Tag are
-- independent triggers; they only share this low-level pack-construction helper.
-- Deck/sleeve packs are NOT represented by Tags and never set `from_tag`.
function HNDS.open_cursed_pack(opts)
    opts = opts or {}
    if not (G and G.GAME and G.P_CENTERS and G.P_CENTERS.p_hnds_cursed_pack
        and G.FUNCS and type(G.FUNCS.use_card) == 'function'
        and SMODS and type(SMODS.create_card) == 'function')
    then
        return false
    end

    -- Use Steamodded's normal card constructor. Creating the booster with raw
    -- Card(...) here left a scripted pack with partially initialized SMODS
    -- runtime state, which could strand the game after choosing its Joker.
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

    -- IMPORTANT: forced/no-skip is a property of this physical booster only.
    -- It must never be a G.GAME flag, otherwise a failed/alternate close path
    -- can make every later Cursed Pack unskippable.
    booster.hnds_forced_no_skip = opts.forced == true
        and not (HNDS.joker_slots_full_of_unmovables and HNDS.joker_slots_full_of_unmovables())

    G.FUNCS.use_card({ config = { ref_table = booster } })
    booster:start_materialize()
    return true
end

-- Queue exactly one deck/sleeve reward. Consumption happens in
-- SMODS.current_mod.calculate({starting_shop=true}), after Cash Out and before
-- the player can interact with the Shop. This is the same stable lifecycle used
-- by the Crystal Deck's queued Ultra Spectral Pack.
function HNDS.queue_cursed_pack(opts)
    if not (G and G.GAME) then return false end
    if G.GAME.hnds_cursed_pack_pending then return false end
    opts = opts or {}
    G.GAME.hnds_cursed_pack_pending = {
        forced = opts.forced == true,
        source = opts.source or 'direct',
        from_tag = false,
    }
    return true
end

function HNDS.open_pending_cursed_pack_at_shop()
    if not (G and G.GAME and G.E_MANAGER) then return false end
    local pending = G.GAME.hnds_cursed_pack_pending
    if not pending then return false end

    -- Consume before scheduling so repeated starting_shop calculations cannot
    -- enqueue the same reward twice.  Open on the next Event tick, matching the
    -- already-stable queued-booster flow used elsewhere in Handsome Devils.
    G.GAME.hnds_cursed_pack_pending = nil
    G.E_MANAGER:add_event(Event({
        trigger = 'immediate',
        func = function()
            if not HNDS.open_cursed_pack(pending) and G and G.GAME
                and not G.GAME.hnds_cursed_pack_pending then
                -- Do not lose the one-time reward if another mod temporarily
                -- makes the opener unavailable.
                G.GAME.hnds_cursed_pack_pending = pending
            end
            return true
        end,
    }))
    return true
end

-- Helper: spawns a free booster pack at the center of the play area.
-- Used by tags/decks that queue packs to open at the start of the next shop.
function HNDS.spawn_queued_booster(pack_key, pre_open_func)
    if not (G and G.E_MANAGER and G.play and G.FUNCS and G.FUNCS.use_card
        and SMODS and type(SMODS.create_card) == 'function' and Event) then return false end
    G.E_MANAGER:add_event(Event({
        func = function()
            local booster = SMODS.create_card { key = pack_key, area = G.play }
            booster.T.x = G.play.T.x + G.play.T.w / 2 - G.CARD_W * 1.27 / 2
            booster.T.y = G.play.T.y + G.play.T.h / 2 - G.CARD_H * 1.27 / 2
            booster.T.w = G.CARD_W * 1.27
            booster.T.h = G.CARD_H * 1.27
            booster.cost = 0
            booster.from_tag = true
            if pre_open_func then pre_open_func(booster) end
            G.FUNCS.use_card({ config = { ref_table = booster } })
            booster:start_materialize()
            return true
        end
    }))
    return true
end

-- Drain the pending Cursed Pack reward at the start-of-shop boundary.
HNDS.on_context(function(context)
    if context.starting_shop then
        HNDS.open_pending_cursed_pack_at_shop()
    end
end)
