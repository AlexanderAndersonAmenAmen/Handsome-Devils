SMODS.Joker({
    key = "angry_mob",
    rarity = 2,
    cost = 6,
    blueprint_compat = true,
    atlas = "Jokers",
    pos = { x = 8, y = 3 },
    config = { extra = { xmult = 2, } },
    loc_vars = function(self, info_queue, card)
        return { vars = {card.ability.extra.xmult} }
    end,
    add_to_deck = function(self, card, from_debuff)
        G.GAME.modifiers.hnds_no_shop_jokers_sources = (G.GAME.modifiers.hnds_no_shop_jokers_sources or 0) + 1
        if G.GAME.modifiers.hnds_no_shop_jokers_sources == 1 then
            G.GAME.modifiers.hnds_saved_joker_rate = G.GAME.joker_rate
            G.GAME.joker_rate = 0
            G.GAME.modifiers.no_shop_jokers = true
        end
    end,
    remove_from_deck = function(self, card, from_debuff)
        G.GAME.modifiers.hnds_no_shop_jokers_sources = math.max((G.GAME.modifiers.hnds_no_shop_jokers_sources or 1) - 1, 0)
        if G.GAME.modifiers.hnds_no_shop_jokers_sources == 0 then
            if G.GAME.modifiers.hnds_saved_joker_rate ~= nil then
                G.GAME.joker_rate = G.GAME.modifiers.hnds_saved_joker_rate
            end
            G.GAME.modifiers.no_shop_jokers = nil
            G.GAME.modifiers.hnds_saved_joker_rate = nil
        end
    end,
    calculate = function(self, card, context)
        local cae = card.ability.extra
        if context.joker_main then
            return{ xmult = cae.xmult }
        end
    end
})

