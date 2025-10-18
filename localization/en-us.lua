return {
	descriptions = {
		-- this key should match the set ("object type") of your object,
		-- e.g. Voucher, Tarot, or the key of a modded consumable type
		Joker = {
			-- this should be the full key of your object, including any prefixes
			j_hnds_color_of_madness = {
				name = "Color of Madness",
				text = {
					"Enhances {C:attention}first{} scored",
					"card into a {C:attention}Wild Card{} if",
					"poker hand contains",
					"{C:attention}4{} different suits",
				},
				-- only needed when this object is locked by default
				-- unlock = {
				--'This is a condition',
				--'for unlocking this card',
				--},
			},
			j_hnds_occultist = {
				name = "Occultist",
				text = {
					"If {C:attention}first hand{} of round",
					"scores {C:attention}4{} different suits,",
					"create a {C:tarot}Charm{}, {C:spectral}Ethereal{},",
					"{C:planet}Meteor{} or {C:attention}Buffoon{} {C:attention}Tag{}",
				},
			},
			j_hnds_supersuit = {
				name = "Supersuit",
				text = {
					"{C:attention}Retrigger{} all",
					"cards with {V:1}#1#{} suit,",
					"{s:0.8}suit changes at end of round",
				},
			},
			j_hnds_dark_idol = {
				name = "The Dark Idol",
				text = {
					"Gains {X:mult,C:white}X#1#{} Mult per",
					"scoring {C:attention}#2#{} of {V:1}#3#{}",
					"played and destroys them",
					"{s:0.8}Card changes at end of round",
					"{C:inactive}(Currently {X:mult,C:white}X#4#{C:inactive} Mult)"
				},
			},
			j_hnds_perfectionist = {
				name = "Perfectionist",
				text = {
					"When you Enhance",
					"an Enhanced card,",
					"it permanently gains",
					"{C:mult}+#1#{} Mult and {C:chips}+#2#{} Chips",
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
			},
			j_hnds_head_of_medusa = {
				name = "Head of Medusa",
				text = {
					"Gains {X:chips,C:white}X#2#{} Chips for each",
					"held in hand {C:attention}face{} card ",
					"at end of round and",
					"turns them to {C:attention}Stone{}",
					"{C:inactive}(Currently {X:chips,C:white}X#1#{C:inactive} Chips)",
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
			},
			j_hnds_digital_circus = {
				name = "Digital Circus",
				text = {
					"Sell this card to create",
					"a random {V:1}#1#{} Joker",
					"with a random {C:dark_edition}Edition",
					"{s:0.8}Upgrades every {s:0.8}{C:attention}#3#{} {s:0.8}rounds",
					"{C:inactive}(Currently {C:attention}#2#{C:inactive}/#3#)",
				},
			},
			j_hnds_coffee_break = {
				name = "Coffee Break",
				text = {
					"After {C:attention}2{} rounds, sell",
					"this card to earn {C:money}$#3#{}",
					"Payout decreases by {C:money}$1{}",
					"for every card played",
					"{C:inactive}(Currently {C:attention}#2#{C:inactive}/#1#)",
				},
			},
			j_hnds_jackpot = {
				name = "Jackpot",
				text = {
					"{C:green}#1# in #2#{} chance to win {C:money}$#3#{} and",
					"{C:red}self destruct{} at end of round",
					"Increases {C:attention}listed{} {C:green}probability{}",
					"by {C:attention}#4#{} per scoring {C:attention}7{} played",
				},
			},
			j_hnds_pot_of_greed = {
				name = "Pot of Greed",
				text = {
					"When you use a",
					"{C:attention}consumable card{},",
					"draw {C:attention}#1#{} cards",
				},
			},
			j_hnds_seismic_activity = {
				name = "Seismic Activity",
				text = {
					"Retrigger all",
					"{C:attention}Stone cards",
				},
			},
			j_hnds_stone_mask = {
				name = "Stone Mask",
				text = {
					"If {C:attention}first hand{} of round",
					"is a single Enhanced card,",
					"add a random {C:dark_edition}Edition{} to it",
				},
			},
			j_hnds_jokestone = {
				name = "Jokestone",
				text = {
					"At the start of round,",
					"draw up to {C:attention}3{} Enhanced",
					"cards from your deck",
				},
			},
			j_hnds_meme = {
				name = "Meme",
				text = {
					"This Joker gains",
					"{X:mult,C:white}X0.05{} Mult per unique",
					"{C:attention}suit{} in scored hand",
					"{C:inactive}(Currently {X:mult,C:white}X#1#{C:inactive} Mult)",
				},
			},
			j_hnds_balloons = {
				name = "Balloons",
				text = {
					"When round ends with no",
					"{C:blue}hands{} left, {C:red}lose{} a {C:attention}Balloon{}",
					"and create a random {C:attention}Tag",
					"{C:inactive}({C:attention}#1#{C:inactive}/#2# Balloons left)",
				},
			},
			j_hnds_jokes_aside = {
				name = "Jokes Aside!",
				text = {
					"Gains {X:mult,C:white}X#2#{} Mult",
					"for every Joker",
					"{C:attention}sold{} during a round",
					"{C:inactive}(Currently {X:mult,C:white}X#1#{C:inactive} Mult)",
				},
			},
			j_hnds_ms_fortune = {
				name = "Ms. Fortune",
				text = {
					"Quadruples all",
					"{C:attention}listed{} {C:green,E:1}probabilities{}",
					"Sets your money to {C:money}$0",
					"when {C:attention}Blind{} is selected",
					"{C:inactive}(e.x. {}{C:green}1 in 3{} {C:inactive}->{} {C:green}#1# in 3{}{C:inactive}){}",
				},
			},
			j_hnds_dark_humor = {
				name = "Dark Humor",
				text = {
					"When hand is played, {c:red}destroy",
					"a random {C:attention}held in hand{} card",
					"and gain its {C:mult}Mult{} and {C:chips}Chips",
					"{C:inactive}(Currently{} {C:mult}+#2#{} {C:inactive}Mult,{} {C:chips}+#1#{} {C:inactive}Chips)",
				},
			},
			j_hnds_krusty = {
				name = "Clown Krusty",
				text = {
					"Adds {C:dark_edition}Negative{}",
					"to {C:attention}Food Jokers",
					"Creates one when",
					"{C:attention}Blind{} is selected",
				}
			},
			j_hnds_energized = {
				name = "Energized",
				text = {
					"If played hand is a single card,",
					"retriggers it {C:attention}#3#{} additional times",
					"{C:green}#1# in #2#{} chance to {C:red}destroy it"
				}
			},
			j_hnds_pennywise = {
				name = "Pennywise",
				text = {
					"When {C:attention}Boss Blind{} is defeated",
					"gain its {C:attention}Soul{} in the form",
					"of a special {C:dark_edition}Negative {C:attention}Joker",
					"Retrigger your {C:attention}Souls"
				}
			},
			j_hnds_handsome = {
				name = "Handsome Devil",
				text = {
					"Retrigger all",
					"cards with {C:dark_edition}Editions",
				}
			},
			j_hnds_art = {
				name = "Art the Clown",
				text = {
					"Sell this card to",
					"add a copy of it to your",
					"next {C:attention}Booster Pack{} and",
					"create {C:attention}#1#{} random {C:attention}Tags"
				}
			},
			j_hnds_public_nuisance = {
				name = "Public Nuisance",
				text = {
					"Keep playing {C:blue}Hands{} after",
					"{C:attention}Blind{} score was met",
				}
			},
			j_hnds_bizzare_joker_spades = {
				name = "Bizarre Joker",
				text = {
				"{C:chips}+#2#{} Chips per scored {C:spades}Spade{} card",
 				"{s:0.8}Effect changes every round",
 				"{C:inactive}(Currently {X:mult,C:white}X#5#{C:inactive} Mult,",
 				"{C:mult}+#3#{C:inactive} Mult, {C:chips}+#1#{C:inactive} Chips)",
				}
			},
			j_hnds_bizzare_joker_clubs = {
				name = "Bizarre Joker",
				text = {
				"{C:mult}+#4#{} Mult per scored {C:clubs}Club{} card",
 				"{s:0.8}Effect changes every round",
 				"{C:inactive}(Currently {X:mult,C:white}X#5#{C:inactive} Mult,",
 				"{C:mult}+#3#{C:inactive} Mult, {C:chips}+#1#{C:inactive} Chips)",
				}
			},
			j_hnds_bizzare_joker_diamonds = {
				name = "Bizarre Joker",
				text = {
				"{C:money}+$#7#{} sell value per scored {C:diamonds}Diamond{} card",
 				"{s:0.8}Effect changes every round",
 				"{C:inactive}(Currently {X:mult,C:white}X#5#{C:inactive} Mult,",
 				"{C:mult}+#3#{C:inactive} Mult, {C:chips}+#1#{C:inactive} Chips)",
				}
			},
			j_hnds_bizzare_joker_hearts = {
				name = "Bizarre Joker",
				text = {
				"{X:mult,C:white}X#6#{} Mult per scored {C:hearts}Heart{} card",
 				"{s:0.8}Effect changes every round",
 				"{C:inactive}(Currently {X:mult,C:white}X#5#{C:inactive} Mult,",
 				"{C:mult}+#3#{C:inactive} Mult, {C:chips}+#1#{C:inactive} Chips)",
				}
			},
			j_hnds_arthur = {
				name = "Arthur",
				text = {
					"{C:attention}+#2#{} free {C:green}Reroll{} for every",
					"scoring {V:1}#3#{} card played",
					"Destroys scored {V:1}#3#",
					"{s:0.8}Suit changes every hand",
					"{C:inactive}(Currently {C:attention}#1#{C:green} Rerolls{C:inactive})"
				}
			},
		},
		Back = {
			b_hnds_premiumdeck = {
				name = "Premium Deck",
				text = {
					"Start run with",
					"{C:green}Premium{} and {C:red}Top Shelf{}",
					"Jokers cost extra {C:money}${}",
					"equal to your {C:attention}Ante{}",
				},
			},
			b_hnds_crystal = {
				name = "Crystal Deck",
				text = {
					"On Ante {C:attention}4{}, face",
					"the {C:attention}Showdown Blind{}",
					"Defeat it to open an",
					"{E:1,C:legendary}Ultra Spectral Pack{}"
				}
			},
			b_hnds_conjuring = {
				name = "Conjuring Deck",
				text = {
					"{C:attention}Jokers{} and {C:attention}consumables{}",
					"may appear multiple times",
					"{C:attention}+1{} card choice available",
					"in {C:attention}Booster Packs{}"
				}
			}
		},
		Spectral = {
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
					"Destroy a random {C:attention}Joker{},",
					"create a random one",
					"of a {C:attention}higher rarity{}",
				},
			},
			c_hnds_petrify = {
				name = "Petrify",
				text = {
					"Enhaces all {C:attention}face{} cards",
					"in hand into {C:attention}Stone Cards{}",
					"Gain {C:money}$#1#{} for each petrified",
				},
			},
			c_hnds_exchange = {
				name = "Exchange",
				text = {
					"Add {C:dark_edition}Negative{} to",
					"{C:attention}#1#{} selected cards",
					"{C:blue}-#2#{} hand each round",
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
					"Creates {C:attention}10{} random",
					"{E:1,C:legendary}Joker Tags{}",
				},
			},
			c_hnds_collision = {
				name = "Collision",
				text = {
					"Enhances {C:attention}#1#{} selected cards",
					"to {C:dark_edition}#2#s",
				},
			},
			c_hnds_gateway = {
				name = "Gateway",
				text = {
					"Enhances {C:attention}#1#{} selected cards",
					"to {C:dark_edition}#2#s",
				},
			},
			c_hnds_spectrum = {
				name = "Spectrum",
				text = {
					"Gives each card in",
					"your hand a random",
					"{C:attention}Enhancement{} and {C:attention}Seal",
					"{s:0.9,C:inactive}(Mult and Bonus excluded)"
				}
			}
		},
		Other = {
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
					"Creates {C:attention}#1# {C:spectral}Spectral{} cards",
					"when {C:attention}destroyed",
					"{C:inactive}(Must have room){}"
				}
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
					"{C:green}Uncommon{}, {C:red}Rare{},",
					"{C:attention}Buffoon Tag{}, etc.",
				}
			},
			hnds_soul = {
				name = "Soul",
				text = {"Created by {C:legendary,E:1}Pennywise"}
			}
		},
		Voucher = {
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
			},
			v_hnds_premium = {
				name = "Premium",
				text = {
					"{C:uncommon}Uncommon{} jokers appear",
					"{C:attention}#1#X{} as often",
				},
			},
			v_hnds_top_shelf = {
				name = "Top Shelf",
				text = {
					"{C:rare}Rare{} jokers appear",
					"{C:attention}#1#X{} as often",
				},
			},
			v_hnds_extra_filling = {
				name = "Extra Filling",
				text = {
					"{C:attention}+1{} card option available",
					"in {C:attention}Booster Packs{}",
				},
			},
			v_hnds_wholesale = {
				name = "Wholesale",
				text = {
					"{C:attention}+1{} Booster Pack slot",
					"available in the shop",
				},
			},
			v_hnds_soaked = {
				name = "Soaked and Wet",
				text = {
					"Leftmost card {C:attention}held in hand",
					"counts in scoring"
				}
			},
			v_hnds_beyond = {
				name = "Go Beyond",
				text = {
					"Rightmost card {C:attention}held in hand",
					"counts in scoring"
				}
			}
		},
		Planet = {
			c_hnds_makemake = {
				name = "Makemake",
				text = {
					"{S:0.8}({S:0.8,V:1}lvl.#1#{S:0.8}){} Level up",
					"{C:attention}#2#",
					"{C:chips}+#3#{} chips. {C:chips}+#4#{} extra",
					"for each {C:attention}Stone Card{}",
					"scored this Ante {C:inactive}[#5#]",
				},
			},
		},
		Enhanced = {
			m_hnds_aberrant = {
				name = "Aberrant Card",
				text = {
					"Gains {C:mult}+#1#{} Mult",
					"while stays in hand",
					"Destroy this card",
					"when {C:attention}discarded{}",
				},
			},
			m_hnds_obsidian = {
				name = "Obsidian Card",
				text = {
					"Lose {C:red}$#1#{}",
					"{C:green}#2# in #3#{} chance to",
					"create a {C:dark_edition}Negative",
					"consumable card",
				},
			},
		},
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
			k_hnds_occultist = "Study!",
			k_hnds_splashed = "Splashed!",
		},
		labels = {
			hnds_black_seal = "Black Seal",
			hnds_spectralseal_seal = "Spectral Seal",
			hnds_soul = "Soul"
		},
		poker_hands = {
			hnds_stone_ocean = "Stone Ocean",
		},
		poker_hand_descriptions = {
			hnds_stone_ocean = { "A hand consisting of 5 Stone cards" },
		},
	},
}
