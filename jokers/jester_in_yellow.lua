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
	config = { extra = { rounds = 6 } },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.rounds } }
	end,
	calculate = function(self, card, context)
		-- On blind select: apply temporary Negative to leftmost Joker only
		if context.setting_blind and G.jokers and G.jokers.cards and #G.jokers.cards > 0 then
			local target = G.jokers.cards[1]
			-- Skip if leftmost is this card itself, already has temporary Negative, or is already naturally Negative
			if target and target ~= card and not target.ability.hnds_jester_negative_rounds and not (target.edition and target.edition.negative) then
				target:set_edition("e_negative")
				target:juice_up(0.3, 0.5)
				target.ability.hnds_jester_negative_rounds = card.ability.extra.rounds
				target:add_sticker('hnds_jester_temp_negative', true)
				return nil, true
			end
		end
	end,
	attributes = { "modify_card", "destroy_card", }
})

SMODS.Sticker {
	key = "jester_temp_negative",
	atlas = "Stickers",
	pos = { x = 0, y = 1 },
	badge_colour = G.C.HNDS_CARCOSA,
	rate = 0,
	sets = { Joker = true },
	should_apply = function(self, card, center, area, bypass_roll)
		if card.ability.hnds_cursed then return false end
		return SMODS.Sticker.should_apply(self, card, center, area, bypass_roll)
	end,
	apply = function(self, card, val)
		SMODS.Sticker.apply(self, card, val)
		if val then
			if SMODS and SMODS.Sticker and SMODS.Sticker.obj_buffer then
				for _, k in ipairs(SMODS.Sticker.obj_buffer) do
					if k ~= self.key and k ~= 'eternal' and k ~= 'hnds_cursed' and card.ability[k] then
						card:remove_sticker(k)
					end
				end
			end
			card.ability.hnds_jester_saved_sell_cost = card.sell_cost
			card.sell_cost = 0
			card.sell_cost_label = 0
		else
			if card.ability.hnds_jester_saved_sell_cost then
				card.sell_cost = card.ability.hnds_jester_saved_sell_cost
				card.sell_cost_label = card.ability.hnds_jester_saved_sell_cost
				card.ability.hnds_jester_saved_sell_cost = nil
			end
		end
	end,
	update = function(self, card, dt)
		if card.sell_cost ~= 0 then
			card.sell_cost = 0
			card.sell_cost_label = 0
		end
	end,
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.hnds_jester_negative_rounds or 0 } }
	end,
	calculate = function(self, card, context)
		if context.end_of_round and context.main_eval then
			card.ability.hnds_jester_negative_rounds = card.ability.hnds_jester_negative_rounds - 1
			if card.ability.hnds_jester_negative_rounds <= 0 then
				SMODS.calculate_effect({ message = localize("k_hnds_jester_fade") }, card)
				SMODS.destroy_cards(card, {immediate = true, bypass_eternal = true})
			else
				SMODS.calculate_effect({ message = localize{ type = "variable", key = "a_remaining", vars = { card.ability.hnds_jester_negative_rounds } } }, card)
			end
		end
	end,
}
