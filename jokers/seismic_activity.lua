SMODS.Joker {
    key = 'seismic_activity',
    atlas = 'Jokers',
    pos = { x = 5, y = 3 },
    rarity = 2,
    cost = 5,
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    config = {
        extra = {
            repetitions = 1
        }
    },
    calculate = function(self, card, context)
        if (context.cardarea == G.play or context.cardarea == G.hand) and context.repetition then
            if context.other_card.config.center == G.P_CENTERS.m_stone then
                return {
                    message = localize('k_hnds_seismic'),
                    repetitions = card.ability.extra.repetitions,
                    card = card
                }
            end
        end
    end,
    in_pool = function(self, args)
        for key, value in pairs(G.playing_cards) do
			if value.config.center == G.P_CENTERS.m_stone then
				return true
			end
		end
        return false
    end
}