SMODS.Joker({
	key = "deep_pockets",
	config = {
		extra = {
			slots = 2,
			consumeable_mult = 8,
		},
	},
	rarity = 2,
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.slots, card.ability.extra.consumeable_mult } }
	end,
	atlas = "Jokers",
	pos = { x = 1, y = 0 },
	cost = 6,
	unlocked = true,
	discovered = true,
	blueprint_compat = true,
	demicoloncompat = true,
	eternal_compat = true,
	perishable_compat = false,
	calculate = function(self, card, context)
		if context.other_consumeable and not context.other_consumeable.debuff then
			local mult = 1
			local c = context.other_consumeable
			if next(SMODS.find_mod("Overflow")) then
				mult = c.ability.immutable and c.ability.immutable.overflow_amount or mult
			end
			G.E_MANAGER:add_event(Event({
				func = function()
					context.other_consumeable:juice_up(0.5, 0.5)
					return true
				end,
			}))
			return {
				mult = card.ability.extra.consumeable_mult*mult,
			}
		end
		if context.forcetrigger then
			return {
				mult = card.ability.extra.consumeable_mult,
			}
		end
	end,
	add_to_deck = function(self, card, from_debuff)
		G.consumeables.config.card_limit = G.consumeables.config.card_limit + card.ability.extra.slots
	end,
	remove_from_deck = function(self, card, from_debuff)
		G.consumeables.config.card_limit = G.consumeables.config.card_limit - card.ability.extra.slots
	end,
	joker_display_def = function(JokerDisplay)
		return {
			text = {
				{ text = "+" },
				{ ref_table = "card.joker_display_values", ref_value = "mult" }
			},
			text_config = { colour = G.C.UI.TEXT_LIGHT },
			calc_function = function(card)
				local mult = 0
				if G.consumeables and G.consumeables.cards then
					for _, c in ipairs(G.consumeables.cards) do
						if not c.debuff then
							local c_mult = 1
							if next(SMODS.find_mod("Overflow")) then
								c_mult = c.ability.immutable and c.ability.immutable.overflow_amount or c_mult
							end
							mult = mult + card.ability.extra.consumeable_mult * c_mult
						end
					end
				end
				card.joker_display_values.mult = mult
			end
		}
	end
})
