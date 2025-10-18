SMODS.Joker {
    key = "krusty",
    unlocked = true, -- set this and discovered to false when releasing!
    discovered = true,
    blueprint_compat = true,
    demicoloncompat = true,
    rarity = 4,
    cost = 20,
    atlas = "Jokers",
    pos = { x = 7, y = 2 },
    soul_pos = { x = 2, y = 3 },
    calculate = function (self, card, context)
        if context.setting_blind then
            G.E_MANAGER:add_event(Event({
                func = function ()
                    SMODS.add_card({
                        set = "Food",
                        edition = 'e_negative',
                        allow_duplicates = false --this shouldnt be needed but like maybe?
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
