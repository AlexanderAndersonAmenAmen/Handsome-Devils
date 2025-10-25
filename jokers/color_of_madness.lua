SMODS.Joker({
	key = "color_of_madness", --joker key
	atlas = "Jokers", --atlas' key
	pos = { x = 4, y = 2 },
	rarity = 2, --rarity: 1 = Common, 2 = Uncommon, 3 = Rare, 4 = Legendary
	--soul_pos = { x = 0, y = 0 },
	cost = 4, --cost
	unlocked = true, --whether it is unlocked or not
	discovered = true, --whether or not it starts discovered
	blueprint_compat = false, --can it be blueprinted/brainstormed/other
	demicoloncompat = true,
	eternal_compat = true, --can it be eternal
	perishable_compat = true, --can it be perishable
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
			context.before
			and context.cardarea == G.jokers
			and not context.blueprint
		then
			if HNDS.get_unique_suits(context.scoring_hand) >= card.ability.extra.suits_needed then
				--[[
                local unenhanced_cards = {}
                for i, v in ipairs(context.scoring_hand) do
                    if not next(SMODS.get_enhancements(v)) then
                        table.insert(unenhanced_cards, v)
                    end
                end]]
				local card_to_enhance = context.scoring_hand[1] --pseudorandom_element(unenhanced_cards, pseudoseed("color_of_madness"))
				card_to_enhance:set_ability(G.P_CENTERS.m_wild, nil, true)
				G.E_MANAGER:add_event(Event({
					func = function()
						card_to_enhance:juice_up()
						play_sound("hnds_madnesscolor", 1.25, 0.25)
						return true
					end,
				}))
				return {
					colour = G.C.GREEN,
					card = card,
					message = localize("k_hnds_color_of_madness"),
				}
			end
		end
		if context.forcetrigger then
			local did_a_thing
			if #G.play > 0 then
				local card_to_enhance = G.play[1]
				did_a_thing = true
				card_to_enhance:set_ability(G.P_CENTERS.m_wild, nil, true)
				G.E_MANAGER:add_event(Event({
					func = function()
						card_to_enhance:juice_up()
						play_sound("hnds_madnesscolor", 1.25, 0.25)
						return true
					end,
				}))
			elseif #G.hand > 0 then
				local card_to_enhance = G.hand[1]
				did_a_thing = true
				card_to_enhance:set_ability(G.P_CENTERS.m_wild, nil, true)
				G.E_MANAGER:add_event(Event({
					func = function()
						card_to_enhance:juice_up()
						play_sound("hnds_madnesscolor", 1.25, 0.25)
						return true
					end,
				}))
			end
			if did_a_thing then
				return {
					colour = G.C.GREEN,
					card = card,
					message = localize("k_hnds_color_of_madness"),
				}
			end
		end
	end,
})
