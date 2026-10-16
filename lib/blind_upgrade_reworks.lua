HNDS = HNDS or {}

local function speed_blinds_defeated()
    return math.max(0, tonumber(G and G.GAME and G.GAME.hnds_speed_one_hand_blinds) or 0)
end

-- Speed Tag uses Balatro's internal key 'tag_skip'. Only actual one-hand
-- victories count, never skips, and the tally persists in the run save.
if Blind and type(Blind.defeat) == 'function' then
    local defeat_ref = Blind.defeat
    function Blind:defeat(...)
        local game = G and G.GAME
        local eligible = game and game.blind == self
            and game.current_round and game.current_round.hands_played == 1
            and not self.hnds_speed_one_hand_counted
        local results = HNDS.pack(defeat_ref(self, ...))
        if eligible then
            self.hnds_speed_one_hand_counted = true
            game.hnds_speed_one_hand_blinds = speed_blinds_defeated() + 1
        end
        return ((table and table.unpack) or unpack)(results, 1, results.n)
    end
end

if Blind and type(Blind.set_blind) == 'function' then
    local set_blind_ref = Blind.set_blind
    function Blind:set_blind(blind, reset, ...)
        local results = HNDS.pack(set_blind_ref(self, blind, reset, ...))
        if not reset and blind then self.hnds_speed_one_hand_counted = nil end
        return ((table and table.unpack) or unpack)(results, 1, results.n)
    end
end

SMODS.Tag:take_ownership('skip', {
    config = { type = 'immediate', skip_bonus = 5 },
    loc_vars = function(self, info_queue, tag)
        return { vars = { 5, speed_blinds_defeated() * 5 } }
    end,
    apply = function(self, tag, context)
        if not (context and context.type == 'immediate') or tag.triggered then return end
        local payout = 5 * speed_blinds_defeated()
        tag.triggered = true
        tag:yep('+$' .. tostring(payout), G.C.MONEY, function()
            if payout > 0 then ease_dollars(payout) end
            return true
        end)
        return true
    end,
}, true)

-- Vanilla Card:update calculates Throwback's XMult using ability.extra as a number.
-- Keep that field numeric and store the reworked rounds on their own ability key.
local THROWBACK_REQUIRED_ROUNDS = 2

local function throwback_progress(card)
    local ability = card and card.ability
    if not ability then return 0 end
    -- Legacy saves from the first rework stored this progress in a table.
    -- The pre-update migration in lib/hooks.lua also handles those saves.
    if type(ability.extra) == 'table' then
        local previous = ability.extra
        ability.hnds_throwback_rounds = math.max(
            tonumber(ability.hnds_throwback_rounds) or 0,
            tonumber(previous.rounds) or 0
        )
        ability.extra = 0
        ability.x_mult = 1
    end
    local rounds = math.max(0, tonumber(ability.hnds_throwback_rounds) or 0)
    return math.min(THROWBACK_REQUIRED_ROUNDS, rounds)
end

local function start_throwback_ready_jiggle(card)
    if not (card and G and G.jokers and card.area == G.jokers)
        or card.removed or card.REMOVED or card.debuff
        or card.hnds_throwback_ready_jiggle
        or throwback_progress(card) < THROWBACK_REQUIRED_ROUNDS
    then
        return
    end

    if type(juice_card_until) == 'function' then
        card.hnds_throwback_ready_jiggle = true
        juice_card_until(card, function(target)
            local active = target and not target.removed and not target.REMOVED
                and G and G.jokers and target.area == G.jokers
                and not target.debuff
                and throwback_progress(target) >= THROWBACK_REQUIRED_ROUNDS
            if not active and target then target.hnds_throwback_ready_jiggle = nil end
            return active
        end, true)
    elseif card.juice_up then
        card:juice_up(0.1, 0.1)
    end
end

SMODS.Joker:take_ownership('throwback', {
    rarity = 3,
    cost = 8,
    blueprint_compat = false,
    config = { extra = 0, x_mult = 1, hnds_throwback_rounds = 0 },
    loc_vars = function(self, info_queue, card)
        return { vars = { THROWBACK_REQUIRED_ROUNDS, throwback_progress(card) } }
    end,
    calculate = function(self, card, context)
        local rounds = throwback_progress(card)
        if context.end_of_round and context.main_eval
            and not context.game_over and not context.blueprint and not context.repetition
        then
            if rounds < THROWBACK_REQUIRED_ROUNDS then
                rounds = rounds + 1
                card.ability.hnds_throwback_rounds = rounds
                if rounds == THROWBACK_REQUIRED_ROUNDS then
                    start_throwback_ready_jiggle(card)
                    return { message = localize('k_active_ex'), colour = G.C.FILTER }
                end
            end
        elseif context.selling_self and not context.blueprint
            and rounds >= THROWBACK_REQUIRED_ROUNDS
        then
            local game = G and G.GAME
            if not (game and game.round_resets) then return end
            -- Match the existing Ante-reduction voucher's blind_ante handling.
            local old_ante = game.round_resets.ante
            ease_ante(-1)
            game.round_resets.blind_ante = (game.round_resets.blind_ante or old_ante) - 1
            game.round_resets.hands = math.max(1, (tonumber(game.round_resets.hands) or 4) - 1)
            local playing_blind = G and G.STATES and (
                G.STATE == G.STATES.SELECTING_HAND
                or G.STATE == G.STATES.DRAW_TO_HAND
                or G.STATE == G.STATES.HAND_PLAYED
            )
            if playing_blind and game.current_round
                and (game.current_round.hands_left or 0) > 1
            then
                ease_hands_played(-1)
            end
            return { message = '-1 Ante, -1 Hand', colour = G.C.RED }
        end
    end,
    update = function(self, card, dt)
        -- Restore the jiggle after loading a save with Throwback already ready.
        start_throwback_ready_jiggle(card)
    end,
}, true)
