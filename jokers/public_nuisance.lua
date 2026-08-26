


local function hnds_public_nuisance_score_met()
    if not (G and G.GAME and G.GAME.blind) then return false end
    local chips = G.GAME.chips
    local blind_chips = G.GAME.blind.chips
    if chips == nil or blind_chips == nil then return false end


    if type(to_big) == 'function' then
        local ok, result = pcall(function()
            return to_big(chips) >= to_big(blind_chips)
        end)
        if ok then return result == true end
    end

    local ok, result = pcall(function()
        return chips >= blind_chips
    end)
    return ok and result == true
end

local function hnds_public_nuisance_is_active()
    local joker_area = G and G.jokers
    local cards = joker_area and joker_area.cards
    if type(cards) ~= 'table' then return false end

    for _, joker in ipairs(cards) do
        if joker
            and not joker.debuff
            and joker.config
            and joker.config.center
            and joker.config.center.key == 'j_hnds_public_nuisance' then
            return true
        end
    end
    return false
end


function HNDS.public_nuisance_should_continue()
    if not (G and G.GAME and G.GAME.current_round and G.GAME.blind) then return false end
    if not G.GAME.blind.in_blind then return false end
    if not hnds_public_nuisance_is_active() then return false end

    local hands_left = tonumber(G.GAME.current_round.hands_left) or 0
    if hands_left < 1 then return false end
    if not hnds_public_nuisance_score_met() then return false end

    local hand_cards = (G.hand and G.hand.cards) or {}
    local deck_cards = (G.deck and G.deck.cards) or {}
    return #hand_cards > 0 or #deck_cards > 0
end

SMODS.Joker({
    key = "public_nuisance",
    atlas = "Jokers",
    pos = { x = 8, y = 1 },
    rarity = 1,
    cost = 3,
    unlocked = false,
    discovered = false,
    unlock_condition = { type = "hnds_joker_unlock", key = "public_nuisance" },
    locked_loc_vars = function(self)
        return HNDS.joker_locked_loc_vars("public_nuisance")
    end,
    check_for_unlock = function(self, args)
        return HNDS.joker_unlock_condition_met("public_nuisance", args)
    end,
    blueprint_compat = false,
    demicoloncompat = true,
    eternal_compat = true,
    perishable_compat = true,
    config = { extra = { dollars = 2, reward_this_hand = false } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.dollars } }
    end,
    calculate = function(self, card, context)


        if context.before and not context.blueprint then
            card.ability.extra.reward_this_hand = hnds_public_nuisance_score_met()
        end

        if context.after and not context.blueprint then
            local reward = card.ability.extra.reward_this_hand
            card.ability.extra.reward_this_hand = false
            if reward then
                return { dollars = card.ability.extra.dollars }
            end
        end


        if (context.setting_blind or context.end_of_round) and not context.blueprint then
            card.ability.extra.reward_this_hand = false
        end
    end,
    attributes = { "passive", "hands" }
})
