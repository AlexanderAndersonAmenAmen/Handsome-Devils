SMODS.Joker({
	key = "banana_split",
	atlas = "Jokers",
	pos = { x = 0, y = 2 },
	rarity = 2,
	cost = 5,
	unlocked = false,
	discovered = false,
	unlock_condition = { type = "hnds_joker_unlock", key = "banana_split" },
	locked_loc_vars = function(self)
	    return HNDS.joker_locked_loc_vars("banana_split")
	end,
	check_for_unlock = function(self, args)
	    return HNDS.joker_unlock_condition_met("banana_split", args)
	end,
	blueprint_compat = false,
	demicoloncompat = true,
	eternal_compat = false,
	perishable_compat = false,
	config = {
		extra_value = 13, -- $5 shop cost still; vanilla $2 sell + $13 = $15 starting sell value
		extra = { Xmult = 1.5, odds = 6, }
	},
	pools = { Food = true },
	loc_vars = function(self, info_queue, card)
		local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, "hnds_banana_split")
		return { vars = { card.ability.extra.Xmult, numerator, denominator } }
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
		then
			G.GAME.joker_buffer = G.GAME.joker_buffer or 0
			local has_room = #G.jokers.cards + G.GAME.joker_buffer < G.jokers.config.card_limit
			if has_room and (
				context.forcetrigger
				or SMODS.pseudorandom_probability(card, "banan", 1, card.ability.extra.odds, "hnds_banana_split")
			) then
				-- Reserve the slot immediately. Without this, two Banana Splits that
				-- trigger during the same evaluation can both see the same free slot
				-- before either delayed copy is emplaced, causing an overflow.
				G.GAME.joker_buffer = G.GAME.joker_buffer + 1

				-- Banana Split copies inherit this exact copy's current sell value.
				-- Gift Card and similar effects change ability.extra_value at runtime;
				-- copy_card can re-seed it from the center config, so restore the
				-- live value explicitly without touching the Joker's shop cost.
				local inherited_extra_value = card.ability and card.ability.extra_value
				local inherited_sell_cost = card.sell_cost
				local source_card = card

				G.E_MANAGER:add_event(Event({
					func = function()
						-- Release our reservation before checking the real CardArea again.
						G.GAME.joker_buffer = math.max(0, (G.GAME.joker_buffer or 1) - 1)
						if not (G.jokers and G.jokers.cards and G.jokers.config)
							or #G.jokers.cards >= G.jokers.config.card_limit
						then
							return true
						end

						local _card = copy_card(source_card, nil, nil, nil, source_card.edition and source_card.edition.negative)
						_card.ability = _card.ability or {}
						if inherited_extra_value ~= nil then
							_card.ability.extra_value = inherited_extra_value
						end
						if _card.set_cost then _card:set_cost() end
						if inherited_sell_cost ~= nil then
							_card.sell_cost = inherited_sell_cost
							_card.sell_cost_label = inherited_sell_cost
						end
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
	joker_display_def = function(JokerDisplay)
        return {
            text = {
                {
                    border_nodes = {
                        { text = "X" },
                        { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" }
                    }
                }
            },
            extra = {
                {
                    { text = "(" },
                    { ref_table = "card.joker_display_values", ref_value = "odds" },
                    { text = ")" },
                }
            },
            calc_function = function(card)
                card.joker_display_values.x_mult = card.ability.extra.Xmult
                card.joker_display_values.odds = localize { type = 'variable', key = 'jdis_odds', vars = { (G.GAME and G.GAME.probabilities.normal or 1), card.ability.extra.odds } }
            end
        }
    end,
	attributes = { "food", "generation", "xmult", "chance", }
})
