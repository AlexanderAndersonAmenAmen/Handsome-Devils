local previewing = false

function HNDS.count_scoring_sevens(cards, preview)
    local count = 0
    for _, card in ipairs(cards or {}) do
        if not card.debuff and card:get_id() == 7 and not SMODS.has_no_rank(card)
            and (not preview or card.facing ~= "back") then count = count + 1 end
    end
    return count
end

function HNDS.loaded_die_bonus(from_roll)
    if not (G and G.GAME) then return 0 end
    if G.STATE == G.STATES.HAND_PLAYED then return G.GAME.hnds_scoring_sevens or 0 end
    if from_roll or previewing or G.STATE ~= G.STATES.SELECTING_HAND
        or not G.hand or #G.hand.highlighted == 0 then return 0 end
    previewing = true
    local _, _, _, scoring_hand = G.FUNCS.get_poker_hand_info(G.hand.highlighted)
    local count = HNDS.count_scoring_sevens(scoring_hand, true)
    previewing = false
    return count
end

local probability_jokers = {
    j_8_ball = true, j_business = true, j_space = true, j_gros_michel = true,
    j_cavendish = true, j_reserved_parking = true, j_hallucination = true,
    j_lucky_cat = true, j_bloodstone = true, j_oops = true,
}

function HNDS.joker_has_probability(card)
    local center = card.config and card.config.center
    if not center then return false end
    if probability_jokers[center.key] then return true end
    for _, attr in ipairs(center.attributes or {}) do
        if attr == "chance" or attr == "probability" or attr == "mod_chance" then return true end
    end
    local entry = G.localization and G.localization.descriptions and G.localization.descriptions.Joker
        and G.localization.descriptions.Joker[center.key]
    for _, line in ipairs(entry and entry.text or {}) do
        if line:lower():find("chance", 1, true) or line:lower():find("probabilit", 1, true) then return true end
    end
    local extra = card.ability and card.ability.extra
    return type(extra) == "table" and (extra.odds ~= nil or extra.base_chance ~= nil
        or extra.probability ~= nil or extra.chance ~= nil) or false
end

SMODS.Joker({
    key = "loaded_die",
    atlas = "Jokers",
    pos = { x = 8, y = 0 },
    rarity = 2,
    cost = 7,
    unlocked = true,
    discovered = false,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    in_pool = function(self)
        for _, card in ipairs(G.playing_cards or {}) do
            if SMODS.has_enhancement(card, "m_lucky") then return true end
        end
        for _, card in ipairs(G.jokers and G.jokers.cards or {}) do
            if HNDS.joker_has_probability(card) then return true end
        end
        return false
    end,
    calculate = function(self, card, context)
        if context.mod_probability then
            return { numerator = context.numerator + HNDS.loaded_die_bonus(context.from_roll) }
        end
    end,
    attributes = { "probability", "mod_chance", "7" },
})
