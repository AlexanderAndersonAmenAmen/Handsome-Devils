SMODS.Joker({
	key = "balloons",
	config = {
		extra = {
			balloons = 3,
			amount = 3,
		},
	},
	rarity = 1,
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.balloons, card.ability.extra.amount } }
	end,
	atlas = "Jokers",
	pos = { x = 9, y = 1 },
	cost = 5,
	unlocked = true,
	discovered = true,
	blueprint_compat = false,
	demicoloncompat = true,
	eternal_compat = false,
	calculate = function(self, card, context)
		if
			(context.end_of_round and context.main_eval and G.GAME.current_round.hands_left == 0)
			or context.forcetrigger and card.ability.extra.balloons > 0
		then
			local tag = HNDS.poll_tag("hnds_balloons")
			add_tag(tag)
			card:juice_up()
			card.ability.extra.balloons = card.ability.extra.balloons - 1
			if card.ability.extra.balloons <= 0 and not context.blueprint then
				SMODS.calculate_effect({ message = localize("k_hnds_balloons"), colour = G.C.RED }, card)
				G.E_MANAGER:add_event(Event({
					func = function()
						card:start_dissolve()
						return true
					end,
				}))
			end
			return nil, true
		end
	end,
})
