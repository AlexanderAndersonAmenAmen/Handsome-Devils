-------------------------------------------------------------------
-- PERILOUS PACT
-- Ante 10 Showdown Boss Blind
-- Caps the final score of every played hand at 50% of this Blind's
-- required score. The score hook follows The Can's implementation:
-- it modifies SMODS.calculate_round_score through a standard
-- modify_hand_chips calculation context.
-------------------------------------------------------------------

HNDS = HNDS or {}

local function set_active(active)
    if not (G and G.GAME) then return end
    G.GAME.hnds_perilous_pact_active = active and true or nil
end

SMODS.Blind {
    key = "perilous_pact",
    boss = { showdown = true },

    mult = 2,
    atlas_table = "ANIMATION_ATLAS",
    atlas = "ante_10_atlas",
    pos = { x = 0, y = 2 },

    boss_colour = HEX("89764b"),
    discovered = true,
    unlocked = true,

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

-- Steamodded's current scoring pipeline no longer adds hand_chips * mult
-- directly in state_events.lua. It routes the final hand score through this
-- function, so this is the reliable place to apply the per-hand cap.
if SMODS and type(SMODS.calculate_round_score) == "function"
    and not HNDS._perilous_pact_score_hooked
then
    HNDS._perilous_pact_score_hooked = true
    local calculate_round_score_ref = SMODS.calculate_round_score

    SMODS.calculate_round_score = function(flames)
        local score = calculate_round_score_ref(flames)
        if flames or score == nil then return score end

        local context = {
            modify_hand_chips = true,
            hand_chips = score,
        }
        SMODS.calculate_context(context)

        -- The direct fallback also covers unusual calculation-context chains
        -- that return without forwarding the modified field.
        return HNDS.cap_perilous_pact_score(context.hand_chips)
    end
end
