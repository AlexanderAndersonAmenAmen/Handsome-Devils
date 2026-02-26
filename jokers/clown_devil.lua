SMODS.Joker({
	key = "clown_devil",
	atlas = "Jokers",
	pos = { x = 1, y = 4 },
	rarity = 1,
	cost = 5,
	unlocked = true,
	discovered = true,
	blueprint_compat = true,
	demicoloncompat = true,
	eternal_compat = true,
	perishable_compat = true,
	config = {
		extra = {
			eaten = 0,
			per_tag = 3,
		}
	},
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.eaten, card.ability.extra.per_tag } }
	end,
	calculate = function(self, card, context)
		-- On blind select: consume held consumables and convert into tags
		if context.setting_blind and G.consumeables and G.consumeables.cards then
			local to_remove = {}
			for _, c in ipairs(G.consumeables.cards) do
				to_remove[#to_remove + 1] = c
			end
			local eaten = #to_remove
			if eaten > 0 then
				for _, c in ipairs(to_remove) do
					G.E_MANAGER:add_event(Event({
						trigger = 'after',
						delay = 0.15,
						func = function()
							c:start_dissolve()
							return true
						end,
					}))
				end
				card.ability.extra.eaten = card.ability.extra.eaten + eaten
				-- Every 3 eaten consumables -> random tag
				while card.ability.extra.eaten >= card.ability.extra.per_tag do
					card.ability.extra.eaten = card.ability.extra.eaten - card.ability.extra.per_tag
					add_tag(HNDS.poll_tag('hnds_clown_devil'))
				end
				return {
					message = localize('k_hnds_clown_eat'),
					colour = G.C.RED
				}
			end
		end
	end,
})
