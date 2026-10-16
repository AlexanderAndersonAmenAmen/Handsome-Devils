return {
	descriptions = {


		Joker = {
			j_hnds_head_of_medusa = {
				name = "美杜莎之首",
				text = {
					"每当{C:attention}人头牌{}计分时",
					"这张小丑牌获得{X:mult,C:white}X#2#{}倍率",
					"将计分的{C:attention}人头牌{}变为{C:attention}石头牌{}",
					"{C:inactive}(当前为{X:mult,C:white}X#1#{C:inactive}倍率)",
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
            j_hnds_pluck_of_the_draw = {
                name = "Pluck of the Draw",
                text = {
                    "Each discarded {C:attention}Enhanced{}",
                    "card, draws {C:attention}2{} extra cards",
                },
            },
            j_hnds_coffee_break = {
                name = "Cup of Joe",
                text = {
                    "Retrigger {C:attention}Joker{} to",
                    "the right and take",
                    "one sip of Coffee",
                    "{C:inactive}({C:attention}#1#{}{C:inactive}/#2# sips left)",
                },
            },
            j_hnds_sunny_side = {
                name = "Sunny Side",
                text = {
                    "{C:mult}+#1#{} Mult",
                    "Each played {C:attention}face card{}",
                    "steals {C:mult}+#2#{} Mult from this",
                    "Joker when scored",
                },
            },
            j_hnds_blueberries = {
                name = "Blueberries",
                text = {
                    "If this is {C:attention}leftmost{}",
                    "Joker, add {C:chips}+#1#{} Chips",
                    "to played hand's score",
                    "and eat one Blueberry",
                    "{C:inactive}({C:attention}#2#{}{C:inactive}/#3# Blueberries left){}",
                },
            },
            j_hnds_loaded_die = {
                name = "Loaded Die",
                text = {
                    "Each scoring {C:attention}7{}",
                    "increases all {C:attention}listed{}",
                    "{C:green}probabilities{} by {C:attention}1{}",
                    "for played hand",
                },
            },
            j_hnds_miner_joker = {
                name = "Miner",
                text = {
                    "Each played {C:attention}Stone card{}",
                    "gets destroyed and creates",
                    "a {C:attention}Joker{} with random {C:dark_edition}Edition{}",
                    "{C:inactive}(Must have room)",
                },
            },
            j_hnds_formosana = {
                name = "Formosana",
                text = {
                    "This Joker gains {X:mult,C:white}X#1#{} Mult",
                    "per {C:attention}Joker{} card destroyed",
                    "{C:inactive}(This can't be destroyed)",
                    "{C:inactive}(Currently {X:mult,C:white}X#2#{C:inactive} Mult)",
                },
            },
            j_hnds_wild_order = {
                name = "Wild Order",
                text = {
                    "Cards with",
                    "{V:1}#1#{} suit are",
                    "always drawn first",
                    "{s:0.8}Suit changes every round",
                },
            },
            j_hnds_trump_suit = {
                name = "Trump Suit",
                text = {
                    "Retrigger all cards",
                    "with {V:1}#1#{} suit",
                    "{s:0.8}Suit changes every round",
                },
            },
            j_hnds_artistic_joker = {
                name = "Artistic Joker",
                text = {
                    "If {C:attention}first hand{} of round",
                    "scores {C:attention}4{} different suits,",
                    "create a random {C:attention}Tag{}",
                },
            },
            j_hnds_cursed_doll = {
                name = "Cursed Doll",
                text = {
                    "Destroy a random card",
                    "in hand when you use",
                    "a {C:attention}consumable card{}",
                },
            },
            j_hnds_joker_recycler = {
                name = "Joker Recycler",
                text = {
                    "When you sell a {C:attention}Joker{}",
                    "while in {C:attention}Blind{}, gain",
                    "{C:attention}+1{} Hand and discard",
                },
            },
            j_hnds_laugh_preserver = {
                name = "Laugh Preserver",
                text = {
                    "Each {C:attention}2{} held",
                    "in hand gives",
                    "{C:attention}+1{} hand size",
                },
            },


			j_idol = {
				name = "The Idol",
				text = {
					"This Joker gains {X:mult,C:white}X#1#{}",
					"Mult when each played",
					"{C:attention}#2#{} of {V:1}#3#{} is scored",
					"{s:0.8}Card changes every round",
					"{C:inactive}(Currently {X:mult,C:white}X#4#{C:inactive} Mult)",
				},
			},

			j_hnds_survey = {
				name = "Survey",
				text = {
					"When you draw a",
					"{C:attention}face{} card, gain {C:money}$1{}",
				},
			},

			j_hnds_color_of_madness = {
				name = "星之彩",
				text = {
					"如果{C:attention}第一次出牌{}",
					"包含{C:attention}4{}种不同的花色",
					"则将{C:attention}第一张{}计分卡",
					"变成{C:attention}万能牌{}",
				},


			},
			j_hnds_deep_pockets = {
				name = "财布鼓鼓",
				text = {
					"消耗牌槽位{C:attention}+#1#{}",
					"你{C:attention}消耗牌栏位{}中的",
					"每张卡给予{C:mult}+#2#{}倍率",
				},
			},
			j_hnds_digital_circus = {
				name = "数字马戏团",
				text = {
					"售出此卡以创建一张",
					"带有随机{C:attention}版本{}的{V:1}#1#{}小丑牌",
					"每{C:attention}#3#{}个回合都会提升其稀有度",
					"{C:inactive}(当前为第{C:attention}#2#{C:inactive}/#3#个回合)",
				},
			},
			j_hnds_pot_of_greed = {
				name = "强欲之壶",
				text = {
					"每当你使用一张{C:attention}消耗牌{}时",
					"抽{C:attention}#1#{}张牌",
				},
			},
			j_hnds_seismic_activity = {
				name = "震测作业",
				text = {
					"重新触发所有",
					"{C:attention}石头牌",
				},
			},
			j_hnds_stone_mask = {
			    name = "Stone Mask",
			    text = {
			        "When you draw a",
			        "{C:attention}face{} card, gain {C:money}$1{}",
			    },
			    unlock = {
			        "Reach {X:mult,C:white}X5{} Mult",
			        "with {C:attention}Vampire{}",
			    },
			},
			j_hnds_jokestone = {
				name = "丑石传说",
				text = {
					"回合开始时",
					"抽取最多{C:attention}3{}张{C:attention}增强牌{}",
				},
			},
			j_hnds_meme = {
				name = "网络迷因",
				text = {
					"你打出的手牌中每有一种{C:attention}花色{}",
					"这张小丑牌获得{X:mult,C:white}X0.05{}倍率",
					"{C:inactive}(当前为{X:mult,C:white}X#1#{C:inactive}倍率)",
				},
			},
			j_hnds_balloons = {
				name = "气球",
				text = {
					"如果回合结束时",
					"你恰好没有出牌次数",
					"{C:red}失去{}一个{C:attention}气球{}",
					"并创建一个随机的{C:attention}标签",
					"{C:inactive}(还剩{C:attention}#1#{C:inactive}/#2#个！)",
				},
			},
			j_hnds_jokes_aside = {
				name = "小丑靠边站！",
				text = {
					"本回合中",
					"每有一张小丑牌被{C:attention}售出{}",
					"这张小丑牌获得{X:mult,C:white}X#2#{}倍率",
					"{C:inactive}(当前为{X:mult,C:white}X#1#{C:inactive}倍率)",
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
			j_jodiac = {
				name = "Jodiac",
				text = {
					"After playing {C:attention}#2#{} unique",
					"poker hands, sell this",
					"card to upgrade every",
					"{C:attention}poker hand{} by {C:attention}#3#{} levels",
					"{C:inactive}(Currently {C:attention}#1#{C:inactive}/#2#){}",
				},
			},
},
		Spectral = {
			c_hnds_abyss = {
				name = "深渊",
				text = {
					"给你手牌中的",
					"{C:attention}1{}张所选卡牌",
					"加上{C:dark_edition}黑色蜡封{}",
				},
			},
			c_hnds_growth = {
				name = "Growth",
				text = {
					"给你手牌中的",
					"{C:attention}1{}张所选卡牌",
					"加上{C:green}绿色蜡封{}",
				},
			},
			c_hnds_gaze = {
				name = "Gaze",
				text = {
					"将你手中所有的{C:attention}人头牌{}",
					"变为{C:attention}石头牌{},",
					"每石化一张牌便获得{C:money}$5{}",
				},
			},
				c_hnds_void = {
					name = "Void",
					text = {
						"使{C:attention}1{}张选中的牌获得",
						"{C:dark_edition}负片{}效果，",
						"{C:red}摧毁所有其他卡牌{}",
					},
				},
			c_hnds_hallows = {
				name = "圣徒",
				text = {
					"摧毁除最左边外的所有小丑牌",
					"获得{C:attention}X#1#{}倍售价的{C:money}${}",
					"{C:inactive}(最高{C:money}$#2#{C:inactive})",
					"{C:inactive}(当前为{C:money}$#3#{C:inactive})",
				},
			},
			c_hnds_dream = {
				name = "梦",
				text = {
					"创建{C:attention}10{}个随机的",
					"{C:attention}小丑标签{}",
				},
			},
		},

		Other = {
            hnds_soul = {
                name = "Soul",
                text = {
                    "No {C:attention}sell value",
                    "Remove this when",
                    "you lose {C:legendary,E:1}Pennywise",
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
				hnds_black_seal = {
					name = "黑色蜡封",
					text = {
						"手持此牌抽取{C:attention}#1#{} [{C:attention}#2#{}]张牌后",
						"生成一张{C:dark_edition}负片小丑牌{}",
						"{C:inactive}仅本回合有效{}",
					},
				},
			hnds_green_seal = {
				name = "绿色蜡封",
				text = {
					"After played or",
					"discarded, draw",
					"{C:attention}3{} extra cards",
				},
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
				name = "标签猎人",
				text = {
					"当{C:attention}Boss盲注{}被击败时",
					"创建一个随机的{C:attention}标签{}",
				},
			},
			v_hnds_hashtag_skip = {
				name = "#2#跳过",
				text = {
					"你每跳过{C:attention}#1#{}个{C:attention}盲注{}",
					"{C:attention}-1{}底注",
				},
			},
			v_hnds_beginners_luck = {
				name = "新手运",
				text = {
					"将所有以{C:attention}数字标注{}出的",
					"{C:green,E:1,S:1.1}几率{}翻倍",
					"{C:inactive}(例如：{C:green}1/3{}几率{C:inactive} -> {C:green}2/3{}几率{C:inactive})",
				},
			},
			v_hnds_rigged = {
				name = "出千",
				text = {
					"将所有以{C:attention}数字标注{}出的",
					"{C:green,E:1,S:1.1}几率{}翻{C:attention}X1.5{}倍",
					"{C:inactive}(例如：{C:green}2/6{}几率{C:inactive} -> {C:green}3/6{}几率{C:inactive})",
				},
			},
		},
		Planet = {
			c_hnds_makemake = {
				name = "鸟神星",
				text = {
					"{S:0.8}({S:0.8,V:1}等级#1#{S:0.8}){}",
					"升级{C:attention}#2#",
					"{C:chips}+#4#{}筹码，本底注中",
					"每次{C:attention}石头牌{}被计分",
					"都会额外{C:chips}+#6#{}筹码",
					"{C:inactive}(已计分#5#次)",
				},
			},
		},
		Blind = {
			bl_serpent = {
				name = "The Serpent",
				text = {
					"After Play or Discard,",
					"draw up to 3 cards",
				},
			},
		},
	},
	misc = {
		dictionary = {
            k_hnds_consumed = "Eaten!",
            k_hnds_destroyed = "Eaten!",
            k_hnds_tag = "+1 Tag",

			k_hnds_rank_up = "Rank Up!",
			k_hnds_krusty_voucher_tag = "Voucher Tag",
			k_hnds_krusty_voucher_tags = "Voucher Tags",
			hnds_config_VanillaTweaks = "Enable vanilla tweaks",
			hnds_config_BlindUpgradeButton = "Enable Blind Upgrade Mechanic (Blue Stake/Nightmare Stake)",
			hnds_config_CustomMenu = "Enable custom main menu",
			hnds_config_PeakMainMenuOST = "Peak Main Menu OST",
			hnds_config_ChaosSuits = "Chaos suits",
			k_hnds_water_slide_discard = "+1 Discard",
			k_hnds_petrified = "石化！",
			k_hnds_goldfish = "金鱼！",
			k_hnds_jevil_chaos = "Chaos! Chaos!",
			k_hnds_cursed_offers = "诅咒馈赠",
			k_hnds_chaos_suits = "Chaos Suits",
            k_hnds_cursed_prices = "诅咒代价",
			k_hnds_green = "抽牌！",
			k_hnds_jackpot = "头奖！",
			k_hnds_probinc = "增加！",
			k_hnds_coffee = "冷掉了！",
			k_hnds_seismic = "地震了！",
			k_hnds_awaken = "已苏醒！",
			k_hnds_IPLAYPOTOFGREED = "我发动！...",
			k_hnds_balloons = "全没了！",
			k_hnds_sunny_side = "Sunny!",
			k_hnds_color_of_madness = "疯狂！",
			k_hnds_occultist = "研究！",
		},
		labels = {
			hnds_black_seal = "黑色蜡封",
			hnds_green_seal = "绿色蜡封",
		},
		poker_hands = {
			hnds_stone_ocean = "石之海",
		},
		poker_hand_descriptions = {
			hnds_stone_ocean = { "五张牌都是石头牌" },
		},
	},
}
