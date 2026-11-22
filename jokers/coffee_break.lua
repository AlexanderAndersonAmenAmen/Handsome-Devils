local function spend_sip(self, card)
    local extra = card.ability.extra
    if extra.sips <= 0 then return end
    extra.sips = extra.sips - 1
    if extra.sips == 0 and not card.hnds_coffee_consuming then
        card.hnds_coffee_consuming = true
        G.E_MANAGER:add_event(Event({ blocking = false, func = function()
            if not card.getting_sliced and not card.removed and not card.REMOVED then
                card_eval_status_text(card, "extra", nil, nil, nil,
                    { message = localize("k_hnds_consumed"), colour = G.C.FILTER })
                -- Avoid the version-dependent destroy_cards options signature.
                -- Dissolve only this spent cup, after its scoring evaluation.
                card:start_dissolve()
            end
            return true
        end }))
    end
end

SMODS.Joker({
    key = "coffee_break",
    atlas = "Jokers", pos = { x = 3, y = 2 },
    rarity = 1, cost = 5, unlocked = true, discovered = false,
    blueprint_compat = true, eternal_compat = false, perishable_compat = true,
    pools = { Food = true },
    config = { extra = { sips = 5, total = 5 } },
    hnds_spend_limited_retrigger = spend_sip,
    loc_vars = function(self, info_queue, card)
        local extra = card.ability.extra
        return { vars = { extra.sips, extra.total } }
    end,
    calculate = function(self, card, context)
        if not context.retrigger_joker_check or context.retrigger_joker
            or card.debuff or SMODS.no_resolve or card.ability.extra.sips <= 0
            or type(context.other_ret) ~= 'table'
            or (not next(context.other_ret) and type(context.other_context) ~= 'table') then return end
        local source = context.blueprint_card or card
        local target
        target = HNDS.retrigger_neighbor(source, 1)
        if not target or target == card or target ~= context.other_card then return end
        local limit = HNDS.joker_retrigger_limit(context)
        if limit and limit <= 0 then return end
        return HNDS.request_safe_retriggers(card, source, context, 1, context.blueprint and 'free' or 'sip')
    end,
    attributes = { "retrigger", "food" },
})
