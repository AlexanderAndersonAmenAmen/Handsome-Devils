SMODS.Joker({
	key = "creepy",
	atlas = "Jokers",
	pos = { x = 7, y = 3 },
	rarity = 2,
	cost = 7,
	unlocked = true,
	discovered = true,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	config = { extra = { xmult = 2, odds = 4 } },
	loc_vars = function(self, info_queue, card)
		local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, "hnds_creepy")
		return { vars = { card.ability.extra.xmult, numerator, denominator } }
	end,
	calculate = function(self, card, context)
		if context.joker_main then
			return {
				xmult = card.ability.extra.xmult,
			}
		end

		if context.end_of_round and context.main_eval and not context.blueprint and not context.retrigger_joker then
			if SMODS.pseudorandom_probability(card, "hnds_creepy", 1, card.ability.extra.odds, "hnds_creepy") then
				-- Find this joker's index
				local this_index = nil
				for i, c in ipairs(G.jokers.cards) do
					if c == card then
						this_index = i
						break
					end
				end
				if not this_index then return end

				-- Collect adjacent jokers (left and right)
				local adjacent = {}
				if this_index > 1 then
					adjacent[#adjacent + 1] = G.jokers.cards[this_index - 1]
				end
				if this_index < #G.jokers.cards then
					adjacent[#adjacent + 1] = G.jokers.cards[this_index + 1]
				end

				if #adjacent > 0 then
					-- Check if there's at least one valid non-Creepy target
					local has_valid_target = false
					for _, target in ipairs(adjacent) do
						if target and target.area == G.jokers and target.config.center.key ~= card.config.center.key then
							has_valid_target = true
							break
						end
					end
					if not has_valid_target then return end

					for _, target in ipairs(adjacent) do
						if target and target.area == G.jokers and target.config.center.key ~= card.config.center.key then
							-- Flip animation
							G.E_MANAGER:add_event(Event({
								trigger = 'after',
								delay = 0.15,
								func = function()
									if target and target.states then
										target:flip()
										play_sound('card1', 1.1)
										target:juice_up(0.3, 0.3)
									end
									return true
								end
							}))

							-- Replace target with an exact copy of Creepy Joker
							G.E_MANAGER:add_event(Event({
								func = function()
									if target and target.area == G.jokers then
										copy_card(card, target, nil, nil, true)
									end
									return true
								end
							}))

							-- Unflip animation
							G.E_MANAGER:add_event(Event({
								trigger = 'after',
								delay = 0.15,
								func = function()
									if target and target.states then
										target:flip()
										play_sound('tarot2', 1, 0.6)
										target:juice_up(0.3, 0.3)
									end
									return true
								end
							}))
						end
					end

					return {
						message = localize("k_hnds_creepy_"..pseudorandom("hnds_creepy_phrase", 1, 8)), --update to highest phrase number
						colour = G.C.RED,
					}
				end
			end
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
			extra = {
				{
					{ text = "(" },
					{ ref_table = "card.joker_display_values", ref_value = "odds" },
					{ text = ")" }
				}
			},
			calc_function = function(card)
				card.joker_display_values.x_mult = card.ability.extra.xmult
				card.joker_display_values.odds = localize { type = 'variable', key = 'jdis_odds', vars = { (G.GAME and G.GAME.probabilities.normal or 1), card.ability.extra.odds } }
			end
		}
	end,
	attributes = { "xmult", "chance" }
})
