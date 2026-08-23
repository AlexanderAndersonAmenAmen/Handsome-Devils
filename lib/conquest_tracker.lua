-------------------------------------------------------------------
-- CONQUEST: RUN-WIDE BOSS-EQUIVALENT DEFEAT TRACKER
--
-- Tracks every defeated real Boss Blind plus every Small/Big Blind
-- explicitly replaced by Blind Raiser with an upgraded Boss Blind.
-- The counter exists independently of owning Conquest, so buying the
-- Joker later in the same run still sees all prior qualifying defeats.
-------------------------------------------------------------------

HNDS = HNDS or {}

local pack = HNDS.pack
local unpack_values = table.unpack or unpack

local function normalize_slot(slot)
    if slot == 'Small' or slot == 'Big' or slot == 'Boss' then return slot end
end

local function current_ante()
    return G and G.GAME and G.GAME.round_resets
        and math.max(1, tonumber(G.GAME.round_resets.ante) or 1)
        or 1
end

local function parse_upgrade_key(key)
    if type(key) ~= 'string' then return nil, nil end
    local ante, slot = key:match('^(%-?%d+):(%a+)$')
    return tonumber(ante), normalize_slot(slot)
end

-- Existing saves from before Conquest have no tracker field. Reconstruct a
-- conservative exact-enough baseline from run state:
--   * reaching Ante N implies N-1 real Bosses have already been defeated;
--   * hnds_blind_upgrades is cumulative;
--   * current-Ante upgraded Small/Big slots that are not yet Defeated are
--     subtracted because they have been rolled but not beaten yet.
local function migrate_existing_run_count()
    if not (G and G.GAME) then return 0 end

    local ante = current_ante()
    local real_bosses = math.max(0, ante - 1)
    local total_upgrades = math.max(0, tonumber(G.GAME.hnds_blind_upgrades) or 0)
    local pending_current = 0
    local upgraded = G.GAME.hnds_upgraded_blinds or {}
    local states = G.GAME.round_resets and G.GAME.round_resets.blind_states or {}

    for key, was_upgraded in pairs(upgraded) do
        if was_upgraded then
            local key_ante, slot = parse_upgrade_key(key)
            if key_ante == ante and (slot == 'Small' or slot == 'Big')
                and states[slot] ~= 'Defeated'
            then
                pending_current = pending_current + 1
            end
        end
    end

    return real_bosses + math.max(0, total_upgrades - pending_current)
end

local function ensure_counter()
    if not (G and G.GAME) then return 0 end
    if type(G.GAME.hnds_conquest_bosses_defeated) ~= 'number' then
        G.GAME.hnds_conquest_bosses_defeated = migrate_existing_run_count()
    end
    G.GAME.hnds_conquest_bosses_defeated = math.max(
        0,
        tonumber(G.GAME.hnds_conquest_bosses_defeated) or 0
    )
    return G.GAME.hnds_conquest_bosses_defeated
end

function HNDS.conquest_bosses_defeated()
    return ensure_counter()
end

local function is_upgraded_boss_blind(blind)
    local slot = blind and normalize_slot(blind.hnds_platinum_replacement_slot)
    return slot == 'Small' or slot == 'Big'
end

local function is_real_boss_blind(blind)
    if not blind then return false end
    if is_upgraded_boss_blind(blind) then return false end

    -- The Investment wrapper snapshots the physical slot on the live Blind;
    -- prefer it because blind_on_deck can advance during end-of-round cleanup.
    local slot = normalize_slot(blind.hnds_investment_physical_slot)
        or normalize_slot(G and G.GAME and G.GAME.blind_on_deck)
    return slot == 'Boss'
end

local function conquest_blind_counts(blind)
    return is_real_boss_blind(blind) or is_upgraded_boss_blind(blind)
end


-- Balatro reuses the same live Blind object across encounters. The old tracker
-- stored its duplicate-defeat guard on that object, so after the first Boss it
-- stayed true forever and every later Boss was ignored. Clear the guard only
-- when a genuinely new Blind center is installed; set_blind(nil, true) refresh
-- calls (selling cards, HUD refreshes, etc.) must not create a second count.
function HNDS.install_conquest_set_blind_hook()
    if not (Blind and type(Blind.set_blind) == 'function') then return false end
    if Blind.set_blind == HNDS._conquest_set_blind_wrapper then return true end

    local set_blind_ref = Blind.set_blind
    local wrapper = function(self, blind, ...)
        if blind ~= nil and self then
            self.hnds_conquest_defeat_counted = nil
        end
        return set_blind_ref(self, blind, ...)
    end

    HNDS._conquest_set_blind_wrapper = wrapper
    Blind.set_blind = wrapper
    return true
end

function HNDS.install_conquest_defeat_hook()
    if not (Blind and type(Blind.defeat) == 'function') then return false end
    if Blind.defeat == HNDS._conquest_defeat_wrapper then return true end

    local defeat_ref = Blind.defeat
    local wrapper = function(self, ...)
        -- Snapshot eligibility before inner wrappers/vanilla cleanup mutate the
        -- current slot. Increment only after defeat returns successfully.
        local qualifies = conquest_blind_counts(self)
        local already_counted = self and self.hnds_conquest_defeat_counted == true
        local results = pack(defeat_ref(self, ...))

        if qualifies and not already_counted and G and G.GAME then
            ensure_counter()
            G.GAME.hnds_conquest_bosses_defeated =
                G.GAME.hnds_conquest_bosses_defeated + 1
            self.hnds_conquest_defeat_counted = true
        end

        return unpack_values(results, 1, results.n)
    end

    HNDS._conquest_defeat_wrapper = wrapper
    Blind.defeat = wrapper
    return true
end

HNDS.install_conquest_set_blind_hook()
HNDS.install_conquest_defeat_hook()
