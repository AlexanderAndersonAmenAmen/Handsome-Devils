local function energized_extra(card)
    local extra = card and card.ability and card.ability.extra
    if type(extra) ~= 'table' then
        extra = { cards_drawn = 0, charges = 0, cards_per_charge = 4 }
        if card and card.ability then card.ability.extra = extra end
    end
    extra.cards_per_charge = 4
    extra.cards_drawn = math.max(0, tonumber(extra.cards_drawn) or 0)
    extra.charges = math.max(0, tonumber(extra.charges) or 0)
    return extra
end

SMODS.Joker {
    key = 'energized', atlas = 'Jokers', pos = { x = 2, y = 2 },
    rarity = 3, cost = 10,
    config = { extra = { cards_per_charge = 4, cards_drawn = 0, charges = 0 } },
    unlocked = false, discovered = false,
    unlock_condition = { type = 'hnds_joker_unlock', key = 'energized' },
    locked_loc_vars = function(self) return HNDS.joker_locked_loc_vars('energized') end,
    check_for_unlock = function(self, args) return HNDS.joker_unlock_condition_met('energized', args) end,
    blueprint_compat = false, eternal_compat = true, perishable_compat = true,
    loc_vars = function(self, info_queue, card)
        local extra = energized_extra(card)
        return { vars = { extra.cards_per_charge - extra.cards_drawn % extra.cards_per_charge, extra.charges } }
    end,
    calculate = function(self, card, context)
        local extra = energized_extra(card)
        if context.hand_drawn and type(context.hand_drawn) == 'table' and not context.blueprint then
            local count = 0
            for _, drawn in ipairs(context.hand_drawn) do
                if drawn and not drawn.debuff and drawn.is_suit and drawn:is_suit('Diamonds') then count = count + 1 end
            end
            if count > 0 then
                local all = extra.cards_drawn + count
                local gained = math.floor(all / extra.cards_per_charge)
                extra.cards_drawn = all % extra.cards_per_charge
                extra.charges = extra.charges + gained
                if gained > 0 then return { message = '+' .. gained .. ' Charge', colour = G.C.FILTER } end
            end
        end
        if context.retrigger_joker_check and context.other_card and not context.other_card.debuff and not context.blueprint
            and extra.charges > 0 and card.area == G.jokers then
            local jokers = G.jokers.cards
            for i = 1, #jokers - 1 do
                if jokers[i] == card and jokers[i+1] == context.other_card then
                    local charges = extra.charges
                    extra.charges = 0
                    return { repetitions = charges, card = card }
                end
            end
        end
    end,
    attributes = { 'retrigger', 'scaling', 'suit' },
}
