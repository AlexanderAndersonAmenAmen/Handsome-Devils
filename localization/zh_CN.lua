return {
	descriptions = {
		-- this key should match the set ("object type") of your object,
		-- e.g. Voucher, Tarot, or the key of a modded consumable type
		Joker = {
			-- this should be the full key of your object, including any prefixes
			j_hnds_color_of_madness = {
				name = "星之彩",
				text = {
					"如果{C:attention}第一次出牌{}",
					"包含{C:attention}4{}种不同的花色",
					"则将{C:attention}第一张{}计分卡",
					"变成{C:attention}万能牌{}",
				},
				-- only needed when this object is locked by default
				-- unlock = {
				--'This is a condition',
				--'for unlocking this card',
				--},
			},
			j_hnds_occultist = {
				name = "神秘学家",
				text = {
					"如果{C:attention}第一次出牌{}",
					"包含{C:attention}4{}种不同的花色",
					"则创造一个{C:planet}流星{},",
					"{C:tarot}吊饰{}或{C:spectral}空灵{}{C:attention}标签{}",
				},
			},
			j_hnds_banana_split = {
				name = "香蕉圣代",
				text = {
					"{X:mult,C:white}X#1#{}倍率",
					"回合结束时",
					"有{C:green}#2#/#3#{}的概率",
					"{C:attention}复制{}这张牌",
					"{C:inactive}(必须有空间){}",
				},
			},
			j_hnds_head_of_medusa = {
				name = "美杜莎之首",
				text = {
					"每当{C:attention}人头牌{}计分时",
					"这张小丑牌获得{X:mult,C:white}X#2#{}倍率",
					"将计分的{C:attention}人头牌{}变为{C:attention}石头牌{}",
					"{C:inactive}(当前为{X:mult,C:white}X#1#{C:inactive}倍率)",
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
			j_hnds_coffee_break = {
				name = "咖啡小憩",
				text = {
					"{C:attention}2{}个回合后",
					"售出此卡可获得{C:money}$#3#{}",
					"你每打出一张牌",
					"此金额减少{C:money}$1{}",
					"{C:inactive}(当前为第{C:attention}#2#{C:inactive}/#1#个回合)",
				},
			},
			j_hnds_jackpot = {
				name = "头奖",
				text = {
					"回合结束时",
					"这张牌有{C:green}#1#/#2#{}的几率",
					"赢得{C:money}$#3#{}并{C:red}自毁{}",
					"每当一张打出的{C:attention}7{}计分时",
					"此{C:green}概率{}增加{C:green}#4#/#2#{} ",
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
				name = "石鬼面",
				text = {
					"如果{C:attention}第一次出牌{}",
					"只有一张{C:attention}增强牌{}",
					"为其添加随机的{C:attention}版本{}",
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
			c_hnds_petrify = {
				name = "石化",
				text = {
					"将你手中所有的{C:attention}人头牌{}",
					"变为{C:attention}石头牌{},",
					"每石化一张牌便获得{C:money}$5{}",
				},
			},
			c_hnds_exchange = {
				name = "交易",
				text = {
					"给{C:attention}2{}张所选卡牌",
					"加上{C:dark_edition}负片{}",
					"{C:blue}-#2#{}出牌次数",
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
			hnds_black_seal = {
				name = "黑色蜡封",
				text = {
					"这张牌在手牌中时",
					"也会参与计分",
				},
			},
			hnds_green_seal = {
				name = "绿色蜡封",
				text = {
					"当此卡被{C:attention}计分{}",
					"或{C:attention}弃掉{}时",
					"额外抽{C:attention}2{}张牌",
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
	},
	misc = {
		dictionary = {
			k_hnds_petrified = "石化！",
			k_hnds_goldfish = "金鱼！",
			k_hnds_green = "抽牌！",
			k_hnds_jackpot = "头奖！",
			k_hnds_probinc = "增加！",
			k_hnds_coffee = "冷掉了！",
			k_hnds_seismic = "地震了！",
			k_hnds_awaken = "已苏醒！",
			k_hnds_IPLAYPOTOFGREED = "我发动！...",
			k_hnds_balloons = "全没了！",
			k_hnds_banana_split = "分裂！",
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
