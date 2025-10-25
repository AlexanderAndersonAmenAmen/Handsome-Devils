SMODS.Joker({
	key = "occultist",
	atlas = "Jokers",
	pos = { x = 3, y = 0 },
	rarity = 3,
	cost = 7,
	unlocked = true,
	discovered = true,
	blueprint_compat = true,
	demicoloncompat = true,
	eternal_compat = true,
	perishable_compat = true,
	config = {
		extra = {
			suits_needed = 4,
		},
	},
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.suits_needed } }
	end,
	calculate = function(self, card, context)
		if
			(context.before and context.cardarea == G.jokers and G.GAME.current_round.hands_played == 0)
			or context.forcetrigger
		then
			if HNDS.get_unique_suits(context.scoring_hand) >= card.ability.extra.suits_needed then
				local tag_name =
					pseudorandom_element({ "tag_meteor", "tag_charm", "tag_ethereal", "tag_buffoon" }, pseudoseed("occ_pool"))
				G.E_MANAGER:add_event(Event({
					func = function()
						add_tag(Tag(tag_name))
						play_sound("hnds_madnesscolor", 1.25, 0.25)
						return true
					end,
				}))
				return {
					colour = G.C.BLUE,
					message = localize("k_hnds_occultist"),
				}
			end
		end
	end,
})
