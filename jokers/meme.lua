SMODS.Joker({
	key = "meme",
	atlas = "Jokers",
	pos = { x = 0, y = 1 },
	rarity = 3,
	cost = 8,
	unlocked = false,
	discovered = false,
	unlock_condition = { type = "hnds_joker_unlock", key = "meme" },
	locked_loc_vars = function(self)
	    return HNDS.joker_locked_loc_vars("meme")
	end,
	check_for_unlock = function(self, args)
	    return HNDS.joker_unlock_condition_met("meme", args)
	end,
	blueprint_compat = true,
	demicoloncompat = true,
	eternal_compat = true,
	perishable_compat = false,
	config = {
		extra = {
			x_mult = 1,
			scaling = 0.05,
		},
	},
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.x_mult, card.ability.extra.scaling } }
	end,
	calculate = function(self, card, context)
		if context.before and not context.blueprint and not context.retrigger_joker then
			local boost = HNDS.get_unique_suits(context.scoring_hand)
			if boost > 0 then
				SMODS.scale_card(card, {
					ref_table = card.ability.extra,
					ref_value = "x_mult",
					scalar_value = "scaling",
					operation = function(ref_table, ref_value, initial, change)
						ref_table[ref_value] = initial + boost * change
					end,
				})
				return nil, true
			end
		elseif context.joker_main or context.forcetrigger then
			return {
				xmult = card.ability.extra.x_mult,
			}
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
	attributes = { "xmult", "scaling", "suit", }
})
