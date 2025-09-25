SMODS.Seal({
	key = "green",
	badge_colour = HEX("56a786"),
	atlas = "Extras",
	pos = { x = 2, y = 0 },
	discovered = true,
	config = { drawn_cards = 2 },
	loc_vars = function(self, info_queue, card)
		return { vars = { self.config.drawn_cards } }
	end,

	-- self - this seal prototype
	-- card - card this seal is applied to
	calculate = function(self, card, context)
		if
			(context.main_scoring and context.cardarea == G.play) or (context.discard and context.other_card == card)
		then
			--[[
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.1,
                func = function()
                    G.FUNCS.draw_from_deck_to_hand(card.ability.seal.drawn_cards)
                    return true
                end
            }))]]
			G.GAME.green_seal_draws = G.GAME.green_seal_draws + card.ability.seal.drawn_cards
			return {
				message = localize("k_hnds_green"),
				colour = G.C.GREEN,
				card = card,
			}
		end
	end,
})
