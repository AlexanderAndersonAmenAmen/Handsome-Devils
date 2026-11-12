HNDS.MP = { protocol = 1, peers = {}, setup_peers = {}, clock = 0 }
local M = HNDS.MP
local pack = HNDS.pack
local unpack_values = table.unpack or unpack
local banned = {
    j_hnds_time_fcked_joker = true,
    j_hnds_public_nuisance = true,
    j_hnds_pennywise = true,
    v_hnds_tag_hunter = true,
    v_hnds_hashtag_skip = true,
}

function HNDS.mp_backend()
    if PVP and PVP.LOBBY then return PVP end
    if MP and MP.LOBBY then return MP end
end

function HNDS.mp_active()
    local api = HNDS.mp_backend()
    return api and api.LOBBY and api.LOBBY.code ~= nil and api.LOBBY.code ~= '' or false
end

function HNDS.mp_slot_is_pvp(slot)
    if not HNDS.mp_active() then return false end
    local resets = G.GAME and G.GAME.round_resets or {}
    local choices = resets.blind_choices or {}
    return choices[slot] == 'bl_mp_nemesis'
        or (resets.pvp_blind_choices and resets.pvp_blind_choices[slot] == true) or false
end

function HNDS.mp_is_pvp(blind)
    if not HNDS.mp_active() then return false end
    blind = blind or (G.GAME and G.GAME.blind)
    local center = blind and blind.config and blind.config.blind
    return (center and center.key == 'bl_mp_nemesis') or (blind and blind.pvp == true)
        or HNDS.mp_slot_is_pvp(G.GAME and G.GAME.blind_on_deck) or false
end

function HNDS.mp_boss_reward_allowed()
    return not HNDS.mp_is_pvp() or (G.GAME and G.GAME.hnds_mp_result == 'win')
end

function HNDS.mp_record_result(lost, draw)
    if not (HNDS.mp_active() and G.GAME) then return end
    if draw == nil and G.GAME.hnds_mp_authoritative_result then return end
    if draw then G.GAME.hnds_mp_result = 'draw'
    elseif lost == true or lost == 'true' then G.GAME.hnds_mp_result = 'loss'
    elseif lost == false or lost == 'false' then G.GAME.hnds_mp_result = 'win' end
end

local function api_lobby()
    return PVP and MPAPI and MPAPI.get_current_lobby and MPAPI.get_current_lobby()
end

local function own_id()
    local lobby = api_lobby()
    if lobby then return tostring(lobby.player_id) end
    local api = HNDS.mp_backend()
    return api and api.LOBBY.is_host and 'host' or 'guest'
end

local function state_token()
    local resets = G.GAME and G.GAME.round_resets or {}
    local api = HNDS.mp_backend()
    local lobby = api_lobby()
    local metadata = lobby and lobby:get_metadata() or {}
    local session = M.run_token or metadata.hnds_compat_session or (api and api.LOBBY.config.hnds_compat_session) or ''
    return tostring(session) .. ':' .. tostring(resets.ante or 0) .. ':' .. tostring(G.GAME and G.GAME.blind_on_deck or '')
end

local function local_crystal_mode()
    local mods = G.GAME and G.GAME.modifiers or {}
    if mods.crystal_sleeve_active then return 2 end
    if mods.hnds_crystal_showdown then return 1 end
    return 0
end

local function message(params)
    local lobby = api_lobby()
    if lobby and M.action then
        lobby:action(M.action):broadcast(params)
    else
        local api = HNDS.mp_backend()
        if api and api.ACTIONS and api.ACTIONS.modded then
            api.ACTIONS.modded('HandsomeDevils', 'compat', params)
        end
    end
end

local function send_state()
    if not HNDS.mp_active() then return end
    local data = { protocol = M.protocol, token = state_token(), crystal = local_crystal_mode(), sender = own_id() }
    M.peers[data.sender] = data
    M.state_dirty = true
    M.last_state_token = data.token
    message(data)
end

