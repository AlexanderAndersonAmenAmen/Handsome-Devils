return {
	descriptions = {
		-- this key should match the set ("object type") of your object,
		-- e.g. Voucher, Tarot, or the key of a modded consumable type
		Joker = {
			-- this should be the full key of your object, including any prefixes
			j_hnds_color_of_madness = {
				name = "Color de la Locura",
				text = {
					"Convierte la {C:attention}primera{}",
					"carta jugada en {C:attention}Carta Versátil{}",
					"si la mano contiene",
					"{C:attention}4{} palos distintos",
				},
				-- only needed when this object is locked by default
				-- unlock = {
				--'This is a condition',
				--'for unlocking this card',
				--},
			},
			j_hnds_occultist = {
				name = "Ocultista",
				text = {
					"Si la {C:attention}primera mano{} jugada",
					"contiene {C:attention}4{} palos distintos,",
					"crea una {C:attention}Etiqueta {C:tarot}Encantada{},",
					"{C:spectral}Etérea{}, {C:planet}de Meteoro{} o {C:attention}de Bufón{}",
				},
			},
			j_hnds_supersuit = {
				name = "Supertraje",
				text = {
					"Recuenta todas las",
					"cartas de {V:1}#1#{}",
					"{s:0.8}el palo cambia en cada ronda",
				},
			},
			j_hnds_dark_idol = {
				name = "Ídolo Oscuro",
				text = {
					"Gana {X:mult,C:white}X#1#{} multi por",
					"cada {C:attention}#2#{} de {V:1}#3#{}",
					"que anota y lo destruye",
					"{s:0.8}la carta cambia en cada ronda",
					"{C:inactive}(Actual: multi {X:mult,C:white}X#4#{C:inactive})"
				},
			},
			j_hnds_perfectionist = {
				name = "Perfeccionista",
				text = {
					"Cuando mejoras una",
					"carta Mejorada,",
					"gana {C:mult}+#1#{} multi y",
					"{C:chips}+#2#{} fichas permanentemente",
				},
			},
			j_hnds_banana_split = {
				name = "Banana Split",
				text = {
					"{X:mult,C:white}X#1#{} multi",
					"{C:green}#2# en #3#{} probabilidades",
					"de {C:attention}Duplicar{} esta carta",
					"al final de la ronda",
					"{C:inactive}(Debe haber espacio){}",
				},
			},
			j_hnds_head_of_medusa = {
				name = "Cabeza de Medusa",
				text = {
					"Gana {X:mult,C:white}X#2#{} multi por cada",
					"carta de {C:attention}figura{} en mano",
					"al final de la ronda y",
					"las convierte en {C:attention}Piedra{}",
					"{C:inactive}(Actual: multi {X:mult,C:white}X#1#{C:inactive})",
				},
			},
			j_hnds_deep_pockets = {
				name = "Bolsillos Hondos",
				text = {
					"{C:attention}+#1#{} ranuras de consumible",
					"Cada carta en tu",
					"{C:attention}área de consumibles{}",
					"da {C:mult}+#2#{} multi",
				},
			},
			j_hnds_digital_circus = {
				name = "Circo Digital",
				text = {
					"Vende esta carta para crear",
					"un Comodín {V:1}#1#{} aleatorio",
					"con una {C:dark_edition}Edición{} aleatoria",
					"{s:0.8}mejora cada {s:0.8}{C:attention}#3#{} {s:0.8}rondas",
					"{C:inactive}(Actual: {C:attention}#2#{C:inactive}/#3#)",
				},
			},
			j_hnds_coffee_break = {
				name = "Pausa de Café",
				text = {
					"Tras {C:attention}2{} rondas, vende",
					"esta carta para ganar {C:money}$#3#{}",
					"Paga disminuye en {C:money}$1{}",
					"por cada carta jugada",
					"{C:inactive}(Actual: {C:attention}#2#{C:inactive}/#1#)",
				},
			},
			j_hnds_jackpot = {
				name = "Bote",
				text = {
					"{C:green}#1# en #2#{} probabilidades de ganar {C:money}$#3#{}",
					"y dar {C:mult}+#4#{} multi por mano jugada",
					"Cada {C:attention}7{} anotado duplica esta",
					"{C:green}probabilidad{} durante la mano",
					"{C:inactive}(p. ej. {C:green}1 en #5#{C:inactive} -> {C:green}2 en #5#{C:inactive})"
				},
			},
			j_hnds_pot_of_greed = {
				name = "Olla de la Codicia",
				text = {
					"Cuando usas una",
					"{C:attention}carta consumible{},",
					"roba {C:attention}#1#{} cartas",
				},
			},
			j_hnds_seismic_activity = {
				name = "Actividad Sísmica",
				text = {
					"Recuenta todas las",
					"{C:attention}Cartas de Piedra",
				},
			},
			j_hnds_stone_mask = {
				name = "Máscara de Piedra",
				text = {
					"Si la {C:attention}primera mano{} jugada",
					"es una sola carta Mejorada,",
					"añade una {C:dark_edition}Edición{} aleatoria",
				},
			},
			j_hnds_jokestone = {
				name = "Piedra del Bufón",
				text = {
					"Al comienzo de la ronda,",
					"roba hasta {C:attention}3{} cartas",
					"Mejoradas de tu mazo",
				},
			},
			j_hnds_meme = {
				name = "Meme",
				text = {
					"Este Comodín gana",
					"{X:mult,C:white}X0.05{} multi por cada",
					"{C:attention}palo{} único anotado",
					"{C:inactive}(Actual: multi {X:mult,C:white}X#1#{C:inactive})",
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
					"Set your money to {C:red}$0",
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
					"edition to {C:attention}Food Jokers",
					"{C:green}#1# in #2#{} chance to create",
					"one at end of round",
				}
			},
			j_hnds_energized = {
				name = "Energized",
				text = {
					"If played hand is a single card,",
					"retrigger it {C:attention}#3#{} additional times",
					"{C:green}#1# in #2#{} chance to {C:red}destroy{} it"
				}
			},
			j_hnds_pennywise = {
				name = "Pennywise",
				text = {
					"If {C:attention}Boss Blind{} is defeated in",
					"{C:attention}one hand{}, gain its {C:legendary}Soul{} in a",
					"form of a {C:dark_edition}Negative{} Joker",
					"Retrigger your {C:legendary}Souls{}"
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
					"Sell this card to add",
					"a copy of it to the next",
					"{C:attention}Booster Pack{} you open and",
					"create a random {C:attention}Tag"
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
			j_hnds_last_laugh = {
				name = "Last Laugh",
				text = {
					"Sell this card to draw {C:attention}#1#{}",
					"card from your deck, then",
					"{C:red}destroy{} all cards in hand",
					"{s:0.8}Upgrades at end of round",
				}
			},
			j_hnds_fregoli = {
				name = "Fregoli",
				text = {
					"Copies the ability of the",
					"last {C:attention}Joker{} you bought",
				}
			},
			j_hnds_walking_joke = {
				name = "Walking Joke",
				text = {
					"Retrigger adjacent",
					"{C:blue}Common{} Jokers",
				}
			},
			j_hnds_blackjack = {
				name = "Blackjack",
				text = {
					"{C:chips}+#2#{} Chips if total {C:attention}rank{} of",
					"discarded cards is {C:attention}21{}, resets",
					"when {C:attention}Boss Blind{} is defeated",
					"{C:inactive}(Currently {C:chips}+#1#{C:inactive} Chips)",
				}
			},
			j_hnds_angry_mob = {
				name = "Angry Mob",
				text = {
					"{X:mult,C:white}X#1#{} Mult,",
					"{C:attention}shops{} no longer",
					"offer {C:attention}Jokers"
				}
			},
			j_hnds_sarmenti = {
				name = "Sarmenti",
				text = {
					"{C:attention}Once{} per round, give",
					"scored cards random",
					"{V:1}#1#{} if played hand",
					"contains a {C:attention}Four of a Kind{}",
					"{s:0.8}Effect changes every round",
				}
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
			},
			b_hnds_crystal = {
				name = "Crystal Deck",
				text = {
					"On Ante {C:attention}4{}, face",
					"the {C:attention}Showdown Blind{}",
					"Defeat it to open an",
					"{C:legendary,T:p_hnds_spectral_ultra}Ultra Spectral Pack{}", --might need to remove the E:1, hover tooltip doesnt seem to work with that
				}
			},
			b_hnds_conjuring = {
				name = "Conjuring Deck",
				text = {
					"All {C:attention}Booster Packs{}",
					"in shop are replaced",
					"by {C:attention,T:p_hnds_magic_1}Magic Packs{} which",
					"contain {C:dark_edition,E:1}random cards"
				}
			},
			b_hnds_circus = {
				name = "Circus Deck",
				text = {
					"Copies ability",
					"of a random {C:attention}Joker",
					"After defeating each",
					"{C:attention}Boss Blind{}, ability changes",
					"{C:inactive}(Currently: {V:1}#1#{C:inactive})"
				}
			},
			b_hnds_ol_reliable = {
				name = "Ol' Reliable Deck",
				text = {
					"Triples all {C:attention}listed",
					"{C:green}probabilities{} during",
					"{C:attention}shop{} and {C:attention}Boss Blinds",
					"{C:inactive}(e.x. {C:green}1 in 3{C:inactive} -> {C:green}3 in 3){C:inactive}"
				}
			},
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
		Edition = {
			e_hnds_vintage = {
				name = "Vintage",
				text = {
					"Earn additional {C:money}$1",
					"per {C:money}$1{} of {C:attention}interest",
					"at end of round",
				},
			},
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
				text = { "Created by {C:legendary,E:1}Pennywise" }
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
			v_hnds_stuffed = {
				name = "Stuffed",
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
		Tag = {
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
					"Next shop Joker is free",
					"and gets {C:attention}duplicated{}",
					"when you buy it",
					"{C:inactive}(Must have room){}",
				},
			},
		},
		Stake = {
			stake_hnds_platinum = {
				name = "Platinum Stake",
				text = {
					"If {C:attention}Blind{} is defeated by scoring",
					"twice the required Chips,",
					"all {C:attention}Blinds{} become {C:mult}X2{} larger",
                    "{s:0.8}Applies all previous Stakes",
				}
			}
		}
	},
	misc = {
		dictionary = {
			k_hnds_petrified = "Petrified!",
			k_hnds_goldfish = "Goldfish!",
			k_hnds_boom_timer = "!!!",
			k_hnds_boom = "BOOM!",
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
			hnds_plus_q = "+1 ???", --this is for the cryptid digital hallucinations creation message with magic packs
			k_hnds_magic_pack = "Magic Pack",
			k_hnds_sarmenti_active = "active",
			k_hnds_sarmenti_inactive = "inactive",
			k_hnds_sarmenti_enhanced = "Enhanced!",
			k_hnds_enhancements = "Enhancements",
		},
		labels = {
			hnds_vintage = "Vintage",
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
		ranks = {
			hnds_creepycard = 'Something Truly Evil',
		},
	},
}
