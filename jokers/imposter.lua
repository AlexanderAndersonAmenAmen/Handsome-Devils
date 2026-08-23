SMODS.Joker {
    key = "imposter",
    atlas = "Jokers",
    pos = { x = 6, y = 4 },
    rarity = 2,
    cost = 6,
    unlocked = false,
    discovered = false,
    unlock_condition = { type = "hnds_joker_unlock", key = "imposter" },
    locked_loc_vars = function(self)
        return HNDS.joker_locked_loc_vars("imposter")
    end,
    check_for_unlock = function(self, args)
        return HNDS.joker_unlock_condition_met("imposter", args)
    end,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    config = { extra = {} },
    calculate = function(self, card, context)
        -- Effect in hooks file, the Joker is the Boolean
    end,
    attributes = { "passive", "face" }
}

-- Imposter Joker: allows face cards (J/Q/K) to match any required rank
-- when the Imposter joker is in the player's joker slots.
-- Consumed by the rank-spoofing system in lib/hooks.lua.
function HNDS.imposter_rank_match(card, required_id)
    if not (card and type(card.get_id) == 'function') then return false end
    local id = card:get_id()
    if id == nil then return false end
    local found = SMODS and type(SMODS.find_card) == 'function' and SMODS.find_card('j_hnds_imposter') or {}
    if type(found) ~= 'table' then found = {} end
    if #found > 0 and id >= 11 and id <= 13 then return true end
    return id == required_id
end
