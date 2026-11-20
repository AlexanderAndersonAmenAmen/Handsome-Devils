local slots = { 'Small', 'Big' }
local default_blinds = { Small = 'bl_small', Big = 'bl_big' }
local unpack_values = table.unpack or unpack
local joker_key = 'j_hnds_excommunicado'

function HNDS.excommunicado_effect_active(exclude)
    if not (G and G.GAME and SMODS and SMODS.find_card) then return false end
    for _, card in ipairs(SMODS.find_card(joker_key) or {}) do
        if card ~= exclude and not card.removed and not card.REMOVED then return true end
    end
    for _, card in ipairs(SMODS.find_card('j_hnds_jack_in_the_box') or {}) do
        local extra = card.ability and card.ability.extra
        if card ~= exclude and not card.removed and not card.REMOVED
            and type(extra) == 'table' and extra.active and extra.rare_key == joker_key
        then
            return true
        end
    end
    return false
end

local function is_pvp_slot(slot, key)
    return key == 'bl_mp_nemesis' or (HNDS.mp_slot_is_pvp and HNDS.mp_slot_is_pvp(slot))
end

local function eligible_boss(game, key, ante)
    local blind = G.P_BLINDS[key]
    local boss = blind and blind.boss
    if type(boss) ~= 'table' or boss.showdown or key == 'bl_mp_nemesis'
        or type(blind.pos) ~= 'table' or not blind.mult or (game.banned_keys and game.banned_keys[key])
        or ante < (tonumber(boss.min) or 1) or ante > (tonumber(boss.max) or math.huge)
    then
        return false
    end
    if type(blind.in_pool) ~= 'function' then return true end
    local ok, allowed = pcall(SMODS.add_to_pool or blind.in_pool, blind)
    return ok and not not allowed
end

local function choose_boss(game, slot, ante, used)
    local lowest_uses, candidates = math.huge, {}
    for key in pairs(G.P_BLINDS) do
        if not used[key] and eligible_boss(game, key, ante) then
            local uses = tonumber(game.bosses_used and game.bosses_used[key]) or 0
            if uses < lowest_uses then lowest_uses, candidates = uses, {} end
            if uses == lowest_uses then candidates[#candidates + 1] = key end
        end
    end
    if #candidates == 0 then return nil end
    table.sort(candidates)
    return pseudorandom_element(candidates, pseudoseed('excom_' .. slot:lower() .. '_' .. ante))
end

local function is_open(state)
    return state ~= 'Current' and state ~= 'Defeated' and state ~= 'Skipped'
end

local function restore_slot(game, choices, slot, record, rollover)
    local upgrades = game.hnds_platinum_blind_replacements or {}
    local upgrade = upgrades[tostring(record.ante) .. ':' .. slot]
    local original = G.P_BLINDS[record.original] and record.original or default_blinds[slot]
    local linked_upgrade = type(upgrade) == 'table' and upgrade.original == record.boss
    if linked_upgrade then upgrade.original = original end
    if choices[slot] == record.boss or (rollover and linked_upgrade and choices[slot] == upgrade.boss) then
        choices[slot] = original
    end
end

function HNDS.update_excom(changed_card, adding, phase)
    local game = G and G.GAME
    local resets = game and game.round_resets
    local choices = resets and resets.blind_choices
    if not (choices and G.P_BLINDS) then return end
    local records = game.hnds_excommunicado_blinds
    local active = adding or HNDS.excommunicado_effect_active(changed_card)
    if not (active or records) then return end

    local rollover = phase == 'new_ante'
    local loading = phase == 'load'
    local legacy = loading and active and not records
    local states = resets.blind_states or {}
    local upgrades = game.hnds_upgraded_blinds or {}
    local ante = math.max(1, tonumber(resets.ante) or 1)
    records = records or {}
    game.hnds_excommunicado_blinds = records

    local changeable = {}
    local used = {}
    if choices.Boss then used[choices.Boss] = true end
    for _, slot in ipairs(slots) do
        local choice = choices[slot]
        local existing = G.P_BLINDS[choice]
        local upgraded = upgrades[tostring(ante) .. ':' .. slot]
        if not is_pvp_slot(slot, choice) then
            local record = records[slot]
            local open = is_open(states[slot])
            if legacy and not upgraded and existing and existing.boss then
                record = { original = default_blinds[slot], boss = choice, ante = ante }
                records[slot] = record
            end
            if open and record and (not active or rollover or record.ante ~= ante
                or (loading and (record.boss == choices.Boss or not eligible_boss(game, record.boss, ante))))
            then
                restore_slot(game, choices, slot, record, rollover)
                records[slot] = nil
            end
            if open and active and not G.P_BLINDS[choices[slot]] then choices[slot] = default_blinds[slot] end
            changeable[slot] = open and not upgraded and (rollover or choices[slot] == default_blinds[slot])
        elseif rollover then
            records[slot] = nil
        end
        if choices[slot] then used[choices[slot]] = true end
    end

    if not active then return end
    for _, slot in ipairs(slots) do
        if changeable[slot] then
            local boss = choose_boss(game, slot, ante, used)
            if boss then
                records[slot] = { original = choices[slot], boss = boss, ante = ante }
                choices[slot] = boss
                used[boss] = true
                if rollover and game.bosses_used then
                    game.bosses_used[boss] = (tonumber(game.bosses_used[boss]) or 0) + 1
                end
            end
        end
    end
end

local function excommunicado_slot(slot, blind_key)
    local game = G and G.GAME
    local records = game and game.hnds_excommunicado_blinds
    local record = records and records[slot]
    return blind_key and record and record.boss == blind_key and not is_pvp_slot(slot, blind_key)
end

function HNDS.excommunicado_blind_score(slot, blind_key, score)
    if not excommunicado_slot(slot, blind_key) then return score end
    local reduced = score * (slot == 'Small' and 0.5 or 0.75)
    return type(reduced) == 'number' and math.floor(reduced) or reduced
end

local get_type_ref = Blind.get_type
function Blind:get_type(...)
    local game = G and G.GAME
    if game and game.blind == self then
        local slot = game.blind_on_deck
        local states = game.round_resets and game.round_resets.blind_states
        local center = self.config and self.config.blind
        local state = states and states[slot]
        if (state == 'Current' or state == 'Defeated') and excommunicado_slot(slot, center and center.key) then
            return slot
        end
    end
    return get_type_ref(self, ...)
end

local reset_blinds_ref = reset_blinds
function reset_blinds(...)
    local resets = G and G.GAME and G.GAME.round_resets
    local rollover = resets and resets.blind_states and resets.blind_states.Boss == 'Defeated'
    local result = HNDS.pack(reset_blinds_ref(...))
    if rollover then HNDS.update_excom(nil, nil, 'new_ante') end
    return unpack_values(result, 1, result.n)
end

local start_run_ref = Game.start_run
function Game:start_run(args, ...)
    local result = HNDS.pack(start_run_ref(self, args, ...))
    if args and args.savetext then HNDS.update_excom(nil, nil, 'load') end
    return unpack_values(result, 1, result.n)
end
