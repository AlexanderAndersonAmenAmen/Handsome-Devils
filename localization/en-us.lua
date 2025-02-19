return {
    descriptions = {
        -- this key should match the set ("object type") of your object,
        -- e.g. Voucher, Tarot, or the key of a modded consumable type
        Joker = {
            -- this should be the full key of your object, including any prefixes
            j_hnds_color_of_madness = {
                name = 'Color of Madness',
                text = {
                    'If {C:attention}first hand{} of round has',
                    'a scoring card of each {C:attention}suit{},',
                    'enhances scored cards',
                    'into {C:attention}Wild Cards{}',
                }
                -- only needed when this object is locked by default
                -- unlock = {
                --'This is a condition',
                --'for unlocking this card',
                --},
            },
            j_hnds_occultist = {
                name = 'Occultist',
                text = {
                    'If {C:attention}first hand{} of round has',
                    'a scoring card of each {C:attention}suit{},',
                    'create a {C:tarot}Charm{}, {C:planet}Meteor{}',
                    'or {C:spectral}Etehreal{} {C:attention}Tag{}',
                }
            },
            j_hnds_banana_split = {
                name = 'Banana Split',
                text = {
                    '{X:mult,C:white}X#1#{} Mult,',
                    '{C:green}#2# in 6{} chance to {C:attention}Duplicate{}',
                    'this Joker at end of round',
                    '{C:inactive}(Must have room){}',
                }
            },
            j_hnds_head_of_medusa = {
                name = 'Head of Medusa',
                text = {
                    'This Joker gains {X:mult,C:white}X#2#{} Mult',
                    'per scoring {C:attention}face card{} played,',
                    'enhances scored face cards',
                    'into {C:attention}Stone Cards{}',
                    '{C:inactive}(Currently {X:mult,C:white}X#1#{C:inactive} Mult)'
                }
            },
            j_hnds_deep_pockets = {
                name = 'Deep Pockets',
                text = {
                    '{C:attention}+#1#{} consumeable slots,',
                    'each card in your',
                    '{C:attention}consumable area{}',
                    'gives {C:mult}+#2#{} Mult',
                }
            },
            j_hnds_digital_circus = {
                name = 'Digital Circus',
                text = {
                    'Sell this card to create',
                    'a {V:1}#1#{} Joker, rarity',
                    'increases every {C:attention}#3#{} rounds',
                    '{C:inactive}(Currently {C:attention}#2#{C:inactive}/#3#)'
                }
            },
            j_hnds_coffee_break = {
                name = 'Coffee Break',
                text = {
                    'After {C:attention}3{} rounds, sell this',
                    'card to earn {C:money}$#3#{}, earn',
                    '{C:money}$1{} less per card played',
                    '{C:inactive}(Currently {C:attention}#2#{C:inactive}/#1#)'
                },
            },
            j_hnds_jackpot = {
                name = "Jackpot",
                text = {
                    '{C:green}#1# in #2#{} chance',
                    'to win {C:money}$#3#{} and {C:red}destroy{}',
                    'this card at end of round,',
                    'increases {C:attention}listed{} {C:green}probability{}',
                    'by {C:attention}#4#{} per scoring {C:attention}7{} played'
                }
            },
            j_hnds_pot_of_greed = {
                name = "Pot of Greed",
                text = {
                    'When you use a {C:attention}consumable card',
                    'during a round, draw {C:attention}#1#{} cards',
                    '{C:inactive}(Max of {C:attention}#2#{C:inactive} per round)'
                }
            },
        },
        Spectral={
            c_hnds_abyss = {
                name = 'Abyss',
                text = {
                    'Add a {C:dark_edition}Black Seal{}',
                    'to {C:attention}1{} selected',
                    'card in your hand'
                }
            },
            c_hnds_growth = {
                name = 'Growth',
                text = {
                    'Add a {C:green}Green Seal{}',
                    'to {C:attention}1{} selected',
                    'card in your hand'
                }
            },
            c_hnds_petrify = {
                name = 'Petrify',
                text = {
                    'Enhaces all cards in hand',
                    'into {C:attention}Stone Cards{}, but gain',
                    '{C:money}$5{} for each {C:attention}petrified{}'
                }
            }
        },
        Other = {
            hnds_black_seal = {
                name = 'Black Seal',
                text = {
                    'Counts in scoring',
                    'if {C:attention}held{} in hand'
                }
            },
            hnds_green_seal = {
                name = 'Green Seal',
                text = {
                    'Draw {C:attention}2{} extra',
                    'cards when {C:attention}scored',
                    'or {C:attention}discarded'
                }
            }
        },
        Voucher = {},
        Planet={
            c_hnds_makemake={
                name="Makemake",
                text={
                    "{S:0.8}({S:0.8,V:1}lvl.#1#{S:0.8}){} Level up",
                    "{C:attention}#2#",
                    "{C:chips}+#4#{} chips, {C:chips}+#6#{} extra",
                    "for each {C:attention}Stone Card{}",
                    "scored this Ante {C:inactive}[#5#]"
                },
            },
        }
    },
    misc = {
        dictionary = {
            k_hnds_petrified = "Petrified!",
            k_hnds_green = "Draw!",
            k_hnds_jackpot = "Jackpot!",
            k_hnds_probinc = "Increased!",
            k_hnds_coffee = "Cold!"
        },
        labels = {
            hnds_black_seal = "Black Seal",
            hnds_green_seal = "Green Seal"
        },
        poker_hands = {
            hnds_stone_ocean = "Stone Ocean"
        },
        poker_hand_descriptions = {
            hnds_stone_ocean = "A hand consisting of 5 Stone cards"
        }
    }
}
