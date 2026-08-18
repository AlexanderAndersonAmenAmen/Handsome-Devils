local function hnds_death_hand_edges()
    if not (G and G.hand and G.hand.cards) or #G.hand.cards < 2 then return nil, nil end
    return G.hand.cards[1], G.hand.cards[#G.hand.cards]
end

SMODS.Joker {
    key = 'death',
    atlas = 'Jokers',
    pos = { x = 4, y = 6 },
    rarity = 2,
    cost = 6,
    unlocked = true,
    discovered = true,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,

    calculate = function(self, card, context)
        if not (context.end_of_round and context.main_eval)
            or context.game_over or context.blueprint or context.retrigger_joker then
            return
        end

        local leftmost, rightmost = hnds_death_hand_edges()
        if not (leftmost and rightmost and leftmost ~= rightmost) then return end

        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.15,
            func = function()
                if leftmost and leftmost.area == G.hand then
                    leftmost:flip()
                    play_sound('card1', 1.05)
                end
                return true
            end,
        }))
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.15,
            func = function()
                if leftmost and rightmost and leftmost.area == G.hand and rightmost.area == G.hand then
                    -- This is the same in-place copy path used by Death Tarot:
                    -- rank, suit, Enhancement, Seal, Edition and card state copy
                    -- without changing the target's hand position.
                    copy_card(rightmost, leftmost)
                end
                return true
            end,
        }))
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.15,
            func = function()
                if leftmost and leftmost.area == G.hand then
                    leftmost:flip()
                    leftmost:juice_up(0.35, 0.35)
                    play_sound('tarot2', 1, 0.6)
                end
                return true
            end,
        }))

        return { message = localize('k_hnds_copied'), colour = G.C.PURPLE }
    end,

    attributes = { 'modify_card' },
}
