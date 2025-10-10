SMODS.Enhancement({
	key = "aberrant",
	atlas = "Extras",
	pos = { x = 2, y = 0 },
	config = { extra = { scale = 2, mult = 0 } },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.scale, card.ability.extra.mult }}
	end,
	weight = 2.5,
	calculate = function (self, card, context)
		if context.main_scoring and context.cardarea == G.hand then
			SMODS.scale_card(card, {
				ref_table = card.ability.extra,
				ref_value = "mult",
				scalar_value = "scale"
			})
		end
		if context.main_scoring and context.cardarea == G.play and card.ability.extra.mult ~= 0 then
			return {
				mult = card.ability.extra.mult
			}
		end
		if context.discard and context.other_card == card then
			return {
				remove = true
			}
		end
	end
})
