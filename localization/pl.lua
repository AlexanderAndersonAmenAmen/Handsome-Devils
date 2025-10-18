return {
	descriptions = {
		-- this key should match the set ("object type") of your object,
		-- e.g. Voucher, Tarot, or the key of a modded consumable type
		Joker = {
			-- this should be the full key of your object, including any prefixes
			j_hnds_color_of_madness = {
				name = "Kolor szaleństwa",
				text = {
					"Jeżeli {C:attention}pierwsza ręka{} w",
					"rundzie posiada {C:attention}4{} różne",
					"kolory, {C:attention}pierwsza{} punktowana",
					"karta staje się {C:attention}Dzika{}",
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
					"Jeśli {C:attention}pierwsza ręka{} w",
					"rundzie posiada {C:attention}4{} różne",
					"kolory, stwórz {C:planet}meteorowy{},",
					"{C:tarot}amultet{} lub {C:spectral}eteryczny{} {C:attention}znacznik{}",
				},
			},
			j_hnds_banana_split = {
				name = "Podział banana",
				text = {
					"Mnoż. {X:mult,C:white}X#1#{}",
					"{C:green}#2# na #3#{} szans by",
					"{C:attention}Utworzyć kopie{} tej",
					"karty na końcu rundy",
					"{C:inactive}(wymaga miejsca){}",
				},
			},
			j_hnds_head_of_medusa = {
				name = "Głowa Meduzy",
				text = {
					"Ten joker zdobywa {X:mult,C:white}X#2#{} do mnoż,",
					"za każdą punktowaną kartę {C:attention}figur{}",
					"Wszystkie zagrane karty figur",
					"stają się {C:attention}kamiennymi{} kartami",
					"{C:inactive}(obecny mnoż.: {X:mult,C:white}X#1#{}",
				},
			},
			j_hnds_deep_pockets = {
				name = "Głębokie kieszenie",
				text = {
					"{C:attention}+#1#{} slot na przedm. zużywalne",
					"karty w obszarze przedm.",
					"{C:attention}zużywalnych{} dają",
					"{C:mult}+#2#{} Mult",
				},
			},
			j_hnds_digital_circus = {
				name = "Cyfrowy cyrk",
				text = {
					"Sprzedaj tą kartę by stworzyć",
					"losowy {V:1}#1#{} joker",
					"z losową {C:dark_edition}wersją",
					"{s:0.8}Ulepsza się co {s:0.8}{C:attention}#3#{} {s:0.8}rundy",
					"{C:inactive}(obecnie {C:attention}#2#{C:inactive}/#3#)",
				},
			},
			j_hnds_coffee_break = {
				name = "Przerwa na kawę",
				text = {
					"Po {C:attention}2{} rundach sprzedaj",
					"tą kartę, by zyskać {C:money}#3#${}",
					"Wypłata maleje o {C:money}1${}",
					"za każdą zagraną kartę",
					"{C:inactive}({C:attention}#2#{C:inactive}/#1#)",
				},
			},
			j_hnds_jackpot = {
				name = "Pula",
				text = {
					"{C:green}#1# na #2#{} szans",
					"wygrania {C:money}#3#${} i {C:red}zniszczenia{}",
					"tej karty na końcu rundy,",
					"zwiększa {C:attention}podane{} {C:green}prawdopodobieństwo{}",
					"o {C:attention}#4#{} za każdą punktowaną {C:attention}7{}",
				},
			},
			j_hnds_pot_of_greed = {
				name = "Garnek chciwości",
				text = {
					"Po użyciu {C:attention}karty zużywalnej{},",
					"dobierasz {C:attention}#1#{} karty",
				},
			},
			j_hnds_seismic_activity = {
				name = "Sejsmiczna działalność",
				text = {
					"Aktywuj ponownie wszystkie",
					"{C:attention}karty kamienne",
				},
			},
			j_hnds_stone_mask = {
				name = "Kamienna maska",
				text = {
					"Jeżeli {C:attention}pierwsza ręka{} rundy",
					"to pojedyńcza ulepszona karta,",
					"dodaj losową {C:attention}wersję{} do niej",
				},
			},
			j_hnds_jokestone = {
				name = "Żartokamień",
				text = {
					"Na początku rundy,",
					"dobierasz do {C:attention}3{} ulepszonych",
					"kart z talii",
				},
			},
			j_hnds_meme = {
				name = "Mem",
				text = {
					"Ten joker zdobywa {X:mult,C:white}X0.05",
					"do mnoż. za każdy różny",
					"{C:attention}kolor{} w zagranej ręce",
					"{C:inactive}(obecnie mnoż.: {X:mult,C:white}X#1#{C:inactive})",
				},
			},
			j_hnds_balloons = {
				name = "Balony",
				text = {
					"Jeśli kończysz runde bez",
					"pozostałych {C:blue}rąk{}, {C:red}traci{} {C:attention}balon{}",
					"i daje losowy {C:attention}znacznik",
					"{C:inactive}({C:attention}#1#{C:inactive} z #2# balonów zostało)",
				},
			},
			j_hnds_jokes_aside = {
				name = "Żarty na bok!",
				text = {
					"Ten joker zdobywa mnoż. {X:mult,C:white}X#2#{}",
					"za każdego jokera",
					"{C:attention}sprzedanego{} podczas rundy",
					"{C:inactive}(obecnie mnoż.: {X:mult,C:white}X#1#{C:inactive})",
				},
			},
			j_hnds_ms_fortune = {
				name = "Pani fortuna",
				text = {
					"Zwiększa wszystkie podane",
					"{C:green,E:1}prawdopodobieństwa{} {C:attention}#1#{} razy,",
					"ale na końcu zakupów w",
					"{C:attention}sklepie{} ustawia pieniądze",
					"na {C:money}#2#${}",
					"{C:inactive}(np. {}{C:green}1 na 3{} {C:inactive}->{} {C:green}#1# na 3{}{C:inactive}){}",
				},
			},
		},
		Spectral = {
			c_hnds_abyss = {
				name = "Odchłań",
				text = {
					"Dodaje {C:dark_edition}Czarną Pieczęć{}",
					"do {C:attention}#1#{} wybranej",
					"karty w ręce",
				},
			},
			c_hnds_growth = {
				name = "Wzrost",
				text = {
					"Dodaje {C:green}Zieloną Pieczęć{}",
					"do {C:attention}#1#{} wybranej",
					"karty w ręce",
				},
			},
			c_hnds_petrify = {
				name = "Skamienienie",
				text = {
					"Wszystkie karty {C:attention}figur{}",
					"w ręce stają się {C:attention}kamienne{},",
					"zyskujesz {C:money}#1#${} za każdą skamieniałą kartę",
				},
			},
			c_hnds_exchange = {
				name = "Wymiana",
				text = {
					"Dodaj {C:dark_edition}negatyw{} do",
					"{C:attention}#1#{} wybranych kart",
					"{C:blue}-#2#{} rąk na rundę",
				},
			},
			c_hnds_hallows = {
				name = "Hallows",
				text = {
					"Niszczy wszystkie jokery poza",
					"jokerem najbardziej wysuniętym",
					"na lewo, zyskujesz {C:attention}#1#X{}",
					"więcej niż wartość sprzedarzy",
					"zniszczonych jokerów",
					"{C:inactive}(maks. {C:money}#2#${C:inactive})",
					"{C:inactive}(obecnie {C:money}#3#${C:inactive})",
				},
			},
			c_hnds_dream = {
				name = "Sen",
				text = {
					"Tworzy {C:attention}10{} losowych",
					"{C:attention}jokerowych znacznikówe{}",
				},
			},
			c_hnds_collision = {
				name = "Kolizja",
				text = {
					"Ulepsza {C:attention}#1#{} wybrane",
					"karty do:",
					"{C:dark_edition}#2#s",
				},
			},
			c_hnds_gateway = {
				name = "Wejście",
				text = {
					"Ulepsza {C:attention}#1#{} wybrane",
					"karty do:",
					"{C:dark_edition}#2#s",
				},
			},
		},
		Other = {
			hnds_black_seal = {
				name = "Czarna Pieczęć",
				text = {
					"Ta karta liczy się w punktowaniu",
					"jeśli jest w ręce",
				},
			},
			hnds_green_seal = {
				name = "Zielona Pieczęć",
				text = {
					"Dobierasz {C:attention}2{} dodatkowe",
					"karty gdy ta karta jest {C:attention}punktowana",
					"lub {C:attention}odrzucona",
				},
			},
		},
		Enhanced = {
			m_hnds_aberrant = {
				name = "Karta antymaterii",
				text = {
					"Nie można zmienić ulepszenia",
					"{C:green}#1# na #2#{} szans by być {C:red}zniszczonym{}",
					"po zagraniu. Nałóż efekt następnego",
					"ulepszenia na wszystkie poprzednie",
					"(obecnie {C:attention}#3#{}, #4# warstw)",
				},
			},
			m_hnds_obsidian = {
				name = "Obsidianowa karta",
				text = {
					"Strać {C:red}#1#${},",
					"{C:green}#2# na #3#{} szans by",
					"stworzyć {C:dark_edition}negatywm",
					"kartę zużywalną",
				},
			},
		},
		Voucher = {
			v_hnds_tag_hunter = {
				name = "Poszukiwacz znaczników",
				text = {
					"Tworzy losowy {C:attention}znacznik{}",
					"po pokonaniu każdej",
					"{C:attention}Przeszkadzajki bossowej{}",
				},
			},
			v_hnds_hashtag_skip = {
				name = "#2#pominąć",
				text = {
					"{C:attention}-1{} wejść co",
					"{C:attention}#1#{} pominięcia",
				},
			},
			v_hnds_beginners_luck = {
				name = "Szczęście początkującego",
				text = {
					"Podwaja wszystkie {C:attention}podane",
					"{C:green,E:1,S:1.1}prawdopodobieństwa{} w rundach",
					"z {C:attention}Małą przeszkadzajką{}",
					"{C:inactive}(np. {C:green}1 na 3{C:inactive} -> {C:green}2 na 3{C:inactive})",
				},
			},
			v_hnds_rigged = {
				name = "Ustawione",
				text = {
					"Podwaja wszystkie {C:attention}podane{}",
					"{C:green}prawdopodobieństwa{}",
					"{C:inactive}(np. {C:green}1 na 3{C:inactive} -> {C:green}2 na 3{C:inactive})",
				},
			},
			v_hnds_premium = {
				name = "Premium",
				text = {
					"{C:uncommon}Niepospolite{} jokery pojawiają",
					"się {C:attention}#1#{} razy częściej",
				},
			},
			v_hnds_top_shelf = {
				name = "Wysoka pólka",
				text = {
					"{C:rare}Rzadkie{} jokery pojawiają",
					"się {C:attention}#1#{} razy częściej",
				},
			},
			v_hnds_stuffed = {
				name = "Dodatkowe wypełnienie",
				text = {
					"Wszystkie {C:attention}paczki wzmacniające",
					"mają {C:attention}+#1#{} kartę",
				},
			},
			v_hnds_wholesale = {
				name = "Hurt",
				text = {
					"{C:attention}+1{} slot na paczkę wzmacniającą",
					"w sklepie",
				},
			},
		},
		Planet = {
			c_hnds_makemake = {
				name = "Makemake",
				text = {
					"{S:0.8}({S:0.8,V:1}lvl.#1#{S:0.8}){} Zwiększ poziom układu",
					"{C:attention}#2# {C:chips}+#3#{} żet.",
					"oraz {C:chips}+#4#{} dodatkowe żet. za każdą",
					"zagraną {C:attention}kartę kamienną{} w wejściu {C:inactive}[#5#]",
					" ",
				},
			},
		},
	},
	misc = {
		dictionary = {
			k_hnds_petrified = "Skamieniały!",
			k_hnds_goldfish = "Złota ryba!",
			k_hnds_green = "Dobierasz!",
			k_hnds_jackpot = "Jackpot!",
			k_hnds_probinc = "Powiększono!",
			k_hnds_coffee = "Zimna!",
			k_hnds_seismic = "Tremor!",
			k_hnds_awaken = "Wstań!",
			k_hnds_IPLAYPOTOFGREED = "JA GRAM!...",
			k_hnds_balloons = "Wszystkie stracone!",
			k_hnds_banana_split = "Podzielone!",
			k_hnds_color_of_madness = "Szaleństwo!",
			k_hnds_occultist = "Ucz się!",
		},
		labels = {
			hnds_black_seal = "Czarna Pieczęć",
			hnds_green_seal = "Zielona Pieczęć",
		},
		poker_hands = {
			hnds_stone_ocean = "Ocean kamienia",
		},
		poker_hand_descriptions = {
			hnds_stone_ocean = { "Ręka składająca się z 5 kart kamiennych" },
		},
	},
}
