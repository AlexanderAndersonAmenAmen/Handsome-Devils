SMODS.Joker ({
    key = "walking_joke",
    config = { extra = {} },
    pos = { x = 5, y = 3 },
    cost = 5,
    rarity = 3,
	atlas = "Jokers",
    blueprint_compat = false,
    eternal_compat = true,
    unlocked = false,
    discovered = false,
    unlock_condition = { type = 'win' },
    check_for_unlock = function(self, args)
        if args.type == 'win' then
            -- Check if any non-common jokers exist in the run history or current deck
            -- The hook tracks this in G.GAME.hnds_walking_joke_non_common
            return not (G and G.GAME and G.GAME.hnds_walking_joke_non_common)
        end
    end,
    calculate = function (self, card, context)
        if context.retrigger_joker_check and not context.retrigger_joker and context.other_card ~= card then
			-- Check if the joker is adjacent
			local this_joker_index = nil
			for i, current_card in ipairs(G.jokers.cards) do
				if current_card == card then
					this_joker_index = i
					break
				end
			end
			if not this_joker_index then return end
			if is_adjacent_joker(this_joker_index, context.other_card) and context.other_card.config.center.rarity == 1 then
				return {
					repetitions = 1,
				}
			end
		end
    end
})

function is_adjacent_joker(cardindex, joker)
	return (cardindex > 1 and G.jokers.cards[cardindex - 1] == joker) or
	       (cardindex < #G.jokers.cards and G.jokers.cards[cardindex + 1] == joker)
end

-- Walking Joke Unlock Tracker
-- Tracks if any non-common jokers were obtained
local function hnds_walking_joke_on_add_to_deck(card, from_debuff)
	if not from_debuff and card and card.config and card.config.center and card.config.center.set == 'Joker' then
		if card.config.center.rarity and card.config.center.rarity > 1 and G and G.GAME then
			G.GAME.hnds_walking_joke_non_common = true
		end
	end
end

if Card and Card.add_to_deck and not Card._hnds_wrapped_add_to_deck_walkingjoke then
	Card._hnds_wrapped_add_to_deck_walkingjoke = true
	local add_to_deck_ref = Card.add_to_deck
	function Card:add_to_deck(from_debuff)
		local ret = add_to_deck_ref(self, from_debuff)
		hnds_walking_joke_on_add_to_deck(self, from_debuff)
		return ret
	end
end