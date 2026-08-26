return {
	descriptions = {
		Joker = {
			j_hnds_color_of_madness = {
				name = "El Color de la Locura",
				text = {
					"Mejora las {C:attention}primeras dos{} cartas",
					"anotadas a {C:attention}Cartas Versátiles{}",
					"si la mano jugada tiene",
					"{C:attention}4{} palos diferentes",
				},
			},
			j_hnds_occultist = {
				name = "Ocultista",
				text = {
					"Si la {C:attention}primera mano{} anota",
					"{C:attention}4{} cartas de palos diferentes,",
					"crea una {C:attention}Etiqueta{} {C:tarot}Encantada{},",
					"{C:spectral}Etérea{}, de {C:planet}Meteoro{} o {C:attention}Bufón{}",
				},
			},
			j_hnds_supersuit = {
				name = "Supertraje",
				text = {
					"Reactiva las cartas",
					"del palo {V:1}#1#{},",
					"{C:inactive,s:0.8}(Cambia cada ronda)",
				},
			},
			j_hnds_dark_idol = {
				name = "Ídolo Oscuro",
				text = {
					"Gana {X:mult,C:white}X#1#{} Multi por",
					"cada {C:attention}#2#{} de {V:1}#3#{}",
					"anotado y los {C:red}destruye{}",
					"{s:0.8}(Cambia al final de la ronda)",
					"{C:inactive}(Actualmente {X:mult,C:white}X#4#{C:inactive} Multi)"
				},
			},
			j_hnds_perfectionist = {
				name = "Perfeccionista",
				text = {
					"Cuando mejoras una carta",
					"ya {C:attention}Mejorada{}, en su lugar",
					"gana permanentemente",
					"{C:mult}+#1#{} Multi y {C:chips}+#2#{} Fichas",
				},
			},
			j_hnds_banana_split = {
				name = "Banana Split",
				text = {
					"{X:mult,C:white}X#1#{} Multi",
					"prob. de {C:green}#2# en #3#{} de",
					"{C:attention}Duplicar{} esta carta",
					"al final de la ronda",
					"{C:inactive}(Debe haber espacio){}",
				},
			},
			j_hnds_head_of_medusa = {
				name = "Cabeza de Medusa",
				text = {
					"Gana {X:mult,C:white}X#2#{} Multi por cada",
					"carta de {C:attention}figura{} en mano",
					"al final de la ronda y las",
					"convierte en {C:attention}Piedra{}",
					"{C:inactive}(Actualmente {X:mult,C:white}X#1#{C:inactive} Multi)",
				},
			},
			j_hnds_deep_pockets = {
				name = "Bolsillos Anchos",
				text = {
					"{C:attention}+#1#{} ranuras de consumibles",
					"cada carta en el",
					"{C:attention}área de consumibles{}",
					"otorga {C:mult}+#2#{} Multi",
				},
			},
			j_hnds_digital_circus = {
				name = "Circo Digital",
				text = {
					"Vende esta carta para crear",
					"un comodín {V:1}#1#{} al azar",
					"con una {C:dark_edition}edición{}",
					"{s:0.8}Se mejora cada {s:0.8}{C:attention}#3#{} {s:0.8}rondas",
					"{C:inactive}(Actualmente {C:attention}#2#{C:inactive}/#3#)",
				},
			},
			j_hnds_coffee_break = {
				name = "Descanso",
				text = {
					"Después de {C:attention}2{} rondas, vende",
					"esta carta para obtener {C:money}$#3#{}",
					"El pago se reduce en {C:money}$1{}",
					"por carta jugada",
					"{C:inactive}(Actualmente {C:attention}#2#{C:inactive}/#1#)",
				},
			},
			j_hnds_jackpot = {
				name = "Jackpot",
				text = {
					"Prob. de {C:green}#1# en #2#{} de ganar {C:money}$#3#{} y",
					"otorgar {C:mult}+#4#{} Multi por mano jugada",
					"duplica la {C:green}probabilidad{} por cada",
					"{C:attention}7{} en mano jugada",
					"{C:inactive}(Ej. {C:green}1 en #5#{C:inactive} -> {C:green}2 en #5#{C:inactive})"
				},
			},
			j_hnds_pot_of_greed = {
				name = "Olla de la Codicia",
				text = {
					"Al usar un {C:attention}consumible{},",
					"sacas {C:attention}#1#{} cartas",
				},
				unlock = {
					"Usa {C:attention}4{} consumibles",
					"durante una {C:attention}Ciega{}",
				},
			},
			j_hnds_seismic_activity = {
				name = "Actividad Sísmica",
				text = {
					"Reactiva las",
					"{C:attention}Cartas de Piedra{}",
				},
			},
			j_hnds_stone_mask = {
				name = "Máscara de Piedra",
				text = {
					"Cuando robas una",
					"{C:attention}Carta de Piedra{}, obtiene una",
					"{C:dark_edition}Edición{} y un {C:attention}Sello{} aleatorios",
					"hasta el final de la ronda",
				},
				unlock = {
					"Alcanza {X:mult,C:white}X5{} Multi",
					"con {C:attention}Vampiro{}",
				}
			},
			j_hnds_jokestone = {
				name = "Jokestone",
				text = {
					"Al iniciar la ronda,",
					"sacas hasta {C:attention}3{}",
					"cartas mejoradas",
				},
				unlock = {
					"Juega una mano con",
					"{C:attention}3{} mejoras diferentes",
				},
			},
			j_hnds_meme = {
				name = "Comodín Meme",
				text = {
					"Gana {X:mult,C:white}X0.05{} Multi por",
					"cada {C:attention}palo{} diferente",
					"en la mano jugada",
					"{C:inactive}(Actualmente {X:mult,C:white}X#1#{C:inactive} Multi)",
				},
			},
			j_hnds_balloons = {
				name = "Globos",
				text = {
					"Al derrotar una {C:attention}Ciega{} en",
					"{C:attention}una mano{}, {C:red}revienta{} un {C:attention}Globo{}",
					"y crea una {C:attention}Etiqueta{} al azar",
					"{C:inactive}({C:attention}#1#{C:inactive}/#2# Globos restantes)",
				},
			},
			j_hnds_jokes_aside = {
				name = "Fuera de broma",
				text = {
					'Gana {X:mult,C:white}X#2#{} Multi por',
					'cada {C:attention}Comodín{} vendido',
					"durante una {C:attention}Ciega{}",
					"{C:inactive}(Actualmente {X:mult,C:white}X#1#{C:inactive} Multi)",
				},
			},
			j_hnds_ms_fortune = {
				name = "Ms. Fortune",
				text = {
					"Cuadriplica todas las",
					"{C:green,E:1}probabilidades{}, te",
					"quedas en {C:red}$0{} al",
					"seleccionar una {C:attention}Ciega{}",
					"{C:inactive}(Ej. {}{C:green}1 en 3{} {C:inactive}->{} {C:green}#1# en 3{}{C:inactive}){}",
				},
			},
			j_hnds_dark_humor = {
				name = "Humor Negro",
				text = {
					"Al jugar una {C:blue}mano{}, una",
					'carta en {C:attention}mano{} {C:red}\"desaparece\"{}',
					"y obtienes su {C:mult}Multi{} y {C:chips}Fichas{}",
					"{C:inactive}(Actualmente{} {C:mult}+#2#{} {C:inactive}Multi y{} {C:chips}+#1#{} {C:inactive}Fichas){}",
				},
			},
			j_hnds_krusty = {
				name = "Krusty el Payaso",
				text = {
					"Vende esta carta para crear {C:attention}#1#",
					"{C:attention}#2#{} {C:inactive}(Máximo #3#)",
					"Mejora por cada",
					"{C:money}$#4#{} {C:inactive}[#5#]{} gastados",
				}
			},
			j_hnds_energized = {
				name = "Corrientazo",
				text = {
					"Si tu mano es {C:attention}1{} sola carta,",
					"se reactiva {C:attention}#3#{} veces y tiene",
					"una prob. de {C:green}#1# en #2#{} de {C:red}destruirse{}",
				},
				unlock = {
					"Destruye {C:attention}50{}",
					"cartas en total",
				}
			},
			j_hnds_pennywise = {
				name = "Pennywise",
				text = {
					"Si derrotas a la {C:attention}Ciega Jefe{}",
					"con {C:attention}una mano{}, absorbe su {C:legendary}Alma{}",
					"y crea un Comodín {C:dark_edition}Negativo{}.",
					"Reactiva todas las {C:legendary}Almas{}",
				}
			},
			j_hnds_most_wanted = {
				name = "Se Busca",
				text = {
					"{C:attention}#1#{}",
					"aparece {C:attention}#2#X{} veces más.",
					"Vende este Comodín para hacer que",
					"El Comodín Mencionado sea {C:green}gratis{}"
				}
			},
			j_hnds_clown_devil = {
				name = "Payaso Demoniaco",
				text = {
					"Al seleccionar {C:attention}Ciega{},",
					"se consume todos los",
					"{C:attention}consumibles{} crea una",
					"{C:attention}Etiqueta{} al azar",
					"cada {C:attention}#2#{} {C:inactive}({C:attention}#1#{C:inactive}/#2#) consumibles"
				}
			},
			j_hnds_jester_in_yellow = {
				name = "El Comodín de Amarillo",
				text = {
					"Al seleccionar una Ciega",
					"el Comodín del extremo izquierdo",
					"se vuelve {C:dark_edition}Negativo{} y se {C:hnds_carcosa}desvance{}",
					"{C:attention}#1#{} rondas"
				}
			},
			j_hnds_wait_what = {
				name = "¿Espera, qué?",
				text = {
					"{X:mult,C:white}X#1#{} Multi",
				}
			},
			j_hnds_excommunicado = {
				name = "Excomulgado",
				text = {
					"Todas las {C:attention}Ciegas{} son",
					"{C:attention}Ciegas Jefe{}, obtienes una",
					"{C:attention}Etiqueta{} al derrotar una {C:attention}Ciega{}"
				}
			},
			j_hnds_handsome = {
				name = "Picaro Hermoso",
				text = {
					"Reactiva todas las",
					"cartas con {C:dark_edition}Ediciones{}",
				}
			},
			j_hnds_art = {
				name = "Art el Payaso",
				text = {
					"Vende esta carta para",
					"crear una copia en el siguiente",
					"{C:attention}Paquete Potenciador{} al abrirlo",
					"y crear una {C:attention}Etiqueta{}",
				}
			},
			j_hnds_public_nuisance = {
				name = "Comodín Linchado",
				text = {
					"Puedes seguir jugando {C:blue}Manos{}",
					"después de obtener la",
					"{C:attention}Puntuación Requerida{}"
				}
			},

			j_hnds_bizzare_joker = {
				name = "Comodín Desalinado",
				text = {
					"Obtiene {X:mult,C:white} XMulti {}, {C:mult}+Multi{}, {C:chips}+Fichas{} o",
					"{C:money}Valor de Venta{} según el palo",
					"elegido que cambia cada ronda",
				},
				unlock = {
					"Tener todas las cartas de",
					"tu baraja del mismo palo",
				}
			},

			j_hnds_bizzare_joker_spades = {
				name = "El Comodín desalinado",
				text = {
					"Gana {C:chips}+#2#{} Fichas al anotar {C:spades}Espadas{}",
					"{s:0.8}Su efecto cambia cada ronda",
					"{C:inactive}(Actualmente {X:mult,C:white}X#5#{C:inactive} Multi,",
					"{C:mult}+#3#{C:inactive} Multi, {C:chips}+#1#{C:inactive} Fichas)",
				},
			},
			j_hnds_bizzare_joker_clubs = {
				name = "El Comodín desalinado",
				text = {
					"Gana {C:mult}+#4#{} Multi al anotar {C:clubs}Treboles{}",
					"{s:0.8}Su efecto cambia cada ronda",
					"{C:inactive}(Actualmente {X:mult,C:white}X#5#{C:inactive} Multi,",
					"{C:mult}+#3#{C:inactive} Multi, {C:chips}+#1#{C:inactive} Fichas)",
				},
			},
			j_hnds_bizzare_joker_diamonds = {
				name = "El Comodín desalinado",
				text = {
					"Gana {C:money}+$#7#{} valor de venta",
					"por {C:diamonds}Diamante{} jugado",
					"{s:0.8}Su efecto cambia cada ronda",
					"{C:inactive}(Actualmente {X:mult,C:white}X#5#{C:inactive} Multi,",
					"{C:mult}+#3#{C:inactive} Multi, {C:chips}+#1#{C:inactive} Fichas)",
				},
			},
			j_hnds_bizzare_joker_hearts = {
				name = "El Comodín desalinado",
				text = {
					"Gana {X:mult,C:white}X#6#{} Multi al anotar {C:hearts}Corazones{}",
					"{s:0.8}Su efecto cambia cada ronda",
					"{C:inactive}(Actualmente {X:mult,C:white}X#5#{C:inactive} Multi,",
					"{C:mult}+#3#{C:inactive} Multi, {C:chips}+#1#{C:inactive} Fichas)",
				},
			},


			j_hnds_arthur = {
				name = "Arthur",
				text = {
					"Destruye cartas {V:1}#3#{} anotadas",
					"y gana {C:attention}#2#{} {C:green}Renovación{} gratis",
					"por cada carta destruida",
					"{s:0.8}El palo cambia cada mano",
					"{C:inactive}(Actualmente {C:attention}#1#{C:inactive} Renovaciones gratis)",
				}
			},
			j_hnds_last_laugh = {
				name = "Bromita Pesada",
				text = {
					"Al venderse, saca {C:attention}#1#{}",
					"cartas de la baraja, y luego",
					"{C:red}destruye{} todas las cartas",
					"en mano",
					"{C:inactive,s:0.8}(Aumenta en{} {C:attention}1{} {C:inactive,s:0.8}cada ronda){}",
				},
				unlock = {
					"Destruye {C:attention}100{}",
					"cartas en total",
				}
			},
			j_hnds_fregoli = {
				name = "Fregoli",
				text = {
					"Copia la habilidad del",
					"último {C:attention}Comodín{} comprado",
				}
			},
			j_hnds_walking_joke = {
				name = "Chiste Andante",
				text = {
					"Reactiva los Comodines",
					"{C:blue}Comunes{} Adyacentes",
				},
				unlock = {
					"Tener solo {C:blue}Comodines Comunes{}",
					"durante una partida",
				}
			},
			j_hnds_demented = {
				name = "Comodín Demente",
				text = {
					"La primera {C:attention}mano{} de la ronda,",
					"cambia al azar las {C:attention}categorías{} y {C:attention}palos{}",
					"de todas las cartas en mano",
				}
			},
			j_hnds_angry_mob = {
				name = "Protesta Violenta",
				text = {
					"{X:mult,C:white}X#1#{} Multi,",
					"no aparecen {C:attention}Comodines{}",
					"en la {C:money}Tienda{}"
				}
			},
			j_hnds_sarmenti = {
				name = "Sarmenti",
				text = {
					"Cambia al azar las {C:dark_edition}Ediciones{}",
					"de los comodines a la derecha si",
					"la mano jugada contiene",
					"un {C:attention}Póquer{}",
				}
			},
			j_hnds_creepy = {
				name = "Comodín Perturbador",
				text = {
					"{X:mult,C:white}X#1#{} Multi",
					"prob. de {C:green}#2# en #3#{} de convertir",
					"comodines adyacentes al",
					"final de la ronda",
				}
			},
			j_hnds_one_punchline_man = {
				name = "One Punchline Man",
				text = {
					"Gana {X:mult,C:white}X0.25{} Multi por",
					"cada {C:blue}mano{} que no usaste",
					"al final de la ronda",
					"{C:inactive}(Actualmente {X:mult,C:white}X#1#{C:inactive} Multi)",
				},
			},
			j_hnds_jigsaw_joker = {
				name = "Comodín Jigsaw",
				text = {
					"Tras jugar {C:attention}8{} manos",
					"de póquer {C:attention}únicas{}, vende esta",
					"carta para subir {C:attention}#3#{} niveles",
					"todas las {C:attention}manos de póquer{}",
				},
			},
			j_hnds_dynamic_duos = {
				name = "Dúo Dinámico",
				text = {
					"Si juegas un {C:attention}Doble Par{} de",
					"cartas de {C:attention}pares{} e {C:attention}impares{},",
					"reactiva las cartas",
				},
			},
			j_hnds_imposter = {
				name = "Impostor",
				text = {
					"Las cartas de {C:attention}figura{} actúan",
					"como cartas enumeradas",
					"para efectos de Comodines",
				},
			},
			j_hnds_contagion = {
				name = "Contagio",
				text = {
					"Los {C:attention}Consumibles{} permiten",
					"seleccionar {C:attention}1{} carta extra",
					"{C:inactive,s:0.8}(ej: Mejora {C:attention,s:0.8}2{} {C:inactive,s:0.8}cartas",
					"{C:inactive,s:0.8}seleccionadas -> {C:attention,s:0.8}3{} {C:inactive,s:0.8}cartas)",
				},
			},

			j_hnds_jack_in_the_box = {
				name = "Jack-in-the-box",
				text = {
					"Every other round",
					"gains an ability of a",
					"random {C:attention}Rare Joker{}",
					"{C:inactive}(Currently {C:attention}#1#{C:inactive}){}",
				},
			},
			j_hnds_be_not_afraid = {
				name = "Be not Afraid",
				text = {
					"If played hand contains",
					"a {C:attention}Three of a Kind{}, every",
					"scoring card permanently gains",
					"{C:mult}+#1#{} Mult before scoring",
				},
			},
			j_hnds_jodiac = {
				name = "Jodiac",
				text = {
					"Gains {C:mult}+#1#{} Mult per",
					"card with {C:attention}unique rank{}",
					"you score, reset scored",
					"ranks at end of {C:attention}Ante{}",
					"{C:inactive}(Currently {C:mult}+#2#{C:inactive} Mult){}",
				},
			},
},
		Back = {
			b_hnds_premiumdeck = {
				name = "Baraja Premium",
				text = {
					"Comienzas con los vales",
					"{C:green,T:v_hnds_premium}Premium{} y {C:red,T:v_hnds_top_shelf}Exclusividad{}",
					"Los comodines cuestan {C:money}dinero{}",
					"adicional igual a tu {C:attention}Apuesta{}",
				},
			},
			b_hnds_crystal = {
				name = "Baraja Cristalina",
				text = {
					"En la Apuesta {C:attention}4{},",
					"enfrentas una {C:attention}Ciega Final{}",
					"si ganas obtienes",
					"{C:legendary,T:p_hnds_spectral_ultra}Ultra Paquete Espectral{}",
				}
			},
			b_hnds_conjuring = {
				name = "Baraja Conjuradora",
				text = {
					"La {C:money}Tienda{} reemplaza",
					"los {C:attention}Paquetes Potenciadores{}",
					"por {C:attention,T:p_hnds_magic_1}Paquetes Mágicos{}",
					"que contienen {C:dark_edition,E:1}cartas al azar{}",
				}
			},
			b_hnds_circus = {
				name = "Baraja de Circo",
				text = {
					"Tiene la habilidad de",
					"un {C:attention}Comodín{} al azar",
					"cambia de comodín después",
					"de cada {C:attention}Ciega{}",
					"{C:inactive}(Actualmente: {V:1}#1#{C:inactive})",
				}
			},
			b_hnds_ol_reliable = {
				name = "Baraja de la Suerte",
				text = {
					"Triplica las {C:green}probabilidades{}",
					"en la {C:money}Tienda{} y durante",
					"la {C:attention}Ciega Jefe{}",
					"{C:inactive}(Ej. {C:green}1 en 3{C:inactive} -> {C:green}3 en 3){C:inactive}",
				}
			},
			b_hnds_cursed = {
				name = "Baraja Maldita",
				text = {
					"Derrota la {C:attention}primera",
					"{C:attention}Ciega Jefe{} para abrir un",
					"{C:red,T:p_hnds_cursed_pack}Paquete Maldito Inevitable{}",
				}
			},
		},
		Sleeve = {
			sleeve_hnds_premium_sleeve = {
				name = "Funda Premium",
				text = {
					"Comienzas con los vales",
					"{C:green,T:v_hnds_premium}Premium{} y {C:red,T:v_hnds_top_shelf}Exclusividad{}",
					"Los comodines cuestan {C:money}dinero{}",
					"adicional igual a tu {C:attention}Apuesta{}",
				},
			},
			sleeve_hnds_premium_sleeve_alt = {
				name = "Funda Premium",
				text = {
					"{C:blue}Comodines Comunes{} aparecen",
					"con {C:blue}X#3#{} menos frecuencia",
				}
			},
			sleeve_hnds_circus_sleeve = {
				name = "Funda de Circo",
				text = {
					"Tiene la habilidad de",
					"un {C:attention}Comodín{} al azar",
					"cambia de comodín después",
					"de cada {C:attention}Ciega{}",
					"{C:inactive}(Actualmente: {V:1}#1#{C:inactive})",
				}
			},
			sleeve_hnds_circus_sleeve_alt = {
				name = "Funda de Circo",
				text = {
					"Crea una {C:dark_edition}Copia{} del",
					"primer {C:attention}Comodín{} elegido después de",
					"derrotar la primer {C:attention}Ciega Jefe{}",
				}
			},
			sleeve_hnds_cursed_sleeve = {
				name = "Funda Maldita",
				text = {
					"Derrota la {C:attention}primera",
					"{C:attention}Ciega Jefe{} para abrir un",
					"{C:red,T:p_hnds_cursed_pack}Paquete Maldito Inevitable{}",
				}
			},
			sleeve_hnds_cursed_sleeve_alt = {
				name = "Funda Maldita",
				text = {
					"El primer {C:red,T:p_hnds_cursed_pack}Paquete Maldito{}",
					"abierto solo ofrece {C:red}Comodines Raros{}"
				}
			},
			sleeve_hnds_crystal_sleeve = {
				name = "Funda Cristalina",
				text = {
					"En la Apuesta {C:attention}4{},",
					"enfrentas una {C:attention}Ciega Final{}",
					"si ganas, obtienes",
					"{C:legendary,T:p_hnds_spectral_ultra}Ultra Paquete Espectral{}",
				}
			},
			sleeve_hnds_crystal_sleeve_alt = {
				name = "Funda Cristalina",
				text = {
					"También enfrentas una Ciega Final",
					"en las Apuestas {C:attention}2{} y {C:attention}6{}",
					"Derrotalas para obtener un",
					"{C:legendary,T:p_hnds_spectral_ultra}Ultra Paquete Espectral{}",
				}
			},
			sleeve_hnds_conjuring_sleeve = {
				name = "Funda de Conjuradora",
				text = {
					"La {C:money}Tienda{} reemplaza",
					"los {C:attention}Paquetes Potenciadores{}",
					"por {C:attention,T:p_hnds_magic_1}Paquetes Mágicos{}",
					"que contienen {C:dark_edition,E:1}cartas al azar{}",
				}
			},
			sleeve_hnds_conjuring_sleeve_alt = {
				name = "Funda de Conjuradora",
				text = {
					"Comienzas con {C:attention,T:v_stuffed}Paquetes Amplios{}",
					"y {C:attention,T:v_wholesale}Mayorista de Paquetes{}"
				}
			},
			sleeve_hnds_ol_sleeve = {
				name = "Funda de la Suerte",
				text = {
					"Triplica las {C:green}probabilidades{}",
					"en la {C:money}Tienda{} y durante",
					"la {C:attention}Ciega Jefe{}",
					"{C:inactive}(Ej. {C:green}1 en 3{C:inactive} -> {C:green}3 en 3){C:inactive}",
				}
			},
			sleeve_hnds_ol_sleeve_alt = {
				name = "Funda de la Suerte",
				text = {
					"Duplica las {C:green}probabilidades{} y las",
					"{C:attention,E:1}Cuadriplica{} en la {C:money}Tienda{} y",
					"durante la {C:attention}Ciega Jefe{}",
					"{C:inactive}(Ej. {C:green}1 en 3{C:inactive} -> {C:green}4 en 3){C:inactive}",
				}
			},
		},
		Spectral = {
			c_hnds_contagion_talisman = {
				name = "Talismán",
				text = {
                    "Otorga un {C:attention}sello de oro{}",
                    "a {C:attention}#1#{} cartas seleccionadas",
				},
			},
			c_hnds_contagion_deja_vu = {
				name = "Déjà vu",
				text = {
                    "Otorga un {C:red}sello rojo{}",
                    "a {C:attention}#1#{} cartas seleccionadas",
				},
			},
			c_hnds_contagion_trance = {
				name = "Trance",
				text = {
                    "Otorga un {C:blue}sello azul{}",
                    "a {C:attention}#1#{} cartas seleccionadas",
				},
			},
			c_hnds_contagion_medium = {
				name = "Médium",
				text = {
                    "Otorga un {C:purple}sello morado{}",
                    "a {C:attention}#1#{} cartas seleccionadas",
				},
			},
			c_hnds_contagion_aura = {
				name = "Aura",
				text = {
                    "Otorga edición {C:dark_edition}laminada{}, {C:dark_edition}holográfica{}",
                    "o {C:dark_edition}polícroma{} a",
                    "{C:attention}#1#{} cartas seleccionadas de tu mano",
				},
			},
			c_hnds_contagion_cryptid = {
				name = "Críptido",
				text = {
                    "Crea {C:attention}#1#{} copias de",
                    "{C:attention}#2#{} cartas seleccionadas",
                    "en tu mano",
				},
			},
			c_hnds_exchange_contagion = {
				name = "Intercambio",
				text = {
					"Otorga edición {C:dark_edition}Negativa{}",
					"a {C:attention}#1#{} cartas seleccionadas,",
					"y pierdes {C:blue}#2#{} mano",
				},
			},
			c_hnds_abyss = {
				name = "Abismo",
				text = {
					"Otorga un {C:dark_edition}Sello negro{}",
					"a {C:attention}#1#{} carta seleccionada",
				},
			},
			c_hnds_cycle = {
				name = "Ciclo",
				text = {
					"Transforma todos tus {C:attention}Comodines{}",
					"en otros de la misma {C:attention}rareza{}",
				},
			},
			c_hnds_petrify = {
				name = "Petrificación",
				text = {
					"Convierte las cartas de {C:attention}figura{}",
					"en {C:attention}piedra{} y ganas {C:money}$#1#{}",
					"por carta petrificada",
				},
			},
			c_hnds_exchange = {
				name = "Intercambio",
				text = {
					"Otorga edición {C:dark_edition}Negativa{}",
					"a {C:attention}#1#{} carta seleccionada,",
					"y pierdes {C:blue}#2#{} mano",
				},
			},
			c_hnds_possess = {
				name = "Poseción",
				text = {
					"Otorga un {C:spectral}Sello Espectral{}",
					"a {C:attention}#1#{} carta seleccionada",
				},
			},
			c_hnds_dream = {
				name = "Sueño",
				text = {
					"Crea {C:attention}10{} {E:1,C:legendary}Etiquetas{}",
					"{E:1,C:legendary}de Comodines{}",
				},
			},
			c_hnds_collision = {
				name = "Colisión",
				text = {
					"Mejora {C:attention}#1#{} cartas",
					"a {C:dark_edition}#2#s",
				},
			},
			c_hnds_gateway = {
				name = "Umbral",
				text = {
					"Mejora {C:attention}#1#{} cartas",
					"a {C:dark_edition}#2#s",
				},
			},
			c_hnds_spectrum = {
				name = "Espectro",
				text = {
					"Otorga una {C:attention}Mejora{}",
					"y {C:attention}Sello{} a las",
					"cartas en mano",
					"{s:0.8,C:inactive}(Multi y Adicionales Escluidas){}"
				}
			}
		},

		Edition = {
			e_hnds_vintage = {
				name = "Vintage",
				text = {
					"Ganas un {C:money}$1{} adicional",
					"por cada {C:money}$1{} de {C:attention}interés{}",
					"al final de la ronda",
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
			hnds_jester_temp_negative = {
				name = "Elegido por Carcosa",
				text = {
					"Este Comodín se desvanece en",
					"{C:attention}#1#{} rondas",
				},
			},
			hnds_black_seal = {
				name = "Sello Negro",
				text = {
					"Al estar en mano,",
					"se considera que",
					"está {C:attention}anotando{}",
				},
			},
			hnds_spectralseal_seal = {
				name = "Sello Espectral",
				text = {
					"Crea una carta {C:spectral}Espectral{}",
					"cada {C:attention}#1#{} {C:inactive}[#2#]{} manos de",
					"póker {C:attention}únicas{} que esta carta jugó",
					"{C:inactive}(Debe haber espacio){}",
				}
			},
			hnds_spectralseal_progress_empty = {
				name = "Manos de Póker Anotadas",
				text = {
					"Actualmente: {C:attention}#1#{}",
					"{C:inactive}(#2#/#3# manos únicas){}",
				},
			},
			hnds_spectralseal_progress_1 = {
				name = "Manos de Póker Anotadas",
				text = {
					"{C:attention}#1#{}",
					"{C:inactive}(#2#/#3# manos únicas){}",
				},
			},
			hnds_spectralseal_progress_2 = {
				name = "Manos de Póker Anotadas",
				text = {
					"{C:attention}#1#{}",
					"{C:attention}#2#{}",
					"{C:inactive}(#3#/#4# manos únicas){}",
				},
			},
			hnds_spectralseal_progress_3 = {
				name = "Manos de Póker Anotadas",
				text = {
					"{C:attention}#1#{}",
					"{C:attention}#2#{}",
					"{C:attention}#3#{}",
					"{C:inactive}(#4#/#5# manos únicas){}",
				},
			},
			hnds_spectralseal_progress_4 = {
				name = "Manos de Póker Anotadas",
				text = {
					"{C:attention}#1#{}",
					"{C:attention}#2#{}",
					"{C:attention}#3#{}",
					"{C:attention}#4#{}",
					"{C:inactive}(#5#/#6# manos únicas){}",
				},
			},
			p_hnds_spectral_ultra = {
				name = "Paquete Ultra Espectral",
				text = {
					"Escoge {C:attention}#2#{} de hasta",
					"{C:attention}#1#{} cartas {C:spectral}Espectrales{}",
					"para usar inmediatamente.",
					"Contiene al menos un",
					"{E:1,C:legendary}Consumible secreto{}"
				}
			},
			hnds_joker_tag_example = {
				name = "Etiquetas de Comodín",
				text = {
					"{C:dark_edition}Laminada{}, {C:dark_edition}Holográfica{},",
					"{C:dark_edition}Policroma{}, {C:dark_edition}Negativa{},",
					"{C:dark_edition}Vintage{}, {C:green}Inusual{}, {C:red}Rara{},",
					"{C:attention}Bufón{}, {C:red}Maldito{} y más",
				}
			},
			hnds_soul = {
				name = "Alma",
				text = { "Creado por {C:legendary,E:1}Pennywise" }
			},
			p_hnds_magic = {
				name = "Paquete Mágico",
				text = {
					"Escoge {C:attention}#2#{} de hasta",
					"{C:attention}#1#{} cartas {C:dark_edition,E:1}al azar{}",
					"para usar o añadir",
					"a tu baraja",
				}
			},
			p_hnds_magic_1 = {
				name = "Paquete Mágico",
				text = {
					"Escoge {C:attention}#2#{} de hasta",
					"{C:attention}#1#{} cartas {C:dark_edition,E:1}al azar{}",
					"para usar o añadir",
					"a tu baraja",
				}
			},
			p_hnds_cursed_pack = {
				name = "Paquete Maldito",
				text = {
					"Escoge {C:attention}#1#{} de hasta {C:attention}#2#{},",
					"Comodines {C:red}Malditos{}"
				}
			},
			hnds_cursed_offer_title = {
				text = {
					"Obtienes una {C:green}Oferta{}:",
				},
			},
			hnds_cursed_price_title = {
				text = {
					"por un {C:red}Precio{}:",
				},
			},
			hnds_cursed = {
				name = "Maldito",
				text = {
					"Obtienes una {C:green}Oferta{}:",
					"{C:inactive}({C:green}sin oferta{C:inactive}){}",
					"a cambio de un {C:red}Precio{}:",
					"{C:inactive}({C:red}sin precio{C:inactive}){}",
				}
			},
			offer_copy_random_tarot = {
				text = {
					"Crea una carta del",
					"{C:tarot}Tarot{} al final",
					"de la {C:attention}ronda{}",
				},
			},
			offer_copy_random_planet = {
				text = {
					"Crea {C:attention}2{} cartas de",
					"{C:planet}Planeta{} al final",
					"de la {C:attention}ronda{}",
				},
			},
			offer_random_enhancement = {
				text = {
					"Otorga {C:attention}Mejoras{}",
					"al azar a",
					"{C:attention}8{} cartas",
				},
			},
			offer_self_negative = {
				text = {
					"Este {C:attention}Comodín{}",
					"se vuelve {C:dark_edition}Negativo{}",
				},
			},
			offer_retrigger = {
				text = {
					"{C:attention}Reactiva{}",
					"este Comodín",
				},
			},
			offer_interest_cap = {
				text = {
					"Crea una carta {C:spectral}Espectral{}",
					"en cada {C:attention}Ante{}",
				},
			},
			offer_free_rerolls = {
				text = {
					"Ganas 2 {C:green}renovaciones{}",
					"gratis en la tienda",
				},
			},
			offer_joker_copy = {
				text = {
					"Crea una {C:attention}copia{}",
					"de este {C:attention}Comodín{}",
				},
			},
			price_destroy_jokers = {
				text = {
					"{C:red,E:2}Destruye{} todos",
					"tus {C:attention}Comodines{}",
				},
			},
			price_destroy_cards = {
				text = {
					"{C:red}Destruye{} 8 cartas",
					"de tu baraja",
				},
			},
			price_bankrupt = {
				text = {
					"Te quedas sin {C:money}dinero{}",
				},
			},
			price_inflation = {
				text = {
					"Aumenta {C:money}precios{} de las {C:attention}Cartas{}",
					"y {C:attention}Paquetes Potenciadores{}",
					"en un {C:red}25%{}",
				},
			},
			price_lose_hand = {
				text = {
					"Pierdes permanentemente {C:attention}1{}",
					"{C:blue}Mano{}",
				},
			},
			price_lose_discard = {
				text = {
					"Pierdes permanentemente {C:attention}1{}",
					"{C:red}Descarte{}",
				},
			},
			price_lose_hand_size = {
				text = {
					"-1 al {C:attention}tamaño de mano{}",
					"permanentemente",
				},
			},
			price_ante_scaling = {
				text = {
					"Aumenta en {C:red}X1.50{} la",
					"{C:attention}puntuación requerida{}",
				},
			},
			dna_tag_tooltip_singular = {
				name = "Etiqueta de ADN",
				text = {
					"Al comprar un comodín,",
					"creas {C:attention}1{} copia adicional",
					"{C:inactive}(Debe haber espacio){}",
				}
			},
			dna_tag_tooltip_plural = {
				name = "Etiqueta de ADN",
				text = {
					"Al comprar un comodín,",
					"creas {C:attention}#1#{} copias adicionales",
					"{C:inactive}(Debe haber espacio){}",
				}
			},
			hnds_platinum_sticker = {
				name = "Sticker de Platino",
				text = {
                    "Usaste este comodín para",
                    "ganar el Pozo de {C:attention}Platino{}",
				}
			},
			hnds_blood_stake_sticker = {
				name = "Sticker de Sangre",
				text = {
					"Usaste este comodín para",
					"ganar el Pozo de {C:attention}Sangre{}",
				}
			},

            hnds_jodiac_ranks_empty = {
                name = "Scored Ranks",
                text = { "No ranks scored this Ante" },
            },
            hnds_jodiac_ranks_1 = {
                name = "Scored Ranks",
                text = {
                    "{C:attention}#1#{}",
                },
            },
            hnds_jodiac_ranks_2 = {
                name = "Scored Ranks",
                text = {
                    "{C:attention}#1#{}",
                    "{C:attention}#2#{}",
                },
            },
            hnds_jodiac_ranks_3 = {
                name = "Scored Ranks",
                text = {
                    "{C:attention}#1#{}",
                    "{C:attention}#2#{}",
                    "{C:attention}#3#{}",
                },
            },
            hnds_jodiac_ranks_4 = {
                name = "Scored Ranks",
                text = {
                    "{C:attention}#1#{}",
                    "{C:attention}#2#{}",
                    "{C:attention}#3#{}",
                    "{C:attention}#4#{}",
                },
            },
            hnds_jodiac_ranks_5 = {
                name = "Scored Ranks",
                text = {
                    "{C:attention}#1#{}",
                    "{C:attention}#2#{}",
                    "{C:attention}#3#{}",
                    "{C:attention}#4#{}",
                    "{C:attention}#5#{}",
                },
            },
            hnds_jodiac_ranks_6 = {
                name = "Scored Ranks",
                text = {
                    "{C:attention}#1#{}",
                    "{C:attention}#2#{}",
                    "{C:attention}#3#{}",
                    "{C:attention}#4#{}",
                    "{C:attention}#5#{}",
                    "{C:attention}#6#{}",
                },
            },
            hnds_jodiac_ranks_7 = {
                name = "Scored Ranks",
                text = {
                    "{C:attention}#1#{}",
                    "{C:attention}#2#{}",
                    "{C:attention}#3#{}",
                    "{C:attention}#4#{}",
                    "{C:attention}#5#{}",
                    "{C:attention}#6#{}",
                    "{C:attention}#7#{}",
                },
            },
            hnds_jodiac_ranks_8 = {
                name = "Scored Ranks",
                text = {
                    "{C:attention}#1#{}",
                    "{C:attention}#2#{}",
                    "{C:attention}#3#{}",
                    "{C:attention}#4#{}",
                    "{C:attention}#5#{}",
                    "{C:attention}#6#{}",
                    "{C:attention}#7#{}",
                    "{C:attention}#8#{}",
                },
            },
            hnds_jodiac_ranks_9 = {
                name = "Scored Ranks",
                text = {
                    "{C:attention}#1#{}",
                    "{C:attention}#2#{}",
                    "{C:attention}#3#{}",
                    "{C:attention}#4#{}",
                    "{C:attention}#5#{}",
                    "{C:attention}#6#{}",
                    "{C:attention}#7#{}",
                    "{C:attention}#8#{}",
                    "{C:attention}#9#{}",
                },
            },
            hnds_jodiac_ranks_10 = {
                name = "Scored Ranks",
                text = {
                    "{C:attention}#1#{}",
                    "{C:attention}#2#{}",
                    "{C:attention}#3#{}",
                    "{C:attention}#4#{}",
                    "{C:attention}#5#{}",
                    "{C:attention}#6#{}",
                    "{C:attention}#7#{}",
                    "{C:attention}#8#{}",
                    "{C:attention}#9#{}",
                    "{C:attention}#10#{}",
                },
            },
            hnds_jodiac_ranks_11 = {
                name = "Scored Ranks",
                text = {
                    "{C:attention}#1#{}",
                    "{C:attention}#2#{}",
                    "{C:attention}#3#{}",
                    "{C:attention}#4#{}",
                    "{C:attention}#5#{}",
                    "{C:attention}#6#{}",
                    "{C:attention}#7#{}",
                    "{C:attention}#8#{}",
                    "{C:attention}#9#{}",
                    "{C:attention}#10#{}",
                    "{C:attention}#11#{}",
                },
            },
            hnds_jodiac_ranks_12 = {
                name = "Scored Ranks",
                text = {
                    "{C:attention}#1#{}",
                    "{C:attention}#2#{}",
                    "{C:attention}#3#{}",
                    "{C:attention}#4#{}",
                    "{C:attention}#5#{}",
                    "{C:attention}#6#{}",
                    "{C:attention}#7#{}",
                    "{C:attention}#8#{}",
                    "{C:attention}#9#{}",
                    "{C:attention}#10#{}",
                    "{C:attention}#11#{}",
                    "{C:attention}#12#{}",
                },
            },
            hnds_jodiac_ranks_13 = {
                name = "Scored Ranks",
                text = {
                    "{C:attention}#1#{}",
                    "{C:attention}#2#{}",
                    "{C:attention}#3#{}",
                    "{C:attention}#4#{}",
                    "{C:attention}#5#{}",
                    "{C:attention}#6#{}",
                    "{C:attention}#7#{}",
                    "{C:attention}#8#{}",
                    "{C:attention}#9#{}",
                    "{C:attention}#10#{}",
                    "{C:attention}#11#{}",
                    "{C:attention}#12#{}",
                    "{C:attention}#13#{}",
                },
            },
},
		Voucher = {
			v_hnds_tag_hunter = {
				name = "Cazaetiquetas",
				text = {
					"Ganas una {C:attention}Etiqueta{}",
					"al derrotar la {C:attention}Ciega Jefe{}",
				},
			},
			v_hnds_hashtag_skip = {
				name = "#2#skip",
				text = {
					"Retrocedes {C:attention}1{} Apuesta",
					"cada {C:attention}#1#{} ciegas omitidas",
				},
			},
			v_hnds_premium = {
				name = "Premium",
				text = {
					"Los Comodines {C:uncommon}Inusuales{}",
					"aparecen con {C:attention}X#1#{}",
					"más frecuencia",
				},
			},
			v_hnds_top_shelf = {
				name = "Exclusividad",
				text = {
					"Los Comodines {C:rare}Raros{}",
					"aparecen con {C:attention}X#1#{}",
					"más frecuencia",
				},
			},
			v_hnds_stuffed = {
				name = "Paquetes Amplios",
				text = {
					"Hay {C:attention}1{} carta adicional",
					"en todos los {C:attention}Paquetes{}",
					"{C:attention}Potenciadores{}",
				},
			},
			v_hnds_wholesale = {
				name = "Mayorista de Paquetes",
				text = {
					"Agrega {C:attention}1{} {C:attention}Paquete{}",
					"{C:attention}Potenciador{} a las tiendas",
				},
			},
			v_hnds_soaked = {
				name = "Empapado",
				text = {
					"La carta del extremo izquierdo",
					"que tengas en {C:attention}mano{}",
					"cuenta en la {C:blue}mano{} jugada"
				}
			},
			v_hnds_beyond = {
				name = "Jabonoso",
				text = {
					"La carta del extremo derecho",
					"que tengas en {C:attention}mano{}",
					"cuenta en la {C:blue}mano{} jugada"
				}
			}
		},
		Planet = {
			c_hnds_makemake = {
				name = "Makemake",
				text = {
					"{S:0.8}({S:0.8,V:1}lvl.#1#{S:0.8}){} Aumento de nivel",
					"{C:attention}#2#",
					"{C:chips}+#3#{} Fichas, más {C:chips}+#4#{}",
					"por carta de {C:attention}Piedra{}",
					"anotada esta apuesta {C:inactive}[#5#]",
				},
			},
		},
		Enhanced = {
			m_hnds_aberrant = {
				name = "Carta Aberrante",
				text = {
					"Puede fusionarse con {C:attention}2{}",
					"Mejoras adicionales",
					"La {C:red}3.ª destruye la carta{}",
					"{C:inactive}#1#{}",
				},
			},
			m_hnds_aberrant_collection = {
				name = "Carta Aberrante",
				text = {
					"Puede fusionarse con {C:attention}2{}",
					"Mejoras adicionales",
					"La {C:red}3.ª destruye la carta{}",
				},
			},
			m_hnds_obsidian = {
				name = "Carta de Obsidiana",
				text = {
					"Sacas {C:attention}2{} cartas después",
					"de que esta sea {C:blue}jugada{}",
					"o {C:red}descartada{}"
				},
			},
		},
		Tag = {
			tag_hnds_vintage_tag = {
				name = "Etiqueta Vintage",
				text = {
					"El siguiente comodín de la tienda",
					"es gratis y se vuelve",
					"{C:dark_edition}Vintage{}"
				}
			},
			tag_hnds_mystery_tag = {
				name = "Etiqueta Misteriosa",
				text = {
					"Crea {C:attention}2{} {C:attention}Etiquetas{}",
				}
			},
			tag_hnds_magic_tag = {
				name = "Etiqueta Mágica",
				text = {
					"Ganas un",
					"{C:dark_edition,E:1}Paquete Mágico{}",
				},
			},
			tag_hnds_dna_tag = {
				name = "Etiqueta de ADN",
				text = {
					"El siguiente comodín de la tienda",
					"es gratis y es {C:attention}duplicado{}",
					"cuando lo obtienes",
					"{C:inactive}(Debe haber espacio){}",
				},
			},
			tag_hnds_cursed_tag = {
				name = "Etiqueta Maldita",
				text = {
					"Abres de inmediato un",
					"{C:red}Paquete Maldito{} \"gratis\"",
				},
			},
			tag_hnds_extinction_tag = {
				name = "Etiqueta de Extinción",
				text = {
					"Transforma todos tus {C:attention}Comodines{}",
					"en otros de la misma {C:attention}rareza{}",
				},
			},
		},
		Stake = {
			stake_blue = {
				name = "Blue Stake",
				text = {
					"Level 1 poker hands and",
					"their respective {C:planet}Planet{} cards",
					"give less {C:mult}Mult{} and {C:chips}Chips{}",
					"{s:0.8}Applies all previous Stakes",
				},
			},
			stake_hnds_platinum = {
				name = "Pozo de Platino",
				text = {
					"Debes alcanzar la Apuesta {C:attention}10{} para ganar.",
					"Puedes mejorar las {C:attention}Ciegas{} a {C:attention,E:1}Ciegas Jefe{}",
					"para obtener una etiqueta de omisión",
					"{s:0.8}Aplica todos los pozos anteriores{}",
				}
			},
			stake_hnds_blood_stake = {
				name = "Pozo de Sangre",
				text = {
					"La Tienda puede tener Comodines {C:red}Malditos{}",
					"Ignorarlos convierte la siguiente {C:attention}Ciega{}",
					"en una {C:attention,E:1}Ciegas Jefe{}",
					"{s:0.8}Aplica todos los pozos anteriores{}",
				},
				unlock = {
					"Gana con esta",
					"baraja en el Pozo de Platino",
				}
			}
		},
		Blind = {
			bl_hnds_blind_devil = {
				name = "El Diablo",
				text = {
					"Invoca a:",
					"#1#, #2#, #3#",
				},
			},
			bl_hnds_forbidden_fruit = {
				name = "Fruta Prohibida",
				text = {
					"Debilita 6 cartas por cada",
					"Etiqueta usada en esta partida",
				},
			},
			bl_hnds_perilous_pact = {
				name = "Pacto Aletargante",
				text = {
					"Limita cada mano al",
					"50% de la puntuación requerida",
				},
			},
			bl_hnds_sinful_soul = {
				name = "Alma Pecadora",
				text = {
					"+20% tamaño de Ciega por cada",
					"{C:money}$1{} de valor de venta",
					"de tus Comodines",
				},
			},
			bl_hnds_wasted_wish = {
				name = "Deseo Desperdiciado",
				text = {
					"Los Vales están",
					"deshabilitados esta Apuesta",
				},
			},
		}
	},
	misc = {
		dictionary = {
			k_hnds_krusty_voucher_tag = "Etiqueta de Vale",
			k_hnds_krusty_voucher_tags = "Etiquetas de Vale",
			hnds_upgrade_blind = "Mejorar Ciega",
			k_hnds_petrified = "¡Petrificado!",
			k_hnds_goldfish = "¡Pez Dorado!",
			k_hnds_jevil_chaos = "Chaos! Chaos!",
			k_hnds_jester_negative = "¡Comodín Negativo!",
			k_hnds_jester_fade = "¡Negativo Desvanecido!",
			k_hnds_clown_eat = "¡Consumido!",
			k_hnds_cursed_offers = "Ofertas Malditas",
			k_hnds_cursed_prices = "Precios Malditos",
			k_hnds_boom_timer = "!!!",
			k_hnds_boom = "¡EXPLOTAAA!",
			k_hnds_green = "¡Sacas!",
			k_hnds_jackpot = "¡Jackpot!",
			k_hnds_probinc = "¡Aumentado!",
			k_hnds_coffee = "¡Frío!",
			k_hnds_seismic = "¡Sismo!",
			k_hnds_awaken = "¡Despierto!",
			k_hnds_IPLAYPOTOFGREED = "¡YO JUEGO!...",
			k_hnds_extint = "¡Extinto!",
			k_hnds_balloons = "¡Sin Globos!",
			k_hnds_banana_split = "¡Split!",
			k_hnds_color_of_madness = "¡Locura!",
			k_hnds_occultist = "¡Estudio!",
			k_hnds_splashed = "¡Salpicado!",
			hnds_plus_q = "+1 ???",
			k_hnds_plus_tag = "+Etiqueta",
			k_hnds_wanted = "[Nombre del comodín]",
			k_hnds_magic_pack = "Paquete Mágico",
			k_hnds_cursed_pack = "Paquete Maldito",
			hnds_cursed_pack = "Paquete Maldito",
			k_hnds_sarmenti_active = "Activo",
			k_hnds_sarmenti_inactive = "Inactivo",
			k_hnds_sarmenti_enhanced = "¡Mejorado!",
			k_hnds_free_reroll = "+1 Renovación gratis",
			k_hnds_enhancements = "Mejoras",
			k_hnds_creepy_1 = "Fue la Planta...",
			k_hnds_creepy_2 = "...nos arrastró",
			k_hnds_creepy_3 = "al abismo...",
			k_hnds_creepy_4 = "ahora sólo...",
			k_hnds_creepy_5 = "...nos queda rezar",
			k_hnds_creepy_6 = "volver a ver...",
			k_hnds_creepy_7 = "al Barón...",
			k_hnds_creepy_8 = "...que nos tracionó",

			hnds_devil_name_default = "El Diablo",
			hnds_devil_name_legion = "La Legión",
			hnds_devil_name_old_nick = "Él",
			hnds_devil_name_deceiver = "El Embustero",
			hnds_devil_name_tempter = "El Tentador",
			hnds_devil_name_adversary = "El Adversario",
			hnds_devil_name_prince_of_darkness = "El Princípe de la Oscuridad",
			hnds_devil_name_belial = "Belial",
			hnds_devil_name_apollyon = "Apollyon",
			hnds_devil_name_lucifer = "Lucifer",
			hnds_devil_name_abaddon = "Abaddon",
			hnds_devil_name_leviathan = "Levitán",

			hnds_require_restart = "Requiere reiniciar",
			hnds_config_StoneOcean = "Habilitar mano de Stone Ocean",
			hnds_config_vintage = "Habilitar edición Vintage",
			hnds_config_UltraSpec = "Habilitar paquetes Ultra Espectrales",
			hnds_config_MagicPack = "Habilitar paquetes Mágicos",
			hnds_config_CursedPack = "Habilitar Paquetes Malditos",
			hnds_config_CustomSounds = "Habilitar sonidos personalizados",
			hnds_config_VanillaTweaks = "Enable vanilla tweaks",
			hnds_config_BlindUpgradeButton = "Enable Blind Upgrade button",
			hnds_config_CustomMenu = "Habilitar menú principal personalizado",
			k_hnds_water_slide_discard = "+1 Discard",
		},
		labels = {
			hnds_vintage = "Vintage",
			hnds_black_seal = "Sello Negro",
			hnds_spectralseal_seal = "Sello Espectral",
			hnds_jester_temp_negative = "Iluminado",
			hnds_soul = "Alma",
			hnds_cursed = "Maldito",
			hnds_offer = "Oferta",
			hnds_price = "Precio",
		},
		challenge_names = {
			c_hnds_devils_round = "La Apuesta del Diablo",
			c_hnds_draw_2_cards = "SACO 2 CARTAS",
			c_hnds_dark_ritual = "Ritual Oscuro",
			c_hnds_the_circus = "El Circo",
			c_hnds_gambling_opportunity = "Ludopatía",
		},
		v_text = {
			ch_c_hnds_devils_round = {  "Todos los Comodines están {C:red,E:2}Malditos{}", },
			ch_c_hnds_draw_2_cards = { "", },
			ch_c_hnds_dark_ritual = { "No puedes visitar la {C:money}Tienda{}", },
			ch_c_hnds_the_circus = {  "", },
			ch_c_hnds_gambling_opportunity = {  "Los {C:attention}Comodines{}, {C:attention}Sello de Oro{}, {C:attention}Carta de Oro{} y {C:attention}de la Suerte{} están deshabilitados", },
		},
		poker_hands = {
			hnds_stone_ocean = "Océano de Piedra",
		},
		poker_hand_descriptions = {
			hnds_stone_ocean = { "Una mano de 5 cartas de piedra" },
		},
	},
}
