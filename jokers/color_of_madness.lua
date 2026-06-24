local function hnds_enhance_wild(card_self, card_to_enhance)
	card_to_enhance:set_ability(G.P_CENTERS.m_wild, nil, true)
	G.E_MANAGER:add_event(Event({
		func = function()
			card_to_enhance:juice_up()
			if hnds_config["enableCustomSounds"] then play_sound("hnds_madnesscolor", 1.25, 0.25) end
			return true
		end,
	}))
	return {
		colour = G.C.GREEN,
		card = card_self,
		message = localize("k_hnds_color_of_madness"),
	}
end

SMODS.Joker({
	key = "color_of_madness",
	atlas = "Jokers",
	pos = { x = 4, y = 2 },
	rarity = 2,
	cost = 4,
	unlocked = true,
	discovered = true,
	blueprint_compat = false,
	demicoloncompat = true,
	eternal_compat = true,
	perishable_compat = true,
	config = { extra = { suits_needed = 4, }, },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.suits_needed } }
	end,
	calculate = function(self, card, context)
		if
			context.before
			and context.cardarea == G.jokers
			and not context.blueprint
		then
			if HNDS.get_unique_suits(context.scoring_hand) >= card.ability.extra.suits_needed then
				return hnds_enhance_wild(card, context.scoring_hand[1])
			end
		end
		if context.forcetrigger and (G.STATE ~= G.STATES.HAND_PLAYED and next(G.hand or {}) or next(G.play or {}) ) then
			local target = (#G.play > 0 and G.play[1]) or (#G.hand > 0 and G.hand[1])
			if target then return hnds_enhance_wild(card, target) end
		end
	end,
	attributes = { "enhancements", "suit", }
})