local function receive(data, from)
    if not HNDS.mp_active() or type(data) ~= 'table' then return end
    local mode = tonumber(data.crystal)
    if tonumber(data.protocol) ~= M.protocol or not mode or mode < 0 or mode > 2 then return end
    local sender = tostring(from or data.from or (own_id() == 'host' and 'guest' or 'host'))
    if data.kind == 'setup_request' then
        local api = HNDS.mp_backend()
        local lobby = api_lobby()
        if sender == 'host' or (lobby and sender == tostring(lobby.host_id)) then
            M.run_token = tostring(data.token)
            local cfg = api.LOBBY.config
            local stake = cfg.different_decks and api.LOBBY.deck.stake or cfg.stake
            message({protocol = M.protocol, token = data.token, crystal = 0, kind = 'setup', high = M.high_stake(stake)})
        end
        return
    end
    if sender == own_id() then return end
    M.state_dirty = true
    local peers = data.kind == 'setup' and M.setup_peers or M.peers
    peers[sender] = { protocol = M.protocol, token = tostring(data.token), crystal = mode, high = data.high == true or data.high == 'true' }
end

local function roster()
    local lobby = api_lobby()
    if lobby then
        local ids = {}
        for _, player in ipairs(lobby:get_players() or {}) do
            local id = type(player) == 'table' and (player.id or player.player_id) or player
            local lives = PVP and PVP._player_lives_cache and PVP._player_lives_cache[id]
            local eliminated = M.pending_start == nil and lives ~= nil and tonumber(lives) == 0
            if id and not eliminated then ids[#ids + 1] = tostring(id) end
        end
        return ids
    end
    return {'host', 'guest'}
end

local function crystal_for_round()
    local token = state_token()
    local mode = local_crystal_mode()
    for _, id in ipairs(roster()) do
        local peer = M.peers[id]
        if not peer or peer.token ~= token then return nil, false end
        mode = math.max(mode, peer.crystal)
    end
    local ante = G.GAME.round_resets.ante
    if not (mode > 0 and (ante == 4 or (mode == 2 and (ante == 2 or ante == 6)))) then return nil, true end
    local keys = {'bl_final_acorn', 'bl_final_heart', 'bl_final_bell', 'bl_final_leaf'}
    local hash = 0
    local api = HNDS.mp_backend()
    local seed = tostring(api.LOBBY.code) .. ':' .. token
    for i = 1, #seed do hash = (hash * 31 + seed:byte(i)) % 65521 end
    return keys[hash % #keys + 1], true
end

local function high_stake(value)
    local pool = G.P_CENTER_POOLS and G.P_CENTER_POOLS.Stake or {}
    local stake = type(value) == 'string' and G.P_STAKES and G.P_STAKES[value] or pool[tonumber(value)]
    local seen = {}
    local function visit(s)
        if not s or seen[s.key] then return false end
        seen[s.key] = true
        if s.key == 'stake_hnds_platinum' then return true end
        for _, key in ipairs(s.applied_stakes or {}) do
            if visit(G.P_STAKES and G.P_STAKES[key]) then return true end
        end
        return false
    end
    return visit(stake)
end
M.high_stake = high_stake

local function apply_lobby_lives()
    local api = HNDS.mp_backend()
    if not api or not api.LOBBY.config then return end
    local cfg = api.LOBBY.config
    local stake = cfg.different_decks and api.LOBBY.deck and api.LOBBY.deck.stake or cfg.stake
    if M.match_high_stake or high_stake(stake) then
        if M.original_lives == nil then M.original_lives = cfg.starting_lives end
        cfg.starting_lives = 5
    elseif M.original_lives ~= nil then
        cfg.starting_lives = M.original_lives
        M.original_lives = nil
    end
end
M.apply_lobby_lives = apply_lobby_lives

M.crystal_for_round = crystal_for_round
M.receive = receive

local function install()
    local api = HNDS.mp_backend()
    if not api or M.installed == api or not api.ACTIONS or not api.ACTIONS.ready_blind then return end
    if api == PVP and (not api.pvp_start_match or not M.action) then return end
    M.installed = api
    if api == MP and api.register_mod_action then api.register_mod_action('compat', receive, 'HandsomeDevils') end
    local ready_ref = api.ACTIONS.ready_blind
    api.ACTIONS.ready_blind = function(e, ...)
        if not HNDS.mp_active() then return ready_ref(e, ...) end
        M.lobby = api.LOBBY.code
        M.pending_ready = { e = e, args = pack(...), token = state_token(), elapsed = 0 }
        api.GAME.ready_blind = true
        api.GAME.next_blind_context = e
        send_state()
    end
    M.ready_ref = ready_ref
    if api.ACTIONS.unready_blind then
        local ref = api.ACTIONS.unready_blind
        api.ACTIONS.unready_blind = function(...)
            M.pending_ready = nil
            return ref(...)
        end
    end
    local start_owner = api.pvp_start_match and api or api.ACTIONS
    local start_key = api.pvp_start_match and 'pvp_start_match' or 'start_game'
    if start_owner[start_key] then
        local ref = start_owner[start_key]
        start_owner[start_key] = function(...)
            if not HNDS.mp_active() or not api.LOBBY.is_host then return ref(...) end
            M.lobby = api.LOBBY.code
            M.match_high_stake = nil
            apply_lobby_lives()
            M.setup_serial = (M.setup_serial or 0) + 1
            local token = 'setup:' .. tostring(M.setup_serial) .. ':' .. tostring(love.timer.getTime())
            local cfg = api.LOBBY.config
            local stake = cfg.different_decks and api.LOBBY.deck.stake or cfg.stake
            M.run_token = token
            M.setup_peers = { [own_id()] = { token = token, high = high_stake(stake), crystal = 0 } }
            M.pending_start = { ref = ref, args = pack(...), token = token, elapsed = 0 }
            message({protocol = M.protocol, token = token, crystal = 0, kind = 'setup_request'})
        end
    end
    if api.pvp_lobby_metadata then
        local ref = api.pvp_lobby_metadata
        api.pvp_lobby_metadata = function(...)
            apply_lobby_lives()
            return ref(...)
        end
    end
    if api.referee_reset then
        local ref = api.referee_reset
        api.referee_reset = function(lives, ...)
            apply_lobby_lives()
            if M.match_high_stake or high_stake(api.LOBBY.config.stake) then lives = 5 end
            return ref(lives, ...)
        end
    end
    if api.UTILS and api.UTILS.get_nemesis_key then
        local ref = api.UTILS.get_nemesis_key
        api.UTILS.get_nemesis_key = function(...)
            if HNDS.mp_active() and G.GAME and G.GAME.hnds_mp_crystal_key then return G.GAME.hnds_mp_crystal_key end
            return ref(...)
        end
    end
end

if PVP and MPAPI and MPAPI.on_loaded then
    MPAPI.on_loaded(function()
        local owner = SMODS.current_mod
        SMODS.current_mod = SMODS.Mods.MultiplayerPvP
        M.action = MPAPI.ActionType {
            key = 'hnds_compat', prefix_config = { key = false },
            on_receive = function(self, from, params) receive(params, from) end,
        }
        SMODS.current_mod = owner
        install()
    end)
end

local init_ref = Game.init_game_object
function Game:init_game_object(...)
    local game = init_ref(self, ...)
    if HNDS.mp_active() then
        game.banned_keys = game.banned_keys or {}
        for key in pairs(banned) do game.banned_keys[key] = true end
    end
    return game
end

for key in pairs(banned) do
    local center = (SMODS.Centers and SMODS.Centers[key]) or G.P_CENTERS[key]
    if center then
        local ref = center.in_pool
        center.in_pool = function(self, ...)
            if HNDS.mp_active() then return false end
            if ref then return ref(self, ...) end
            return true
        end
    end
end

local update_ref = Game.update
function Game:update(dt, ...)
    install()
    local result = pack(update_ref(self, dt, ...))
    if HNDS.mp_active() then
        local api = HNDS.mp_backend()
        if M.lobby ~= api.LOBBY.code then
            M.lobby = api.LOBBY.code
            M.peers = {}
            M.pending_ready = nil
            M.pending_start = nil
        end
        M.clock = M.clock + (dt or 0)
        if G.STAGE == G.STAGES.RUN and G.GAME and not M.pending_start and M.last_state_token ~= state_token() then send_state() end
        for _, field in ipairs({'pending_start', 'pending_ready'}) do
            local pending = M[field]
            if pending then
                pending.elapsed = (pending.elapsed or 0) + (dt or 0)
                if field == 'pending_start' and pending.elapsed > 20 then
                    M[field] = nil
                    if api.UI and api.UI.UTILS and api.UI.UTILS.overlay_message then
                        api.UI.UTILS.overlay_message(localize('hnds_mp_sync_timeout'))
                    end
                end
            end
        end
        if M.pending_start then
            local pending = M.pending_start
            local synced, high = true, false
            for _, id in ipairs(roster()) do
                local peer = M.setup_peers[id]
                synced = synced and peer ~= nil and peer.token == pending.token
                high = high or (peer and peer.token == pending.token and peer.high == true)
            end
            if synced then
                M.pending_start = nil
                M.match_high_stake = high
                if high then
                    if M.original_lives == nil then M.original_lives = api.LOBBY.config.starting_lives end
                    api.LOBBY.config.starting_lives = 5
                end
                api.LOBBY.config.hnds_compat_session = pending.token
                if api == MP then api.ACTIONS.lobby_options()
                else
                    local lobby = api_lobby()
                    if lobby and lobby.is_host then lobby:set_metadata({starting_lives = api.LOBBY.config.starting_lives, hnds_compat_session = pending.token}) end
                end
                pending.ref(unpack_values(pending.args, 1, pending.args.n))
            elseif M.clock >= 1 then
                M.clock = 0
                message({protocol = M.protocol, token = pending.token, crystal = 0, kind = 'setup_request'})
            end
        end
        if M.state_dirty and G.STATE == G.STATES.BLIND_SELECT and HNDS.mp_slot_is_pvp(G.GAME.blind_on_deck) then
            local crystal, synced = crystal_for_round()
            if synced then
                G.GAME.hnds_mp_crystal_key = crystal
                M.state_dirty = false
            end
        end
        if M.pending_ready then
            if M.pending_ready.token ~= state_token() then M.pending_ready = nil
            else
                if M.clock >= 1 then M.clock = 0; send_state() end
                local key, synced = crystal_for_round()
                if synced then
                    G.GAME.hnds_mp_crystal_key = key
                    local pending = M.pending_ready
                    M.pending_ready = nil
                    M.ready_ref(pending.e, unpack_values(pending.args, 1, pending.args.n))
                end
            end
        end
        if HNDS.mp_refresh_crystal_tooltip then HNDS.mp_refresh_crystal_tooltip() end
    else
        M.peers = {}
        M.pending_ready = nil
        M.lobby = nil
        M.pending_start = nil
        M.run_token = nil
        M.original_lives = nil
        M.match_high_stake = nil
        M.last_state_token = nil
    end
    return unpack_values(result, 1, result.n)
end

assert(SMODS.load_file('lib/multiplayer_crystal.lua'))()

local context_ref = SMODS.calculate_context
function SMODS.calculate_context(context, ...)
    if context and context.end_of_round and HNDS.mp_is_pvp() then
        local scoped = {}
        for k, v in pairs(context) do scoped[k] = v end
        scoped.beat_boss = HNDS.mp_boss_reward_allowed()
        return context_ref(scoped, ...)
    end
    return context_ref(context, ...)
end

function HNDS.mp_record_legacy_result(p)
    local draw = false
    if MP and MP.GAME and MP.INSANE_INT and not p.pvpTimerLost then
        local enemy = MP.GAME.enemy or {}
        local theirs = enemy.real_score or enemy.score
        local ours = MP.GAME.score
        if theirs and ours then draw = MP.INSANE_INT.equal(ours, theirs) end
    end
    HNDS.mp_record_result(p.lost, draw)
end
