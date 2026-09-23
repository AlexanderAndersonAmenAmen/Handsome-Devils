local HNDS_DARK_IDOL_RANK_IDS = {
    ['2'] = 2, ['3'] = 3, ['4'] = 4, ['5'] = 5, ['6'] = 6, ['7'] = 7,
    ['8'] = 8, ['9'] = 9, ['10'] = 10, Jack = 11, Queen = 12, King = 13, Ace = 14,
}

local function hnds_dark_idol_state()
    local state = G and G.GAME and G.GAME.current_round and G.GAME.current_round.dark_idol
    return state or { rank = 'Ace', id = 14 }
end

local function hnds_dark_idol_article(rank)
    return (rank == 'Ace' or rank == '8') and 'an' or 'a'
end

local function hnds_dark_idol_extra(card)
    local extra = card and card.ability and card.ability.extra
    if type(extra) ~= 'table' then
        extra = {}
        if card and card.ability then card.ability.extra = extra end
    end
    if extra.total ~= nil then
        extra.mult = 0
        extra.total = nil
    end
    extra.gain = 2
    extra.mult = tonumber(extra.mult) or 0
    return extra
end

SMODS.Joker {
    key = 'dark_idol',
    atlas = 'Jokers',
    pos = { x = 1, y = 2 },
    rarity = 2,
    cost = 7,
    unlocked = false,
    discovered = false,
    unlock_condition = { type = 'hnds_joker_unlock', key = 'dark_idol' },
    locked_loc_vars = function(self)
        return HNDS.joker_locked_loc_vars('dark_idol')
    end,
    check_for_unlock = function(self, args)
        return HNDS.joker_unlock_condition_met('dark_idol', args)
    end,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = false,
    config = { extra = { gain = 2, mult = 0 } },
    loc_vars = function(self, info_queue, card)
        local state = hnds_dark_idol_state()
        local extra = hnds_dark_idol_extra(card)
        return { vars = { hnds_dark_idol_article(state.rank), localize(state.rank, 'ranks'), extra.gain, extra.mult } }
    end,
    calculate = function(self, card, context)
        local extra = hnds_dark_idol_extra(card)
        if context.hand_drawn and type(context.hand_drawn) == 'table' and not context.blueprint then
            local state = hnds_dark_idol_state()
            local id = tonumber(state.id) or HNDS_DARK_IDOL_RANK_IDS[state.rank] or 14
            local count = 0
            for _, drawn in ipairs(context.hand_drawn) do
                if drawn and type(drawn.get_id) == 'function' and drawn:get_id() == id then count = count + 1 end
            end
            if count > 0 then
                extra.mult = extra.mult + extra.gain * count
                return { message = localize('k_upgrade_ex'), colour = G.C.MULT }
            end
        end
        if context.joker_main and extra.mult > 0 then return { mult = extra.mult } end
    end,
    attributes = { 'scaling', 'mult', 'rank' },
}
