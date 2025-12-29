SMODS.Joker({
	key = "head_of_medusa",
	config = {
		extra = {
			x_mult = 1,
			scaling = 0.2,
		},
	},
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
		if context.end_of_round and context.individual and context.other_card:is_face() then
			context.other_card.hnds_petrifying = true
			local c = context.other_card
			G.E_MANAGER:add_event(Event({
				func = function()
					c:set_ability("m_stone", nil, true)
					c.hnds_petrifying = nil
					c:juice_up()
					return true
				end
			}))
			SMODS.scale_card(card, {
				ref_table = card.ability.extra,
				ref_value = "x_mult",
				scalar_value = "scaling",
				scaling_message = {
					message_key = "k_hnds_petrified",
					colour = G.C.GREY
				}
			})
			return nil, true
		end
		if context.forcetrigger then
			if G.hand and #G.hand.cards > 0 then
				local faces = 0
				for _, c in ipairs(G.hand.cards) do
					if c:is_face() then
						c.hnds_petrifying = true
						faces = faces + 1
						G.E_MANAGER:add_event(Event({
							func = function()
								c:set_ability("m_stone", nil, true)
								c.hnds_petrifying = nil
								c:juice_up()
								return true
							end
						}))
					end
				end
				if faces > 0 then
					SMODS.scale_card(card, {
						ref_table = card.ability.extra,
						ref_value = "x_mult",
						scalar_value = "scaling",
						scaling_message = {
							message_key = "k_hnds_petrified",
							colour = G.C.GREY
						},
						operation = function (ref_table, ref_value, initial, change)
							ref_table[ref_value] = initial + faces*change
						end
					})
				end
			end
			return {
				xmult = card.ability.extra.x_mult,
			}
		end

		--Scoring
		if context.joker_main and context.cardarea == G.jokers then
			return {
				xmult = card.ability.extra.x_mult,
			}
		end
	end,
})
