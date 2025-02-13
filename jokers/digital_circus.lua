SMODS.Joker {
    key = "digital_circus",
    config = {
        extra = {
            max_rounds = 3,
            current_rounds = 0,
            current_rarity = 1,
            rarity_strings = { "Common", "Uncommon", "Rare", "Legendary" }
        }
    },
    rarity = 3,
    loc_vars = function(self, info_queue, card)
        local rarity_color = { "blue", "green", "red", "legendary,E:1" }
        return {
            vars = {
                card.ability.extra.rarity_strings[card.ability.extra.current_rarity],
                card.ability.extra.current_rounds,
                card.ability.extra.max_rounds,
                colours = {
                    G.C.RARITY[card.ability.extra.current_rarity]
                }
            }
        }
    end,
    atlas = "Jokers",
    pos = { x = 2, y = 0 },
    cost = 8,
    unlocked = true,
    discovered = true,
    blueprint_compat = false,
    eternal_compat = false,
    perishable_compat = true,
    calculate = function(self, card, context)
        if not card.debuff then
            if context.selling_self and not context.blueprint then
                if #G.jokers.cards <= G.jokers.config.card_limit then
                    local rarity_vals = { 0, 0.8, 1 }
                    SMODS.add_card({
                        set = 'Joker',
                        area = G.jokers,
                        legendary = (card.ability.extra.current_rarity == 4) or nil,
                        rarity = (card.ability.extra.current_rarity ~= 4) and
                        rarity_vals[card.ability.extra.current_rarity] or nil
                    })
                else
                    card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil,
                        { message = localize('k_no_room_ex') })
                end
            end

            if context.end_of_round and context.cardarea == G.jokers then
                if card.ability.extra.current_rarity ~= 4 then
                    card.ability.extra.current_rounds = card.ability.extra.current_rounds + 1
                    if card.ability.extra.current_rounds >= card.ability.extra.max_rounds then
                        card.ability.extra.current_rarity = card.ability.extra.current_rarity + 1
                        if card.ability.extra.current_rarity ~= 4 then
                            card.ability.extra.current_rounds = 0
                        end
                    end
                    if card.ability.extra.current_rounds ~= 0 and card.ability.extra.current_rounds ~= card.ability.extra.max_rounds then
                        return {
                            message = card.ability.extra.current_rounds .. '/' .. card.ability.extra.max_rounds,
                            colour = G.C.FILTER
                        }
                    else
                        return {
                            message = card.ability.extra.rarity_strings[card.ability.extra.current_rarity] .. "!",
                            colour = G.C.RARITY[card.ability.extra.current_rarity]
                        }
                    end
                end
            end
        end
    end,
    add_to_deck = function(self, card, from_debuff)
        card:set_cost()
    end
}
