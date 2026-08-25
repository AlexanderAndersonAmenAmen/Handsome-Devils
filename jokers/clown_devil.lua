SMODS.Joker({
	key = "clown_devil",
	atlas = "Jokers",
	pos = { x = 1, y = 4 },
	rarity = 1,
	cost = 3,
	unlocked = false,
	discovered = false,
	unlock_condition = { type = "hnds_joker_unlock", key = "clown_devil" },
	locked_loc_vars = function(self)
	    return HNDS.joker_locked_loc_vars("clown_devil")
	end,
	check_for_unlock = function(self, args)
	    return HNDS.joker_unlock_condition_met("clown_devil", args)
	end,
	blueprint_compat = true,
	demicoloncompat = true,
	eternal_compat = true,
	perishable_compat = true,
	config = { extra = { eaten = 0, per_tag = 2 } },
	loc_vars = function(self, info_queue, card)
		local extra = card.ability.extra
		local remaining = extra.per_tag - (extra.eaten % extra.per_tag)
		return { vars = { remaining, extra.per_tag } }
	end,
	calculate = function(self, card, context)

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

				while card.ability.extra.eaten >= card.ability.extra.per_tag do
					card.ability.extra.eaten = card.ability.extra.eaten - card.ability.extra.per_tag
					add_tag(HNDS.poll_tag('hnds_clown_devil'))
				end
				return { message = localize('k_hnds_clown_eat'), colour = G.C.RED }
			end
		end
	end,
	joker_display_def = function(JokerDisplay)
        return {
            text = {
                { text = "[" },
                { ref_table = "card.joker_display_values", ref_value = "remaining" },
                { text = "]" }
            },
            calc_function = function(card)
                local extra = card.ability.extra
                card.joker_display_values.remaining = extra.per_tag - (extra.eaten % extra.per_tag)
            end
        }
    end,
	attributes = { "destroy_card", "generation", }
})
