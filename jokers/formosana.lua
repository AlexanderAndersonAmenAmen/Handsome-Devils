local function target_nonplaying_card(context)
    return context and (context.card or context.other_card)
end

local function is_joker_card(card)
    local center = card and card.config and card.config.center
    return center and center.set == "Joker"
end

SMODS.Joker({
    key = "formosana",
    atlas = "Jokers",
    pos = { x = 0, y = 9 },
    rarity = 3,
    cost = 8,
    unlocked = true,
    discovered = false,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    config = { extra = { gain = 1, xmult = 1 } },
    loc_vars = function(self, info_queue, card)
        local extra = card and card.ability and card.ability.extra or self.config.extra
        return { vars = { extra.gain, extra.xmult } }
    end,
    calculate = function(self, card, context)
        if context.joker_type_destroyed then
            local target = target_nonplaying_card(context)
            local from_sell = context.trigger and context.trigger.from_sell
            if target == card and not from_sell and not context.blueprint then return { no_destroy = true } end
            if not context.blueprint and not from_sell and target ~= card and is_joker_card(target) then
                local target_key = target.config and target.config.center and target.config.center.key
                local protected = target_key == "j_hnds_formosana" or target.ability and target.ability.eternal
                if not protected then
                    card.ability.extra.xmult = card.ability.extra.xmult + card.ability.extra.gain
                    return { message = localize("k_upgrade_ex"), colour = G.C.MULT }
                end
            end
        end
        if context.joker_main and card.ability.extra.xmult > 1 then return { xmult = card.ability.extra.xmult } end
    end,
    attributes = { "xmult", "destroy_card", "scaling" },
})
