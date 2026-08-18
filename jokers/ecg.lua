local function hnds_ecg_has_scoring_heart(context)
    for _, scoring_card in ipairs((context and context.scoring_hand) or {}) do
        if scoring_card and scoring_card.is_suit and scoring_card:is_suit('Hearts') then
            return true
        end
    end
    return false
end

SMODS.Joker {
    key = 'ecg',
    atlas = 'Jokers',
    pos = { x = 2, y = 7 },
    rarity = 1,
    cost = 5,
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,

    config = { extra = { mult = 0, gain = 1 } },

    loc_vars = function(self, info_queue, card)
        local extra = card and card.ability and card.ability.extra or self.config.extra
        return { vars = { tonumber(extra.gain) or 1, tonumber(extra.mult) or 0 } }
    end,

    calculate = function(self, card, context)
        local extra = card.ability.extra

        if context.before and not context.blueprint then
            if hnds_ecg_has_scoring_heart(context) then
                extra.mult = (tonumber(extra.mult) or 0) + (tonumber(extra.gain) or 1)
                return { message = localize('k_upgrade_ex'), colour = G.C.MULT }
            else
                extra.mult = 0
            end
        end

        if context.joker_main and (tonumber(extra.mult) or 0) > 0 then
            return { mult = extra.mult }
        end
    end,

    joker_display_def = function(JokerDisplay)
        return {
            text = {
                { text = '+' },
                { ref_table = 'card.ability.extra', ref_value = 'mult', colour = G.C.MULT },
            },
            text_config = { colour = G.C.MULT },
        }
    end,

    attributes = { 'mult', 'suit' },
}
