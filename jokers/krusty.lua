SMODS.Joker {
    key = "krusty",
    unlocked = true, -- set this and discovered to false when releasing!
    discovered = true,
    blueprint_compat = true,
    demicoloncompat = true,
    atlas = "Jokers",
    pos = { x = 7, y = 2 },
    soul_pos = { x = 2, y = 3 },
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

create_card_ref = create_card
function create_card(_type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append)
    local card = create_card_ref(_type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append)
    if card and next(SMODS.find_card("j_hnds_krusty")) and card.config and G.P_CENTER_POOLS.Food[card.config.center.key] then
        card:set_edition("e_negative", true)
    end
    return card
end