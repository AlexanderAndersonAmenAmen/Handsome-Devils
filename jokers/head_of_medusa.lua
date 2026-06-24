-- patatas
local function hnds_petrify(card, face_cards)
	card_eval_status_text(card, 'extra', nil, nil, nil, {
		message = localize('k_hnds_petrified'),
		colour = G.C.GREY,
	})
	for _, c in ipairs(face_cards) do
		if c and c.area == G.hand then
			c:set_ability(G.P_CENTERS.m_stone, nil, false)
			c:juice_up()
		end
	end
	SMODS.scale_card(card, {
		ref_table = card.ability.extra,
		ref_value = "x_mult",
		scalar_value = "scaling",
		scaling_message = { message_key = "k_hnds_petrified", colour = G.C.GREY },
		operation = function(ref_table, ref_value, initial, change)
			ref_table[ref_value] = initial + #face_cards * change
		end,
	})
	G.E_MANAGER:add_event(Event({
		trigger = 'after',
		delay = 1.5,
		func = function() return true end,
	}))
end

SMODS.Joker({
	key = "head_of_medusa",
	config = { extra = { x_mult = 1, scaling = 0.2, }, },
	rarity = 2,
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue+1] = G.P_CENTERS.m_stone
		return { vars = { card.ability.extra.x_mult, card.ability.extra.scaling } }
	end,
	atlas = "Jokers",
	pos = { x = 6, y = 0 },
	cost = 8,
	unlocked = true,
	discovered = true,
	blueprint_compat = true,
	demicoloncompat = true,
	eternal_compat = true,
	perishable_compat = false,
	calculate = function(self, card, context)
		if context.end_of_round and context.individual and context.other_card
			and context.other_card:is_face() and context.other_card.area == G.hand then
			local face_cards = {}
			for _, c in ipairs(G.hand.cards) do
				if c:is_face() and not c.hnds_medusa_petrified then
					c.hnds_medusa_petrified = true
					face_cards[#face_cards + 1] = c
				end
			end
			if #face_cards > 0 then
				hnds_petrify(card, face_cards)
			end
			return nil, true
		end

		if context.forcetrigger and G.hand and #G.hand.cards > 0 then
			local face_cards = {}
			for _, c in ipairs(G.hand.cards) do
				if c:is_face() then face_cards[#face_cards + 1] = c end
			end
			if #face_cards > 0 then
				hnds_petrify(card, face_cards)
			end
			return { xmult = card.ability.extra.x_mult }
		end

		if context.joker_main and context.cardarea == G.jokers then
			return { xmult = card.ability.extra.x_mult }
		end
	end,
	joker_display_def = function(JokerDisplay)
		return {
			text = {
				{
					border_nodes = {
						{ text = "X" },
						{ ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" }
					}
				}
			},
			calc_function = function(card)
				card.joker_display_values.x_mult = card.ability.extra.x_mult
			end
		}
	end,
	attributes = { "face", "enhancements", "xmult", "scaling", }
})
