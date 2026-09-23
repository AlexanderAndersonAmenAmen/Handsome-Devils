local function hnds_be_not_afraid_ace_values(playing_card)
    if not playing_card or playing_card.debuff then return 0, 0 end
    if type(playing_card.get_id) ~= 'function' or playing_card:get_id() ~= 14 then return 0, 0 end
    if HNDS and HNDS.safe_has_no_rank and HNDS.safe_has_no_rank(playing_card) then return 0, 0 end
    local chips = 0
    local mult = 0
    if type(playing_card.get_chip_bonus) == 'function' then chips = chips + (tonumber(playing_card:get_chip_bonus()) or 0) end
    if type(playing_card.get_chip_h_bonus) == 'function' then chips = chips + (tonumber(playing_card:get_chip_h_bonus()) or 0) end
    if type(playing_card.get_chip_mult) == 'function' then mult = mult + (tonumber(playing_card:get_chip_mult()) or 0) end
    if type(playing_card.get_chip_h_mult) == 'function' then mult = mult + (tonumber(playing_card:get_chip_h_mult()) or 0) end
    if type(playing_card.edition) == 'table' then
        chips = chips + (tonumber(playing_card.edition.chips) or 0)
        mult = mult + (tonumber(playing_card.edition.mult) or 0)
    end
    return chips, mult
end

SMODS.Joker {
    key = 'be_not_afraid',
    atlas = 'Jokers',
    pos = { x = 6, y = 6 },
    rarity = 2,
    cost = 5,
    unlocked = false,
    discovered = false,
    unlock_condition = { type = "hnds_joker_unlock", key = "be_not_afraid" },
    locked_loc_vars = function(self)
        return HNDS.joker_locked_loc_vars("be_not_afraid")
    end,
    check_for_unlock = function(self, args)
        return HNDS.joker_unlock_condition_met("be_not_afraid", args)
    end,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = false,
    config = { extra = { chips = 0, mult = 0 } },
    loc_vars = function(self, info_queue, card)
        local extra = card and card.ability and card.ability.extra or self.config.extra
        return { vars = { tonumber(extra.chips) or 0, tonumber(extra.mult) or 0 } }
    end,
    calculate = function(self, card, context)
        if context.hand_drawn and type(context.hand_drawn) == 'table' and not context.blueprint then
            local chips_gain = 0
            local mult_gain = 0
            for _, drawn in ipairs(context.hand_drawn) do
                local chips, mult = hnds_be_not_afraid_ace_values(drawn)
                chips_gain = chips_gain + chips
                mult_gain = mult_gain + mult
            end
            if chips_gain ~= 0 or mult_gain ~= 0 then
                card.ability.extra.chips = (tonumber(card.ability.extra.chips) or 0) + chips_gain
                card.ability.extra.mult = (tonumber(card.ability.extra.mult) or 0) + mult_gain
                return { message = localize('k_upgrade_ex'), colour = G.C.FILTER }
            end
        end
        if context.joker_main then
            local chips = tonumber(card.ability.extra.chips) or 0
            local mult = tonumber(card.ability.extra.mult) or 0
            if chips ~= 0 or mult ~= 0 then
                return { chips = chips, mult = mult }
            end
        end
    end,
    attributes = { 'chips', 'mult', 'rank', 'scaling' },
}
