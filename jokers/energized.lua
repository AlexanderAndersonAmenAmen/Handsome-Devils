-- A single held card counts, even with multiple Energized Jokers.
-- Rankless cards are excluded; equal ranks retain their left-to-right order.
function HNDS.energized_highest_card()
    if not (G and G.hand and SMODS.find_card and next(SMODS.find_card('j_hnds_energized'))) then return end
    local highest, highest_rank
    for _, held in ipairs(G.hand.cards or {}) do
        if not held.removed and not held.REMOVED and not held.getting_sliced
            and not HNDS.safe_has_no_rank(held) and type(held.get_id) == 'function'
        then
            local rank = held:get_id()
            if type(rank) == 'number' and (not highest_rank or rank > highest_rank) then
                highest, highest_rank = held, rank
            end
        end
    end
    return highest
end

SMODS.Joker {
    key = 'energized', atlas = 'Jokers', pos = { x = 2, y = 2 },
    rarity = 2, cost = 7,
    config = {},
    unlocked = false, discovered = false,
    unlock_condition = { type = 'hnds_joker_unlock', key = 'energized' },
    locked_loc_vars = function(self) return HNDS.joker_locked_loc_vars('energized') end,
    check_for_unlock = function(self, args) return HNDS.joker_unlock_condition_met('energized', args) end,
    blueprint_compat = false, eternal_compat = true, perishable_compat = true,
    attributes = { 'held_in_hand', 'passive' },
}
