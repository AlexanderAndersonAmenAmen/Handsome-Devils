HNDS = HNDS or {}

local function shallow_copy(src)
    local out = {}
    if type(src) == 'table' then
        for k, v in pairs(src) do out[k] = v end
    end
    return out
end

local function current_blind_key()
    local blind = G and G.GAME and G.GAME.blind
    local cfg = blind and blind.config and blind.config.blind
    return cfg and cfg.key or nil
end

local function replay_token(ante, slot, blind_key)
    return tostring(ante or 0) .. ':' .. tostring(slot or '?') .. ':' .. tostring(blind_key or '?')
end

function HNDS.capture_time_fcked_blind()
    if not (G and G.GAME and G.GAME.round_resets and G.GAME.blind) then return false end

    local resets = G.GAME.round_resets
    local blind_key = current_blind_key()
    local ante = tonumber(resets.ante) or 0
    if not blind_key then return false end


    local slot = G.GAME.blind.hnds_platinum_replacement_slot
    local choices = resets.blind_choices or {}
    local on_deck = G.GAME.blind_on_deck
    if not slot and on_deck and choices[on_deck] == blind_key then slot = on_deck end
    if not slot then
        for _, candidate_slot in ipairs({ 'Small', 'Big', 'Boss' }) do
            if choices[candidate_slot] == blind_key then
                local state = resets.blind_states and resets.blind_states[candidate_slot]
                if state == 'Defeated' or state == 'Current' or state == 'Select' then
                    slot = candidate_slot
                    break
                end
            end
        end
    end
    if not slot and G.GAME.blind.get_type then
        local ok, kind = pcall(G.GAME.blind.get_type, G.GAME.blind)
        if ok and (kind == 'Small' or kind == 'Big' or kind == 'Boss') then slot = kind end
    end
    if not slot then return false end

    local token = replay_token(ante, slot, blind_key)
    G.GAME.hnds_time_fcked_candidate = {
        token = token,
        ante = ante,
        blind_ante = tonumber(resets.blind_ante) or ante,
        slot = slot,
        blind_key = blind_key,
        blind_choices = shallow_copy(resets.blind_choices),
        blind_states = shallow_copy(resets.blind_states),
    }
    return true
end

local function eligible_time_jokers()
    local found = SMODS.find_card and SMODS.find_card('j_hnds_time_fcked_joker') or {}
    local eligible = {}
    for _, c in ipairs(found or {}) do
        if c and not c.debuff and c.ability and c.ability.extra then
            eligible[#eligible + 1] = c
        end
    end
    return eligible
end

local function should_replay(candidate)
    if not (G and G.GAME and candidate and candidate.token) then return false end
    G.GAME.hnds_time_fcked_rolled = G.GAME.hnds_time_fcked_rolled or {}
    if G.GAME.hnds_time_fcked_rolled[candidate.token] then return false end


    G.GAME.hnds_time_fcked_rolled[candidate.token] = true

    local jokers = eligible_time_jokers()
    if #jokers == 0 then return false end


    local card = jokers[1]
    local odds = tonumber(card.ability.extra.odds) or 2
    return SMODS.pseudorandom_probability(
        card, 'hnds_time_fcked_' .. candidate.token, 1, odds, 'hnds_time_fcked'
    )
end

local function restore_replay_state(candidate)
    if not (G and G.GAME and G.GAME.round_resets and candidate) then return end
    local resets = G.GAME.round_resets

    resets.ante = candidate.ante or resets.ante
    resets.blind_ante = candidate.blind_ante or candidate.ante or resets.blind_ante
    resets.blind_choices = shallow_copy(candidate.blind_choices)
    resets.blind_states = shallow_copy(candidate.blind_states)

    local slot = candidate.slot
    if slot then
        resets.blind_choices[slot] = candidate.blind_key


        if slot == 'Small' then
            resets.blind_states.Small = 'Select'
            resets.blind_states.Big = 'Upcoming'
            resets.blind_states.Boss = 'Upcoming'
        elseif slot == 'Big' then
            resets.blind_states.Small = 'Defeated'
            resets.blind_states.Big = 'Select'
            resets.blind_states.Boss = 'Upcoming'
        elseif slot == 'Boss' then
            resets.blind_states.Small = 'Defeated'
            resets.blind_states.Big = 'Defeated'
            resets.blind_states.Boss = 'Select'
        else
            resets.blind_states[slot] = 'Select'
        end
        G.GAME.blind_on_deck = slot
    end

    local blind_center = G.P_BLINDS and G.P_BLINDS[candidate.blind_key]
    if blind_center then resets.blind = blind_center end


    G.GAME.hnds_time_fcked_candidate = nil
end

local function cash_out_to_replay(e, candidate)
    return HNDS.cash_out_skip_to_blind_select(e, {
        -- Balatro's long Negative-edition sting marks the successful timeline
        -- rewind. It runs after the round-eval guard so a failed transition
        -- can never play the proc sound.
        before = function()
            play_sound('negative', 1, 0.7)
        end,
        -- Restore the just-defeated Blind before the round counters reset.
        mid_event = function()
            restore_replay_state(candidate)
        end,
    })
end


if G and G.FUNCS and type(G.FUNCS.cash_out) == 'function'
    and not G.FUNCS._hnds_time_fcked_cash_out_wrapped
then
    local cash_out_ref = G.FUNCS.cash_out
    G.FUNCS._hnds_time_fcked_cash_out_wrapped = true

    function G.FUNCS.cash_out(e, delay_seconds, ...)
        local candidate = G and G.GAME and G.GAME.hnds_time_fcked_candidate
        if candidate and should_replay(candidate) then
            if cash_out_to_replay(e, candidate) then
                return
            end
        end


        if G and G.GAME then G.GAME.hnds_time_fcked_candidate = nil end
        return cash_out_ref(e, delay_seconds, ...)
    end
end
