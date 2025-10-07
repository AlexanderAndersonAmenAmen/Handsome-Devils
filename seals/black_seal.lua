SMODS.Seal({
	key = "black",
	badge_colour = HEX("545454"),
	atlas = "Extras",
	pos = { x = 3, y = 1 },
	--sound = { sound = 'blk_seal_obtained', per = 1.06, vol = 0.4 },
	discovered = true,

	loc_vars = function(self, info_queue)
		return { vars = {} }
	end,

	-- self - this seal prototype
	-- card - card this seal is applied to
	calculate = function(self, card, context)
		if context.main_scoring and context.cardarea == G.hand and not context.black_trigger then
			local new_context = {}
			for k, v in pairs(context) do
				new_context[k] = v
			end
			new_context.black_trigger = true
			new_context.cardarea = G.play
			local eval, post = eval_card(card, new_context)
			local effects = {eval}
			new_context.main_scoring = nil
			new_context.individual = true
			SMODS.calculate_context(new_context)
			for _,v in ipairs(post or {}) do
				effects[#effects+1] = v
			end
			if eval.retriggers then
				for rt = 1, #eval.retriggers do
					local rt_eval, rt_post = eval_card(card, new_context)
					table.insert(effects, {eval.retriggers[rt]})
					table.insert(effects, rt_eval)
					for _, v in ipairs(rt_post or {}) do
						effects[#effects+1] = v
					end
					SMODS.calculate_context(new_context)
				end
			end
			SMODS.trigger_effects(effects, card)
		end
		if context.destroying_card and context.destroy_card == card and context.cardarea == G.hand and not context.black_trigger then
			local new_context = {}
			for k, v in pairs(context) do
				new_context[k] = v
			end
			new_context.black_trigger = true
			new_context.cardarea = G.play
			local eval, post = eval_card(card, new_context)
			local remove
			for k,v in pairs(eval) do
				if v.remove then remove = true end
			end
			return {
				remove = remove
			}
		end
	end,
})

local get_areas_ref = SMODS.get_card_areas
SMODS.get_card_areas = function (_type, _context)
	local ret = get_areas_ref(_type, _context)
	if _type == 'playing_cards' and _context == 'destroying_cards' then
		ret[#ret+1] = G.hand
	end
	return ret
end