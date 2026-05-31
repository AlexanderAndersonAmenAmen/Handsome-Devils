SMODS.Joker {
    key = "jigsaw_joker",
    atlas = "Jokers",
    pos = { x = 8, y = 4 },
    rarity = 1,
    cost = 4,
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    eternal_compat = false,
    perishable_compat = false,
    config = { extra = { hands_played = 0, required_hands = 8, tags = 3, unique_hands = {} } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.hands_played, card.ability.extra.required_hands, card.ability.extra.tags } }
    end,
    calculate = function(self, card, context)
        if context.joker_main and not context.repetition and not context.blueprint then
            local hand_type = context.scoring_name
            if hand_type and card.ability.extra.unique_hands then
                if not card.ability.extra.unique_hands[hand_type] then
                    card.ability.extra.unique_hands[hand_type] = true
                    card.ability.extra.hands_played = card.ability.extra.hands_played + 1
                    if card.ability.extra.hands_played >= card.ability.extra.required_hands then
                        card.ability.extra.complete = true
                        local eval = function(c) return not c.REMOVED end
                        juice_card_until(card, eval, true)
                        return { message = "Complete!", colour = G.C.RED, }
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
                    for k, v in pairs(G.P_TAGS) do
                        if not v.in_pool or v:in_pool() then
                            table.insert(tag_types, k)
                        end
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
    joker_display_def = function(JokerDisplay)
        return {
            reminder_text = {
                { text = "(" },
                { ref_table = "card.joker_display_values", ref_value = "played" },
                { text = "/" },
                { ref_table = "card.joker_display_values", ref_value = "req" },
                { text = ")" }
            },
            calc_function = function(card)
                card.joker_display_values.played = card.ability.extra.hands_played
                card.joker_display_values.req = card.ability.extra.required_hands
            end
        }
    end,
    attributes = { "generation" }
}
