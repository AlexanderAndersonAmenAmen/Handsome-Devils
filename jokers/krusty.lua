SMODS.Joker {
    key = "krusty",
    unlocked = true, -- set this and discovered to false when releasing!
    discovered = true,
    blueprint_compat = true,
    demicoloncompat = true,
    calculate = function (self, card, context)
        if context.setting_blind then
            G.E_MANAGER:add_event(Event({
                func = function ()
                    SMODS.add_card({
                        set = "Food",
                        edition = 'e_negative'
                    })
                    return true
                end
            }))
        end
        if context.setting_ability and G.P_CENTER_POOLS.Food and G.P_CENTER_POOLS.Food[context.new] and not (context.other_card.edition and context.other_card.edition == "e_negative") and not context.blueprint then
            context.other_card:set_edition("e_negative", nil, true)
        end
    end
}