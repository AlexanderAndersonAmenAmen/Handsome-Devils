RA = "Clubs"

reset_arthur = function()
    local ancient_suits = {}
    for k, v in pairs(SMODS.Suits) do
        if v.key ~= RA then
            ancient_suits[#ancient_suits+1] = v.key
        end
    end
    local ancient_card = pseudorandom_element(ancient_suits, pseudoseed("slurp"))
    RA = ancient_card
end

SMODS.Joker {
    key = "arthur",
    unlocked = true,
    discovered = true,
    blueprint_compat = false,
    rarity = 4,
    cost = 20,
    atlas = "Jokers",
    pos = { x = 9, y = 2 },
    soul_pos = { x = 4, y = 3 },
    config = { extra = { re = 0, rep = 1 } },
    loc_vars = function (self, info_queue, card)
        return { vars = { card.ability.extra.re, card.ability.extra.rep, RA, colours ={ G.C.SUITS[RA]} } }
    end,
    calculate = function (self, card, context)
        if context.after and not context.blueprint then
            reset_arthur()
            return{
                message = "Changed!",
            }
        end
        if context.individual and context.cardarea == G.play and context.other_card:is_suit(RA) and not context.blueprint then
            
            card.ability.extra.re = card.ability.extra.re + card.ability.extra.rep
            calculate_reroll_cost(true)
            G.GAME.current_round.free_rerolls = G.GAME.current_round.free_rerolls + card.ability.extra.rep

            SMODS.destroy_cards(context.other_card)
            
            return{
                message = localize("k_upgrade_ex"),
                colour = G.C.GREEN,
            }
            
        end

        if context.reroll_shop and card.ability.extra.re > 0 and not context.blueprint then
            card.ability.extra.re = card.ability.extra.re - 1
        end

    end
}