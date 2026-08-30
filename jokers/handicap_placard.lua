SMODS.Joker {
    key = 'handicap_placard',
    atlas = 'Jokers',
    pos = { x = 1, y = 8 },
    rarity = 2,
    cost = 6,
    unlocked = true,
    discovered = false,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    config = { extra = { xmult = 2 } },
    loc_txt = {
        name = 'Handicap Placard',
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
