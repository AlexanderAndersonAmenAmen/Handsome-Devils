SMODS.Joker({
	key = "seismic_activity",
	atlas = "Jokers",
	pos = { x = 7, y = 0 },
	rarity = 2,
	cost = 4,
	unlocked = false,
	discovered = false,
	unlock_condition = { type = "hnds_joker_unlock", key = "seismic_activity" },
	locked_loc_vars = function(self)
	    return HNDS.joker_locked_loc_vars("seismic_activity")
	end,
	check_for_unlock = function(self, args)
	    return HNDS.joker_unlock_condition_met("seismic_activity", args)
	end,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	config = { extra = { repetitions = 1, }, },
	calculate = function(self, card, context)
        if type(context) ~= "table" then return end
        local other = context.other_card
		if other and G and (context.cardarea == G.play or context.cardarea == G.hand) and context.repetition then
			if SMODS.has_enhancement(other, "m_stone") then
				return {
					message = localize("k_hnds_seismic"),
					repetitions = card.ability.extra.repetitions,
				}
			end
		end
	end,
	in_pool = function(self, args)
		if HNDS.stone_joker_in_pool then return HNDS.stone_joker_in_pool(args) end
		return true
	end,
	attributes = { "enhancements", "retrigger" }
})
