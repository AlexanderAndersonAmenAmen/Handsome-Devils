SMODS.Joker {
    key = "jokes_aside",
    config = {
        extra = {
            x_mult = 1,
            scaling = 0.2,
        }
    },
    rarity = 2,
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.x_mult, card.ability.extra.scaling } }
    end,
    atlas = "Jokers",
    pos = { x = 9, y = 0 },
    cost = 7,
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = false,
    calculate = function(self, card, context)
        if not card.debuff then
            if context.selling_card and context.card ~= card and G.STATE == G.STATES.SELECTING_HAND and context.card.ability.set == "Joker" then
                card.ability.extra.x_mult = card.ability.extra.x_mult + card.ability.extra.scaling
                return {
                    message = localize('k_upgrade_ex')
                }
            end

            --Scoring
            if context.joker_main and context.cardarea == G.jokers then
                return {
                    Xmult_mod = card.ability.extra.x_mult,
                    message = localize { type = 'variable', key = 'a_xmult', vars = { card.ability.extra.x_mult } },
                }
            end
        end
    end
}