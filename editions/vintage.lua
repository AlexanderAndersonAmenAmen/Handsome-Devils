if hnds_config.enableVintageEdition then

SMODS.Shader({ key = 'vintage', path = 'vintage.fs' })

local function is_playing_card(card)
    local set = card and card.ability and card.ability.set
    return set == 'Default' or set == 'Enhanced'
end

SMODS.Edition({
    key = "vintage",
    disable_shadow = false,
    disable_base_shader = true,
    shader = "vintage",
    discovered = false,
    unlocked = true,
    config = {},
    in_shop = true,
    weight = 7,
    extra_cost = 4,
    sound = { sound = "hnds_vintage", per = 1.2, vol = 0.225 },
    apply_to_float = true,
    loc_vars = function(self, info_queue, card)
        return {
            key = is_playing_card(card) and "e_hnds_vintage_playing_card" or nil,
            vars = {},
        }
    end,
    calculate = function(self, card, context)
        if is_playing_card(card) then
            if context.main_scoring and context.cardarea == G.play and not card.debuff then
                return { dollars = 3 }
            end
            return
        end

        if context.end_of_round and context.main_eval and context.cardarea == G.jokers then
            card.ability.extra_value = (card.ability.extra_value or 0) + 2
            card:set_cost()
            return { message = localize('k_val_up'), colour = G.C.MONEY }
        end
    end,
})

end
