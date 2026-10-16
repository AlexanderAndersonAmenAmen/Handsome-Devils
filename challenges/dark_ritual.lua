local banned_tags = {
	{ id = 'tag_d_six' },
	{ id = 'tag_boss' }, -- Boss Reroll Tag stays banned, but is hidden from the Restrictions tab.
	{ id = 'tag_investment' },
	{ id = 'tag_economy' },
	{ id = 'tag_skip' },
	{ id = 'tag_hnds_dna_tag' },
	{ id = 'tag_foil' },
	{ id = 'tag_holo' },
	{ id = 'tag_polychrome' },
	{ id = 'tag_negative' },
	{ id = 'tag_hnds_vintage_tag' },
	{ id = 'tag_coupon' }, -- Actually banned; still displayed as the Vintage replacement.
	{ id = 'tag_handy' },
	{ id = 'tag_garbage' },
	{ id = 'tag_speed' },
	{ id = 'tag_hnds_extinction_tag' },
	{ id = 'tag_rare' },
	{ id = 'tag_uncommon' },
}


-- Keep the gameplay ban set independent from the display-only replacement
-- list. This is also consulted when a tag is generated outside the normal
-- blind-pool code (e.g. Mystery Tag).
HNDS = HNDS or {}
HNDS.art_gallery_banned_tags = {}
for _, entry in ipairs(banned_tags) do
    HNDS.art_gallery_banned_tags[entry.id] = true
    for _, key in ipairs(entry.ids or {}) do
        HNDS.art_gallery_banned_tags[key] = true
    end
end

local visible_tags = {
    tag_hnds_dna_tag = true,
    tag_foil = true,
    tag_holo = true,
    tag_polychrome = true,
    tag_negative = true,
    tag_hnds_vintage_tag = true,
    tag_rare = true,
    tag_uncommon = true,
}

-- The Art Gallery Restrictions tab uses display-only substitutes for two
-- banned tags. The gameplay ban list above is intentionally unchanged.
local display_tag_replacements = {
    tag_hnds_dna_tag = 'tag_d_six',
    tag_hnds_vintage_tag = 'tag_coupon',
}

local displayed_tags = {}
for _, tag in ipairs(banned_tags) do
    if visible_tags[tag.id] then
        displayed_tags[#displayed_tags + 1] = {
            id = display_tag_replacements[tag.id] or tag.id,
        }
    end
end

SMODS.Challenge {
	key = 'dark_ritual',
	loc_txt = {
		name = 'Art Gallery',
	},
	rules = {
		custom = {
			{ id = 'hnds_dark_ritual' },
		},
		modifiers = {
		},
	},
	jokers = {
		{ id = 'j_hnds_artistic_joker', eternal = true, edition = 'negative' },
		{ id = 'j_hnds_artistic_joker', eternal = true, edition = 'negative' },
	},
	consumeables = {
	},
	vouchers = {
	},
	deck = {
		type = 'Challenge Deck',
		cards = {
			{ s = 'S', r = 'A' }, { s = 'S', r = 'K' }, { s = 'S', r = 'Q' }, { s = 'S', r = 'J', e = 'm_wild' }, { s = 'S', r = 'T' }, { s = 'S', r = '9' }, { s = 'S', r = '8' }, { s = 'S', r = '7' }, { s = 'S', r = '6' }, { s = 'S', r = '5' }, { s = 'S', r = '4' }, { s = 'S', r = '3' }, { s = 'S', r = '2' },
			{ s = 'H', r = 'A' }, { s = 'H', r = 'K' }, { s = 'H', r = 'Q' }, { s = 'H', r = 'J', e = 'm_wild' }, { s = 'H', r = 'T' }, { s = 'H', r = '9' }, { s = 'H', r = '8' }, { s = 'H', r = '7' }, { s = 'H', r = '6' }, { s = 'H', r = '5' }, { s = 'H', r = '4' }, { s = 'H', r = '3' }, { s = 'H', r = '2' },
			{ s = 'C', r = 'A' }, { s = 'C', r = 'K' }, { s = 'C', r = 'Q' }, { s = 'C', r = 'J', e = 'm_wild' }, { s = 'C', r = 'T' }, { s = 'C', r = '9' }, { s = 'C', r = '8' }, { s = 'C', r = '7' }, { s = 'C', r = '6' }, { s = 'C', r = '5' }, { s = 'C', r = '4' }, { s = 'C', r = '3' }, { s = 'C', r = '2' },
			{ s = 'D', r = 'A' }, { s = 'D', r = 'K' }, { s = 'D', r = 'Q' }, { s = 'D', r = 'J', e = 'm_wild' }, { s = 'D', r = 'T' }, { s = 'D', r = '9' }, { s = 'D', r = '8' }, { s = 'D', r = '7' }, { s = 'D', r = '6' }, { s = 'D', r = '5' }, { s = 'D', r = '4' }, { s = 'D', r = '3' }, { s = 'D', r = '2' },
		},
	},
	restrictions = {
		banned_cards = {
			{ id = 'j_credit_card' },
			{ id = 'j_delayed_grat' },
			{ id = 'j_business' },
			{ id = 'j_egg' },
			{ id = 'j_faceless' },
			{ id = 'j_todo_list' },
			{ id = 'j_cloud_9' },
			{ id = 'j_midas_mask' },
			{ id = 'j_gift' },
			{ id = 'j_reserved_parking' },
			{ id = 'j_mail' },
			{ id = 'j_to_the_moon' },
			{ id = 'j_golden' },
			{ id = 'j_trading' },
			{ id = 'j_ticket' },
			{ id = 'j_rough_gem' },
			{ id = 'j_rocket' },
			{ id = 'j_satellite' },
			{ id = 'j_astronomer' },
			{ id = 'j_chaos' },
			{ id = 'j_flash' },
			{ id = 'j_hnds_arthur' },
			{ id = 'c_hermit' },
			{ id = 'c_devil' },
			{ id = 'c_magician' },
			{ id = 'c_temperance' },
			{ id = 'c_talisman' },
			{ id = 'v_clearance_sale' },
			{ id = 'v_liquidation' },
			{ id = 'v_reroll_surplus' },
			{ id = 'v_reroll_glut' },
			{ id = 'v_seed_money' },
			{ id = 'v_money_tree' },
		},
		banned_tags = function()
            return HNDS.challenge_restrictions_ui and displayed_tags or banned_tags
        end,
		banned_other = {
		},
	},
}
