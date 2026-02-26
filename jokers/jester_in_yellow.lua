SMODS.Joker({
	key = "jester_in_yellow",
	atlas = "Jokers",
	pos = { x = 2, y = 4 },
	rarity = 3,
	cost = 8,
	unlocked = true,
	discovered = true,
	blueprint_compat = true,
	demicoloncompat = false,
	eternal_compat = true,
	perishable_compat = true,
	config = { extra = { rounds = 5 } },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.rounds } }
	end,
	calculate = function(self, card, context)
		-- On blind select: apply temporary Negative to leftmost Joker only
		if context.setting_blind and G.jokers and G.jokers.cards and #G.jokers.cards > 0 then
			local target = G.jokers.cards[1]
			-- Skip if leftmost is this card itself, already has temporary Negative, or is already naturally Negative
			if target and target ~= card and not target.ability.hnds_jester_negative_rounds and not (target.edition and target.edition.negative) then
				play_sound('negative', 1.5, 0.4)
				target:set_edition("e_negative", nil, true)
				target:juice_up(0.3, 0.5)
				target.ability.hnds_jester_negative_rounds = card.ability.extra.rounds
				if target.add_sticker then
					target:add_sticker('hnds_jester_temp_negative', true)
				end
				return nil, true
			end
		end
	end,
})

SMODS.Sticker({
	key = 'hnds_jester_temp_negative',
	badge_colour = G.C.HNDS_CARCOSA or G.C.GOLD,
	pos = { x = 10, y = 10 },
	rate = 0,
	sets = { Joker = true },
	loc_vars = function(self, info_queue, card)
		local source = card
		if not source and G and G.jokers and G.jokers.cards then
			for _, j in ipairs(G.jokers.cards) do
				local has_sticker = (j and j.stickers and j.stickers.hnds_jester_temp_negative) or (j and j.ability and j.ability.stickers and j.ability.stickers.hnds_jester_temp_negative)
				if j and j.ability and j.ability.hnds_jester_negative_rounds and has_sticker then
					source = j
					break
				end
			end
		end
		local rounds_left = source and source.ability and source.ability.hnds_jester_negative_rounds
		if rounds_left == nil and info_queue and info_queue.card and info_queue.card.ability then
			rounds_left = info_queue.card.ability.hnds_jester_negative_rounds
		end
		return { vars = { rounds_left or 0 } }
	end,
	generate_ui = function(self, info_queue, card, desc_nodes, specific_vars, full_UI_table)
		if not desc_nodes then return end
		local source = card
		if not source and G and G.jokers and G.jokers.cards then
			for _, j in ipairs(G.jokers.cards) do
				local has_sticker = (j and j.stickers and j.stickers.hnds_jester_temp_negative) or (j and j.ability and j.ability.stickers and j.ability.stickers.hnds_jester_temp_negative)
				if j and j.ability and j.ability.hnds_jester_negative_rounds and has_sticker then
					source = j
					break
				end
			end
		end
		local rounds_left = source and source.ability and source.ability.hnds_jester_negative_rounds
		if rounds_left == nil and specific_vars and specific_vars[1] ~= nil then
			rounds_left = specific_vars[1]
		end
		rounds_left = rounds_left or 0
		for i = #desc_nodes, 1, -1 do
			desc_nodes[i] = nil
		end
		localize({
			type = 'other',
			key = 'hnds_jester_temp_negative',
			nodes = desc_nodes,
			vars = { rounds_left },
			shadow = false,
			default_col = G.C.UI.TEXT_DARK,
		})
	end,
	calculate = function(self, card, context)
		if not (card and card.ability and card.ability.hnds_jester_negative_rounds) then return end
		if not (context and context.end_of_round and context.main_eval) then return end

		card.ability.hnds_jester_negative_rounds = card.ability.hnds_jester_negative_rounds - 1
		if card.ability.hnds_jester_negative_rounds <= 0 then
			card.ability.hnds_jester_negative_rounds = nil
			if card.remove_sticker then
				card:remove_sticker('hnds_jester_temp_negative')
			else
				if card.stickers then
					card.stickers.hnds_jester_temp_negative = nil
				end
				if card.ability and card.ability.stickers then
					card.ability.stickers.hnds_jester_temp_negative = nil
				end
			end
			if card.sticker_display then
				card.sticker_display:remove()
				card.sticker_display = nil
			end
			G.E_MANAGER:add_event(Event({
				func = function()
					card:start_dissolve({ G.C.HNDS_CARCOSA or G.C.GOLD })
					return true
				end,
			}))
		else
			card_eval_status_text(card, 'extra', nil, nil, nil, {
				message = card.ability.hnds_jester_negative_rounds .. " " .. localize("k_hnds_jester_negative"),
				colour = G.C.DARK_EDITION
			})
		end
	end,
})
