SMODS.Joker({
	key = "digital_circus",
	config = {
		extra = {
			max_rounds = 2,
			current_rounds = 0,
			current_rarity = 1,
			rarity_strings = { "Common", "Uncommon", "Rare" },
		},
	},
	rarity = 3,
	loc_vars = function(self, info_queue, card)
		return {
			vars = {
				card.ability.extra.rarity_strings[card.ability.extra.current_rarity],
				card.ability.extra.current_rounds,
				card.ability.extra.max_rounds,
				colours = {
					G.C.RARITY[card.ability.extra.current_rarity],
				},
			},
		}
	end,
	atlas = "Jokers",
	pos = { x = 2, y = 0 },
	cost = 8,
	unlocked = true,
	discovered = true,
	blueprint_compat = false,
	demicoloncompat = true,
	eternal_compat = false,
	perishable_compat = true,
	calculate = function(self, card, context)
		if context.selling_self or context.forcetrigger and not context.blueprint then
			if #G.jokers.cards <= G.jokers.config.card_limit then
				local rarity_vals = { "Common", "Uncommon", "Rare" }
				SMODS.add_card({
					set = "Joker",
					area = G.jokers,
					rarity = rarity_vals[card.ability.extra.current_rarity],
					edition = poll_edition("digital_circus", 1, false, true),
				})
				return nil, true
			else
				return { message = localize("k_no_room_ex") }
			end
		end

		if (context.end_of_round and context.main_eval) or context.forcetrigger then
			if card.ability.extra.current_rarity ~= 4 then
				card.ability.extra.current_rounds = card.ability.extra.current_rounds + 1
				if card.ability.extra.current_rounds >= card.ability.extra.max_rounds then
					card.ability.extra.current_rarity = card.ability.extra.current_rarity + 1
					if card.ability.extra.current_rarity ~= 4 then
						card.ability.extra.current_rounds = 0
					end
				end
				if
					card.ability.extra.current_rounds ~= 0
					and card.ability.extra.current_rounds ~= card.ability.extra.max_rounds
				then
					return {
						message = card.ability.extra.current_rounds .. "/" .. card.ability.extra.max_rounds,
						colour = G.C.FILTER,
					}
				else
					return {
						message = card.ability.extra.rarity_strings[card.ability.extra.current_rarity] .. "!",
						colour = G.C.RARITY[card.ability.extra.current_rarity],
					}
				end
			end
		end
	end,
})
