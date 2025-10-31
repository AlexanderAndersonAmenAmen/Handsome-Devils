SMODS.Joker({
	key = "jokes_aside",
	config = {
		extra = {
			x_mult = 1,
			scaling = 0.25,
		},
	},
	rarity = 2,
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.x_mult, card.ability.extra.scaling } }
	end,
	atlas = "Jokers",
	pos = { x = 9, y = 0 },
	cost = 6,
	unlocked = true,
	discovered = true,
	blueprint_compat = true,
	demicoloncompat = true,
	eternal_compat = true,
	perishable_compat = false,
	calculate = function(self, card, context)
		if
			not context.blueprint
			and (
				(
					context.selling_card
					and context.card ~= card
					and G.GAME.blind.in_blind
					and context.card.ability.set == "Joker"
				) or context.forcetrigger
			)
		then
			SMODS.scale_card(card, {
				ref_table = card.ability.extra,
				ref_value = "x_mult",
				scalar_value = "scaling",
			})
			return nil, true
		end

		--Scoring
		if context.joker_main or context.forcetrigger then
			return {
				xmult = card.ability.extra.x_mult,
			}
		end
	end,
})
