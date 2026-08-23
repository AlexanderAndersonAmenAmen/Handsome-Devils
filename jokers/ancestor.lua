local function hnds_ancestor_all_spectrals_discovered()
    local total, discovered = 0, 0
    for _, center in pairs((G and G.P_CENTERS) or {}) do
        if center and center.set == 'Spectral'
            and center.no_collection ~= true and center.omit ~= true
        then
            total = total + 1
            if center.discovered then discovered = discovered + 1 end
        end
    end
    return total > 0 and discovered >= total
end

local function hnds_ancestor_curse_first_shop_joker()
    if not (G and G.shop_jokers and G.shop_jokers.cards) then return true end

    local target
    for _, shop_card in ipairs(G.shop_jokers.cards) do
        local center = shop_card and shop_card.config and shop_card.config.center
        local set = (shop_card and shop_card.ability and shop_card.ability.set)
            or (center and center.set)
        if set == 'Joker' then
            target = shop_card
            break
        end
    end

    if not target then return true end
    target.ability = target.ability or {}

    -- Multiple Ancestors should still affect only the first Joker in the shop.
    if target.ability.hnds_ancestor_cursed then return true end

    if type(apply_curse) == 'function' then
        apply_curse(target)
    elseif HNDS and type(HNDS.assign_curse_data) == 'function' then
        HNDS.assign_curse_data(target)
        if target.add_sticker and not target.ability.hnds_cursed then
            target:add_sticker('hnds_cursed', true)
        end
    else
        return true
    end

    -- Mark only the Joker forced by The Ancestor. trigger_curse uses this flag
    -- to give this purchase (and no other Cursed Joker) a 1-in-4 price bypass.
    target.ability = target.ability or {}
    target.ability.hnds_ancestor_cursed = true
    return true
end

SMODS.Joker {
    key = 'ancestor',
    atlas = 'Jokers',
    pos = { x = 9, y = 7 },
    rarity = 3,
    cost = 8,
    unlocked = false,
    discovered = false,
    config = {
		extra = { odds = 4 }
	},
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    unlock_condition = { type = 'hnds_discovery' },

    loc_vars = function(self, info_queue, card)
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, "hnds_ancestor")
        return { key = self.key, vars = { numerator, denominator } }
    end,

    check_for_unlock = function(self, args)
        return hnds_ancestor_all_spectrals_discovered()
    end,

    calculate = function(self, card, context)
        if context.starting_shop and context.main_eval
            and not context.repetition and not context.blueprint
            and G and G.E_MANAGER and Event
        then
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0,
                func = hnds_ancestor_curse_first_shop_joker,
            }))
        end
    end,

    attributes = { 'joker', 'passive' },
}
