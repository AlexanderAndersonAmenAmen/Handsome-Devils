local function held_twos()
    local count = 0
    for _, held in ipairs((G and G.hand and G.hand.cards) or {}) do
        if held and held.get_id and held:get_id() == 2
            and not (SMODS.has_no_rank and SMODS.has_no_rank(held))
        then
            count = count + 1
        end
    end
    return count
end

local function update_hand_size(card, desired)
    if not (card and card.ability and type(card.ability.extra) == 'table'
        and G and G.hand and G.hand.change_size)
    then
        return
    end

    local extra = card.ability.extra
    local previous = tonumber(extra.hand_size_bonus) or 0
    local difference = desired - previous
    if difference ~= 0 then
        G.hand:change_size(difference)
        extra.hand_size_bonus = desired
    end
end

SMODS.Joker({
    key = 'laugh_preserver',
    atlas = 'Jokers',
    pos = { x = 0, y = 2 },
    rarity = 2,
    cost = 6,
    unlocked = true,
    discovered = false,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    config = { extra = { hand_size_bonus = 0 } },

    update = function(self, card, dt)
        if not (G and G.hand and G.hand.change_size) then return end
        local active = G.jokers and card.area == G.jokers
            and not card.debuff and not card.REMOVED and not card.removed
        update_hand_size(card, active and held_twos() or 0)
    end,

    remove_from_deck = function(self, card, from_debuff)
        update_hand_size(card, 0)
    end,

    attributes = { 'hand_size', 'passive', '2' },
})
