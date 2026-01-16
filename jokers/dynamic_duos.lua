SMODS.Joker {
    key = "dynamic_duos",
    atlas = "Jokers",
    pos = { x = 7, y = 4 },
    rarity = 1,
    cost = 6,
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    config = { extra = { repetitions = 1 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.repetitions } }
    end,
    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play then
            -- Check if hand is Two Pair with odd and even ranks
            if context.scoring_name == "Two Pair" and context.scoring_hand then
                local ranks = {}
                local odd_found = false
                local even_found = false
                
                for _, playing_card in ipairs(context.scoring_hand) do
                    local rank = playing_card:get_id()
                    ranks[rank] = (ranks[rank] or 0) + 1
                    
                    -- Check if odd or even (Aces count as odd like Odd Todd)
                    if rank % 2 == 1 or rank == 14 then
                        odd_found = true
                    else
                        even_found = true
                    end
                end
                
                -- Check if we have exactly two pairs
                local pair_count = 0
                for rank, count in pairs(ranks) do
                    if count == 2 then
                        pair_count = pair_count + 1
                    end
                end
                
                if pair_count == 2 and odd_found and even_found then
                    return {
                        repetitions = card.ability.extra.repetitions,
                    }
                end
            end
        end
    end,
}
