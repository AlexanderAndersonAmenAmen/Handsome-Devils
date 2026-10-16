local ARTISTIC_TAG_EXCLUSIONS = {
    tag_boss = true,
    tag_juggle = true,
    tag_handy = true,
    tag_garbage = true,
    tag_speed = true,
}

local function four_scoring_suits(cards)
    local suits = {}
    for key in pairs(SMODS.Suits) do suits[#suits + 1] = key end
    table.sort(suits)
    local used = {}
    local function match(index, count)
        if count >= 4 then return true end
        if index > #(cards or {}) or #(cards or {}) - index + 1 < 4 - count then return false end
        local card = cards[index]
        if not card.debuff then
            for _, suit in ipairs(suits) do
                if not used[suit] and card:is_suit(suit) then
                    used[suit] = true
                    if match(index + 1, count + 1) then return true end
                    used[suit] = nil
                end
            end
        end
        return match(index + 1, count)
    end
    return match(1, 0)
end

SMODS.Joker({
    key = "artistic_joker",
    atlas = "Jokers", pos = { x = 4, y = 1 },
    rarity = 3, cost = 7, unlocked = true, discovered = false,
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    calculate = function(self, card, context)
        if context.after and G.GAME.current_round.hands_played == 0
            and four_scoring_suits(context.scoring_hand) then
            G.E_MANAGER:add_event(Event({ func = function()
                local tag = HNDS.poll_allowed_tag("hnds_artistic_tag", ARTISTIC_TAG_EXCLUSIONS)
                if tag then
                    add_tag(tag)
                    play_sound("generic1", 0.9, 0.8)
                end
                return true
            end }))
            return { message = localize("k_hnds_tag"), colour = G.C.FILTER }
        end
    end,
    attributes = { "tag", "suits" },
})
