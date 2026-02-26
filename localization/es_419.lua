return {
	descriptions = {
		Joker = {
			j_hnds_color_of_madness = {
				name = "El Color de la Locura",
				text = {
					"Mejora la {C:attention}primera{} carta",
					"anotada a una {C:attention}Carta Versátil{}",
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
					"Al mejorar una carta",
					"{C:attention}Mejorada{} obtiene adicionalmente",
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
					"Si la {C:attention}primera mano{} es una",
					"sola carta, esta obtiene",
					"una {C:attention}Mejora{}, {C:dark_edition}Edición{}",
					"o {C:attention}Sello{}",
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
					"Si terminas una ronda sin",
					"{C:blue}mano{}, {C:red}pierde{} un {C:attention}Globo{}",
					"y crea una {C:attention}Etiqueta{}",
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
					"Otorga edición {C:dark_edition}Negativa{}",
					"a los comodines de {C:attention}Comida{}",
					"prob. de {C:green}#1# en #2#{} crear",
					"comodín de comida al",
					"final de la ronda",
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
					"{C:attention}#1#{} aparece",
					"{C:attention}4X{} más seguido",
					"en tienda y paquetes ponciadores",
					"Este Comodín se destruye al",
					"encontrar a {C:attention}#1#{C:inactive}"
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
			-- Bizzare Joker section
			j_hnds_bizzare_joker = {
				name = "Comodín Desalinado",
				text = {
					"Su efecto cambia según",
					"el palo elegido cada ronda",
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
					"Gana {C:mult}+#4#{} Multi al anotar {C:clubs}Club{}",
					"{s:0.8}Su efecto cambia cada ronda",
					"{C:inactive}(Actualmente {X:mult,C:white}X#5#{C:inactive} Multi,",
					"{C:mult}+#3#{C:inactive} Multi, {C:chips}+#1#{C:inactive} Fichas)",
				},
			},
			j_hnds_bizzare_joker_diamonds = {
				name = "El Comodín desalinado",
				text = {
					"Gana {C:money}+$#7#{} valor de venta",
					"por {C:diamonds}Diamante{} anotado",
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
					"Ganas {C:attention}+#2#{} {C:green}renovación{} de",
					"la tienda al anotar {V:1}#3#{}",
					"y se {C:red}destruyen{} después",
					"{s:0.8}El palo cambia cada ronda",
					"{C:inactive,s:0.8}(Actualmente {C:attention,s:0.8}#1#{C:green,s:0.8} Renovaciones{C:inactive,s:0.8})"
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
			j_hnds_blackjack = {
				name = "Blackjack",
				text = {
					"Gana {C:chips}+#2#{} Fichas si las",
					"{C:attention}categorías{} descartadas suman",
					"{C:attention}21{}, se reinicia al derrotar",
					"la {C:attention}Ciega Jefe{}",
					"{C:inactive}(Actualmente {C:chips}+#1#{C:inactive} Fichas)",
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
					"{C:attention}1 vez{} por ronda,",
					"otorga {V:1}#1#{} a las",
					"si la mano es {C:attention}Póker{}",
					"{s:0.8}El efecto cambia cada ronda",
				}
			},
			j_hnds_creepy = {
				name = "Comodín Perturbador",
				text = {
					"{X:mult,C:white}X#1#{} Multi",
					"prob. de {C:green}#2# en #3#{} de convertir",
					"comodines adyacentes en copias",
					"exactas al final de la ronda",
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
					"únicas, vende esta carta",
					"para crear {C:attention}#3#{} Etiquetas",
					"{C:inactive}(Actualmente {C:attention}#1#{C:inactive}/8){}",
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
					"Las cartas de {C:attention}figura{} anotadas",
					"actúan como cartas enumeradas",
				},
			},
			j_hnds_contagion = {
				name = "Contagio",
				text = {
					"Las cartas {C:attention}mejoradas{} tienen",
					"una prob. de {C:green}#1# en #2#{} de",
					"copiar su mejora a una",
					"carta a la {C:attention}derecha{}",
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
				name = "Crystal Deck",
				text = {
					"En la Apuesta {C:attention}4{},",
					"enfrenta una {C:attention}Ciega Final{}",
					"y ganas un",
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
		Spectral = {
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
					"Otorga {C:attention}#1#{} {C:green}Renovaciones{}",
					"gratis en la tienda hasta",
					"el final de la ronda",
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
				name = "Gateway",
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
					"Crea {C:attention}#1#{} cartas {C:spectral}Espectrales{}",
					"al ser {C:attention}destruida{}",
					"{C:inactive}(Debe haber espacio){}"
				}
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
					"Escoge {C:attention}#2#{} de hasta {C:attention}#1#{},",
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
					"Crea una carta de",
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
					"{C:money}Aumenta{} el interés",
					"máximo en $5",
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
					"Aumenta todos los {C:money}precios{}",
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
			hnds_blood_sticker = {
				name = "Sticker de Sangre",
				text = {
					"Usaste este comodín para",
					"ganar el Pozo de {C:attention}Sangre{}",
				}
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
				name = "Oferta de Paquetes",
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
					"Gana {C:mult}+#1#{} Multi",
					"al estar en mano.",
					"se destruye al",
					"{C:attention}descartarse{}",
				},
			},
			m_hnds_obsidian = {
				name = "Carta de Obsidiana",
				text = {
					"Pierdes {C:red}$#1#{}",
					"cuando anota.",
					"Prob. de {C:green}#2# en #3#{} de crear",
					"un consumible {C:dark_edition}negativo{}",
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
		},
		Stake = {
			stake_hnds_platinum = {
				name = "Pozo de Platino",
				text = {
					"Si la {C:attention}Ciega{} es derrotada con el {C:attention}doble{}",
					"fichas requeridas, la siguiente {C:attention}Ciega{} es {C:mult}X2{} más grande",
                    "{s:0.8}Aplica todos los pozos anteriores{}",
				}
			},
			stake_hnds_blood_stake = {
				name = "Pozo de Sangre",
				text = {
					"La tienda puede tener Comodines {C:red}Malditos{}",
					"{s:0.8}Aplica todos los pozos anteriores{}",
				},
				unlock = {
                    'Gana con esta',
                    'baraja en el Pozo de Platino',
                }
			}
		}
	},
	misc = {
		dictionary = {
			k_hnds_petrified = "¡Petrificado!",
			k_hnds_goldfish = "¡Pez Dorado!",
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
			k_hnds_balloons = "¡Sin Globos!",
			k_hnds_banana_split = "¡Split!",
			k_hnds_color_of_madness = "¡Locura!",
			k_hnds_occultist = "¡Estudio!",
			k_hnds_splashed = "¡Salpicado!",
			hnds_plus_q = "+1 ???", --this is for the cryptid digital hallucinations creation message with magic packs
			k_hnds_magic_pack = "Paquete Mágico",
			k_hnds_cursed_pack = "Paquete Maldito",
			hnds_cursed_pack = "Paquete Maldito",
			k_hnds_sarmenti_active = "Activo",
			k_hnds_sarmenti_inactive = "Inactivo",
			k_hnds_sarmenti_enhanced = "¡Mejorado!",
			k_hnds_enhancements = "Mejoras",
			k_hnds_creepy_1 = "Únete a nosotros...",
			k_hnds_creepy_2 = "Tú sigues.",
			k_hnds_creepy_3 = "¡Uno de nosotros!",
			k_hnds_creepy_4 = "No mires atrás.",
			k_hnds_creepy_5 = "No puedes escapar.",
			k_hnds_creepy_6 = "Se propaga...",
			k_hnds_creepy_7 = "Para siempre.",
			k_hnds_creepy_8 = "Somos uno.",
		},
		labels = {
			hnds_vintage = "Vintage",
			hnds_black_seal = "Sello Negro",
			hnds_spectralseal_seal = "Sello Espectral",
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
		ranks = {
			hnds_creepycard = 'Algo está mal...',
		},
	},
}
