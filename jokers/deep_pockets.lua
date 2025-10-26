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
})
