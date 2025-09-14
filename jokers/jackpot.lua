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
    rarity = 2,
    loc_vars = function(self, info_queue, card)
        local numerator, denominator = SMODS.get_probability_vars(card, card.ability.extra.prob, card.ability.extra.base_chance, "hnds_jackpot")
        return { vars = { numerator, denominator, card.ability.extra.money, card.ability.extra.prob_inc } }
    end,
    atlas = "Jokers",
    pos = { x = 8, y = 0},
    cost = 4,
    unlocked = true,
    discovered = true,
    blueprint_compat = false,
    eternal_compat = false,
    perishable_compat = true,

    calc_dollar_bonus = function(self, card)
        if SMODS.pseudorandom_probability(card, "hnds_jackpot", card.ability.extra.prob, card.ability.extra.base_chance, "hnds_jackpot") then
            SMODS.calculate_effect({message = localize("k_hnds_jackpot"), colour = G.C.MONEY }, card)
            G.E_MANAGER:add_event(Event({
                func = function()
                    card:start_dissolve()
                    return true end
            }))
            return card.ability.extra.money
        elseif mxms_scale_pessimistics then mxms_scale_pessimistics(G.GAME.probabilities.normal * card.ability.extra.prob, card.ability.extra.base_chance) end
    end,

    calculate = function(self, card, context)
        if context.cardarea == G.play and context.individual then
            if context.other_card:get_id() == 7 then
                SMODS.scale_card(card, {
                    ref_table = card.ability.extra,
                    ref_value = "prob",
                    scalar_value = "prob_inc",
                    scaling_message = {
                        message_key = "k_hnds_probinc",
                        colour = G.C.GREEN
                    }
                })
            end
        end
    end
}