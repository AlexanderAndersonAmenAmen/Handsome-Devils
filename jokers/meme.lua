SMODS.Joker {
    key = 'meme',
    atlas = 'Jokers',
    pos = { x = 0, y = 1 },
    rarity = 3,
    cost = 8,
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    config = {
        extra = {
            x_mult = 1,
            scaling = 0.05,
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.x_mult, card.ability.extra.scaling } }
    end,
    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            --[[
            local suits = {}
            for i, other_card in ipairs(context.scoring_hand) do
                for suit, _ in pairs(SMODS.Suits) do
                    if other_card:is_suit(suit) and not suits[suit] then
                        suits[suit] = true
                        card.ability.extra.x_mult = card.ability.extra.x_mult + card.ability.extra.scaling
                    end
                end
            end]]
            local boost = card.ability.extra.scaling * HNDS.get_unique_suits(context.scoring_hand)
            if boost > 0 then
                card.ability.extra.x_mult = card:scale_value(card.ability.extra.x_mult, card.ability.extra.scaling)
                return {
                    message = localize('k_upgrade_ex')
                }
            end
        elseif context.joker_main then
            return {
                xmult = card.ability.extra.x_mult
            }
        end
    end
}
