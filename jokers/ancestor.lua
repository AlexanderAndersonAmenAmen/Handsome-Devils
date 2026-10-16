local hnds_ancestor_unlock_cache = { value = false, checked_at = -math.huge }

local function hnds_ancestor_all_spectrals_discovered()
    local now = G and G.TIMERS and G.TIMERS.REAL or 0
    if now - hnds_ancestor_unlock_cache.checked_at < 1 then
        return hnds_ancestor_unlock_cache.value
    end
    local total, discovered = 0, 0
    for _, center in pairs((G and G.P_CENTERS) or {}) do
        if center and center.set == 'Spectral'
            and center.no_collection ~= true and center.omit ~= true
        then
            total = total + 1
            if center.discovered then discovered = discovered + 1 end
        end
    end
    hnds_ancestor_unlock_cache.checked_at = now
    hnds_ancestor_unlock_cache.value = total > 0 and discovered >= total
    return hnds_ancestor_unlock_cache.value
end

-- Replaces exactly one of the two normal shop pack slots, not a third slot.
local function hnds_ancestor_owned()
    for _, joker in ipairs((G and G.jokers and G.jokers.cards) or {}) do
        if joker and joker.config and joker.config.center
            and joker.config.center.key == 'j_hnds_ancestor' and not joker.debuff then
            return true
        end
    end
    return false
end

function HNDS.ancestor_starting_shop()
    if not (G and G.GAME) then return end
    local game = G.GAME
    game.hnds_ancestor_shop_number = (game.hnds_ancestor_shop_number or 0) + 1
    game.hnds_ancestor_slot_used = false
    game.hnds_ancestor_shop_active = hnds_ancestor_owned()
    if not game.hnds_ancestor_shop_active then return end
    local chance = pseudorandom('hnds_ancestor_forced_' .. game.hnds_ancestor_shop_number)
    game.hnds_ancestor_shop_forced = chance < ((game.probabilities and game.probabilities.normal or 1) / 3)
    -- Handle versions or other mods that generate shop packs before firing
    -- starting_shop, as well as the normal later CardArea:emplace pathway.
    if G.shop_booster and G.shop_booster.cards and G.shop_booster.cards[1] then
        HNDS.ancestor_process_shop_pack(G.shop_booster.cards[1])
    end
end

function HNDS.ancestor_process_shop_pack(pack)
    local game = G and G.GAME
    if not (game and game.hnds_ancestor_shop_active and not game.hnds_ancestor_slot_used
        and G.shop_booster and pack and pack.area == G.shop_booster
        and G.P_CENTERS and G.P_CENTERS.p_hnds_cursed_pack) then return end
    -- Mark slot before changing the center, to prevent recursive callbacks.
    game.hnds_ancestor_slot_used = true
    if pack.set_ability then pack:set_ability(G.P_CENTERS.p_hnds_cursed_pack) end
    pack.cost = 0
    pack.ability = pack.ability or {}
    pack.ability.couponed = true
    pack.hnds_forced_no_skip = game.hnds_ancestor_shop_forced == true
    pack.hnds_cursed_pack_source = 'ancestor'
    if pack.set_cost then pack:set_cost() end
    pack.cost = 0
end

-- Shop booster objects are not guaranteed to exist when starting_shop fires.
-- Intercept their insertion instead, so one real pack slot is replaced.
if CardArea and CardArea.emplace and not CardArea._hnds_ancestor_pack_wrapped then
    CardArea._hnds_ancestor_pack_wrapped = true
    local emplace_ref = CardArea.emplace
    function CardArea:emplace(card, ...)
        local result = emplace_ref(self, card, ...)
        if G and self == G.shop_booster then
            HNDS.ancestor_process_shop_pack(card)
        end
        return result
    end
end

SMODS.Joker {
    key = 'ancestor',
    atlas = 'Jokers',
    pos = { x = 9, y = 7 },
    rarity = 3,
    cost = 8,
    unlocked = false,
    discovered = false,
    config = { extra = { odds = 3 } },
    blueprint_compat = false,
    eternal_compat = false,
    perishable_compat = true,
    unlock_condition = { type = 'hnds_discovery' },

    loc_vars = function(self, info_queue, card)
        if info_queue and G and G.P_CENTERS and G.P_CENTERS.p_hnds_cursed_pack then
            info_queue[#info_queue + 1] = G.P_CENTERS.p_hnds_cursed_pack
        end
        local numerator, denominator = SMODS.get_probability_vars(card, 1, 3, 'hnds_ancestor')
        return { vars = { numerator, denominator } }
    end,

    check_for_unlock = function(self, args)
        return hnds_ancestor_all_spectrals_discovered()
    end,

    calculate = function(self, card, context)
        -- Shop pack replacement is handled once through the mod's
        -- starting_shop context and CardArea insertion hook.
    end,

    attributes = { 'joker', 'passive' },
}
