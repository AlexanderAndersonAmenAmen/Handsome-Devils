local RARITY_NAMES = { 'k_common', 'k_uncommon', 'k_rare' }
local RARITY_KEYS = { 'Common', 'Uncommon', 'Rare' }

SMODS.Joker({
	key = "digital_circus",
	config = { extra = { max_rounds = 2, current_rounds = 0, current_rarity = 1 } },
	rarity = 3,
	loc_vars = function(self, info_queue, card)
		local r = math.min(3, card.ability.extra.current_rarity)
		return {
			vars = {
				localize(RARITY_NAMES[r]),
				card.ability.extra.current_rounds,
				card.ability.extra.max_rounds,
				colours = { G.C.RARITY[r] },
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
		if (context.selling_self or context.forcetrigger) and not context.blueprint then
			if #G.jokers.cards > G.jokers.config.card_limit then
				return { message = localize("k_no_room_ex") }
			end
			local r = math.min(3, card.ability.extra.current_rarity)
			SMODS.add_card({ set = "Joker", area = G.jokers, rarity = RARITY_KEYS[r], edition = poll_edition("digital_circus", 1, false, true) })
			return nil, true
		end

		if (context.end_of_round and context.main_eval) or context.forcetrigger then
			local r = card.ability.extra.current_rarity
			if r >= 3 then return end
			card.ability.extra.current_rounds = card.ability.extra.current_rounds + 1
			if card.ability.extra.current_rounds < card.ability.extra.max_rounds then
				return { message = card.ability.extra.current_rounds .. "/" .. card.ability.extra.max_rounds, colour = G.C.FILTER }
			end
			r = math.min(3, r + 1)
			card.ability.extra.current_rarity = r
			card.ability.extra.current_rounds = 0
			return { message = localize(RARITY_NAMES[r]) .. "!", colour = G.C.RARITY[r] }
		end
	end,
	joker_display_def = function(JokerDisplay)
        return {
            reminder_text = {
                { text = "(" },
                { ref_table = "card.joker_display_values", ref_value = "rarity" },
                { text = ") (" },
                { ref_table = "card.joker_display_values", ref_value = "rounds" },
                { text = "/" },
                { ref_table = "card.joker_display_values", ref_value = "max" },
                { text = ")" }
            },
            calc_function = function(card)
                local r = math.min(3, card.ability.extra.current_rarity)
                card.joker_display_values.rarity = localize(RARITY_NAMES[r])
                card.joker_display_values.rounds = card.ability.extra.current_rounds
                card.joker_display_values.max = card.ability.extra.max_rounds
            end
        }
    end,
	attributes = { "joker", "scaling", "generation" }
})
