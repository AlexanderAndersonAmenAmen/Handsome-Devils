return {
    descriptions = {
        -- this key should match the set ("object type") of your object,
        -- e.g. Voucher, Tarot, or the key of a modded consumable type
        Joker = {
            -- this should be the full key of your object, including any prefixes
            j_hnds_color_of_madness = {
                name = 'Color of Madness',
                text = {
                    'If {C:attention}first poker hand{} of',
                    'round contains {C:attention}4{} unique',
                    'suits, {C:attention}first{} scored card',
                    'becomes a {C:attention}Wild Card{}'
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
                    'If {C:attention}first poker hand{} of',
                    'round contains {C:attention}4{} unique',
                    'suits, create a {C:planet}Meteor{},',
                    '{C:tarot}Charm{} or {C:spectral}Ethereal{} {C:attention}Tag{}',
                }
            },
            j_hnds_banana_split = {
                name = 'Banana Split',
                text = {
                    '{X:mult,C:white}X#1#{} Mult,',
                    '{C:green}#2# in #3#{} chance to',
                    '{C:attention}Duplicate{} this card',
                    'at end of round',
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
                    '{C:attention}+#1#{} consumable slots,',
                    'each card in your',
                    '{C:attention}consumable area{}',
                    'gives {C:mult}+#2#{} Mult',
                }
            },
            j_hnds_digital_circus = {
                name = 'Digital Circus',
                text = {
                    'Sell this card to create',
                    'a {V:1}#1#{} Joker with',
                    'a random edition, rarity',
                    'increases every {C:attention}#3#{} rounds',
                    '{C:inactive}(Currently {C:attention}#2#{C:inactive}/#3#)'
                }
            },
            j_hnds_coffee_break = {
                name = 'Coffee Break',
                text = {
                    'After {C:attention}2{} rounds, sell this',
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
                    'When you use a',
                    '{C:attention}consumable card{},',
                    'draw {C:attention}#1#{} cards'
                }
            },
            j_hnds_seismic_activity = {
                name = "Seismic Activity",
                text = {
                    'Retrigger all',
                    '{C:attention}Stone cards'
                }
            },
            j_hnds_stone_mask = {
                name = "Stone Mask",
                text = {
                    'If {C:attention}first hand{} of round',
                    'is a single Enhanced card,',
                    'add a random {C:attention}edition{} to it',
                }
            },
            j_hnds_jokestone = {
                name = "Jokestone",
                text = {
                    'At the start of round,',
                    'draw up to {C:attention}3{} Enhanced',
                    'cards from your deck',
                }
            },
            j_hnds_meme = {
                name = "Meme",
                text = {
                    'This Joker gains',
                    '{X:mult,C:white}X0.05{} Mult per unique',
                    '{C:attention}suit{} in scored hand',
                    '{C:inactive}(Currently {X:mult,C:white}X#1#{C:inactive} Mult)',
                }
            },
            j_hnds_balloons = {
                name = "Balloons",
                text = {
                    "When round ends with no",
                    "{C:blue}hands{} left, {C:red}lose{} a {C:attention}Balloon{}",
                    "and create a random {C:attention}Tag",
                    "{C:inactive}({C:attention}#1#{C:inactive}/#2# Balloons left)"
                }
            },
            j_hnds_jokes_aside = {
                name = "Jokes Aside!",
                text = {
                    'This Joker gains',
                    '{X:mult,C:white}X#2#{} Mult for each Joker',
                    '{C:attention}sold{} during a round',
                    '{C:inactive}(Currently {X:mult,C:white}X#1#{C:inactive} Mult)'
                }
            },
            j_hnds_ms_fortune = {
                name = "Ms. Fortune",
                text = {
                    'Increases all listed',
                    '{C:green}probabilities{} by {C:attention}X#1#{},',
                    'but at the end',
                    'of {C:attention}shop{}, sets money',
                    'to {C:money}$#2#{}',
                    '{C:inactive}(e.x. {}{C:green}1 in 3{} {C:inactive}->{} {C:green}#1# in 3{}{C:inactive}){}'
                }
            },
        },
        Spectral = {
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
                    'Enhaces all {C:attention}face{} cards',
                    'in hand into {C:attention}Stone Cards{},',
                    'gain {C:money}$5{} for each petrified'
                }
            },
            c_hnds_exchange = {
                name = 'Exchange',
                text = {
                    "Add {C:dark_edition}Negative{} to",
                    "{C:attention}#1#{} selected cards,",
                    "{C:blue}-#2#{} hand each round",
                }
            },
            c_hnds_hallows = {
                name = 'Hallows',
                text = {
                    "Destroy all but the",
                    "leftmost Joker, gives {C:attention}X#1#{}",
                    "the sell value of destroyed",
                    "Jokers {C:inactive}(Max of {C:money}$#2#{C:inactive})",
                    "{C:inactive}(Currently {C:money}$#3#{C:inactive})",
                }
            },
            c_hnds_dream = {
                name = 'Dream',
                text = {
                    "Creates {C:attention}10{} random",
                    "{C:attention}Joker Tags{}"
                }
            },
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
        Voucher = {
            v_hnds_tag_hunter={
                name="Tag Hunter",
                text={
                    "Create a random {C:attention}Tag{}",
                    "when {C:attention}Boss Blind{}",
                    "is defeated"
                },
            },
            v_hnds_hashtag_skip={
                name="#2#skip",
                text={
                    "{C:attention}-1{} Ante for",
                    "every {C:attention}#1#{} skips"
                },
            },
            v_hnds_beginners_luck = {
                name = "Beginner's Luck",
                text = {
                    "Double all {C:attention}listed",
                    "{C:green,E:1,S:1.1}probabilities{} during",
                    "{C:attention}Small Blind{} round",
                    "{C:inactive}(ex: {C:green}1 in 3{C:inactive} -> {C:green}2 in 3{C:inactive})",
                },
            },
            v_hnds_rigged = {
                name = 'Rigged',
                text = {
                    "Double all {C:attention}listed{}",
                    "{C:green}probabilities{}",
                    "{C:inactive}(ex: {C:green}1 in 3{C:inactive} -> {C:green}2 in 3{C:inactive})",
                },
            }
        },
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
            k_hnds_goldfish = "Goldfish!",
            k_hnds_green = "Draw!",
            k_hnds_jackpot = "Jackpot!",
            k_hnds_probinc = "Increased!",
            k_hnds_coffee = "Cold!",
            k_hnds_seismic = "Tremor!",
            k_hnds_awaken = "Awaken!",
            k_hnds_IPLAYPOTOFGREED = "I PLAY!...",
            k_hnds_balloons = "All gone!",
            k_hnds_banana_split = "Split!",
            k_hnds_color_of_madness = "Madness!",
            k_hnds_occultist = "Study!"
        },
        labels = {
            hnds_black_seal = "Black Seal",
            hnds_green_seal = "Green Seal"
        },
        poker_hands = {
            hnds_stone_ocean = "Stone Ocean"
        },
        poker_hand_descriptions = {
            hnds_stone_ocean = { "A hand consisting of 5 Stone cards" }
        }
    }
}
