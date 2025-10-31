SMODS.Joker({
	key = "banana_split",
	atlas = "Jokers",
	pos = { x = 0, y = 2 },
	rarity = 2,
	cost = 5,
	unlocked = true,
	discovered = true,
	blueprint_compat = false,
	demicoloncompat = true,
	eternal_compat = false,
	perishable_compat = false,
	config = { extra = {
		Xmult = 1.5,
		odds = 6,
	} },
	pools = { Food = true },
	loc_vars = function(self, info_queue, card)
		local main_end
		if card and card.edition and card.edition.negative then
			main_end = {}
			localize { type = 'other', key = 'remove_negative', nodes = main_end, vars = {} }
		end
		local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, "hnds_banana_split")
		return { vars = { card.ability.extra.Xmult, numerator, denominator }, main_end = main_end }
	end,
	calculate = function(self, card, context)
		if context.joker_main then
			return {
				xmult = card.ability.extra.Xmult,
			}
		end

		if
			(context.end_of_round and context.main_eval or context.forcetrigger)
				and not context.blueprint
				and #G.jokers.cards + G.GAME.joker_buffer < G.jokers.config.card_limit
		then
			if
				context.forcetrigger
				or SMODS.pseudorandom_probability(card, "banan", 1, card.ability.extra.odds, "hnds_banana_split")
			then
				local _card = copy_card(card, nil, nil, nil, card.edition and card.edition.negative)
				G.E_MANAGER:add_event(Event({
					func = function()
						_card:add_to_deck()
						G.jokers:emplace(_card)
						return true
					end,
				}))
				return {
					colour = G.C.ORANGE,
					message = localize("k_hnds_banana_split"),
					xmult = context.forcetrigger and card.ability.extra.Xmult or nil
				}
			end
		end
	end,
})
