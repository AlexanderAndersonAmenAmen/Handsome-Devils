local jokestone_draw = function(self, card, context)
	G.E_MANAGER:add_event(Event({
		trigger = "before",
		func = function()
			local _cards = {}
			for i = 1, #G.deck.cards do
				local _card = G.deck.cards[i]
				if _card.ability.set == "Enhanced" and not _card.ability.hnds_drawing then
					_cards[#_cards + 1] = _card
				end
			end
			if #_cards > 0 then
				local cards_to_draw = {}
				for i = 1, card.ability.extra.draw do
					if _cards[i] then
						cards_to_draw[i] = _cards[i]
						cards_to_draw[i].ability.hnds_drawing = true
					end
				end
				card_eval_status_text(context and context.blueprint_card or card, "extra", nil, nil, nil, {
					message = localize("k_hnds_goldfish"),
					colour = G.C.PURPLE,
					instant = true,
				})
				for i = 1, #cards_to_draw do
					draw_card(G.deck, G.hand, nil, "up", true, cards_to_draw[i])
				end
				G.E_MANAGER:add_event(Event({
					trigger = "before",
					delay = 0.1,
					func = function()
						for i = 1, #cards_to_draw do
							cards_to_draw[i].ability.hnds_drawing = nil
						end
						return true
					end,
				}))
			end
			return true
		end,
	}))
end

SMODS.Joker({
	key = "jokestone",
	atlas = "Jokers",
	pos = { x = 6, y = 1 },
	rarity = 1,
	cost = 4,
	unlocked = true,
	discovered = true,
	blueprint_compat = true,
	demicoloncompat = true,
	eternal_compat = true,
	perishable_compat = true,
	config = { extra = {
		draw = 3,
	} },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.draw } }
	end,
	calculate = function(self, card, context)
		if context.first_hand_drawn or context.forcetrigger and #G.deck.cards > 0 then
			jokestone_draw(self, card, context)
			if not context.forcetrigger then
				G.E_MANAGER:add_event(Event({
					func = function()
						save_run()
						return true
					end,
				}))
			end
			return nil, true
		end
	end,
})
