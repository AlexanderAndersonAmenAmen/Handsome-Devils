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
			G.E_MANAGER:add_event(Event({
				func = function ()
					local options = {}
					for _, _card in ipairs(G.deck.cards) do
						if _card:get_id() == card:get_id() then options[#options+1] = _card end
					end
					if #options > 0 then
						G.GAME.green_seal_draws[#G.GAME.green_seal_draws+1] = pseudorandom_element(options, "green_seal_draw")
					end
				end
			}))
			return {
				message = localize("k_hnds_green"),
				colour = G.C.GREEN,
				card = card,
			}
		end
	end,
})
