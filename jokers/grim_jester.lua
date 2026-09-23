HNDS = HNDS or {}

function HNDS.grim_jester_active()
    if not (G and G.jokers and G.jokers.cards) then return false end

    for _, joker in ipairs(G.jokers.cards) do
        local center = joker and joker.config and joker.config.center
        local key = center and center.key
        local name = joker and joker.ability and joker.ability.name
        if (key == 'j_grim_jester' or key == 'j_hnds_grim_jester' or name == 'Grim Jester')
            and not joker.debuff and not joker.REMOVED and not joker.removed
        then
            return true
        end
    end

    return false
end

function HNDS.grim_jester_prioritized(card)
    if not card or card.removed or card.REMOVED then return false end

    if type(card.is_suit) == 'function' then
        local ok_spades, is_spades = pcall(card.is_suit, card, 'Spades')
        if ok_spades and is_spades then return true end

        local ok_clubs, is_clubs = pcall(card.is_suit, card, 'Clubs')
        if ok_clubs and is_clubs then return true end
    end

    local suit = card.base and card.base.suit
    return suit == 'Spades' or suit == 'Clubs'
end

function HNDS.grim_jester_next_card(deck, discarded_only)
    if not HNDS.grim_jester_active() then return nil end

    local cards = deck and deck.cards
    if type(cards) ~= 'table' then return nil end

    for index = #cards, 1, -1 do
        local candidate = cards[index]
        local allowed = not discarded_only
            or (candidate and candidate.ability and candidate.ability.discarded)
        if allowed and HNDS.grim_jester_prioritized(candidate) then
            return candidate
        end
    end

    return nil
end

SMODS.Joker {
    key = 'grim_jester',
    prefix_config = { key = { mod = false } },
    atlas = 'Jokers',
    pos = { x = 8, y = 4 },
    rarity = 2,
    cost = 6,
    unlocked = true,
    discovered = false,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    loc_vars = function(self, info_queue, card)
        local suit_colours = G and G.C and G.C.SUITS or {}
        local fallback = G and G.C and G.C.BLACK or { 0, 0, 0, 1 }
        return { vars = { colours = {
            suit_colours.Spades or fallback,
            suit_colours.Clubs or fallback,
        } } }
    end,
    attributes = { 'joker', 'passive', 'suit' },
}
