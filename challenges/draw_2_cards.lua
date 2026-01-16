SMODS.Challenge {
	key = 'draw_2_cards',
	loc_txt = {
		name = 'DRAW 2 CARDS',
	},
	rules = {
		custom = {
			{ id = 'hnds_draw_2_cards' },
		},
		modifiers = {
			{ id = 'hand_size', value = 5 },
		},
	},
	jokers = {
		{ id = 'j_hnds_pot_of_greed', eternal = true },
		{ id = 'j_cartomancer', eternal = true },
	},
	consumeables = {
	},
	vouchers = {
		{ id = 'v_clearance_sale' },
		{ id = 'v_liquidation' },
		{ id = 'v_crystal_ball' },
	},
	restrictions = {
		banned_cards = {
			{ id = 'j_turtle_bean' },
			{ id = 'j_juggler' },
			{ id = 'j_troubadour' },
			{ id = 'v_paint_brush' },
			{ id = 'v_palette' },
		},
		banned_tags = {
			{ id = 'tag_juggle' },
		},
		banned_other = {
			{ id = 'bl_psychic', type = 'blind' },
			{ id = 'bl_manacle', type = 'blind' },
		},
	},
}