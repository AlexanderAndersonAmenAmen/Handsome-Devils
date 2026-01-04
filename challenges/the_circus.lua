SMODS.Challenge {
	key = 'the_circus',
	loc_txt = {
		name = 'The Circus',
	},
	rules = {
		custom = {
			{ id = 'hnds_the_circus' },
			{ id = 'no_shop_jokers' },
		},
		modifiers = {
		},
	},
	jokers = {
		{ id = 'j_hnds_digital_circus' },
		{ id = 'j_hnds_digital_circus' },
		{ id = 'j_hnds_digital_circus' },
		{ id = 'j_hnds_digital_circus' },
		{ id = 'j_hnds_digital_circus' },
	},
	consumeables = {
	},
	vouchers = {
	},
	restrictions = {
		banned_cards = {
			{ id = 'j_hnds_fregoli' },
			{ id = 'j_hnds_pennywise' },
			{ id = 'j_hnds_krusty' },
			{ id = 'j_hnds_banana_split' },
			{ id = 'j_invisible' },
			{ id = 'c_judgement' },
			{ id = 'c_wraith' },
			{ id = 'c_soul' },
			{ id = 'p_buffoon_normal_1', ids = {
				'p_buffoon_normal_1','p_buffoon_normal_2','p_buffoon_jumbo_1','p_buffoon_mega_1',
			}},
			{ id = 'v_blank' },
			{ id = 'v_antimatter' },
		},
		banned_tags = {
			{ id = 'tag_buffoon' },
			{ id = 'tag_top_up' },
			{ id = 'tag_holo' },
			{ id = 'tag_polychrome' },
			{ id = 'tag_negative' },
			{ id = 'tag_foil' },
			{ id = 'tag_rare' },
			{ id = 'tag_uncommon' },
			{ id = 'tag_hnds_vintage_tag' },
			{ id = 'tag_hnds_dna_tag' },
		},
		banned_other = {
			{ id = 'bl_final_leaf', type = 'blind' },
		},
	},
}