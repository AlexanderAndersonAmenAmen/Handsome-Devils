local jokestone_draw = function(self, card, context)
	if not (G and G.E_MANAGER and G.deck and G.deck.cards and G.hand) then return false end
	G.E_MANAGER:add_event(Event({
		trigger = "before",
		func = function()
			if not (G and G.deck and G.deck.cards and G.hand) then return true end
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
				if hnds_config["enableCustomSounds"] then play_sound("hnds_jokestone", 1, 0.45) end
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
						-- Persist the *post-draw* card areas.  The old save point was
						-- queued from calculate() before draw_card's nested movement
						-- Events had finished, so reopening a run restored these cards
						-- back into G.deck.
						if not (context and context.forcetrigger) and type(save_run) == "function" then save_run() end
						return true
					end,
				}))
			end
			return true
		end,
	}))
	return true
end

SMODS.Joker({
	key = "jokestone",
	atlas = "Jokers",
	pos = { x = 6, y = 1 },
	rarity = 1,
	cost = 4,
	unlocked = false,
	discovered = false,
	blueprint_compat = true,
	demicoloncompat = true,
	eternal_compat = true,
	perishable_compat = true,
	config = { extra = {
		draw = 3,
	} },
	unlock_condition = { type = 'hand_contents', extra = 3 },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.draw } }
	end,
	check_for_unlock = function(self, args)
		if args.type == 'hand_contents' and args.cards then
			local seen = {}
			local count = 0
			for _, v in ipairs(args.cards) do
				if v and v.ability and v.ability.set == "Enhanced" then
					local key = v.ability.name or v.ability.effect
					if key and not seen[key] then
						seen[key] = true
						count = count + 1
						if count >= self.unlock_condition.extra then
							return true
						end
					end
				end
			end
		end
	end,
	calculate = function(self, card, context)
		if (context.first_hand_drawn or context.forcetrigger)
			and G and G.deck and G.deck.cards and #G.deck.cards > 0
			and jokestone_draw(self, card, context)
		then
			return nil, true
		end
	end,
	attributes = { "enhancements" }
})
