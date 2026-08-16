return {
	descriptions = {
		Joker = {
			j_matador = {
				name = "Matador",
				text = {
					"Gana {C:money}$#1#{} por cada mano",
					"jugada contra una {C:attention}Ciega Jefe{}",
				},
			},
			j_superposition = {
				name = "Superposición",
				text = {
					"Crea una carta {C:tarot}Bufón{}",
					"si la mano de póker contiene",
					"un {C:attention}As{} y una {C:attention}Escalera{}",
					"{C:inactive}(Debe haber espacio)",
				},
			},
			j_splash = {
				name = "Salpicadura",
				text = {
					"Las cartas jugadas",
					"{C:attention}siempre{} anotan",
				},
			},
			j_flower_pot = {
				name = "Maceta",
				text = {
					"Da {X:mult,C:white}X{} Multi según la",
					"cantidad de palos {C:attention}únicos{}",
					"en la mano de póker jugada",
					"{C:inactive}(Actualmente {X:mult,C:white}X#1#{C:inactive} Multi)",
				},
			},
			j_hnds_flower_pot_none = {
				name = "Maceta",
				text = {
					"Da {X:mult,C:white}X{} Multi según la",
					"cantidad de palos {C:attention}únicos{}",
					"en la mano de póker jugada",
					"{C:inactive}(Actualmente ninguno)",
				},
			},
			j_mail = {
				name = "Reembolso por Correo",
				text = {
					"Gana {C:money}$#1#{} por cada",
					"{C:attention}#2#{} descartado; la categoría",
					"cambia cada ronda",
				},
			},
			j_stone = {
				name = "Comodín de Piedra",
				text = {
					"Da {C:chips}+#1#{} Fichas por cada",
					"{C:attention}Carta de Piedra{} en tu baraja",
					"{C:inactive}(Actualmente {C:chips}+#2#{C:inactive} Fichas)",
				},
			},
			j_greedy_joker = {
				name = "Comodín Codicioso",
				text = {
					"Las cartas jugadas de",
					"{C:diamonds}Diamantes{} dan {C:mult}+#1#{} Multi",
					"al anotar",
				},
			},
			j_lusty_joker = {
				name = "Comodín Lujurioso",
				text = {
					"Las cartas jugadas de",
					"{C:hearts}Corazones{} dan {C:mult}+#1#{} Multi",
					"al anotar",
				},
			},
			j_wrathful_joker = {
				name = "Comodín Iracundo",
				text = {
					"Las cartas jugadas de",
					"{C:spades}Espadas{} dan {C:mult}+#1#{} Multi",
					"al anotar",
				},
			},
			j_gluttenous_joker = {
				name = "Comodín Glotón",
				text = {
					"Las cartas jugadas de",
					"{C:clubs}Tréboles{} dan {C:mult}+#1#{} Multi",
					"al anotar",
				},
			},
			j_throwback = {
				name = "Nostalgia",
				text = {
					"{X:mult,C:white}X#1#{} Multi por cada",
					"{C:attention}Ciega{} omitida en esta partida",
					"{C:inactive}(Actualmente {X:mult,C:white}X#2#{C:inactive} Multi)",
				},
			},
			j_seeing_double = {
				name = "Doble Visión",
				text = {
					"Reactiva todos los {C:attention}7{}",
					"Reactívalos una vez más si",
					"su palo es {C:clubs}Tréboles{}",
				},
			},
			j_ring_master = {
				name = "Presentador",
				text = {
					"Las cartas {C:attention}Comodín{}, {C:tarot}Tarot{},",
					"{C:planet}Planeta{} y {C:spectral}Espectral{} pueden",
					"aparecer varias veces",
				},
			},
			j_hiker = {
				name = "Excursionista",
				text = {
					"Cada {C:attention}carta{} jugada obtiene",
					"permanentemente {C:chips}+#1#{} Fichas",
					"al anotar",
				},
			},
			j_hnds_color_of_madness = {
				name = "El Color de la Locura",
				text = {
					"Mejora las {C:attention}primeras dos{} cartas",
					"anotadas a {C:attention}Cartas Versátiles{}",
					"si la mano jugada tiene",
					"{C:attention}4{} palos diferentes",
				},
				unlock = {
					"Ten al menos {C:attention}10{}",
					"{C:attention}Cartas Versátiles{}",
					"en tu baraja",
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
				unlock = {
					"Crea un total de",
					"{C:attention}150 Etiquetas{}",
					"{C:inactive}(#1#){}",
				},
			},
			j_hnds_supersuit = {
				name = "Supertraje",
				text = {
					"Reactiva las cartas",
					"del palo {V:1}#1#{},",
					"{C:inactive,s:0.8}(Cambia cada ronda)",
				},
				unlock = {
					"Anota {C:attention}4{} Colores",
					"de palos diferentes",
					"en una Apuesta",
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
				unlock = {
					"Destruye un total",
					"de {C:attention}50{} cartas",
					"{C:inactive}(#1#){}",
				},
			},
			j_hnds_perfectionist = {
				name = "Perfeccionista",
				text = {
					"Al mejorar una carta",
					"{C:attention}Mejorada{} obtiene adicionalmente",
					"{C:mult}+#1#{} Multi y {C:chips}+#2#{} Fichas",
				},
				unlock = {
					"Mejora {C:attention}10{}",
					"cartas {C:attention}Mejoradas{}",
					"{C:inactive}(#1#){}",
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
				unlock = {
					"Ten a la vez {C:attention}Cavendish{}",
					"y {C:attention}Gros Michel{}",
					"en tu partida",
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
				unlock = {
					"Ten al menos {C:attention}10{}",
					"{C:attention}Cartas de Piedra{}",
					"en tu baraja",
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
				unlock = {
					"Crea {C:attention}5{} cartas",
					"consumibles en una ronda",
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
				unlock = {
					"Ten {C:attention}4{} Comodines",
					"de rarezas diferentes",
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
				unlock = {
					"Omite la Ciega Pequeña y",
					"la Ciega Grande de la",
					"Apuesta {C:attention}8{}",
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
				unlock = {
					"Gana {C:money}$50{} o",
					"más en una ronda",
					"{C:inactive}(#1#)",
				},
			},
			j_hnds_pot_of_greed = {
				name = "Olla de la Codicia",
				text = {
					"Al usar un {C:attention}consumible{},",
					"sacas {C:attention}#1#{} cartas",
				},
				unlock = {
					"Saca toda tu",
					"baraja en una ronda",
				},
			},
			j_hnds_seismic_activity = {
				name = "Actividad Sísmica",
				text = {
					"Reactiva las",
					"{C:attention}Cartas de Piedra{}",
				},
				unlock = {
					"Anota {C:attention}30 Cartas de Piedra{}",
					"en una partida",
					"{C:inactive}(#1#)",
				},
			},
			j_hnds_stone_mask = {
				name = "Máscara de Piedra",
				text = {
					"Prob. de {C:green}#1# en #2#{} de que la primera",
					"carta de {C:attention}figura{} anotada robe",
					"las {C:attention}Mejoras{}, {C:dark_edition}Ediciones{} o",
					"{C:attention}Sellos{} de cartas adyacentes",
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
					"sacas hasta {C:attention}#1#{} cartas",
					"Mejoradas de tu baraja",
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
				unlock = {
					"Juega una {C:attention}mano de póker{}",
					"con {C:attention}5{} cartas",
					"{C:red}Debilitadas{}",
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
				unlock = {
					"Crea un total de",
					"{C:attention}50 Etiquetas{}",
					"{C:inactive}(#1#)",
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
				unlock = {
					"Vende un total de",
					"{C:attention}15{} Comodines en",
					"una partida {C:inactive}(#1#)",
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
				unlock = {
					"Falla una comprobación de",
					"{C:green}probabilidad{} {C:attention}100{} veces",
					"{C:inactive}(#1#)",
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
				unlock = {
					"Ten una baraja de",
					"{C:attention}25{} cartas o menos",
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
					"Destruye un total",
					"de {C:attention}100{} cartas",
					"{C:inactive}(#1#)",
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
				},
				unlock = {
					"Ten {C:attention}5 Comodines Raros{}",
					"a la vez",
				},
			},
			j_hnds_clown_devil = {
				name = "Payaso Demoniaco",
				text = {
					"Al seleccionar una {C:attention}Ciega{},",
					"consume todos los {C:attention}consumibles{} en mano",
					"Crea una {C:attention}Etiqueta{} al azar por",
					"cada {C:attention}2{} {C:inactive}[#1#]{} cartas consumidas",
				},
				unlock = {
					"Crea un total de",
					"{C:attention}100 Etiquetas{}",
					"{C:inactive}(#1#)",
				},
			},
			j_hnds_jester_in_yellow = {
				name = "El Comodín de Amarillo",
				text = {
					"Al seleccionar una Ciega",
					"el Comodín del extremo izquierdo",
					"se vuelve {C:dark_edition}Negativo{} y se {C:hnds_carcosa}desvance{}",
					"{C:attention}#1#{} rondas"
				},
				unlock = {
					"Convierte un total de",
					"{C:attention}10{} Comodines en {C:dark_edition}Negativos{}",
					"{C:inactive}(#1#)",
				},
			},
			j_hnds_wait_what = {
				name = "¿Espera, qué?",
				text = {
					"{X:mult,C:white}X#1#{} Multi",
				}
				,
				unlock = {
					"?????",
				}
			},
			j_hnds_excommunicado = {
				name = "Excomulgado",
				text = {
					"Todas las {C:attention}Ciegas{} son",
					"{C:attention}Ciegas Jefe{}, obtienes una",
					"{C:attention}Etiqueta{} al derrotar una {C:attention}Ciega{}"
				},
				unlock = {
					"Derrota un total de",
					"{C:attention}100 Ciegas Jefe{}",
					"{C:inactive}(#1#)",
				},
			},
			j_hnds_handsome = {
				name = "Picaro Hermoso",
				text = {
					"Reactiva todas las",
					"cartas con {C:dark_edition}Ediciones{}",
				},
				unlock = {
					"Ten {C:attention}4{} Comodines",
					"con {C:dark_edition}Ediciones{} diferentes",
				},
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
					"Sigue jugando {C:blue}Manos{} después de",
					"alcanzar la puntuación de la {C:attention}Ciega{}",
					"y gana {C:money}$#1#{} por cada mano jugada"
				},
				unlock = {
					"Usa todas las {C:blue}manos{}",
					"para derrotar una",
					"{C:attention}Ciega Jefe{}",
				},
			},
			-- Bizzare Joker section
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

			-- Bizzare Joker section
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
					"{C:attention}#3#{} de tu baraja, luego",
					"{C:red}destruye{} todas las cartas en mano",
					"{s:0.8}Mejora al final de la ronda",
				},
				unlock = {
					"Destruye un total",
					"de {C:attention}150{} cartas",
					"{C:inactive}(#1#){}",
				}
			},
			j_hnds_fregoli = {
				name = "Fregoli",
				text = {
					"Copia la habilidad del",
					"último {C:attention}Comodín{} comprado",
				}
				,
				unlock = {
					"Compra el mismo",
					"Comodín {C:attention}3{} veces",
					"en una partida",
				},
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
				,
				unlock = {
					"Cambia las {C:attention}categorías{} o",
					"{C:attention}palos{} de {C:attention}100{} cartas",
					"{C:inactive}(#1#){}",
				},
			},
			j_hnds_angry_mob = {
				name = "Protesta Violenta",
				text = {
					"{X:mult,C:white}X#1#{} Multi,",
					"no aparecen {C:attention}Comodines{}",
					"en la {C:money}Tienda{}"
				},
				unlock = {
					"No compres Comodines durante",
					"{C:attention}10{} rondas seguidas",
					"{C:inactive}(#1#)",
				},
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
				},
				unlock = {
					"Ten {C:attention}3{} copias del",
					"mismo Comodín",
				},
			},
			j_hnds_one_punchline_man = {
				name = "One Punchline Man",
				text = {
					"Gana {X:mult,C:white}X0.25{} Multi por",
					"cada {C:blue}mano{} que no usaste",
					"al final de la ronda",
					"{C:inactive}(Actualmente {X:mult,C:white}X#1#{C:inactive} Multi)",
				},
				unlock = {
					"Derrota {C:attention}3{} Ciegas Jefe",
					"seguidas en {C:attention}una mano{}",
				},
			},
			j_hnds_jigsaw_joker = {
				name = "Comodín Jigsaw",
				text = {
					"Tras jugar {C:attention}8{} manos",
					"de póquer {C:attention}únicas{}, vende esta",
					"carta para subir {C:attention}#3#{} niveles",
					"todas las {C:attention}manos de póquer{}",
					"{C:inactive}(Actualmente {C:attention}#1#{C:inactive}/8){}",
				},
				unlock = {
					"Juega {C:attention}8 manos de póker{}",
					"únicas en una Apuesta",
					"{C:inactive}(#1#)",
				},
			},
			j_hnds_dynamic_duos = {
				name = "Dúo Dinámico",
				text = {
					"Si juegas un {C:attention}Doble Par{} de",
					"cartas de {C:attention}pares{} e {C:attention}impares{},",
					"reactiva las cartas",
				},
				unlock = {
					"Juega un {C:attention}Doble Par{}",
					"de categorías {C:attention}par{} e {C:attention}impar{}",
				},
			},
			j_hnds_imposter = {
				name = "Impostor",
				text = {
					"Las cartas de {C:attention}figura{} anotadas",
					"actúan como cartas enumeradas",
				},
				unlock = {
					"Gana {C:attention}3{} rondas seguidas",
					"con un Comodín que no",
					"se haya activado ni una vez",
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
				unlock = {
					"Ten una baraja llena de",
					"cartas {C:attention}Mejoradas{}",
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
				unlock = {
					"Descubre al menos",
					"{C:attention}150{} objetos de",
					"tu colección",
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
				,
				unlock = {
					"Gana una partida con cualquier",
					"baraja al menos en dificultad",
					"de {C:attention}Pozo de Oro{}",
				},
			},
			b_hnds_conjuring = {
				name = "Baraja Conjuradora",
				text = {
					"La {C:money}Tienda{} reemplaza",
					"los {C:attention}Paquetes Potenciadores{}",
					"por {C:attention,T:p_hnds_magic_1}Paquetes Mágicos{}",
					"que contienen {C:dark_edition,E:1}cartas al azar{}",
				}
				,
				unlock = {
					"Descubre todos los",
					"{C:attention}Paquetes Potenciadores{}",
				},
			},
			b_hnds_circus = {
				name = "Baraja de Circo",
				text = {
					"Tiene la habilidad de",
					"un {C:attention}Comodín{} al azar",
					"Después de derrotar cada",
					"{C:attention}Ciega{}, cambia la habilidad",
				},
				unlock = {
					"Descubre todos los",
					"{C:attention}Comodines{}",
				},
			},
			b_hnds_ol_reliable = {
				name = "Baraja de la Suerte",
				text = {
					"Triplica las {C:green}probabilidades{}",
					"en la {C:money}Tienda{} y durante",
					"la {C:attention}Ciega Jefe{}",
					"{C:inactive}(Ej. {C:green}1 en 3{C:inactive} -> {C:green}3 en 3){C:inactive}",
				}
				,
				unlock = {
					"Activa correctamente el efecto",
					"de probabilidad de las {C:attention}Cartas de la Suerte{}",
					"{C:green}77{} veces {C:inactive}(#1#)",
				},
			},
			b_hnds_cursed = {
				name = "Baraja Maldita",
				text = {
					"Derrota la {C:attention}primera",
					"{C:attention}Ciega Jefe{} para abrir un",
					"{C:red,T:p_hnds_cursed_pack}Paquete Maldito Inevitable{}",
				}
				,
				unlock = {
					"Gana una partida con cualquier",
					"baraja al menos en dificultad",
					"de {C:dark_edition}Pozo de Platino{}",
				},
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
			c_black_hole = {
				name = "Agujero Negro",
				text = {
					"Duplica el",
					"nivel de todas las",
					"{C:legendary,E:1}manos de póker{}",
				},
			},
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
			c_hnds_contagion_death = {
				name = "Muerte",
				text = {
					"Selecciona {C:attention}3{} cartas,",
					"convierte todas",
					"en copias de la",
					"{C:attention}carta del extremo derecho{}",
				},
			},
			c_hnds_exchange_contagion = {
				name = "Intercambio",
				text = {
					"Otorga el efecto {C:dark_edition}Negativo{} a",
					"{C:attention}#1#{} cartas seleccionadas en mano,",
					"-1 {C:blue}mano{} cada ronda",
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
					"a {C:attention}1{} carta seleccionada en mano,",
					"-1 {C:blue}mano{} cada ronda",
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
			e_hnds_vintage_playing_card = {
				name = "Vintage",
				text = {
					"Ganas {C:money}$3{} cuando esta",
					"carta se juega",
					"y anota",
				},
			},
			e_negative_playing_card = {
				name = "Negativa",
				text = {
					"{C:attention}+1{} al tamaño de mano",
				},
			},
		},

		Other = {
            hnds_jigsaw_progress_empty = {
                name = "Manos de póker jugadas",
                text = {
                    "Actualmente: {C:attention}#1#{}",
                    "{C:inactive}(#2#/#3# manos únicas){}",
                },
            },
            hnds_jigsaw_progress_1 = {
                name = "Manos de póker jugadas",
                text = {
                    "{C:attention}#1#{}",
                    "{C:inactive}(#2#/#3# manos únicas){}",
                },
            },
            hnds_jigsaw_progress_2 = {
                name = "Manos de póker jugadas",
                text = {
                    "{C:attention}#1#{}",
                    "{C:attention}#2#{}",
                    "{C:inactive}(#3#/#4# manos únicas){}",
                },
            },
            hnds_jigsaw_progress_3 = {
                name = "Manos de póker jugadas",
                text = {
                    "{C:attention}#1#{}",
                    "{C:attention}#2#{}",
                    "{C:attention}#3#{}",
                    "{C:inactive}(#4#/#5# manos únicas){}",
                },
            },
            hnds_jigsaw_progress_4 = {
                name = "Manos de póker jugadas",
                text = {
                    "{C:attention}#1#{}",
                    "{C:attention}#2#{}",
                    "{C:attention}#3#{}",
                    "{C:attention}#4#{}",
                    "{C:inactive}(#5#/#6# manos únicas){}",
                },
            },
            hnds_jigsaw_progress_5 = {
                name = "Manos de póker jugadas",
                text = {
                    "{C:attention}#1#{}",
                    "{C:attention}#2#{}",
                    "{C:attention}#3#{}",
                    "{C:attention}#4#{}",
                    "{C:attention}#5#{}",
                    "{C:inactive}(#6#/#7# manos únicas){}",
                },
            },
            hnds_jigsaw_progress_6 = {
                name = "Manos de póker jugadas",
                text = {
                    "{C:attention}#1#{}",
                    "{C:attention}#2#{}",
                    "{C:attention}#3#{}",
                    "{C:attention}#4#{}",
                    "{C:attention}#5#{}",
                    "{C:attention}#6#{}",
                    "{C:inactive}(#7#/#8# manos únicas){}",
                },
            },
            hnds_jigsaw_progress_7 = {
                name = "Manos de póker jugadas",
                text = {
                    "{C:attention}#1#{}",
                    "{C:attention}#2#{}",
                    "{C:attention}#3#{}",
                    "{C:attention}#4#{}",
                    "{C:attention}#5#{}",
                    "{C:attention}#6#{}",
                    "{C:attention}#7#{}",
                    "{C:inactive}(#8#/#9# manos únicas){}",
                },
            },
            hnds_jigsaw_progress_8 = {
                name = "Manos de póker jugadas",
                text = {
                    "{C:attention}#1#{}",
                    "{C:attention}#2#{}",
                    "{C:attention}#3#{}",
                    "{C:attention}#4#{}",
                    "{C:attention}#5#{}",
                    "{C:attention}#6#{}",
                    "{C:attention}#7#{}",
                    "{C:attention}#8#{}",
                    "{C:inactive}(#9#/#10# manos únicas){}",
                },
            },
			hnds_exchange_draw = {
				name = "Fijada",
				text = {
					"Siempre se saca al",
					"inicio de cada ronda",
				},
			},
			hnds_bound = {
				name = "Fijada",
				text = {
					"Siempre se saca al",
					"inicio de cada ronda",
				},
			},
			hnds_negative_playing_card = {
				name = "Negativa",
				text = {
					"{C:attention}+1{} al tamaño de mano",
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
		},
		Voucher = {
			v_magic_trick = {
				name = "Truco de Magia",
				text = {
					"Las {C:attention}cartas de juego{} pueden",
					"comprarse en la Tienda y tener",
					"una {C:attention}Mejora{}",
				},
			},
			v_illusion = {
				name = "Ilusión",
				text = {
					"Las {C:attention}cartas de juego{} en la",
					"Tienda pueden tener una",
					"{C:dark_edition}Edición{} o un {C:attention}Sello{}",
				},
			},
			v_planet_merchant = {
				name = "Mercader de Planetas",
				text = {
					"Al comprar una carta {C:planet}Planeta{},",
					"crea una copia adicional",
					"{C:inactive}(Debe haber espacio)",
				},
			},
			v_planet_tycoon = {
				name = "Magnate de Planetas",
				text = {
					"Al comprar una carta {C:planet}Planeta{},",
					"crea una copia {C:dark_edition}Negativa{}",
				},
			},
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
				unlock = {
					"Omite un total de",
					"{C:attention}50 Ciegas{} {C:inactive}(#1#)",
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
				unlock = {
					"Compra un total de {C:attention}50{}",
					"cartas {C:rare}Comodín Raras{}",
					"en la Tienda {C:inactive}(#1#)",
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
				unlock = {
					"Compra al menos {C:attention}40{}",
					"{C:attention}Paquetes Potenciadores{}",
					"en una partida {C:inactive}(#1#)",
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
				name = "Más Allá",
				text = {
					"La carta del extremo derecho",
					"que tengas en {C:attention}mano{}",
					"cuenta en la {C:blue}mano{} jugada"
				},
				unlock = {
					"Activa un total de {C:attention}100{}",
					"efectos {C:attention}en mano{} {C:inactive}(#1#)",
				},
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
			m_wild = {
				name = "Carta Versátil",
				text = {
					"No puede voltearse",
					"ni debilitarse",
					"Puede usarse",
					"como cualquier palo",
				},
			},
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
					"Se vuelve {C:dark_edition}Fijada{} permanentemente",
					"si anota en las {C:attention}#1#{} manos finales",
					"de la ronda",
					"{C:inactive}(Actualmente {C:attention}#2#{}{C:inactive}/2)",
				},
			},
			m_hnds_obsidian_complete = {
				name = "Carta de Obsidiana",
				text = {
					"{C:dark_edition}Fijada{} permanentemente",
				},
			},
		},
		Tag = {
			tag_juggle = {
				name = "Etiqueta de Malabares",
				text = {
					"{C:attention}+#1#{} al tamaño de mano,",
					"se reduce en {C:red}1{}",
					"cada ronda",
				},
			},
			tag_investment = {
				name = "Etiqueta de Inversión",
				text = {
					"Después de derrotar la",
					"{C:attention}Ciega Jefe{} de la Apuesta,",
					"gana {C:money}$#1#{}",
				},
			},
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
			stake_hnds_platinum = {
				name = "Pozo de Platino",
				text = {
					"Derrota la {C:attention}Ciega Jefe{} de la Apuesta {C:attention}10{} para ganar",
					"{s:0.8}Aplica todos los Pozos anteriores",
				}
			},
			stake_hnds_blood_stake = {
				name = "Pozo de Sangre",
				text = {
					"La Tienda puede tener Comodines {C:red}Malditos{}",
					"{C:inactive,s:0.8}(Poder {C:green,s:0.8}adicional{} {C:inactive,s:0.8}a cambio de un {C:red,s:0.8}precio{}{C:inactive,s:0.8})",
					"{s:0.8}Aplica todos los Pozos anteriores",
				},
				unlock = {
					"Gana con esta",
					"baraja en el Pozo de Platino",
				}
			},
			stake_hnds_nightmare = {
				name = "Pozo de Pesadilla",
				text = {
					"Dejar un Comodín {C:red}Maldito{} en",
					"la Tienda mejora la siguiente {C:attention}Ciega{}",
					"{s:0.8}Aplica todos los Pozos anteriores",
				},
				unlock = {
					"Gana con esta",
					"baraja en el Pozo de Sangre",
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
			bl_hnds_perilous_pact_active = {
				name = "Pacto Aletargante",
				text = {
					"Limita cada mano al",
					"{C:attention}#1#%{} de la puntuación requerida",
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
			hnds_blind_raiser_tooltip_title = "Puntuación si mejora",
			hnds_blind_raiser_tooltip_current_blind = "Ciega actual: #1#",
			hnds_blind_raiser_tooltip_boss_blind = "Ciega Jefe: #1#",
			k_hnds_petrified = "¡Petrificado!",
			k_hnds_goldfish = "¡Pez Dorado!",
			k_hnds_jester_negative = "¡Comodín Negativo!",
			k_hnds_jester_fade = "¡Negativo Desvanecido!",
			k_hnds_clown_eat = "¡Consumido!",
			k_hnds_ritual_complete = "Ritual completado",
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
			hnds_plus_q = "+1 ???", --this is for the cryptid digital hallucinations creation message with magic packs
			k_hnds_plus_tag = "+Etiqueta",
			k_hnds_wanted = "[Nombre del comodín]",
			k_hnds_magic_pack = "Paquete Mágico",
			k_hnds_cursed_pack = "Paquete Maldito",
			hnds_cursed_pack = "Paquete Maldito",
			k_hnds_sarmenti_active = "Activo",
			k_hnds_sarmenti_inactive = "Inactivo",
			k_hnds_sarmenti_enhanced = "¡Mejorado!",
			k_hnds_free_reroll = "+1 Renovación gratis",
			k_hnds_arthurs_suit = " ",
			k_hnds_enhancements = "Mejoras",
			k_hnds_creepy_1 = "Fue la Planta...",
			k_hnds_creepy_2 = "...nos arrastró",
			k_hnds_creepy_3 = "al abismo...",
			k_hnds_creepy_4 = "ahora sólo...",
			k_hnds_creepy_5 = "...nos queda rezar",
			k_hnds_creepy_6 = "volver a ver...",
			k_hnds_creepy_7 = "al Barón...",
			k_hnds_creepy_8 = "...que nos tracionó",
			-- DEVIL BLIND ALIASES
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
			-- CONFIG TAB LOCALIZATION
			hnds_require_restart = "Requiere reiniciar",
			hnds_config_StoneOcean = "Habilitar mano de Stone Ocean",
			hnds_config_vintage = "Habilitar edición Vintage",
			hnds_config_UltraSpec = "Habilitar paquetes Ultra Espectrales",
			hnds_config_MagicPack = "Habilitar paquetes Mágicos",
			hnds_config_CursedPack = "Habilitar Paquetes Malditos",
			hnds_config_CustomSounds = "Habilitar sonidos personalizados",
			hnds_config_VanillaTweaks = "Habilitar ajustes de vanilla",
		},
		labels = {
			hnds_exchange_draw = "Fijada",
			hnds_bound = "Fijada",
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
			ch_c_hnds_draw_2_cards = { "Comienzas con un {C:attention}tamaño de mano{} de 5", },
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
