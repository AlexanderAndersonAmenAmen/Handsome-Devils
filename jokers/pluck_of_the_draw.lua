-- Pluck records bonus draws when Enhanced cards are discarded. They must
-- happen AFTER the vanilla/Steamodded refill, not in a discard event (which
-- can resolve before the normal cards finish entering G.hand).
HNDS = HNDS or {}

function HNDS.install_pluck_refill_hook()
    if not (G and G.FUNCS and type(G.FUNCS.draw_from_deck_to_hand) == 'function') then
        return false
    end
    if HNDS._pluck_draw_hook == G.FUNCS.draw_from_deck_to_hand then return true end

    local vanilla_refill = G.FUNCS.draw_from_deck_to_hand
    local function wrapped_refill(...)
        local game = G and G.GAME
        local result = { vanilla_refill(...) }
        -- Regular cards have now been scheduled. Queue Pluck afterwards,
        -- leaving the game's regular refill/hand-size calculations untouched.
        if game and (tonumber(game.hnds_pluck_pending_draws) or 0) > 0
            and not game.hnds_pluck_refill_queued and G.E_MANAGER and Event
        then
            game.hnds_pluck_refill_queued = true
            G.E_MANAGER:add_event(Event({ trigger = 'after', delay = 0.4,
                func = function()
                    if G and G.GAME == game then
                        local count = math.max(0, tonumber(game.hnds_pluck_pending_draws) or 0)
                        game.hnds_pluck_pending_draws = 0
                        game.hnds_pluck_refill_queued = nil
                        if G.deck and G.deck.cards and G.hand then
                            for i = 1, math.min(count, #G.deck.cards) do
                                -- Deliberately exceeds the hand-size limit.
                                draw_card(G.deck, G.hand, 1, 'up', true)
                            end
                        end
                    else
                        game.hnds_pluck_refill_queued = nil
                        game.hnds_pluck_pending_draws = 0
                    end
                    return true
                end,
            }))
        end
        return unpack(result)
    end
    HNDS._pluck_draw_hook = wrapped_refill
    G.FUNCS.draw_from_deck_to_hand = wrapped_refill
    return true
end

SMODS.Joker({
    key = 'pluck_of_the_draw', rarity = 2, cost = 5,
    blueprint_compat = true, atlas = 'Jokers', pos = { x = 1, y = 9 },
    config = { extra = { draw_per_card = 2 } },
    loc_vars = function(self, info_queue, card) return { vars = { 2 } } end,
    update = function(self, card, dt) HNDS.install_pluck_refill_hook() end,
    calculate = function(self, card, context)
        if not (context.discard and context.other_card and not context.repetition) then return end
        local discarded = context.other_card
        local enhanced = false
        if SMODS and type(SMODS.get_enhancements) == 'function' then
            local ok, enhancements = pcall(SMODS.get_enhancements, discarded)
            enhanced = ok and type(enhancements) == 'table' and next(enhancements) ~= nil
        end
        if not enhanced then
            enhanced = discarded.config and discarded.config.center
                and discarded.config.center.set == 'Enhanced'
        end
        if not (enhanced and G and G.GAME and G.deck and G.hand) then return end
        HNDS.install_pluck_refill_hook()
        G.GAME.hnds_pluck_pending_draws = (tonumber(G.GAME.hnds_pluck_pending_draws) or 0) + 2
        return { message = '+2 Cards', colour = G.C.FILTER }
    end,
    attributes = {'draw', 'joker'},
})

HNDS.install_pluck_refill_hook()
