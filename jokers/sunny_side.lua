local function sunny_extra(card)
    if type(card.ability.extra) ~= "table" then card.ability.extra = {} end
    local extra = card.ability.extra
    if extra.mult == nil then extra.mult = 15 end
    extra.steal = extra.steal or 1
    return extra
end

SMODS.Joker({
    key = "sunny_side",
    atlas = "Jokers",
    pos = { x = 6, y = 0 },
    rarity = 1,
    cost = 6,
    unlocked = true,
    discovered = false,
    blueprint_compat = true,
    eternal_compat = false,
    perishable_compat = true,
    pools = { Food = true },
    config = { extra = { mult = 15, steal = 1 } },
    loc_vars = function(self, info_queue, card)
        local extra = sunny_extra(card)
        return { vars = { extra.mult, extra.steal } }
    end,
    calculate = function(self, card, context)
        local extra = sunny_extra(card)
        if context.individual and context.cardarea == G.play and not context.blueprint
            and context.other_card and not context.other_card.debuff and context.other_card:is_face()
            and extra.mult > 0 then
            local amount = math.min(extra.steal, extra.mult)
            extra.mult = extra.mult - amount
            context.other_card.ability.perma_mult = (context.other_card.ability.perma_mult or 0) + amount
            return { mult = amount, message = localize("k_upgrade_ex"), colour = G.C.MULT, card = context.other_card }
        end
        if context.joker_main then return { mult = extra.mult } end
        if context.after and not context.blueprint and extra.mult <= 0
            and not card.getting_sliced and not card.removed and not card.REMOVED then
            local destroyed = SMODS.destroy_cards({ card }, { pinch_anim = true })
            if destroyed and #destroyed > 0 then
                return { message = localize("k_hnds_consumed"), colour = G.C.MULT }
            end
        end
    end,
    attributes = { "mult", "face", "food" },
})
