
function bizzare_suit()
    local ancient_suits = {}
    for _, v in ipairs({'Spades', 'Hearts', 'Clubs', 'Diamonds'}) do
        if v ~= G.GAME.hnds_bizzare_suit then
            ancient_suits[#ancient_suits + 1] = v
        end
    end
    local ancient_card = pseudorandom_element(ancient_suits, pseudoseed("this_is_so_bizzare"))
    G.GAME.hnds_bizzare_suit = ancient_card
end

SMODS.Joker({
    key = "bizzare_joker",
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    config = {
        extra = {
            chips = 0,
            chipsg = 5,
            mult = 0,
            multg = 1,
            xmult = 1,
            xmultg = 0.05,
            sell_value = 2
        }
    },
    loc_vars = function(self, info_queue, card)
        local cae = card.ability.extra
        local key, vars
		key = (self.key .. "_" .. (string.lower(G.GAME.hnds_bizzare_suit or "spades") or "spades"))
        vars = {cae.chips, cae.chipsg, cae.mult, cae.multg, cae.xmult, cae.xmultg, cae.sell_value}
		return { key = key, vars = vars }
    end,
    rarity = 2,
    cost = 7,
    atlas = "Jokers",
    pos = {
        x = 7,
        y = 1
    },
    demicoloncompat = true,
    calculate = function(self, card, context)
        local cae = card.ability.extra
        if context.before then
            for k, v in pairs(G.play.cards) do
                if v:is_suit(G.GAME.hnds_bizzare_suit) then
                    if G.GAME.hnds_bizzare_suit == "Spades" then
                        SMODS.scale_card(card, {
                            ref_table = cae,
                            ref_value = "chips",
                            scalar_value = "chipsg",
                            message = { colour = G.C.CHIPS }
                        })
                    elseif G.GAME.hnds_bizzare_suit == "Clubs" then
                        SMODS.scale_card(card, {
                            ref_table = cae,
                            ref_value = "mult",
                            scalar_value = "multg",
                            message = { colour = G.C.RED }
                        })
                    elseif G.GAME.hnds_bizzare_suit == "Hearts" then
                        SMODS.scale_card(card, {
                            ref_table = cae,
                            ref_value = "xmult",
                            scalar_value = "xmultg",
                            message = { colour = G.C.MULT }
                        })
                    elseif G.GAME.hnds_bizzare_suit == "Diamonds" then
                        card.ability.extra_value = (card.ability.extra_value or 0) + cae.sell_value
                        card:set_cost()
                        return {
                            message = localize("k_val_up"),
                            colour = G.C.MONEY
                        }
                    end
                end
            end
        end

        if context.joker_main then
            return {
                chips = cae.chips,
                mult = cae.mult,
                extra = { xmult = cae.xmult }
            }
        end

    end
})
