-- Keep round data before the MP end-round/reset path clears hands/stack state.
function HNDS.capture_pvp_soul_round(context)
    local game = G and G.GAME
    local blind = game and game.blind
    if not (blind and HNDS.mp_is_pvp and HNDS.mp_is_pvp(blind)) then return nil end
    local token = HNDS.round_effect_token()
    local state = game.hnds_pvp_soul_round
    if not state or state.token ~= token then
        state = { token = token, hands = 0, bosses = {} }
        game.hnds_pvp_soul_round = state
    end
    local hands = tonumber(game.current_round and game.current_round.hands_played) or 0
    if context and context.setting_blind then hands = 0 end
    -- before/after scoring precede Balatro's hands_played increment.
    if context and context.before then hands = hands + 1 end
    state.hands = math.max(state.hands, hands)
    if game.hnds_platinum_boss_stack_active or blind.hnds_platinum_boss_stack_active then
        local ante = game.hnds_platinum_boss_stack_ante or blind.hnds_reward_ante
            or (game.round_resets and game.round_resets.ante)
        state.bosses = {}
        for _, key in ipairs(HNDS.platinum_boss_effects_for_ante(ante) or {}) do
            state.bosses[#state.bosses + 1] = key
        end
    end
    return state
end

function HNDS.pvp_soul_reward(state, seed)
    if state and #state.bosses > 0 then
        local key = pseudorandom_element(state.bosses, pseudoseed(seed .. '_stack'))
        key = (HNDS.PLATINUM_HOOK_TO_BLIND or {})[key] or key
        local center = G.P_BLINDS and G.P_BLINDS[key] or { key = key }
        local soul = HNDS.get_blind_soul({config = {blind = center}}, seed .. '_soul')
        if soul then return soul end
    end
    return { set = 'Joker', key = 'j_joker' }
end

function HNDS.trigger_pvp_souls()
    local game = G and G.GAME
    local api = HNDS.mp_backend and HNDS.mp_backend()
    local spectator = api and api.SPECTATOR
    if spectator and (spectator.is_spectating or spectator.is_spectator_role) then return end
    local state = HNDS.capture_pvp_soul_round()
    if not (state and game.hnds_mp_result == 'win' and state.hands <= 1) or state.rewarded then return end
    -- Normal evaluation keeps Pennywise ownership, debuffs and copy behavior.
    state.rewarded = true
    SMODS.calculate_context({hnds_pvp_soul_reward = state})
end
