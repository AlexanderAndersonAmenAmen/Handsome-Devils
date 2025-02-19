SMODS.Joker {
    key = 'color_of_madness',               --joker key
    atlas = 'Jokers',          --atlas' key
    pos = { x = 4, y = 2 },
    rarity = 2,                --rarity: 1 = Common, 2 = Uncommon, 3 = Rare, 4 = Legendary
    --soul_pos = { x = 0, y = 0 },
    cost = 6,                  --cost
    unlocked = true,           --whether it is unlocked or not
    discovered = true,         --whether or not it starts discovered
    blueprint_compat = false,  --can it be blueprinted/brainstormed/other
    eternal_compat = false,    --can it be eternal
    perishable_compat = false, --can it be perishable
    calculate = function(card, card, context)
        if context.before and context.cardarea == G.jokers and not context.blueprint and G.GAME.current_round.hands_played == 0 then
            local suits = {
                ['Hearts'] = 0,
                ['Diamonds'] = 0,
                ['Spades'] = 0,
                ['Clubs'] = 0
            }
            for i = 1, #context.scoring_hand do
                if context.scoring_hand[i].ability.name ~= 'Wild Card' then
                    if context.scoring_hand[i]:is_suit('Hearts', true) and suits["Hearts"] == 0 then
                        suits["Hearts"] = suits["Hearts"] + 1
                    elseif context.scoring_hand[i]:is_suit('Diamonds', true) and suits["Diamonds"] == 0 then
                        suits["Diamonds"] = suits["Diamonds"] + 1
                    elseif context.scoring_hand[i]:is_suit('Spades', true) and suits["Spades"] == 0 then
                        suits["Spades"] = suits["Spades"] + 1
                    elseif context.scoring_hand[i]:is_suit('Clubs', true) and suits["Clubs"] == 0 then
                        suits["Clubs"] = suits["Clubs"] + 1
                    end
                end
            end
            for i = 1, #context.scoring_hand do
                if context.scoring_hand[i].ability.name == 'Wild Card' then
                    if context.scoring_hand[i]:is_suit('Hearts') and suits["Hearts"] == 0 then
                        suits["Hearts"] = suits["Hearts"] + 1
                    elseif context.scoring_hand[i]:is_suit('Diamonds') and suits["Diamonds"] == 0 then
                        suits["Diamonds"] = suits["Diamonds"] + 1
                    elseif context.scoring_hand[i]:is_suit('Spades') and suits["Spades"] == 0 then
                        suits["Spades"] = suits["Spades"] + 1
                    elseif context.scoring_hand[i]:is_suit('Clubs') and suits["Clubs"] == 0 then
                        suits["Clubs"] = suits["Clubs"] + 1
                    end
                end
            end
            if suits["Hearts"] > 0 and
                suits["Diamonds"] > 0 and
                suits["Spades"] > 0 and
                suits["Clubs"] > 0 then
                for i, v in ipairs(context.scoring_hand) do
                    v:set_ability(G.P_CENTERS.m_wild, nil, true)
                    play_sound('hnds_madnesscolor', 1.25, 0.05)
                end
                return
                {
                    colour = G.C.GREEN,
                    card = card,
                    message = 'Madness!',
                    sound = 'hnds_madnesscolor'
                }
            end
        end
    end,
    in_pool = function(card, wawa, wawa2)
        --whether or not this card is in the pool, return true if it is, return false if its not
        return true
    end
}