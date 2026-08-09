local localization = {
	descriptions = {
		Joker = {

			j_matador = {
				name = "Matador",
				text = {
                    'Gain {C:money}$#1#{} per hand',
                    'played vs {C:attention}Boss Blind{}',
				},
			},
			j_superposition = {
				name = "Superposition",
				text = {
                    'Create a {C:tarot}Fool{} card',
                    'if poker hand contains',
                    'an {C:attention}Ace{} and a {C:attention}Straight{}',
                    '{C:inactive}(Must have room)',
				},
			},
			j_splash = {
                name = 'Splash',
                text = {
					'Played cards',
				    '{C:attention}always{} score'
				},
			},
			j_flower_pot = {
				name = "Flower Pot",
				text = {
                    'Gives {X:mult,C:white}X{} Mult equal to the',
                    'number of {C:attention}unique{} suits',
                    'in played poker hand',
                    '{C:inactive}(Currently {X:mult,C:white}X#1#{C:inactive} Mult)',
				},
			},
			j_hnds_flower_pot_none = {
				name = "Flower Pot",
				text = {
                    'Gives {X:mult,C:white}X{} Mult equal to the',
                    'number of {C:attention}unique{} suits',
                    'in played poker hand',
					"{C:inactive}(Currently none)",
				},
			},
			j_mail = {
				name = "Mail-In Rebate",
				text = {
                    'Earn {C:money}$#1#{} for each',
                    'discarded {C:attention}#2#{}, rank',
                    'changes every round',
				},
			},
			j_stone = {
				name = "Stone Joker",
				text = {
					"Gives {C:chips}+#1#{} Chips for",
					"each {C:attention}Stone Card{}",
					"in your full deck",
					"{C:inactive}(Currently {C:chips}+#2#{C:inactive} Chips)",
				},
			},
			j_greedy_joker = {
				name = "Greedy Joker",
				text = {
					"Played cards with",
					"{C:diamonds}Diamond{} suit give",
					"{C:mult}+#1#{} Mult when scored",
				},
			},
			j_lusty_joker = {
				name = "Lusty Joker",
				text = {
					"Played cards with",
					"{C:hearts}Heart{} suit give",
					"{C:mult}+#1#{} Mult when scored",
				},
			},
			j_wrathful_joker = {
				name = "Wrathful Joker",
				text = {
					"Played cards with",
					"{C:spades}Spade{} suit give",
					"{C:mult}+#1#{} Mult when scored",
				},
			},
			j_gluttenous_joker = {
				name = "Gluttonous Joker",
				text = {
					"Played cards with",
					"{C:clubs}Club{} suit give",
					"{C:mult}+#1#{} Mult when scored",
				},
			},
			j_throwback = {
				name = "Throwback",
				text = {
					"{X:mult,C:white}X#1#{} Mult for each",
					"{C:attention}Blind{} skipped this run",
					"{C:inactive}(Currently {X:mult,C:white}X#2#{C:inactive} Mult)",
				},
			},
			j_seeing_double = {
				name = "Seeing Double",
				text = {
					"Retrigger all {C:attention}7s{}",
					"Retrigger them an",
					"additional time if",
					"their suit is {C:clubs}Clubs{}",
				},
			},
			j_ring_master = {
				name = "Showman",
				text = {
                    '{C:attention}Joker{}, {C:tarot}Tarot{}, {C:planet}Planet{}',
                    'and {C:spectral}Spectral{} cards may',
                    'appear multiple times',
				},
			},
			j_hiker = {
				name = "Hiker",
				text = {
					'Every played {C:attention}card{}',
                    'permanently gains',
                    '{C:chips}+#1#{} Chips when scoring',
				},
			},
			j_hnds_color_of_madness = {
				name = "Color of Madness",
				text = {
					"Enhances {C:attention}first two{} scored",
					"cards into {C:attention}Wild Cards{} if",
					"poker hand contains",
					"{C:attention}4{} different suits",
				},
				unlock = {
					"Have a at least {C:attention}10",
					"{C:attention}Wild Cards{}",
					"in your deck",
				},
			},
			j_hnds_occultist = {
				name = "Occultist",
				text = {
					"If {C:attention}first hand{} of round",
					"scores {C:attention}4{} different suits,",
					"create a {C:tarot}Charm{}, {C:spectral}Ethereal{},",
					"{C:planet}Meteor{} or {C:attention}Buffoon{} {C:attention}Tag{}",
				},
				unlock = {
					"Create a total",
					"of {C:attention}150 Tags{}",
					"{C:inactive}(#1#){}",
				},
			},
			j_hnds_supersuit = {
				name = "Supersuit",
				text = {
					"Retrigger all cards",
					"with {V:1}#1#{} suit",
					"{s:0.8}Suit changes every round",
				},
				unlock = {
					"Score {C:attention}4{} Flushes",
					"of different suits",
					"in one Ante",
				},
			},
			j_hnds_dark_idol = {
				name = "The Dark Idol",
				text = {
					"Destroys scored {C:attention}#2#{} of",
					"{V:1}#3#{} and gains {X:mult,C:white}X#1#{}",
					"Mult for each destroyed",
					"{s:0.8}Card changes every round",
					"{C:inactive}(Currently {X:mult,C:white}X#4#{C:inactive} Mult)"
				},
				unlock = {
					"Destroy a total",
					"of {C:attention}50{} cards",
					"{C:inactive}(#1#){}",
				},
			},
			j_hnds_perfectionist = {
				name = "Perfectionist",
				text = {
					"When you enhance",
					"an Enhanced card,",
					"it permanently gains",
					"{C:mult}+#1#{} Mult and {C:chips}+#2#{} Chips",
				},
				unlock = {
					"Enhance {C:attention}10{}",
					"{C:attention}Enhanced{} cards",
					"{C:inactive}(#1#){}",
				},
			},
			j_hnds_banana_split = {
				name = "Banana Split",
				text = {
					"{X:mult,C:white}X#1#{} Mult",
					"{C:green}#2# in #3#{} chance to",
					"{C:attention}Duplicate{} this card",
					"at end of round",
					"{C:inactive}(Must have room){}",
				},
				unlock = {
					"Have both {C:attention}Cavendish{}",
					"and {C:attention}Gros Michel{} at",
					"the same time",
				},
			},
			j_hnds_head_of_medusa = {
				name = "Head of Medusa",
				text = {
					"Gains {X:mult,C:white}X#2#{} Mult for each",
					"held in hand {C:attention}face{} card ",
					"at end of round and",
					"turns them to {C:attention}Stone{}",
					"{C:inactive}(Currently {X:mult,C:white}X#1#{C:inactive} Mult)",
				},
				unlock = {
					"Have a at least {C:attention}10",
					"{C:attention}Stone Cards{}",
					"in your deck",
				},
			},
			j_hnds_deep_pockets = {
				name = "Deep Pockets",
				text = {
					"{C:attention}+#1#{} consumable slots",
					"Each card in your",
					"{C:attention}consumable area{}",
					"gives {C:mult}+#2#{} Mult",
				},
				unlock = {
					"Create {C:attention}5{} consumable",
					"cards in a single round",
				},
			},
			j_hnds_digital_circus = {
				name = "Digital Circus",
				text = {
					"Sell this card to create",
					"a random {V:1}#1#{} Joker",
					"with a random {C:dark_edition}Edition",
					"{s:0.8}Upgrades every {C:attention,s:0.8}#3#{} {s:0.8}rounds",
					"{C:inactive}(Currently {C:attention}#2#{C:inactive}/#3#)",
				},
				unlock = {
					"Have {C:attention}4{} Jokers",
					"with different",
					"rarities",
				},
			},
			j_hnds_coffee_break = {
				name = "Coffee Break",
				text = {
					"After {C:attention}2 Blinds{}, sell",
					"this card to earn {C:money}$#3#{}",
					"Payout decreases by {C:money}$1{}",
					"for every card played",
					"{C:inactive}(Currently {C:attention}#2#{C:inactive}/#1#)",
				},
				unlock = {
					"Skip both",
					"Ante {C:attention}8 Small{}",
					"and {C:attention}Big Blind{}",
				},
			},
			j_hnds_jackpot = {
				name = "Jackpot",
				text = {
					"{C:green}#1# in #2#{} chance to win {C:money}$#3#{} and",
					"give {C:mult}+#4#{} Mult per hand played",
					"Each scoring {C:attention}7{} doubles this",
					"{C:green}probability{} for played hand",
					"{C:inactive}(ex. {C:green}1 in #5#{C:inactive} -> {C:green}2 in #5#{C:inactive})"
				},
				unlock = {
					"Gain {C:money}$50{} or",
					"more in one",
					"round {C:inactive}(#1#)",
				},
			},
			j_hnds_pot_of_greed = {
				name = "Pot of Greed",
				text = {
					"When you use a",
					"{C:attention}consumable card{},",
					"draw {C:attention}#1#{} cards",
				},
				unlock = {
					"Draw your",
					"entire deck",
					"in one round",
				},
			},
			j_hnds_seismic_activity = {
				name = "Seismic Activity",
				text = {
					"Retrigger all",
					"{C:attention}Stone cards",
				},
				unlock = {
					"Score {C:attention}30 Stone",
					"{C:attention}cards{} in one run",
					"{C:inactive}(#1#)",
				},
			},
			j_hnds_stone_mask = {
				name = "Stone Mask",
				text = {
					"{C:green}#1# in #2#{} chance for first",
					"scored {C:attention}face{} card to steal",
					"{C:attention}Enhancements{}, {C:dark_edition}Editions{} or",
					"{C:attention}Seals{} of adjacent cards",
				},
				unlock = {
					"Reach {X:mult,C:white}X5{} Mult",
					"with {C:attention}Vampire{}",
				},
			},
			j_hnds_jokestone = {
				name = "Jokestone",
				text = {
					"At the start of round,",
					"draw up to {C:attention}#1#{} Enhanced", -- Using a var instead bc Dongtong from all in jest, also the var was already there
					"cards from your deck",
				},
				unlock = {
					"Play a hand with {C:attention}3{}",
					"different Enhancements",
				},
			},
			j_hnds_meme = {
				name = "Meme",
				text = {
					"This Joker gains",
					"{X:mult,C:white}X0.05{} Mult per {C:attention}unique",
					"suit in scored hand",
					"{C:inactive}(Currently {X:mult,C:white}X#1#{C:inactive} Mult)",
				},
				unlock = {
					"Play a {C:attention}poker",
					"{C:attention}hand{} with {C:attention}5{}",
					"{C:red}Debuffed{} cards",
				},
			},
			j_hnds_balloons = {
				name = "Balloons",
				text = {
					"If {C:attention}Blind{} is defeated in",
					"{C:attention}one hand{}, pop a Balloon",
					"to create a random {C:attention}Tag",
					"{C:inactive}({C:attention}#1#{C:inactive}/#2# Balloons left)",
				},
				unlock = {
					"Create a total",
					"of {C:attention}50 Tags{}",
					"{C:inactive}(#1#)",
				},
			},
			j_hnds_jokes_aside = {
				name = "Jokes Aside!",
				text = {
					"Gains {X:mult,C:white}X#2#{} Mult",
					"for every Joker",
					"sold while in {C:attention}Blind",
					"{C:inactive}(Currently {X:mult,C:white}X#1#{C:inactive} Mult)",
				},
				unlock = {
					"Sell a total of",
					"{C:attention}15{} Jokers in",
					"one run {C:inactive}(#1#)",
				},
			},
			j_hnds_ms_fortune = {
				name = "Ms. Fortune",
				text = {
					"Quadruples all",
					"{C:attention}listed{} {C:green,E:1}probabilities{}",
					"Set your money to {C:red}$0",
					"when {C:attention}Blind{} is selected",
					"{C:inactive}(e.x. {}{C:green}1 in 3{} {C:inactive}->{} {C:green}#1# in 3{}{C:inactive}){}",
				},
				unlock = {
					"Fail a {C:green}probability{}",
					"check {C:attention}100{} times",
					"{C:inactive}(#1#)",
				},
			},
			j_hnds_dark_humor = {
				name = "Dark Humor",
				text = {
					"When hand is played, destroy",
					"a random held in hand card",
					"to gain its {C:mult}Mult{} and {C:chips}Chips",
					"{C:inactive}(Currently{} {C:mult}+#2#{} {C:inactive}Mult,{} {C:chips}+#1#{} {C:inactive}Chips)",
				},
				unlock = {
					"Have a deck",
					"with {C:attention}25{} cards",
					"or less",
				},
			},
			j_hnds_krusty = {
				name = "Clown Krusty",
				text = {
					"Sell this card to create {C:attention}#1#",
					"{C:attention}#2#{} {C:inactive}(Max of #3#)",
					"Upgrades for every",
					"{C:money}$#4#{} {C:inactive}[#5#]{} spent",
				}
			},
			j_hnds_energized = {
				name = "Energized",
				text = {
					"If played hand is a single card,",
					"retrigger it {C:attention}#3#{} additional times",
					"{C:green}#1# in #2#{} chance to destroy it"
				},
				unlock = {
					"Destroy a total",
					"of {C:attention}100{} cards",
					"{C:inactive}(#1#)",
				},
			},
			j_hnds_pennywise = {
				name = "Pennywise",
				text = {
					"If {C:attention}Boss Blind{} is defeated",
					"in {C:attention}one hand{}, gain its {C:legendary}Soul{}",
					"as a {C:dark_edition}Negative{} Joker"
				}
			},
			j_hnds_most_wanted = {
				name = "Most Wanted",
				text = {
					"{C:attention}#1#{}",
					"appears {C:attention}#2#X{} more often",
					"It becomes free when",
					"you sell this card"
				},
				unlock = {
					"Have {C:attention}5 Rare{}",
					"Jokers at the",
					"same time",
				},
			},
			j_hnds_clown_devil = {
				name = "The Clown Devil",
				text = {
					"When {C:attention}Blind{} is selected,",
					"eats all held {C:attention}consumables{}",
					"Create a random {C:attention}Tag{} for",
					"every {C:attention}2{} {C:inactive}[#1#]{} cards eaten",
				},
				unlock = {
					"Create a total",
					"of {C:attention}100 Tags{}",
					"{C:inactive}(#1#)",
				},
			},
			j_hnds_jester_in_yellow = {
				name = "Jester in Yellow",
				text = {
					"When {C:attention}Blind{} is selected,",
					"leftmost Joker becomes",
					"{C:dark_edition}Negative{}, but will fade",
					"away in {C:attention}#1#{} rounds"
				},
				unlock = {
					"Make a total",
					"of {C:attention}10{} Jokers",
					"{C:dark_edition}Negative{} {C:inactive}(#1#)",
				},
			},
			j_hnds_wait_what = {
				name = "Wait, what?",
				text = {
					"{X:mult,C:white}X#1#{} Mult",
				},
				unlock = {
					"?????",
				},
			},
			j_hnds_excommunicado = {
				name = "Excommunicado",
				text = {
					"{C:attention}Small{} and {C:attention}Big Blinds{} are",
					"replaced with {C:attention}Boss Blinds{}",
					"Create a random {C:attention}Tag{} when",
					"{C:attention}Boss Blind{} is defeated",
				},
				unlock = {
					"Beat a total of",
					"{C:attention}100 Boss Blinds{}",
					"{C:inactive}(#1#)",
				},
			},
			j_hnds_handsome = {
				name = "Handsome Devil",
				text = {
					"Retrigger all",
					"cards with {C:dark_edition}Editions",
				},
				unlock = {
					"Have {C:attention}4{} Jokers",
					"with different",
					"{C:dark_edition}Editions{}",
				},
			},
			j_hnds_art = {
				name = "Art the Clown",
				text = {
					"Sell this card to add",
					"Art the Clown to the next",
					"{C:attention}Booster Pack{} you open and",
					"create a random {C:attention}Tag"
				}
			},
			j_hnds_public_nuisance = {
				name = "Public Nuisance",
				text = {
					"Keep playing {C:blue}Hands{} after",
					"{C:attention}Blind{} score was met and",
					"gain {C:money}$#1#{} for each played"
				},
				unlock = {
					"Use all {C:blue}hands{}",
					"to defeat a",
					"{C:attention}Boss Blind{}",
				},
			},
			j_hnds_bizzare_joker = {
				name = "Bizarre Joker",
				text = {
					"Gains {X:mult,C:white}XMult{}, {C:mult}+Mult{}, {C:chips}+Chips{}",
					"or {C:attention}sell value{} based on",
					"the suit chosen that",
					"changes every round"
				},
				unlock = {
					"Have all cards",
					"in your deck be",
					"of the {C:attention}same suit{}",
				}
			},
			j_hnds_bizzare_joker_spades = {
				name = "Bizarre Joker",
				text = {
					"{C:chips}+#2#{} Chips per played {C:spades}Spade{} card",
					"{s:0.8}Effect changes every round",
					"{C:inactive}(Currently {X:mult,C:white}X#5#{C:inactive} Mult,",
					"{C:mult}+#3#{C:inactive} Mult, {C:chips}+#1#{C:inactive} Chips)",
				},
			},
			j_hnds_bizzare_joker_clubs = {
				name = "Bizarre Joker",
				text = {
					"{C:mult}+#4#{} Mult per played {C:clubs}Club{} card",
					"{s:0.8}Effect changes every round",
					"{C:inactive}(Currently {X:mult,C:white}X#5#{C:inactive} Mult,",
					"{C:mult}+#3#{C:inactive} Mult, {C:chips}+#1#{C:inactive} Chips)",
				},
			},
			j_hnds_bizzare_joker_diamonds = {
				name = "Bizarre Joker",
				text = {
					"{C:money}+$#7#{} sell value per played {C:diamonds}Diamond{} card",
					"{s:0.8}Effect changes every round",
					"{C:inactive}(Currently {X:mult,C:white}X#5#{C:inactive} Mult,",
					"{C:mult}+#3#{C:inactive} Mult, {C:chips}+#1#{C:inactive} Chips)",
				},
			},
			j_hnds_bizzare_joker_hearts = {
				name = "Bizarre Joker",
				text = {
					"{X:mult,C:white}X#6#{} Mult per played {C:hearts}Heart{} card",
					"{s:0.8}Effect changes every round",
					"{C:inactive}(Currently {X:mult,C:white}X#5#{C:inactive} Mult,",
					"{C:mult}+#3#{C:inactive} Mult, {C:chips}+#1#{C:inactive} Chips)",
				},
			},
			j_hnds_one_punchline_man = {
				name = "One Punchline Man",
				text = {
					"{X:mult,C:white}X#1#{} Mult for the",
					"{C:attention}first hand{} of round",
					"If it didn't defeat the",
					"{C:attention}Blind{}, destroy this card",
				},
				unlock = {
					"Beat {C:attention}3{} Boss Blinds",
					"in a row in {C:attention}one hand{}",
				},
			},
			j_hnds_jigsaw_joker = {
				name = "Jigsaw",
				text = {
					"After playing {C:attention}8{} {C:attention}unique{}",
					"poker hands, sell this",
					"card to upgrade every",
					"{C:attention}poker hand{} by {C:attention}#3#{} levels",
					"{C:inactive}(Currently {C:attention}#1#{C:inactive}/8){}",
				},
				unlock = {
					"Play {C:attention}8 unique{}",
					"poker hands",
					"in one Ante {C:inactive}(#1#)",
				},
			},
			hnds_jigsaw_progress_empty = {
				name = "Played Poker Hands",
				text = {
					"Currently: {C:attention}#1#{}",
					"{C:inactive}(#2#/#3# unique hands){}",
				},
			},
			hnds_jigsaw_progress_1 = {
				name = "Played Poker Hands",
				text = {
					"{C:attention}#1#{}",
					"{C:inactive}(#2#/#3# unique hands){}",
				},
			},
			hnds_jigsaw_progress_2 = {
				name = "Played Poker Hands",
				text = {
					"{C:attention}#1#{}",
					"{C:attention}#2#{}",
					"{C:inactive}(#3#/#4# unique hands){}",
				},
			},
			hnds_jigsaw_progress_3 = {
				name = "Played Poker Hands",
				text = {
					"{C:attention}#1#{}",
					"{C:attention}#2#{}",
					"{C:attention}#3#{}",
					"{C:inactive}(#4#/#5# unique hands){}",
				},
			},
			hnds_jigsaw_progress_4 = {
				name = "Played Poker Hands",
				text = {
					"{C:attention}#1#{}",
					"{C:attention}#2#{}",
					"{C:attention}#3#{}",
					"{C:attention}#4#{}",
					"{C:inactive}(#5#/#6# unique hands){}",
				},
			},
			hnds_jigsaw_progress_5 = {
				name = "Played Poker Hands",
				text = {
					"{C:attention}#1#{}",
					"{C:attention}#2#{}",
					"{C:attention}#3#{}",
					"{C:attention}#4#{}",
					"{C:attention}#5#{}",
					"{C:inactive}(#6#/#7# unique hands){}",
				},
			},
			hnds_jigsaw_progress_6 = {
				name = "Played Poker Hands",
				text = {
					"{C:attention}#1#{}",
					"{C:attention}#2#{}",
					"{C:attention}#3#{}",
					"{C:attention}#4#{}",
					"{C:attention}#5#{}",
					"{C:attention}#6#{}",
					"{C:inactive}(#7#/#8# unique hands){}",
				},
			},
			hnds_jigsaw_progress_7 = {
				name = "Played Poker Hands",
				text = {
					"{C:attention}#1#{}",
					"{C:attention}#2#{}",
					"{C:attention}#3#{}",
					"{C:attention}#4#{}",
					"{C:attention}#5#{}",
					"{C:attention}#6#{}",
					"{C:attention}#7#{}",
					"{C:inactive}(#8#/#9# unique hands){}",
				},
			},
			hnds_jigsaw_progress_8 = {
				name = "Played Poker Hands",
				text = {
					"{C:attention}#1#{}",
					"{C:attention}#2#{}",
					"{C:attention}#3#{}",
					"{C:attention}#4#{}",
					"{C:attention}#5#{}",
					"{C:attention}#6#{}",
					"{C:attention}#7#{}",
					"{C:attention}#8#{}",
					"{C:inactive}(#9#/#10# unique hands){}",
				},
			},
			j_hnds_dynamic_duos = {
				name = "Dynamic Duos",
				text = {
					"If played hand is a",
					"{C:attention}Two Pair{} of {C:attention}odd{} and {C:attention}even{}",
					"rank cards, retrigger them",
					"{C:inactive}(ex: 6, 6, 9, 9)"
				},
				unlock = {
					"Play a {C:attention}Two Pair{}",
					"of {C:attention}even{} and {C:attention}odd{}",
					"{C:attention}rank{} cards",
				},
			},
			j_hnds_imposter = {
				name = "Imposter",
				text = {
					"Scored {C:attention}face cards{}",
					"count as any rank",
					"for Joker effects",
				},
				unlock = {
					"Win {C:attention}3{} rounds",
					"in a row with a",
					"Joker that didn't",
					"trigger once",
				},
			},
			j_hnds_contagion = {
				name = "Contagion",
				text = {
					"{C:attention}Consumables{} allow to",
					"select {C:attention}1{} extra card",
					"{C:inactive}(ex: Enhances {C:attention}2{} {C:inactive}selected",
					"{C:inactive}cards -> {C:attention}3{} {C:inactive}selected cards)",
				},
				unlock = {
					"Have a deck full",
					"of {C:attention}Enhanced{} cards",
				},
			},
			j_hnds_last_laugh = {
				name = "Last Laugh",
				text = {
					"Sell this card to draw {C:attention}#1#{}",
					"#3# from your deck, then",
					"destroy all cards in hand",
					"{s:0.8}Upgrades at end of round",
				},
				unlock = {
					"Destroy a total",
					"of {C:attention}150{} cards",
					"{C:inactive}(#1#){}",
				},
			},
			j_hnds_fregoli = {
				name = "Fregoli",
				text = {
					"Copies the ability of the",
					"last {C:attention}Joker{} you bought",
				},
				unlock = {
					"Buy the same",
					"Joker {C:attention}3{} times",
					"in one run",
				},
			},
			j_hnds_walking_joke = {
				name = "Walking Joke",
				text = {
					"Retrigger adjacent",
					"{C:blue}Common{} Jokers",
				},
				unlock = {
					"Own only {C:blue}Common{}",
					"Jokers during a run",
				}
			},
			j_hnds_demented = {
				name = "Demented Joker",
				text = {
					"When {C:attention}first hand{} of",
					"round is played, randomize",
					"{C:attention}Ranks{} and {C:attention}Suits{} of all",
					"cards held in hand",
				},
				unlock = {
					"Change {C:attention}Ranks{} or",
					"{C:attention}Suits{} of {C:attention}100{} cards",
					"{C:inactive}(#1#){}",
				},
			},
			j_hnds_angry_mob = {
				name = "Angry Mob",
				text = {
					"{X:mult,C:white}X#1#{} Mult",
					"Jokers don't",
					"appear in shop"
				},
				unlock = {
					"Don't buy Jokers",
					"{C:attention}10{} rounds in a row",
					"{C:inactive}(#1#)",
				},
			},
			j_hnds_sarmenti = {
				name = "Sarmenti",
				text = {
					"Randomize {C:dark_edition}Editions{} of",
					"Jokers to the right if",
					"played hand contains",
					"a {C:attention}Four of a Kind{}",
				}
			},
			j_hnds_arthur = {
				name = "Arthur",
				text = {
					"Destroy scored {V:1}#3#{}",
					"cards and gain {C:attention}#2#{} {C:inactive}[#1#]{} free",
					"{C:green}Reroll{} for each destroyed",
					"{s:0.8}Suit changes every hand"
				},
			},
			j_hnds_creepy = {
				name = "Creepy Joker",
				text = {
					"{X:mult,C:white}X#1#{} Mult",
					"{C:green}#2# in #3#{} chance adjacent",
					"Jokers become a copy of",
					"this at end of round",
				},
				unlock = {
					"Have {C:attention}3{} copies of",
					"the same Joker",
				},
			},
		},
		Back = {
			b_hnds_premiumdeck = {
				name = "Premium Deck",
				text = {
					"Start run with",
					"{C:green,T:v_hnds_premium}Premium{} and {C:red,T:v_hnds_top_shelf}Top Shelf{}",
					"Jokers cost extra {C:money}${}",
					"equal to your {C:attention}Ante{}",
				},
				unlock = {
					"Discover at least",
					"{C:attention}150{} items from",
					"your collection",
				},
			},
			b_hnds_crystal = {
				name = "Crystal Deck",
				text = {
					"On Ante {C:attention}4{}, face",
					"the {C:attention}Showdown Blind{}",
					"Defeat it to open an",
					"{C:legendary,T:p_hnds_spectral_ultra}Ultra Spectral Pack{}", --might need to remove the E:1, hover tooltip doesnt seem to work with that
				},
				unlock = {
					"Win a run with any",
					"deck on at least",
					"{C:attention}Gold Stake{} difficulty",
				},
			},
			b_hnds_conjuring = {
				name = "Conjuring Deck",
				text = {
					"All {C:attention}Booster Packs{}",
					"in shop are replaced",
					"by {C:attention,T:p_hnds_magic_1}Magic Packs{} which",
					"contain {C:dark_edition,E:1}random cards"
				},
				unlock = {
					"Discover every",
					"{C:attention}Booster Pack{}",
				},
			},
			b_hnds_circus = {
				name = "Circus Deck",
				text = {
					"Has an ability",
					"of a random {C:attention}Joker",
					"After defeating each",
					"{C:attention}Blind{}, ability changes",
				},
				unlock = {
					"Discover every",
					"{C:attention}Joker card{}",
				},
			},
			b_hnds_ol_reliable = {
				name = "Ol' Reliable Deck",
				text = {
					"Triples all {C:attention}listed",
					"{C:green}probabilities{} during",
					"{C:attention}shop{} and {C:attention}Boss Blinds",
					"{C:inactive}(e.x. {C:green}1 in 3{C:inactive} -> {C:green}3 in 3{C:inactive}){}"
				},
				unlock = {
					"Successfully trigger",
					"{C:attention}Lucky cards'{} {C:green}probability{}",
					"{C:green}effects{} {C:attention}77{} times {C:inactive}(#1#)",
				},
			},
			b_hnds_cursed = {
				name = "Cursed Deck",
				text = {
					"Defeat the {C:attention}first",
					"{C:attention}Boss Blind{} to open",
					"an {C:red}unskippable{}",
					"{C:red,T:p_hnds_cursed_pack}Cursed Pack{}",
				},
				unlock = {
					"Win a run with any",
					"deck on at least",
					"{C:dark_edition}Platinum Stake{} difficulty",
				},
			},
		},
		Sleeve = {
			sleeve_hnds_premium_sleeve = {
				name = "Premium Sleeve",
				text = {
					"Start run with",
					"{C:green,T:v_hnds_premium}Premium{} and {C:red,T:v_hnds_top_shelf}Top Shelf{}",
					"Jokers cost extra {C:money}${}",
					"equal to your {C:attention}Ante{}",
				}
			},
			sleeve_hnds_premium_sleeve_alt = {
				name = "Premium Sleeve",
				text = {
					"{C:blue}Common{} Jokers appear",
					"{C:blue}X#3#{} less often",
				}
			},
			sleeve_hnds_circus_sleeve = {
				name = "Circus Sleeve",
				text = {
					"Has an ability",
					"of a random {C:attention}Joker",
					"After defeating each",
					"{C:attention}Blind{}, ability changes",
					"{C:inactive}(Currently: {V:1}#1#{C:inactive})",
				}
			},
			sleeve_hnds_circus_sleeve_alt = {
				name = "Circus Sleeve",
				text = {
					"Creates a {C:dark_edition}Copy{} of the",
					"first {C:attention}Joker{} chosen after defeating",
					"the first {C:attention}Boss Blind{}"
				}
			},
			sleeve_hnds_cursed_sleeve = {
				name = "Cursed Sleeve",
				text = {
					"Defeat the {C:attention}first",
					"{C:attention}Boss Blind{} to open",
					"an {C:red}unskippable{}",
					"{C:red,T:p_hnds_cursed_pack}Cursed Pack{}"
				}
			},
			sleeve_hnds_cursed_sleeve_alt = {
				name = "Cursed Sleeve",
				text = {
					"The first {C:red,T:p_hnds_cursed_pack}Cursed Pack{}",
					"opened only offers {C:red}Rare Jokers{}"
				}
			},
			sleeve_hnds_crystal_sleeve = {
				name = "Crystal Sleeve",
				text = {
					"On Ante {C:attention}4{}, face",
					"the {C:attention}Showdown Blind{}",
					"Defeat it to open an",
					"{C:legendary,T:p_hnds_spectral_ultra}Ultra Spectral Pack{}"
				}
			},
			sleeve_hnds_crystal_sleeve_alt = {
				name = "Crystal Sleeve",
				text = {
					"Also Face a Showdown Blind",
					"in Antes {C:attention}2{} and {C:attention}6{}",
					"Defeat them to open an",
					"{C:legendary,T:p_hnds_spectral_ultra}Ultra Spectral Pack{}",
				}
			},
			sleeve_hnds_conjuring_sleeve = {
				name = "Conjuring Sleeve",
				text = {
					"All {C:attention}Booster Packs{}",
					"in shop are replaced",
					"by {C:attention,T:p_hnds_magic_1}Magic Packs{} which",
					"contain {C:dark_edition,E:1}random cards"
				}
			},
			sleeve_hnds_conjuring_sleeve_alt = {
				name = "Conjuring Sleeve",
				text = {
					"Start with {C:attention,T:v_hnds_stuffed}Stuffed{}",
					"and {C:attention,T:v_hnds_wholesale}Wholesale{}"
				}
			},
			sleeve_hnds_ol_sleeve = {
				name = "Ol' Sleeve",
				text = {
					"Triples all {C:attention}listed",
					"{C:green}probabilities{} during",
					"{C:attention}shop{} and {C:attention}Boss Blinds",
					"{C:inactive}(e.x. {C:green}1 in 3{C:inactive} -> {C:green}3 in 3{C:inactive}){}"
				}
			},
			sleeve_hnds_ol_sleeve_alt = {
				name = "Ol' Sleeve",
				text = {
					"Doubles all {C:attention}listed{} {C:green}probabilities{},",
					"and Cuadruples all {C:attention}listed{} {C:green}probabilities{}",
					"during boss blinds and the shop",
					"{C:inactive}(replaces deck effect){}",
					"{C:inactive}(e.x. {C:green}1 in 3{C:inactive} -> {C:green}4 in 3{C:inactive}){}"
				}
			},
		},
		Tarot = {
			c_hnds_contagion_death = {
				name = "Death",
				text = {
					"Select {C:attention}3{} cards,",
					"convert them all",
					"into copies of the",
					"{C:attention}rightmost card{}",
				},
			},
		},
		Spectral = {

			c_black_hole = {
				name = "Black Hole",
				text = {
					"Double the",
					"level of all",
					"{C:legendary,E:1}poker hands{}",
				},
			},
            c_hnds_contagion_talisman = {
                name = "Talisman",
                text = {
                    "Add a {C:attention}Gold Seal{}",
                    "to {C:attention}#1#{} selected",
                    "cards in your hand",
                },
            },
            c_hnds_contagion_deja_vu = {
                name = "Deja Vu",
                text = {
                    "Add a {C:red}Red Seal{}",
                    "to {C:attention}#1#{} selected",
                    "cards in your hand",
                },
            },
            c_hnds_contagion_trance = {
                name = "Trance",
                text = {
                    "Add a {C:blue}Blue Seal{}",
                    "to {C:attention}#1#{} selected",
                    "cards in your hand",
                },
            },
            c_hnds_contagion_medium = {
                name = "Medium",
                text = {
                    "Add a {C:purple}Purple Seal{}",
                    "to {C:attention}#1#{} selected",
                    "cards in your hand",
                },
            },
            c_hnds_contagion_aura = {
                name = "Aura",
                text = {
                    "Add {C:dark_edition}Foil{}, {C:dark_edition}Holographic{},",
                    "or {C:dark_edition}Polychrome{} effect to",
                    "{C:attention}#1#{} selected cards in hand",
                },
            },
            c_hnds_contagion_cryptid = {
                name = "Cryptid",
                text = {
                    "Create {C:attention}#1#{} copies of",
                    "each of {C:attention}#2#{} selected",
                    "cards in your hand",
                },
            },
            c_hnds_exchange_contagion = {
                name = "Exchange",
                text = {
                    "Add {C:dark_edition}Negative{} effect to",
                    "{C:attention}#1#{} selected cards in hand,",
                    "{C:blue}-1{} hand each round",
                },
            },
			c_hnds_abyss = {
				name = "Abyss",
				text = {
					"Add a {C:dark_edition}Black Seal{}",
					"to {C:attention}#1#{} selected",
					"card in your hand",
				},
			},
			c_hnds_cycle = {
				name = "Cycle",
				text = {
					"Replace your {C:attention}Jokers{}",
					"with new ones of",
					"the {C:attention}same rarity{}",
				},
			},
			c_hnds_petrify = {
				name = "Petrify",
				text = {
					"Enhances all {C:attention}face{} cards",
					"in hand to {C:attention}Stone Cards{},",
					"gain {C:money}$#1#{} for each",
					"petrified card"
				},
			},
			c_hnds_exchange = {
				name = "Exchange",
				text = {
					"Add {C:dark_edition}Negative{} effect to",
					"{C:attention}1{} selected card in hand,",
					"{C:blue}-1{} hand each round",
				},
			},
			c_hnds_possess = {
				name = "Possess",
				text = {
					"Add a {C:spectral}Spectral Seal{}",
					"to {C:attention}#1#{} selected",
					"card in your hand",
				},
			},
			c_hnds_dream = {
				name = "Dream",
				text = {
					"Creates",
					"{C:attention}10{} random",
					"{E:1,C:legendary}Joker Tags{}",
				},
			},
			c_hnds_collision = {
				name = "Collision",
				text = {
					"Enhances {C:attention}#1#{}",
					"selected cards to",
					"{C:dark_edition}#2#s",
				},
			},
			c_hnds_gateway = {
				name = "Gateway",
				text = {
					"Enhances {C:attention}#1#{}",
					"selected cards to",
					"{C:dark_edition}#2#s",
				},
			},
			c_hnds_spectrum = {
				name = "Spectrum",
				text = {
					"Gives each card in",
					"your hand a random",
					"{E:1,C:legendary}Enhancement{} and {E:1,C:legendary}Seal"
				}
			}
		},
		Edition = {
			e_hnds_vintage = {
				name = "Vintage",
				text = {
					"{C:money}+$2{} {C:attention}sell value{}",
					"every round",
				},
			},
			e_hnds_vintage_playing_card = {
				name = "Vintage",
				text = {
					"Earn {C:money}$3{} when this",
					"card is played",
					"and scores",
				},
			},
			e_negative_playing_card = {
				name = "Negative",
				text = {
					"{C:attention}+1{} hand size",
				},
			},
		},

		Other = {
            hnds_jigsaw_progress_empty = {
                name = "Played Poker Hands",
                text = {
                    "Currently: {C:attention}#1#{}",
                    "{C:inactive}(#2#/#3# unique hands){}",
                },
            },
            hnds_jigsaw_progress_1 = {
                name = "Played Poker Hands",
                text = {
                    "{C:attention}#1#{}",
                    "{C:inactive}(#2#/#3# unique hands){}",
                },
            },
            hnds_jigsaw_progress_2 = {
                name = "Played Poker Hands",
                text = {
                    "{C:attention}#1#{}",
                    "{C:attention}#2#{}",
                    "{C:inactive}(#3#/#4# unique hands){}",
                },
            },
            hnds_jigsaw_progress_3 = {
                name = "Played Poker Hands",
                text = {
                    "{C:attention}#1#{}",
                    "{C:attention}#2#{}",
                    "{C:attention}#3#{}",
                    "{C:inactive}(#4#/#5# unique hands){}",
                },
            },
            hnds_jigsaw_progress_4 = {
                name = "Played Poker Hands",
                text = {
                    "{C:attention}#1#{}",
                    "{C:attention}#2#{}",
                    "{C:attention}#3#{}",
                    "{C:attention}#4#{}",
                    "{C:inactive}(#5#/#6# unique hands){}",
                },
            },
            hnds_jigsaw_progress_5 = {
                name = "Played Poker Hands",
                text = {
                    "{C:attention}#1#{}",
                    "{C:attention}#2#{}",
                    "{C:attention}#3#{}",
                    "{C:attention}#4#{}",
                    "{C:attention}#5#{}",
                    "{C:inactive}(#6#/#7# unique hands){}",
                },
            },
            hnds_jigsaw_progress_6 = {
                name = "Played Poker Hands",
                text = {
                    "{C:attention}#1#{}",
                    "{C:attention}#2#{}",
                    "{C:attention}#3#{}",
                    "{C:attention}#4#{}",
                    "{C:attention}#5#{}",
                    "{C:attention}#6#{}",
                    "{C:inactive}(#7#/#8# unique hands){}",
                },
            },
            hnds_jigsaw_progress_7 = {
                name = "Played Poker Hands",
                text = {
                    "{C:attention}#1#{}",
                    "{C:attention}#2#{}",
                    "{C:attention}#3#{}",
                    "{C:attention}#4#{}",
                    "{C:attention}#5#{}",
                    "{C:attention}#6#{}",
                    "{C:attention}#7#{}",
                    "{C:inactive}(#8#/#9# unique hands){}",
                },
            },
            hnds_jigsaw_progress_8 = {
                name = "Played Poker Hands",
                text = {
                    "{C:attention}#1#{}",
                    "{C:attention}#2#{}",
                    "{C:attention}#3#{}",
                    "{C:attention}#4#{}",
                    "{C:attention}#5#{}",
                    "{C:attention}#6#{}",
                    "{C:attention}#7#{}",
                    "{C:attention}#8#{}",
                    "{C:inactive}(#9#/#10# unique hands){}",
                },
            },
			hnds_exchange_draw = {
				name = "Bound",
				text = {
					"Always drawn at the",
					"start of each round",
				},
			},
			hnds_bound = {
				name = "Bound",
				text = {
					"Always drawn at the",
					"start of each round",
				},
			},
			hnds_negative_playing_card = {
				name = "Negative",
				text = {
					"{C:attention}+1{} hand size",
				},
			},
			hnds_jester_temp_negative = {
				name = "Chosen by Carcosa",
				text = {
					"This Joker fades in",
					"{C:attention}#1#{} rounds",
				}
			},
			hnds_black_seal = {
				name = "Black Seal",
				text = {
					"Counts in {C:attention}scoring{}",
					"while this card",
					"stays in hand",
				},
			},
			hnds_spectralseal_seal = {
				name = "Spectral Seal",
				text = {
					"Creates a {C:spectral}Spectral{} card",
					"every {C:attention}#1#{} {C:inactive}[#2#]{} {C:attention}unique{} poker",
					"hands this card scored in",
					"{C:inactive}(Must have room){}"
				}
			},
			hnds_spectralseal_progress_empty = {
				name = "Scored Poker Hands",
				text = {
					"Currently: {C:attention}#1#{}",
					"{C:inactive}(#2#/#3# unique hands){}",
				},
			},
			hnds_spectralseal_progress_1 = {
				name = "Scored Poker Hands",
				text = {
					"{C:attention}#1#{}",
					"{C:inactive}(#2#/#3# unique hands){}",
				},
			},
			hnds_spectralseal_progress_2 = {
				name = "Scored Poker Hands",
				text = {
					"{C:attention}#1#{}",
					"{C:attention}#2#{}",
					"{C:inactive}(#3#/#4# unique hands){}",
				},
			},
			hnds_spectralseal_progress_3 = {
				name = "Scored Poker Hands",
				text = {
					"{C:attention}#1#{}",
					"{C:attention}#2#{}",
					"{C:attention}#3#{}",
					"{C:inactive}(#4#/#5# unique hands){}",
				},
			},
			hnds_spectralseal_progress_4 = {
				name = "Scored Poker Hands",
				text = {
					"{C:attention}#1#{}",
					"{C:attention}#2#{}",
					"{C:attention}#3#{}",
					"{C:attention}#4#{}",
					"{C:inactive}(#5#/#6# unique hands){}",
				},
			},
			p_hnds_spectral_ultra = {
				name = "Ultra Spectral Pack",
				text = {
					"Choose {C:attention}#2#{} of up to",
					"{C:attention}#1# {C:spectral}Spectral{} cards to",
					"be used immediately",
					"Contains at least one",
					"{E:1,C:legendary}Ultra Rare consumable"
				}
			},
			hnds_joker_tag_example = {
				name = "Joker Tags",
				text = {
					"{C:dark_edition}Foil{}, {C:dark_edition}Holographic{},",
					"{C:dark_edition}Polychrome{}, {C:dark_edition}Negative{},",
					"{C:dark_edition}Vintage{}, {C:green}Uncommon{}, {C:red}Rare{},",
					"{C:attention}Buffoon, Cursed{} {C:attention}Tag{} etc.",
				}
			},
			hnds_soul = {
				name = "Soul",
				text = {
					"No {C:attention}sell value",
					"Remove this when",
				    "you lose {C:legendary,E:1}Pennywise",
			 }
			},
			p_hnds_magic = {
				name = "Magic Pack",
				text = {
					"Choose {C:attention}#2#{} of up to",
					"{C:attention}#1# {C:dark_edition,E:1}random{} cards to",
					"be used immediately or",
					"to add to your deck",
				}
			},
			p_hnds_magic_1 = {
				name = "Magic Pack",
				text = {
					"Choose {C:attention}#2#{} of up to",
					"{C:attention}#1# {C:dark_edition,E:1}random{} cards to",
					"be used immediately or",
					"to add to your deck",
				}
			},
			dna_tag_tooltip_singular = {
				name = "DNA Tag",
				text = {
					"When you buy this Joker,",
					"create a copy of it",
					"{C:inactive}(Must have room){}",
				}
			},
			dna_tag_tooltip_plural = {
				name = "DNA Tag",
				text = {
					"When you buy this Joker,",
					"create {C:attention}#1#{} copies of it",
					"{C:inactive}(Must have room){}",
				}
			},
			hnds_platinum_sticker = {
				name = "Platinum Sticker",
				text = {
					"Used this Joker",
					"to win on {C:attention}Platinum",
					"{C:attention}Stake{} difficulty",
				}
			},
			hnds_blood_stake_sticker = {
				name = "Blood Sticker",
				text = {
					"Used this Joker",
					"to win on {C:attention}Blood",
					"{C:attention}Stake{} difficulty",
				}
			},
			p_hnds_cursed_pack = {
				name = "Cursed Pack",
				text = {
					"Choose {C:attention}#1#{} of up to {C:attention}#2#{}",
					"{C:red}Cursed{} Joker cards"
				}
			},
			-- Cursed Sticker
			hnds_cursed_offer_title = {
				text = {
					"{C:green}Offer{}:",
				},
			},
			hnds_cursed_price_title = {
				text = {
					"{C:red}Price{}:",
				},
			},
			hnds_cursed = { -- Display in the Collection
				name = "Cursed",
				text = {
					"Extra {C:green}power{} but",
					"at what {C:red}cost{}?",
				}
			},
			-- Cursed Offers Descriptions
			offer_copy_random_tarot = {
				text = {
					"Creates a {C:tarot}Tarot{}",
					"card each round",
				},
			},
			offer_copy_random_planet = {
				text = {
					"Creates {C:attention}2{} {C:planet}Planet{}",
					"cards each round",
				},
			},
			offer_random_enhancement = {
				text = {
					"Randomly enhance",
					"{C:attention}8{} cards in deck",
				},
			},
			offer_self_negative = {
				text = {
					"Add {C:dark_edition}Negative{}",
					"to this Joker",
				},
			},
			offer_retrigger = {
				text = {
					"Retriggers an",
					"additional time",
				},
			},
			offer_spectral_gen = {
				text = {
					"Creates a {C:spectral}Spectral{}",
					"card each Ante",
				},
			},
			offer_free_rerolls = {
				text = {
					"Gives {C:attention}2{} free",
					"{C:green}Rerolls{} per shop",
				},
			},
			offer_joker_copy = {
				text = {
					"Create a copy",
					"of this {C:attention}Joker{}",
				},
			},
			-- Cursed Prices Descriptions
			price_destroy_jokers = {
				text = {
					"Destroy your",
					"other Jokers"
				},
			},
			price_destroy_cards = {
				text = {
					"Destroy {C:attention}8{} random",
					"cards in deck",
				},
			},
			price_bankrupt = {
				text = {
					"Set money to {C:red}$0{}",
				},
			},
			price_inflation = {
				text = {
					"{C:green}Rerolls{} cost {C:red}$2{}",
					"more permanently",
				},
			},
			price_lose_hand = {
				text = {
					"Lose {C:red}1{} hand",
					"permanently",
				},
			},
			price_lose_discard = {
				text = {
					"Lose {C:red}1{} discard",
					"permanently",
				},
			},
			price_lose_hand_size = {
				text = {
					"{C:red}-1{} hand size",
					"permanently",
				},
			},
			price_ante_scaling = {
				text = {
					"{C:red}+50%{} base Blind",
					"size permanently",
				},
			},
		},
		Voucher = {
			v_magic_trick = {
				name = "Magic Trick",
				text = {
					"{C:attention}Playing cards{} can be",
					"purchased from the",
					"shop and may have",
					"an {C:attention}Enhancement{}",
				},
			},
			v_illusion = {
				name = "Illusion",
				text = {
					"{C:attention}Playing cards{} in",
					"shop may have an",
					"{C:dark_edition}Edition{} and/or {C:attention}Seal{}",
				},
			},
			v_planet_merchant = {
				name = "Planet Merchant",
				text = {
					"When you buy a",
					"{C:planet}Planet{} card, create",
					"an extra copy of it",
					"{C:inactive}(Must have room)",
				},
			},
			v_planet_tycoon = {
				name = "Planet Tycoon",
				text = {
					"When you buy a",
					"{C:planet}Planet{} card, create",
					"a {C:dark_edition}Negative{} copy of it",
				},
			},
			v_hnds_tag_hunter = {
				name = "Tag Hunter",
				text = {
					"Create a random {C:attention}Tag{}",
					"when {C:attention}Boss Blind{}",
					"is defeated",
				},
			},
			v_hnds_hashtag_skip = {
				name = "#2#skip",
				text = {
					"{C:attention}-1{} Ante for",
					"every {C:attention}#1#{} skips",
				},
				unlock = {
					"Skip a total of",
					"{C:attention}50 Blinds{} {C:inactive}(#1#)",
				},
			},
			v_hnds_premium = {
				name = "Premium",
				text = {
					"{C:uncommon}Uncommon Jokers",
					"appear {C:attention}#1#X{} as often",
				},
			},
			v_hnds_top_shelf = {
				name = "Top Shelf",
				text = {
					"{C:rare}Rare Jokers{}",
					"appear {C:attention}#1#X{} as often",
				},
				unlock = {
					"Buy a total of {C:attention}50{}",
					"{C:rare}Rare Joker{} cards",
					"from the shop {C:inactive}(#1#)",
				},
			},
			v_hnds_stuffed = {
				name = "Stuffed",
				text = {
					"{C:attention}+1{} extra card in",
					"all {C:attention}Booster Packs{}",
				},
			},
			v_hnds_wholesale = {
				name = "Wholesale",
				text = {
					"{C:attention}+1{} Booster Pack slot",
					"available in shop",
				},
				unlock = {
					"Buy at least {C:attention}40{}",
					"{C:attention}Booster Packs{}",
					"in one run {C:inactive}(#1#)",
				},
			},
			v_hnds_soaked = {
				name = "Soaked and Wet",
				text = {
					"{C:attention}Leftmost{} card",
					"held in hand",
					"counts in scoring"
				}
			},
			v_hnds_beyond = {
				name = "Go Beyond",
				text = {
					"{C:attention}Rightmost{} card",
					"held in hand",
					"counts in scoring"
				},
				unlock = {
					"Trigger a total of {C:attention}100{}",
					"{C:attention}held in hand{} effects {C:inactive}(#1#)",
				},
			}
		},
		Planet = {
			c_hnds_makemake = {
				name = "Makemake",
				text = {
					"{S:0.8}({S:0.8,V:1}lvl.#1#{S:0.8}){} Level up",
					"{C:attention}#2#",
					"{C:chips}+#3#{} chips, {C:chips}+#4#{} extra",
					"for each {C:attention}Stone Card{}",
					"scored this Ante {C:inactive}[#5#]",
				},
			},
		},
		Enhanced = {

			m_wild = {
				name = "Wild Card",
				text = {
					"Can't be flipped",
					"or debuffed",
					"Can be used",
					"as any suit",
				},
			},
			m_hnds_aberrant = {
				name = "Aberrant Card",
				text = {
					"Can be fused with {C:attention}2{}",
					"other Enhancements",
					"{C:red}3rd destroys card{}",
					"{C:inactive}#1#{}",
				},
			},
			m_hnds_aberrant_collection = {
				name = "Aberrant Card",
				text = {
					"Can be fused with {C:attention}2{}",
					"other Enhancements",
					"{C:red}3rd destroys card{}",
				},
			},
			m_hnds_obsidian = {
				name = "Obsidian Card",
				text = {
					"Permanently becomes",
					"{C:dark_edition}Bound{} if scored in {C:attention}#1#{}",
					"final hands of round",
					"{C:inactive}(Currently {C:attention}#2#{}{C:inactive}/2)",
				},
			},
			m_hnds_obsidian_complete = {
				name = "Obsidian Card",
				text = {
					"Permanently {C:dark_edition}Bound{}",
				},
			},
		},
		Tag = {

			tag_juggle = {
				name = "Juggle Tag",
				text = {
					"{C:attention}+#1#{} hand size,",
					"reduces by {C:red}1{}",
					"every round",
				},
			},
			tag_investment = {
				name = "Investment Tag",
				text = {
					"After defeating",
					"the {C:attention}Boss Blind{} of",
					"the Ante, gain {C:money}$#1#{}",
				},
			},
			tag_hnds_vintage_tag = {
				name = "Vintage Tag",
				text = {
					"Next base edition shop",
					"Joker is free and",
					"becomes {C:dark_edition}Vintage"
				}
			},
			tag_hnds_mystery_tag = {
				name = "Mystery Tag",
				text = {
					"Create {C:attention}2{} random {C:attention}Tags",
				}
			},
			tag_hnds_magic_tag = {
				name = "Magic Tag",
				text = {
					"Gives a free",
					"{C:dark_edition,E:1}Magic Pack",
				},
			},
			tag_hnds_dna_tag = {
				name = "DNA Tag",
				text = {
					"Next shop Joker",
					"is free and creates",
					"a {C:attention}copy{} when bought",
					"{C:inactive}(Must have room){}"
				},
			},
			tag_hnds_cursed_tag = {
				name = "Cursed Tag",
				text = {
					"Gives a free",
					"{C:red,T:p_hnds_cursed_pack}Cursed Pack{}",
				},
			},
			tag_hnds_extinction_tag = {
				name = "Extinction Tag",
				text = {
					"Replace your {C:attention}Jokers{}",
					"with new ones of",
					"the {C:attention}same rarity{}",
				},
			},
		},
		Stake = {
			stake_hnds_platinum = {
				name = "Platinum Stake",
				text = {
					"Defeat Ante {C:attention}10 Boss{} to win",
					"{s:0.8}Applies all previous Stakes",
				}
			},
			stake_hnds_blood_stake = {
				name = "Blood Stake",
				text = {
					"Shop can have {C:red}Cursed{} Jokers",
					"{C:inactive,s:0.8}(Extra {C:green,s:0.8}power{} {C:inactive,s:0.8}for a {C:red,s:0.8}price{}{C:inactive,s:0.8})",
					"{s:0.8}Applies all previous Stakes",
				},
				unlock = {
					'Win with this',
					'deck on Platinum Stake',
				}
			},
			stake_hnds_nightmare = {
				name = "Nightmare Stake",
				text = {
					"Leaving {C:red}Cursed{} Joker in",
					"shop upgrades next {C:attention}Blind",
					"{s:0.8}Applies all previous Stakes",
				},
				unlock = {
					'Win with this',
					'deck on Blood Stake',
				}
			}
		},
		Blind = {
			bl_hnds_blind_devil = {
				name = "The Devil",
				text = {
					"Summons #1#,",
					"#2#, #3#",
				},
			},
			bl_hnds_forbidden_fruit = {
				name = "Forbidden Fruit",
				text = {
					"Debuff 6 cards in deck",
					"per Tag used this run",
				},
			},
			bl_hnds_perilous_pact = {
				name = "Perilous Pact",
				text = {
					"Caps each hand at",
					"50% of required score",
				},
			},
			bl_hnds_perilous_pact_active = {
				name = "Perilous Pact",
				text = {
					"Caps each hand at",
					"{C:attention}#1#%{} of required score",
				},
			},
			bl_hnds_sinful_soul = {
				name = "Sinful Soul",
				text = {
					"+20% Blind size per $1",
					"of Jokers' sell value",
				},
			},
			bl_hnds_wasted_wish = {
				name = "Wasted Wish",
				text = {
					"Vouchers are",
					"disabled this Ante",
				},
			},
		},
	},
	misc = {
		dictionary = {
			k_hnds_krusty_voucher_tag = "Voucher Tag",
			k_hnds_krusty_voucher_tags = "Voucher Tags",
			hnds_upgrade_blind = "Upgrade Blind",
			hnds_blind_raiser_tooltip_title = "Score if upgraded",
			hnds_blind_raiser_tooltip_current_blind = "Current Blind: #1#",
			hnds_blind_raiser_tooltip_boss_blind = "Boss Blind: #1#",
			k_hnds_petrified = "Petrified!",
			k_hnds_goldfish = "Goldfish!",
			k_hnds_jester_negative = "Joker Negatived!",
			k_hnds_jester_fade = "Faded...",
			k_hnds_clown_eat = "Consumed!",
			k_hnds_ritual_complete = "Ritual complete",
			k_hnds_cursed_offers = "Cursed Offers",
			k_hnds_cursed_prices = "Cursed Prices",
			k_hnds_boom_timer = "!!!",
			k_hnds_boom = "BOOM!",
			k_hnds_green = "Draw!",
			k_hnds_jackpot = "Jackpot!",
			k_hnds_probinc = "Increased!",
			k_hnds_coffee = "Cold!",
			k_hnds_seismic = "Tremor!",
			k_hnds_awaken = "Awaken!",
			k_hnds_IPLAYPOTOFGREED = "I PLAY!...",
			k_hnds_extint = "Extinct!",
			k_hnds_balloons = "All gone!",
			k_hnds_banana_split = "Split!",
			k_hnds_color_of_madness = "Madness!",
			k_hnds_occultist = "Study!",
			k_hnds_splashed = "Splashed!",
			hnds_plus_q = "+1 ???", --this is for the cryptid digital hallucinations creation message with magic packs
			k_hnds_plus_tag = "+Tag",
			k_hnds_magic_pack = "Magic Pack",
			k_hnds_cursed_pack = "Cursed Pack",
			hnds_cursed_pack = "Cursed Pack",
			k_hnds_sarmenti_active = "active",
			k_hnds_sarmenti_inactive = "inactive",
			k_hnds_sarmenti_enhanced = "Enhanced!",
			k_hnds_free_reroll = "+1 Free Reroll",
			k_hnds_arthurs_suit = " ",
			k_hnds_enhancements = "Enhancements",
			k_hnds_creepy_1 = "It was the Plant...",
			k_hnds_creepy_2 = "...it dragged us",
			k_hnds_creepy_3 = "into the abyss...",
			k_hnds_creepy_4 = "now only...",
			k_hnds_creepy_5 = "...we can only pray",
			k_hnds_creepy_6 = "to see again...",
			k_hnds_creepy_7 = "the Baron...",
			k_hnds_creepy_8 = "...who betrayed us",
			k_hnds_wanted = "[Joker name]",
			-- DEVIL BLIND ALIASES
			hnds_devil_name_default = "The Devil",
			hnds_devil_name_legion = "Legion",
			hnds_devil_name_old_nick = "Old Nick",
			hnds_devil_name_deceiver = "The Deceiver",
			hnds_devil_name_tempter = "The Tempter",
			hnds_devil_name_adversary = "The Adversary",
			hnds_devil_name_prince_of_darkness = "Prince of Darkness",
			hnds_devil_name_belial = "Belial",
			hnds_devil_name_apollyon = "Apollyon",
			hnds_devil_name_lucifer = "Lucifer",
			hnds_devil_name_abaddon = "Abaddon",
			hnds_devil_name_leviathan = "Leviathan",
			-- CONFIG TAB LOCALIZATION
			hnds_require_restart = "Requires restart",
			hnds_config_StoneOcean = "Enable Stone Ocean hand",
			hnds_config_vintage = "Enable Vintage edition",
			hnds_config_UltraSpec = "Enable Ultra Spectral packs spawning",
			hnds_config_MagicPack = "Enable Magic packs spawning",
			hnds_config_CursedPack = "Enable Cursed packs spawning",
			hnds_config_CustomSounds = "Enable custom joker sounds",
			hnds_config_VanillaTweaks = "Enable vanilla tweaks",
		},
		labels = {
			hnds_exchange_draw = "Bound",
			hnds_bound = "Bound",
			hnds_vintage = "Vintage",
			hnds_black_seal = "Black Seal",
			hnds_spectralseal_seal = "Spectral Seal",
			hnds_jester_temp_negative = "Illuminated",
			hnds_soul = "Soul",
			hnds_cursed = "Cursed",
			hnds_offer = "Offer",
			hnds_price = "Price",
		},
		challenge_names = {
			c_hnds_devils_round = "Devil's Round",
			c_hnds_draw_2_cards = "DRAW 2 CARDS",
			c_hnds_dark_ritual = "Dark Ritual",
			c_hnds_the_circus = "The Circus",
			c_hnds_gambling_opportunity = "Gambling Opportunity",
		},
		v_text = {
			ch_c_hnds_devils_round = {  "All Jokers are {C:red,E:2}Cursed{}", },
			ch_c_hnds_draw_2_cards = { "Start with 5 {C:attention}hand size{}", },
			ch_c_hnds_dark_ritual = { "You can't visit the {C:money}Shop{}", },
			ch_c_hnds_the_circus = {  "", },
			ch_c_hnds_gambling_opportunity = {  "Economy {C:attention}Jokers{}, {C:attention}Gold Seal{}, {C:attention}Gold card{} and {C:attention}Lucky Card{} are banned", },
		},
		poker_hands = {
			hnds_stone_ocean = "Stone Ocean",
		},
		poker_hand_descriptions = {
			hnds_stone_ocean = { "A hand consisting of 5 Stone cards" },
		},
	},
}

-- Vanilla balance text must follow the restart-required config toggle. When
-- disabled, omit these entries so Balatro's original localization remains.
local vanilla_tweaks_config = hnds_config
	or (SMODS and SMODS.Mods and SMODS.Mods.HandsomeDevils and SMODS.Mods.HandsomeDevils.config)
	or (SMODS and SMODS.current_mod and SMODS.current_mod.config)
if vanilla_tweaks_config and vanilla_tweaks_config.enableVanillaTweaks == false then
	local joker_keys = {
		"j_matador", "j_superposition", "j_splash", "j_flower_pot",
		"j_mail", "j_stone", "j_greedy_joker", "j_lusty_joker",
		"j_wrathful_joker", "j_gluttenous_joker", "j_throwback",
		"j_seeing_double", "j_ring_master", "j_hiker",
	}
	for _, key in ipairs(joker_keys) do
		localization.descriptions.Joker[key] = nil
	end
	localization.descriptions.Spectral.c_black_hole = nil
	localization.descriptions.Enhanced.m_wild = nil
	localization.descriptions.Tag.tag_juggle = nil
	localization.descriptions.Tag.tag_boss = nil
end

return localization
