-- Prevent repeated debuff/undebuff of passive hand/discard auras from creating
-- playable resources. Fun Police and Handicap Placard both use the standard
-- Card:set_debuff -> remove_from_deck/add_to_deck(true) path.
-- Keep changes to round_resets (future rounds) and to unrelated perks intact.
HNDS = HNDS or {}

local tracked = setmetatable({}, { __mode = 'k' })

function HNDS.advance_aura_blind_round()
    if not (G and G.GAME) then return end
    G.GAME.hnds_aura_blind_serial = (tonumber(G.GAME.hnds_aura_blind_serial) or 0) + 1
end

local function active_blind()
    return G and G.GAME and G.GAME.facing_blind == true
        and G.GAME.current_round and G.jokers
end

local function card_budget(card)
    local game = G and G.GAME
    local serial = game and game.hnds_aura_blind_serial or 0
    local budget = tracked[card]
    if not budget or budget.game ~= game or budget.serial ~= serial then
        budget = {game = game, serial = serial, debited_discards = false,
            debited_hands = false}
        tracked[card] = budget
    end
    return budget
end

local function guarded_transfer(card, ref, is_add, from_debuff, ...)
    if not (from_debuff and active_blind() and card and card.area == G.jokers) then
        return ref(card, from_debuff, ...)
    end
    local budget = card_budget(card)
    local original_discard, original_hands = ease_discard, ease_hands_played
    local round = G.GAME.current_round
    local before_discard = tonumber(round.discards_left)
    local before_hands = tonumber(round.hands_left)

    -- Both Balatro's Merry Andy and other aura Jokers use the ease_*
    -- functions, whose changes may execute later in the event manager.
    -- Intercept *before* those events are queued: a clamp after recalc_debuff
    -- cannot stop their delayed refunds.
    if type(original_discard) == 'function' then
        ease_discard = function(amount, ...)
            if type(amount) == 'number' then
                if is_add and amount > 0 then return end
                if not is_add and amount < 0 then
                    if budget.debited_discards then return end
                    budget.debited_discards = true
                end
            end
            return original_discard(amount, ...)
        end
    end
    if type(original_hands) == 'function' then
        ease_hands_played = function(amount, ...)
            if type(amount) == 'number' then
                if is_add and amount > 0 then return end
                if not is_add and amount < 0 then
                    if budget.debited_hands then return end
                    budget.debited_hands = true
                end
            end
            return original_hands(amount, ...)
        end
    end

    local results = {pcall(ref, card, from_debuff, ...)}
    ease_discard, ease_hands_played = original_discard, original_hands
    -- Also guard mods that alter the counters synchronously instead of
    -- calling ease_discard/ease_hands_played. Do not undo legitimate losses.
    if is_add then
        if before_discard and tonumber(round.discards_left) and round.discards_left > before_discard then
            round.discards_left = before_discard
        end
        if before_hands and tonumber(round.hands_left) and round.hands_left > before_hands then
            round.hands_left = before_hands
        end
    end
    if not results[1] then error(results[2], 0) end
    return unpack(results, 2, #results)
end

if Card and not Card._hnds_aura_resource_guard then
    Card._hnds_aura_resource_guard = true
    local add_ref, remove_ref = Card.add_to_deck, Card.remove_from_deck
    function Card:add_to_deck(from_debuff, ...)
        return guarded_transfer(self, add_ref, true, from_debuff, ...)
    end
    function Card:remove_from_deck(from_debuff, ...)
        return guarded_transfer(self, remove_ref, false, from_debuff, ...)
    end
end
