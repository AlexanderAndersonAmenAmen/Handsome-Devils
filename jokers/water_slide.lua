SMODS.Joker {
    key = 'water_slide',
    atlas = 'Jokers',
    pos = { x = 4, y = 7 },
    rarity = 2,
    cost = 5,
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    config = { extra = { odds = 2, discards = 1 } },

    loc_vars = function(self, info_queue, card)
        local numerator = (G and G.GAME and G.GAME.probabilities and G.GAME.probabilities.normal) or 1
        return { vars = { numerator, card.ability.extra.odds, card.ability.extra.discards } }
    end,

    calculate = function(self, card, context)
        -- pre_discard fires exactly once for the entire discarded selection and
        -- exposes context.full_hand, unlike context.discard which fires once per
        -- individual card. This guarantees one roll total even if several 8s are
        -- discarded together.
        if context.pre_discard and not context.hook and not context.retrigger_joker then
            local has_eight = false
            for _, playing_card in ipairs(context.full_hand or {}) do
                if playing_card and playing_card.get_id then
                    local ok, id = pcall(playing_card.get_id, playing_card)
                    if ok and id == 8 then
                        has_eight = true
                        break
                    end
                end
            end
            if has_eight then
                local numerator = (G and G.GAME and G.GAME.probabilities and G.GAME.probabilities.normal) or 1
                if pseudorandom('hnds_water_slide') < numerator / card.ability.extra.odds then
                    if ease_discard then ease_discard(card.ability.extra.discards) end
                    return {
                        message = localize('k_hnds_water_slide_discard'),
                        colour = G.C.RED,
                    }
                end
            end
        end
    end,
}
