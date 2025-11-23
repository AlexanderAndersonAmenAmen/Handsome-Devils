SMODS.Joker({
	key = "jackpot",
	config = {
		extra = {
			base_chance = 20,
			money = 20,
			mult = 20,
		},
	},
	rarity = 2,
	loc_vars = function(self, info_queue, card)
		local seven = 0
		if G.hand and G.hand.highlighted then
			local _, _, _, cards = G.FUNCS.get_poker_hand_info(G.hand.highlighted)
			for _, c in ipairs(cards or {}) do
				if c:get_id() == 7 and c.facing == "front" then seven = seven + 1 end
			end
		end
		local numerator, denominator =
			SMODS.get_probability_vars(card, 2^seven, card.ability.extra.base_chance, "hnds_jackpot")
		return { vars = { numerator, denominator, card.ability.extra.money, card.ability.extra.mult, card.ability.extra.base_chance } }
	end,
	atlas = "Jokers",
	pos = { x = 8, y = 0 },
	cost = 4,
	unlocked = true,
	discovered = true,
	blueprint_compat = false,
	demicoloncompat = true,
	eternal_compat = false,
	perishable_compat = true,
	calculate = function(self, card, context)
		if context.joker_main then
			local seven = 0
			for _, c in ipairs(context.scoring_hand) do
				if c:get_id() == 7 then seven = seven+1 end
			end
			if SMODS.pseudorandom_probability(card, "hnds_jackpot", 2^seven, card.ability.extra.base_chance) then
				return {
					dollars = card.ability.extra.money,
					mult = card.ability.extra.mult
				}
			end
		end
	end,
})
