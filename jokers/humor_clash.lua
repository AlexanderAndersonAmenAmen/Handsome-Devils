local balance_colour = { 1, 1, 1, 1 }
local balance_purple = { 204 / 255, 115 / 255, 217 / 255, 1 }

-- Keep one shared table: open description text holds this reference, so it
-- animates without rebuilding the tooltip or changing other UI colours.
function HNDS.update_humor_clash_colour()
    if not (G and G.C and G.C.CHIPS and G.C.MULT) then return balance_colour end
    local time = G.TIMERS and G.TIMERS.REAL or 0
    local phase = (time / 1.2) % 4
    local segment = math.floor(phase)
    local t = phase - segment
    t = t * t * (3 - 2 * t)
    local from = segment == 0 and G.C.CHIPS or segment == 2 and G.C.MULT or balance_purple
    local to = segment == 1 and G.C.MULT or segment == 3 and G.C.CHIPS or balance_purple
    for i = 1, 4 do balance_colour[i] = from[i] + (to[i] - from[i]) * t end
    return balance_colour
end

local function plasma_run()
    local back = G and G.GAME and G.GAME.selected_back
    local center = back and back.effect and back.effect.center
    return center and center.key == 'b_plasma' or false
end

local function clash_extra(card)
    local extra = card.ability.extra
    if type(extra) ~= 'table' then extra = {}; card.ability.extra = extra end
    -- Also initializes existing copies saved with the former X2 Mult effect.
    extra.parity = extra.parity == 'even' and 'even' or 'odd'
    extra.scored = math.max(0, tonumber(extra.scored) or 0)
    extra.xmult = nil
    return extra
end

local function target(extra)
    return extra.parity == 'odd' and 5 or 4
end

local function matches_rank(card, parity)
    if not card or card.debuff or type(card.get_id) ~= 'function' then return false end
    if HNDS.safe_has_no_rank(card) then return false end
    local rank = card:get_id()
    -- Same rank groups as Odd Todd/Even Steven: Ace is odd, faces are neither.
    if parity == 'odd' then
        return rank == 14 or rank == 3 or rank == 5 or rank == 7 or rank == 9
    end
    return rank == 2 or rank == 4 or rank == 6 or rank == 8 or rank == 10
end

SMODS.Joker {
    key = 'humor_clash',
    atlas = 'Jokers',
    pos = { x = 8, y = 9 },
    rarity = 3,
    cost = 8,
    unlocked = true,
    discovered = false,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    config = { extra = { parity = 'odd', scored = 0 } },
    in_pool = function(self, args)
        return not plasma_run()
    end,
    loc_vars = function(self, info_queue, card)
        local extra = clash_extra(card)
        local next_parity = extra.parity == 'odd' and 'even' or 'odd'
        return { vars = { target(extra), math.max(0, target(extra) - extra.scored),
            extra.parity, next_parity, colours = { HNDS.update_humor_clash_colour() } } }
    end,
    calculate = function(self, card, context)
        if context.blueprint or context.retrigger_joker or card.debuff then return end
        local extra = clash_extra(card)
        if context.before then
            extra.hand_finished = false
        elseif context.individual and context.cardarea == G.play and not extra.hand_finished then
            if matches_rank(context.other_card, extra.parity) then
                -- Playing-card retriggers count, but Joker reevaluations do not.
                -- Keep the same parity throughout this hand, even after overflow.
                extra.scored = extra.scored + 1
            end
        elseif context.final_scoring_step and not extra.hand_finished then
            extra.hand_finished = true
            if extra.scored >= target(extra) then
                extra.scored = 0
                extra.parity = extra.parity == 'odd' and 'even' or 'odd'
                -- Steamodded balances final Chips and Mult before the deck's
                -- final scoring effect; no direct score mutation is needed.
                return { balance = true, no_retrigger = true }
            end
        end
    end,
    attributes = { 'ranks' },
}
