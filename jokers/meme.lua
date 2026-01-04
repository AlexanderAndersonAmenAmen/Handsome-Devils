SMODS.Joker({
	key = "meme",
	atlas = "Jokers",
	pos = { x = 0, y = 1 },
	rarity = 3,
	cost = 8,
	unlocked = true,
	discovered = true,
	blueprint_compat = true,
	demicoloncompat = true,
	eternal_compat = true,
	perishable_compat = false, -- By default, all Scaling Jokers cant be perishable
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
					operation = function(ref_table, ref_value, initial, change) --errors but should work
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
})
