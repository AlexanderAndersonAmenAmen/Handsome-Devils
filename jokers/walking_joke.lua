function HNDS.is_adjacent_joker(cardindex, joker)
    local cards = G and G.jokers and G.jokers.cards
    if type(cards) ~= "table" or type(cardindex) ~= "number" or not joker then return false end
    return (cardindex > 1 and cards[cardindex - 1] == joker) or
           (cardindex < #cards and cards[cardindex + 1] == joker)
end

local function walking_joke_index(card, cards)
    if not cards then return end
    for index, joker in ipairs(cards) do
        if joker == card then return index end
    end
end

local function walking_joke_compatible(joker)
    local center = joker and joker.config and joker.config.center
    return center and center.rarity == 1
end

local function walking_joke_compatibility_row(side, joker)
    local compatible = walking_joke_compatible(joker)
    local status = localize(compatible and 'k_compatible' or 'k_incompatible')
    local colour = mix_colours(compatible and G.C.GREEN or G.C.RED, G.C.JOKER_GREY, 0.8)
    return {
        n = G.UIT.R,
        config = { align = 'cm', padding = 0.02 },
        nodes = {
            {
                n = G.UIT.C,
                config = { align = 'cm', colour = colour, r = 0.05, padding = 0.05 },
                nodes = {
                    { n = G.UIT.T, config = {
                        text = localize(side) .. ' | ' .. status,
                        scale = 0.3,
                        colour = G.C.UI.TEXT_LIGHT,
                    } },
                },
            },
        },
    }
end

function HNDS.calculate_walking_joke(card, context)
    if type(context) ~= 'table' or not context.retrigger_joker_check or context.retrigger_joker then return end
    local target_context = context.other_context
    if target_context and (target_context.check
        or (target_context.modify_scoring_hand and not target_context.in_scoring))
    then
        return
    end

    local other = context.other_card
    if other == card or not walking_joke_compatible(other) then return end
    local cards = G and G.jokers and G.jokers.cards
    local index = walking_joke_index(card, cards)
    if HNDS.is_adjacent_joker(index, other) then
        return { repetitions = 1 }
    end
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
    loc_vars = function(self, info_queue, card)
        local cards = G and G.jokers and G.jokers.cards
        local index = walking_joke_index(card, cards)
        if not index then return end

        return { main_end = {
            {
                n = G.UIT.C,
                config = { align = 'cm' },
                nodes = {
                    walking_joke_compatibility_row('hnds_walking_joke_left', cards[index - 1]),
                    walking_joke_compatibility_row('hnds_walking_joke_right', cards[index + 1]),
                },
            },
        } }
    end,
    unlock_condition = { type = 'win' },
    check_for_unlock = function(self, args)
        if type(args) == 'table' and args.type == 'win' then
            return not (G and G.GAME and G.GAME.hnds_walking_joke_non_common)
        end
    end,
    calculate = function(self, card, context)
        return HNDS.calculate_walking_joke(card, context)
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
