SMODS.Joker {
    key = "head_of_medusa",
    config = {
        extra = {
            x_mult = 1,
            scaling = 0.1,
        }
    },
    rarity = 2,
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.x_mult, card.ability.extra.scaling } }
    end,
    atlas = "Jokers",
    pos = { x = 6, y = 0 },
    cost = 8,
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = false,
    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            local faces = 0
            for k, v in ipairs(context.scoring_hand) do
                if v:is_face() then
                    faces = faces + 1
                    v.hnds_petrifying = true
                    v:set_ability(G.P_CENTERS.m_stone, nil, true)
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            v:juice_up()
                            v.hnds_petrifying = nil
                            return true
                        end
                    }))
                end
            end
            if faces > 0 then
                SMODS.scale_card(card, {
                    ref_table = card.ability.extra,
                    ref_value = "x_mult",
                    scalar_value = "scaling",
                    operation = function(ref_table, ref_value, initial, change)
                        ref_table[ref_value] = initial + faces * change
                    end,
                    scaling_message = {
                        message_key = "k_hnds_petrified",
                        colour = G.C.GREY
                    }
                })
            end
        end
        if context.forcetrigger then
            SMODS.scale_card(card, {
                ref_table = card.ability.extra,
                ref_value = "x_mult",
                scalar_value = "scaling",
                scaling_message = {
                    message_key = "k_hnds_petrified",
                    colour = G.C.GREY
                }
            })
            return {
                xmult = card.ability.extra.x_mult
            }
        end

        --Scoring
        if context.joker_main and context.cardarea == G.jokers then
            return {
                xmult = card.ability.extra.x_mult,
            }
        end
    end
}
