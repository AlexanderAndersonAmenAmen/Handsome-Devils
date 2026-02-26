SMODS.Joker({
	key = "last_laugh",
	atlas = "Jokers",
	pos = { x = 9, y = 3 },
	rarity = 3,
	cost = 10,
	unlocked = false,
	discovered = false,
	blueprint_compat = false,
	demicoloncompat = true,
	eternal_compat = false,
	perishable_compat = true,
	config = {
		extra = {
			draw = 1,
			draw_scaling = 1,
			destroy = 9999,
		}
	},
	unlock_condition = { type = 'career_stat', extra = 100, stat = 'c_hnds_cards_destroyed' },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.draw, card.ability.extra.destroy } }
	end,
	check_for_unlock = function(self, args)
		if args.type == 'career_stat' and args.statname == self.unlock_condition.stat then
			local stats = (G.PROFILES and G.SETTINGS and G.PROFILES[G.SETTINGS.profile] and G.PROFILES[G.SETTINGS.profile].career_stats) or {}
			local destroyed = stats[self.unlock_condition.stat] or 0
			return destroyed >= self.unlock_condition.extra
		end
	end,
	calculate = function(self, card, context)
		if context.setting_blind then
			card.ability.extra.currently_drawn = 0 --this does literally nothing? -- Marffe: looks like it just checks how many cards are currently draw in hand to be an additive to the draw_scaling
		end

		if (context.selling_self or context.forcetrigger) and G.hand and G.hand.cards and #G.hand.cards > 0 then
			SMODS.draw_cards(card.ability.extra.draw)
			G.E_MANAGER:add_event(Event({
				func = function()
					local destroyed_cards = {}
					local temp_hand = {}
					for _, playing_card in ipairs(G.hand.cards) do temp_hand[#temp_hand + 1] = playing_card end
					table.sort(temp_hand,
						function(a, b)
							return not a.playing_card or not b.playing_card or a.playing_card < b.playing_card
						end
					)
					pseudoshuffle(temp_hand, 'lastlaugh')
					for i = 1, card.ability.extra.destroy do destroyed_cards[#destroyed_cards + 1] = temp_hand[i] end
					SMODS.destroy_cards(destroyed_cards)
					card:juice_up()
					return true
				end,
			}))
			return {
				message = localize("k_hnds_boom"),
				colour = G.C.RED,
			}
		end
		if (context.end_of_round and context.main_eval) or context.forcetrigger then
			card.ability.extra.draw = card.ability.extra.draw + card.ability.extra.draw_scaling
			return {
				colour = G.C.RED,
				card = card,
				message = localize("k_hnds_boom_timer"),
			}
		end
	end
})
