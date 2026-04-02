SMODS.Joker({
	key = "jester_in_yellow",
	atlas = "Jokers",
	pos = { x = 2, y = 4 },
	rarity = 3,
	cost = 8,
	unlocked = true,
	discovered = true,
	blueprint_compat = true,
	demicoloncompat = false,
	eternal_compat = true,
	perishable_compat = true,
	config = { extra = { rounds = 5 } },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.rounds } }
	end,
	calculate = function(self, card, context)
		-- On blind select: apply temporary Negative to leftmost Joker only
		if context.setting_blind and G.jokers and G.jokers.cards and #G.jokers.cards > 0 then
			local target = G.jokers.cards[1]
			-- Skip if leftmost is this card itself, already has temporary Negative, or is already naturally Negative
			if target and target ~= card and not target.ability.hnds_jester_negative_rounds and not (target.edition and target.edition.negative) then
				target:set_edition("e_negative")
				target:juice_up(0.3, 0.5)
				target.ability.hnds_jester_negative_rounds = card.ability.extra.rounds
				return nil, true
			end
		end
	end,
	attributes = { "modify_card", "destroy_card", }
})
