-------------------------------------------------------------------
-- PERILOUS PACT
-- Ante 10 Showdown Boss Blind
-- Caps each played hand according to the number of hands available
-- at the start of the Boss round.
-------------------------------------------------------------------

HNDS = HNDS or {}

local function reset_hands()
    local reset = G and G.GAME and G.GAME.round_resets
        and tonumber(G.GAME.round_resets.hands)
    return math.max(1, math.floor(reset or 1))
end

local function starting_hands()
    local current = G and G.GAME and G.GAME.current_round
        and tonumber(G.GAME.current_round.hands_left)
    if current and current > 0 then return math.floor(current) end
    return reset_hands()
end

local function on_blind_select_screen()
    return G and G.STATES and G.STATE == G.STATES.BLIND_SELECT
end

local function cap_fraction(hands)
    hands = math.max(1, math.floor(tonumber(hands) or 1))
    if hands <= 1 then return 1.00 end
    if hands <= 3 then return 0.50 end
    if hands == 4 then return 0.40 end
    if hands == 5 then return 0.30 end
    return 0.25
end

local function active_perilous_pact()
    if not (G and G.GAME and G.GAME.blind and not G.GAME.blind.disabled) then return false end
    local center = G.GAME.blind.config and G.GAME.blind.config.blind
    local key = center and center.key
    return G.GAME.hnds_perilous_pact_active
        or key == "bl_hnds_perilous_pact"
        or key == "perilous_pact"
end

local function set_active(active)
    if not (G and G.GAME) then return end
    if active then
        local hands = starting_hands()
        G.GAME.hnds_perilous_pact_active = true
        G.GAME.hnds_perilous_pact_starting_hands = hands
        G.GAME.hnds_perilous_pact_cap = cap_fraction(hands)
    else
        G.GAME.hnds_perilous_pact_active = nil
        G.GAME.hnds_perilous_pact_starting_hands = nil
        G.GAME.hnds_perilous_pact_cap = nil
    end
end

SMODS.Blind {
    key = "perilous_pact",
    boss = { showdown = true },

    mult = 2,
    atlas_table = "ANIMATION_ATLAS",
    atlas = "ante_10_atlas",
    pos = { x = 0, y = 2 },

    boss_colour = HEX("89764b"),
    discovered = false,
    unlocked = true,

    loc_vars = function(self)
        local selecting = on_blind_select_screen()
        if active_perilous_pact() or selecting then
            local fraction
            if selecting and not active_perilous_pact() then
                -- hands_left may still contain the previous round's value while
                -- choosing a Blind, so preview from the next round's reset.
                fraction = cap_fraction(reset_hands())
            else
                fraction = G.GAME.hnds_perilous_pact_cap
                    or cap_fraction(G.GAME.hnds_perilous_pact_starting_hands or starting_hands())
            end
            return {
                key = "bl_hnds_perilous_pact_active",
                vars = { math.floor(fraction * 100 + 0.5) },
            }
        end
        return { vars = {} }
    end,

    in_pool = function(self)
        return G and G.GAME
            and G.GAME.win_ante == 10
            and G.GAME.round_resets
            and G.GAME.round_resets.ante == 10
    end,

    set_blind = function(self, blind)
        set_active(true)
    end,

    disable = function(self, blind)
        set_active(false)
    end,

    defeat = function(self, blind)
        set_active(false)
    end,

    calculate = function(self, blind, context)
        if blind.disabled then return end

        if context.modify_hand_chips and context.hand_chips ~= nil then
            local original = context.hand_chips
            context.hand_chips = HNDS.cap_perilous_pact_score(original)
            if context.hand_chips ~= original then
                blind.triggered = true
            end
        end

        if context.after and blind.triggered then
            G.E_MANAGER:add_event(Event({
                func = function()
                    if SMODS.juice_up_blind then
                        SMODS.juice_up_blind()
                    elseif G.GAME and G.GAME.blind then
                        G.GAME.blind:juice_up()
                    end
                    return true
                end,
            }))
        end
    end,
}

-- Steamodded's current scoring pipeline routes the final hand score through
-- this function, so this is the reliable place to apply the per-hand cap.
if SMODS and type(SMODS.calculate_round_score) == "function"
    and not HNDS._perilous_pact_score_hooked
then
    HNDS._perilous_pact_score_hooked = true
    local calculate_round_score_ref = SMODS.calculate_round_score

    SMODS.calculate_round_score = function(flames, ...)
        local score = calculate_round_score_ref(flames, ...)
        if flames or score == nil then return score end

        local context = {
            modify_hand_chips = true,
            hand_chips = score,
        }
        SMODS.calculate_context(context)

        return HNDS.cap_perilous_pact_score(context.hand_chips)
    end
end
