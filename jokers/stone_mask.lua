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
	unlock_condition = { type = 'round_win', extra = 5 },
	loc_vars = function(self, info_queue, card)
		-- No tooltips needed
	end,
	check_for_unlock = function(self, args)
		if args.type == 'round_win' then
			local jokers = SMODS.find_card('j_vampire')
			for _, v in ipairs(jokers) do
				if v.ability and v.ability.extra and v.ability.extra.x_mult and v.ability.extra.x_mult >= self.unlock_condition.extra then
					return true
				end
			end
		end
	end,
	calculate = function(self, card, context)
		if
			(context.before and #context.full_hand == 1 and G.GAME.current_round.hands_played == 0)
			or (context.forcetrigger and #G.play > 0)
		then
			local othercard = G.play.cards[1]
			if othercard then
				-- Check if card already has seal, edition, or enhancement
				local has_seal = othercard.seal ~= nil
				local has_edition = othercard.edition ~= nil
				local has_enhancement = othercard.ability.set ~= 'Default'
				
				-- Only activate if card doesn't have all three types
				if not (has_seal and has_edition and has_enhancement) then
					G.E_MANAGER:add_event(Event({
						func = function()
							-- Determine which bonuses the card already has
							local has_seal = othercard.seal ~= nil
							local has_edition = othercard.edition ~= nil
							local has_enhancement = othercard.ability.set ~= 'Default'
							
							-- Create list of missing bonuses to choose from
							local missing_bonuses = {}
							if not has_seal then table.insert(missing_bonuses, 'seal') end
							if not has_edition then table.insert(missing_bonuses, 'edition') end
							if not has_enhancement then table.insert(missing_bonuses, 'enhancement') end
							
							if #missing_bonuses > 0 then
								-- Choose randomly from missing bonuses
								local choice = missing_bonuses[pseudorandom('stone_mask_choice'..tostring(othercard.ID or ''), 1, #missing_bonuses)]
								
								if choice == 'seal' then
									-- Give random seal using SMODS.poll_seal
									local seal = SMODS.poll_seal({ key = 'stone_mask', guaranteed = true })
									othercard:set_seal(seal, true)
								elseif choice == 'edition' then
									-- Give random edition (weighted)
									othercard:set_edition(
										poll_edition("tag", nil, false, true, {
											{ name = "e_foil", weight = 40 },
											{ name = "e_holo", weight = 40 },
											{ name = "e_polychrome", weight = 15 },
											{ name = "e_negative", weight = 5 },
										}),
										true
									)
								elseif choice == 'enhancement' then
									-- Give random enhancement (weighted)
									local enhancements = {
										{ key = 'm_wild', weight = 25 },
										{ key = 'm_mult', weight = 25 },
										{ key = 'm_bonus', weight = 20 },
										{ key = 'm_glass', weight = 15 },
										{ key = 'm_steel', weight = 10 },
										{ key = 'm_stone', weight = 5 }
									}
									local total_weight = 0
									for _, enh in ipairs(enhancements) do total_weight = total_weight + enh.weight end
									local rand = pseudorandom('stone_mask_enhance_weight'..tostring(othercard.ID or ''), 1, total_weight)
									local current_weight = 0
									local selected_enhancement = enhancements[1].key
									for _, enh in ipairs(enhancements) do
										current_weight = current_weight + enh.weight
										if rand <= current_weight then
											selected_enhancement = enh.key
											break
										end
									end
									set_enhancement(othercard, selected_enhancement)
								end
							end
							return true
						end,
					}))
					
					return {
						message = localize("k_hnds_awaken"),
						colour = G.C.GREY,
					}
				end
			end
		end
	end,
})
