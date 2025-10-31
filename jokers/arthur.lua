
reset_arthur = function()
    local ancient_suits = {}
    for _, v in pairs(SMODS.Suits) do
        if v.key ~= G.GAME.hnds_arthur_suit then
            ancient_suits[#ancient_suits+1] = v.key
        end
    end
    local ancient_card = pseudorandom_element(ancient_suits, pseudoseed("slurp"))
    G.GAME.hnds_arthur_suit = ancient_card or "Spades"
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
        local suit = G.GAME.hnds_arthur_suit or "Spades"
        return { vars = { card.ability.extra.re, card.ability.extra.rep, localize(suit, "suits_plural"), colours ={ G.C.SUITS[suit]} } }
    end,
    calculate = function (self, card, context)
        if context.after and not context.blueprint and not context.retrigger_joker then
            return{
                message = "Changed!",
            }
        end
        if context.individual and context.cardarea == G.play and context.other_card:is_suit(G.GAME.hnds_arthur_suit) and not context.blueprint then
            
            card.ability.extra.re = card.ability.extra.re + card.ability.extra.rep
            G.GAME.current_round.free_rerolls = G.GAME.current_round.free_rerolls + card.ability.extra.rep
            calculate_reroll_cost(true)
            return{
                message = localize("k_upgrade_ex"),
                colour = G.C.GREEN,
            }
            
        end

        if context.reroll_shop and card.ability.extra.re > 0 and not context.blueprint and not context.retrigger_joker then
            card.ability.extra.re = card.ability.extra.re - 1
        end

        if context.destroy_card and context.destroy_card:is_suit(G.GAME.hnds_arthur_suit) then
            return { remove = true }
        end
    end,
    remove_from_deck = function (self, card, from_debuff)
        G.GAME.current_round.free_rerolls = G.GAME.current_round.free_rerolls - card.ability.extra.re
        calculate_reroll_cost(true)
    end,
    add_to_deck = function (self, card, from_debuff) --this is for if he gets undebuffed
        G.GAME.current_round.free_rerolls = G.GAME.current_round.free_rerolls + card.ability.extra.re
        calculate_reroll_cost(true)
    end
}