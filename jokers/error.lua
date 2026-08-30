SMODS.Atlas {
    key = 'ERROR_BG',
    path = 'ERROR2.png',
    px = 71,
    py = 95,
    frames = 26,
    fps = 24,
    atlas_table = 'ANIMATION_ATLAS',
}

SMODS.Atlas {
    key = 'ERROR_FG',
    path = 'ERROR.png',
    px = 71,
    py = 95,
    frames = 26,
    fps = 24,
    atlas_table = 'ANIMATION_ATLAS',
}

SMODS.Joker {
    key = 'error',
    atlas = 'ERROR_BG',
    pos = { x = 0, y = 0 },
    soul_atlas = 'ERROR_FG',
    soul_pos = {
        x = 0,
        y = 0,
        draw = function(card, scale_mod, rotate_mod)
            if card.children.floating_sprite then
                card.children.floating_sprite:draw_shader('dissolve', nil, nil, nil, card.children.center, scale_mod, rotate_mod)
            end
        end,
    },
    rarity = 2,
    cost = 6,
    unlocked = true,
    discovered = false,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    config = { extra = { xmult = 2 } },
    loc_txt = {
        name = 'ERROR',
        text = {
            '{X:mult,C:white}X#1#{} Mult',
        },
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult } }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            return { xmult = card.ability.extra.xmult }
        end
    end,
    joker_display_def = function(JokerDisplay)
        return {
            text = {
                {
                    border_nodes = {
                        { text = 'X' },
                        { ref_table = 'card.joker_display_values', ref_value = 'x_mult', retrigger_type = 'exp' },
                    },
                },
            },
            calc_function = function(card)
                card.joker_display_values.x_mult = card.ability.extra.xmult
            end,
        }
    end,
    attributes = { 'xmult' },
}
