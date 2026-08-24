function HNDS.is_adjacent_joker(cardindex, joker)
    local cards = G and G.jokers and G.jokers.cards
    if type(cards) ~= "table" or type(cardindex) ~= "number" or not joker then return false end
    return (cardindex > 1 and cards[cardindex - 1] == joker) or
           (cardindex < #cards and cards[cardindex + 1] == joker)
end

SMODS.Joker ({
    key = "walking_joke",
    config = { extra = {} },
    pos = { x = 5, y = 3 },
    cost = 10,
    rarity = 3,
    atlas = "Jokers",
    blueprint_compat = false,
    eternal_compat = true,
    unlocked = false,
    discovered = false,
    unlock_condition = { type = 'win' },
    check_for_unlock = function(self, args)
        if type(args) == 'table' and args.type == 'win' then
            return not (G and G.GAME and G.GAME.hnds_walking_joke_non_common)
        end
    end,
    calculate = function (self, card, context)
        if type(context) ~= "table" then return end
        local other = context.other_card
        local cards = G and G.jokers and G.jokers.cards
        if context.retrigger_joker_check and not context.retrigger_joker and other and other ~= card
            and type(cards) == "table" then
            local this_joker_index = nil
            for i, current_card in ipairs(cards) do
                if current_card == card then
                    this_joker_index = i
                    break
                end
            end
            if not this_joker_index then return end
            local center = other.config and other.config.center
            if HNDS.is_adjacent_joker(this_joker_index, other) and center and center.rarity == 1 then
                return { repetitions = 1 }
            end
        end
    end,
    attributes = { "retrigger", "joker" }
})

if Card and Card.add_to_deck and not Card._hnds_walking_joke_hook then
	Card._hnds_walking_joke_hook = true
	local add_to_deck_ref = Card.add_to_deck
	function Card:add_to_deck(from_debuff, ...)
		local results = HNDS.pack(add_to_deck_ref(self, from_debuff, ...))
		if not from_debuff
			and self and self.config and self.config.center
			and self.config.center.set == 'Joker'
			and self.config.center.rarity and self.config.center.rarity ~= 1
			and G and G.GAME then
			G.GAME.hnds_walking_joke_non_common = true
		end
		return ((table and table.unpack) or unpack)(results, 1, results.n)
	end
end
