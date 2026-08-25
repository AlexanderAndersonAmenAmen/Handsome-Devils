HNDS = HNDS or {}


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

    G.FUNCS.use_card({ config = { ref_table = booster } })
    booster:start_materialize()
    return true
end


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


    G.GAME.hnds_cursed_pack_pending = nil
    G.E_MANAGER:add_event(Event({
        trigger = 'immediate',
        func = function()
            if not HNDS.open_cursed_pack(pending) and G and G.GAME
                and not G.GAME.hnds_cursed_pack_pending then


                G.GAME.hnds_cursed_pack_pending = pending
            end
            return true
        end,
    }))
    return true
end
