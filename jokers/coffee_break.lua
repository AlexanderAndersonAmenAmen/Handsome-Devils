SMODS.Joker({
    key = "coffee_break",
    atlas = "Jokers", pos = { x = 3, y = 2 },
    rarity = 1, cost = 5, unlocked = true, discovered = false,
    blueprint_compat = true, eternal_compat = false, perishable_compat = true,
    pools = { Food = true },
    config = { extra = { sips = 5, total = 5 } },
    loc_vars = function(self, info_queue, card)
        local extra = card.ability.extra
        return { vars = { extra.sips, extra.total } }
    end,
    calculate = function(self, card, context)
        if not context.retrigger_joker_check or context.retrigger_joker
            or card.ability.extra.sips <= 0 or not context.other_ret
            or not next(context.other_ret) then return end
        local source = context.blueprint_card or card
        local target
        for i, joker in ipairs(G.jokers.cards) do
            if joker == source then target = G.jokers.cards[i + 1]; break end
        end
        if not target or target == card or target ~= context.other_card then return end
        if not context.blueprint then
            card.ability.extra.sips = card.ability.extra.sips - 1
            if card.ability.extra.sips == 0 then
                G.E_MANAGER:add_event(Event({ func = function()
                    if not card.getting_sliced and not card.removed and not card.REMOVED then
                        card_eval_status_text(card, "extra", nil, nil, nil,
                            { message = localize("k_hnds_consumed"), colour = G.C.FILTER })
                        SMODS.destroy_cards({ card }, { pinch_anim = true })
                    end
                    return true
                end }))
            end
        end
        return { repetitions = 1, message = localize("k_again_ex"), card = source }
    end,
    attributes = { "retrigger", "food" },
})
