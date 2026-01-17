SMODS.Joker {
    key = "jigsaw_joker",
    atlas = "Jokers",
    pos = { x = 8, y = 4 },
    rarity = 2,
    cost = 8,
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    config = { extra = { hands_played = 0, required_hands = 8, tags = 3 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.hands_played, card.ability.extra.required_hands, card.ability.extra.tags } }
    end,
    calculate = function(self, card, context)
        if context.joker_main and not context.repetition and not context.blueprint then
            local hand_type = context.scoring_name
            if hand_type and not G.GAME.hnds_unique_hands then
                G.GAME.hnds_unique_hands = {}
            end
            if hand_type and G.GAME.hnds_unique_hands then
                if not G.GAME.hnds_unique_hands[hand_type] then
                    G.GAME.hnds_unique_hands[hand_type] = true
                    card.ability.extra.hands_played = card.ability.extra.hands_played + 1
                    if card.ability.extra.hands_played >= card.ability.extra.required_hands then
                        card.ability.extra.complete = true
                        card:juice_up()
                        return { message = "Complete!", colour = G.C.GOLD, }
                    else
                        return {
                            message = card.ability.extra.hands_played .. "/" .. card.ability.extra.required_hands,
                            colour = G.C.BLUE,
                        }
                    end
                end
            end
        end
        if (context.selling_self or context.selling_card) and card.ability.extra.complete and not card.ability.extra.tags_given and not context.blueprint then
            card.ability.extra.tags_given = true
            G.E_MANAGER:add_event(Event({
                func = function()
                    local tag_types = {}
                    for k, _ in pairs(G.P_TAGS) do
                        table.insert(tag_types, k)
                    end

                    for i = 1, card.ability.extra.tags do
                        if #tag_types > 0 then
                            local tag_key = pseudorandom_element(tag_types, pseudoseed('jigsaw_tag'..i))
                            local tag = Tag(tag_key)
                            if tag then
                                add_tag(tag)
                            end
                        end
                    end
                    return true
                end
            }))
        end
    end,
    add_to_deck = function(self, card, from_debuff)
        -- Initialize unique hands tracking if not exists
        if not G.GAME.hnds_unique_hands then
            G.GAME.hnds_unique_hands = {}
        end
    end
}
