SMODS.Joker({
    key = "blackjack",
    rarity = 1,
    cost = 5,
    blueprint_compat = true,
    atlas = "Jokers",
    pos = { x = 6, y = 3 },
    config = {
        extra = {
            chips = 0,
            chipg = 21
        }
    },
    loc_vars = function(self, info_queue, card)
        return {
            vars = {card.ability.extra.chips, card.ability.extra.chipg}
        }
    end,
    calculate = function(self, card, context)
        local cae = card.ability.extra
        if context.pre_discard and not context.blueprint then
            local sum = 0
            for k, v in pairs(context.full_hand) do
                sum = sum + v.base.nominal
            end
            if sum == 21 then
				SMODS.scale_card(card, {
					ref_table = cae,
					ref_value = "chips",
					scalar_value = "chipg",
				})
                return nil, true
            end
        end

        if context.joker_main then
            return{
                chips = cae.chips
            }
        end

        if context.end_of_round and not context.blueprint and G.GAME.blind.boss and context.main_eval then
            cae.chips = 0
            return {message = localize("k_reset"), card = card}
        end
    end
})

