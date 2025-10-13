BC = "Spades"

function bizzare_suit()
    local ancient_suits = {}
    for k, v in ipairs({'Spades', 'Hearts', 'Clubs', 'Diamonds'}) do
        if v ~= BC then
            ancient_suits[#ancient_suits + 1] = v
        end
    end
    local ancient_card = pseudorandom_element(ancient_suits, pseudoseed("this_is_so_bizzare"))
    BC = ancient_card
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
		key = (self.key .. "_" .. string.lower(BC))
        vars = {cae.chips, cae.chipsg, cae.mult, cae.multg, cae.xmult, cae.xmultg, cae.sell_value}
		return { key = key, vars = vars }
    end,
    rarity = 3,
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
                if v:is_suit(BC) then
                    if BC == "Spades" then
                        cae.chips = cae.chips + cae.chipsg
                        return {
                            message = localize("k_upgrade_ex"),
                            colour = G.C.CHIPS
                        }
                    elseif BC == "Clubs" then
                        cae.mult = cae.mult + cae.multg
                        return {
                            message = localize("k_upgrade_ex"),
                            colour = G.C.MULT
                        }
                    elseif BC == "Hearts" then
                        cae.xmult = cae.xmult + cae.xmultg
                        return {
                            message = localize("k_upgrade_ex"),
                            colour = G.C.MULT
                        }
                    elseif BC == "Diamonds" then
                        card.ability.extra_value = (card.ability.extra_value or 0) + cae.selL_value
                        card:set_cost()
                        return {
                            message = localize("k_val_up"),
                            colour = G.C.MONEY
                        }
                    end
                end
            end
        end
    end
})
