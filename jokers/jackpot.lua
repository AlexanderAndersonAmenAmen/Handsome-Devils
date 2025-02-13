SMODS.Joker {
    key = "jackpot",
    config = {
        extra = {
            base_chance = 100,
            money = 100,
            prob_inc = 1,
            prob = 1
        }
    },
    rarity = 1,
    loc_vars = function(self, info_queue, card)
        return { vars = { ((G.GAME.probabilities.normal or 1) * card.ability.extra.prob), card.ability.extra.base_chance, card.ability.extra.money, card.ability.extra.prob_inc } }
    end,
    atlas = "Jokers",
    pos = { x = 8, y = 0},
    cost = 5,
    unlocked = true,
    discovered = true,
    blueprint_compat = false,
    eternal_compat = false,
    perishable_compat = true,

    calc_dollar_bonus = function(self, card)
        if pseudorandom("Jackpot") < (G.GAME.probabilities.normal * card.ability.extra.prob) / card.ability.extra.base_chance then
            SMODS.calculate_effect({message = localize("k_hnds_jackpot"), colour = G.C.MONEY }, card)
            G.E_MANAGER:add_event(Event({
                func = function()
                    card:start_dissolve()
                    return true end
            }))
            return card.ability.extra.money
        end
    end,

    calculate = function(self, card, context)
        if context.cardarea == G.play and context.individual then
            if context.other_card:get_id() == 7 and ((G.GAME.probabilities.normal or 1) * card.ability.extra.prob) < 100 then
                card.ability.extra.prob = card.ability.extra.prob + card.ability.extra.prob_inc
                return {
                    message = localize('k_hnds_probinc'),
                    colour = G.C.GREEN,
                    focus = card
                }
            end
        end
    end
}