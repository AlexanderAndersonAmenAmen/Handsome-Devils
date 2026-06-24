local function hnds_stone_mask_weighted_pick(seed, options)
	local total = 0
	for _, o in ipairs(options) do total = total + (o.weight or 1) end
	if total <= 0 then return options[1] and options[1].key or nil end
	local roll = pseudorandom(seed) * total
	local acc = 0
	for _, o in ipairs(options) do
		acc = acc + (o.weight or 1)
		if roll <= acc then return o.key end
	end
	return options[#options].key
end

SMODS.Joker({
	key = "stone_mask",
	atlas = "Jokers",
	pos = { x = 5, y = 1 },
	rarity = 3,
	cost = 10,
	unlocked = false,
	discovered = false,
	blueprint_compat = false,
	eternal_compat = true,
	perishable_compat = true,
	unlock_condition = { type = 'modify_jokers', extra = 5 },
	check_for_unlock = function(self, args)
		if args.type == 'modify_jokers' then
			local jokers = SMODS.find_card('j_vampire')
			for _, v in ipairs(jokers) do
				if v.ability and v.ability.extra and v.ability.extra.x_mult
						and v.ability.extra.x_mult >= self.unlock_condition.extra then
					return true
				end
			end
		end
	end,
	calculate = function(self, card, context)
		if context.setting_blind and not context.blueprint then
			local eval = function(c)
				return not c.REMOVED and G.GAME.current_round and G.GAME.current_round.hands_played == 0
			end
			juice_card_until(card, eval, true)
		end

		local trigger =
			(context.before and not context.blueprint and #context.full_hand == 1
				and G.GAME.current_round.hands_played == 0)
			or (context.forcetrigger and G.play and #G.play.cards > 0)
		if not trigger then return end

		local target = (G.play and G.play.cards[1]) or context.full_hand and context.full_hand[1]
		if not target then return end

		-- Priority: enhancement > edition > seal. Pick first missing slot.
		local has_enhancement = target.ability and target.ability.set ~= 'Default' and target.ability.set ~= nil
		local choice = not has_enhancement and 'enhancement' or not target.edition and 'edition' or not target.seal and 'seal'
		if not choice then return end

		local seed_id = tostring(target.sort_id or target.ID or '')

		if choice == 'enhancement' then
			local enh = hnds_stone_mask_weighted_pick('hnds_stone_mask_enh' .. seed_id, {
				{ key = 'm_wild',  weight = 20 },
				{ key = 'm_mult',  weight = 20 },
				{ key = 'm_bonus', weight = 15 },
				{ key = 'm_glass', weight = 15 },
				{ key = 'm_steel', weight = 12 },
				{ key = 'm_gold',  weight = 9 },
				{ key = 'm_stone', weight = 9 },
			})
			if enh and G.P_CENTERS[enh] then
				target:set_ability(G.P_CENTERS[enh], nil, nil)
			end
		elseif choice == 'edition' then
			local ed_key = hnds_stone_mask_weighted_pick('hnds_stone_mask_edition' .. seed_id, {
				{ key = 'e_foil',       weight = 40 },
				{ key = 'e_holo',       weight = 40 },
				{ key = 'e_polychrome', weight = 15 },
				{ key = 'e_negative',   weight = 5 },
			})
			if ed_key then
				target:set_edition(ed_key, true, true)
			end
		elseif choice == 'seal' then
			local seal_key = hnds_stone_mask_weighted_pick('hnds_stone_mask_seal' .. seed_id, {
				{ key = 'Red',        weight = 20 },
				{ key = 'Blue',       weight = 20 },
				{ key = 'Gold',       weight = 20 },
				{ key = 'Purple',     weight = 20 },
				{ key = 'hnds_black', weight = 20 },
			})
			if seal_key then target:set_seal(seal_key, true) end
		end
		target:juice_up()

		card_eval_status_text(card, 'jokers', nil, nil, nil, { message = localize('k_hnds_awaken'), colour = G.C.GREY, delay = 0.4 })
		return nil, true
	end,
	attributes = { "modify_card", "enhancements", "editions", "seals", "hands" }
})
