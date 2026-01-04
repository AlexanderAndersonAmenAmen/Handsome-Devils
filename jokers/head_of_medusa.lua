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
		if context.end_of_round and context.individual and context.other_card and context.other_card:is_face() then
			local c = context.other_card
			
			-- Avoid re-queuing the same card multiple times in the same end-of-round pass
			if not c.hnds_medusa_queued then
				c.hnds_medusa_queued = true
				c.hnds_petrifying = true
				G.GAME.hnds_medusa_queue = G.GAME.hnds_medusa_queue or {}
				G.GAME.hnds_medusa_queue[#G.GAME.hnds_medusa_queue + 1] = c
			end
			
			-- Schedule the animation once; the queue will be filled during the individual loop
			if not G.GAME.hnds_medusa_anim_scheduled then
				G.GAME.hnds_medusa_anim_scheduled = true
				
				-- Show petrification message immediately
				local q = G.GAME.hnds_medusa_queue or {}
				if #q > 0 then
					card_eval_status_text(card, 'extra', nil, nil, nil, {
						message = localize('k_hnds_petrified'),
						colour = G.C.GREY
					})
				end
				
				-- Apply stone to all queued cards after delay
				G.E_MANAGER:add_event(Event({
					delay = 0.8,
					func = function()
						local q = G.GAME.hnds_medusa_queue or {}
						for _, qc in ipairs(q) do
							if qc and qc.area == G.hand then
								qc:set_ability(G.P_CENTERS.m_stone, nil, false)
								qc.hnds_petrifying = nil
								qc:juice_up()
							end
						end
						return true
					end
				}))
				
				-- Delay the end of round to allow visual feedback
				G.E_MANAGER:add_event(Event({
					delay = 1.5,
					func = function()
						-- This delay prevents the round from ending too quickly
						-- allowing players to see the petrification effect
						return true
					end
				}))
				
				-- Cleanup per-round flags
				G.E_MANAGER:add_event(Event({
					func = function()
						local q = G.GAME.hnds_medusa_queue or {}
						for _, qc in ipairs(q) do
							if qc then
								qc.hnds_medusa_queued = nil
								qc.hnds_petrifying = nil
							end
						end
						G.GAME.hnds_medusa_queue = nil
						G.GAME.hnds_medusa_anim_scheduled = nil
						return true
					end
				}))
			end
			
			SMODS.scale_card(card, {
				ref_table = card.ability.extra,
				ref_value = "x_mult",
				scalar_value = "scaling",
				scaling_message = { message_key = "k_hnds_petrified", colour = G.C.GREY, }
			})
			
			return nil, true
		end
		if context.forcetrigger then
			if G.hand and #G.hand.cards > 0 then
				local faces = 0
				local face_cards = {}
				
				-- Collect face cards first
				for _, c in ipairs(G.hand.cards) do
					if c:is_face() then
						c.hnds_petrifying = true
						faces = faces + 1
						face_cards[#face_cards + 1] = c
					end
				end
				
				if faces > 0 then
					-- Show petrification message immediately
					card_eval_status_text(card, 'extra', nil, nil, nil, {
						message = localize('k_hnds_petrified'),
						colour = G.C.GREY
					})
					
					-- Apply stone to all face cards after delay
					G.E_MANAGER:add_event(Event({
						delay = 0.8,
						func = function()
							for _, c in ipairs(face_cards) do
								if c and c.area == G.hand then
									c:set_ability(G.P_CENTERS.m_stone, nil, false)
									c.hnds_petrifying = nil
									c:juice_up()
								end
							end
							return true
						end
					}))
					
					SMODS.scale_card(card, {
						ref_table = card.ability.extra,
						ref_value = "x_mult",
						scalar_value = "scaling",
						scaling_message = { message_key = "k_hnds_petrified", colour = G.C.GREY },
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
			return { xmult = card.ability.extra.x_mult, }
		end
	end,
})
