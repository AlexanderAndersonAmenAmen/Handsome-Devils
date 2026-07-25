SMODS.Joker {
    key = "contagion",
    atlas = "Jokers",
    pos = { x = 5, y = 4 },
    rarity = 3,
    cost = 7,
    unlocked = true,
    discovered = true,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    config = {},
    calculate = function(self, card, context)
        -- Card-selection limits are synchronized centrally in lib/hooks.lua so
        -- every eligible consumable, including cards already held, updates live.
    end,
    attributes = { "consumable", "passive" },
}

-- Vanilla Spectral descriptions hard-code "1 selected card" and therefore do
-- not reflect Contagion. Take ownership of their localization and give Aura a
-- normal one-card targeting config; the runtime hooks extend the effects.
local function hnds_contagion_display_bonus()
    return HNDS and HNDS.get_contagion_bonus and HNDS.get_contagion_bonus() or 0
end

local function hnds_add_contagion_spectral_info(info_queue, kind)
    if not info_queue then return end
    if kind == 'Gold' then
        info_queue[#info_queue + 1] = { key = 'gold_seal', set = 'Other' }
    elseif kind == 'Red' then
        info_queue[#info_queue + 1] = { key = 'red_seal', set = 'Other' }
    elseif kind == 'Blue' then
        info_queue[#info_queue + 1] = { key = 'blue_seal', set = 'Other' }
    elseif kind == 'Purple' then
        info_queue[#info_queue + 1] = { key = 'purple_seal', set = 'Other' }
    elseif kind == 'Aura' then
        info_queue[#info_queue + 1] = G.P_CENTERS.e_foil
        info_queue[#info_queue + 1] = G.P_CENTERS.e_holo
        info_queue[#info_queue + 1] = G.P_CENTERS.e_polychrome
    end
end

local hnds_contagion_vanilla_spectrals = {
    talisman = 'Gold',
    deja_vu = 'Red',
    trance = 'Blue',
    medium = 'Purple',
    aura = 'Aura',
}

for key, kind in pairs(hnds_contagion_vanilla_spectrals) do
    -- Lua 5.1 closures capture loop variables by reference, so make per-entry
    -- copies before creating loc_vars.
    local spectral_key = key
    local spectral_kind = kind
    local ownership = {
        loc_vars = function(self, info_queue, card)
            hnds_add_contagion_spectral_info(info_queue, spectral_kind)
            local bonus = hnds_contagion_display_bonus()
            if bonus > 0 then
                return {
                    key = 'c_hnds_contagion_' .. spectral_key,
                    vars = { 1 + bonus },
                }
            end
            return { vars = {} }
        end,
    }
    -- Aura's vanilla one-card rule is hard-coded and its center has an empty
    -- config. Supplying the standard fields lets the hand UI highlight the
    -- extra Contagion targets; can_use still verifies that every target has no
    -- Edition.
    if spectral_key == 'aura' then
        ownership.config = { max_highlighted = 1, mod_num = 1 }
    end
    SMODS.Consumable:take_ownership(spectral_key, ownership)
end

-- Cryptid already localizes the number of copies, but its target count is
-- hard-coded. Supply a second variable while Contagion is active.
SMODS.Consumable:take_ownership('cryptid', {
    loc_vars = function(self, info_queue, card)
        local copies = (card and card.ability and tonumber(card.ability.extra))
            or (self.config and tonumber(self.config.extra))
            or 2
        local bonus = hnds_contagion_display_bonus()
        if bonus > 0 then
            return {
                key = 'c_hnds_contagion_cryptid',
                vars = { copies, 1 + bonus },
            }
        end
        return { vars = { copies } }
    end,
})
