local HNDS_WAR_HANDS = {
    'High Card',
    'Pair',
    'Two Pair',
    'Three of a Kind',
    'Straight',
    'Flush',
    'Full House',
    'Four of a Kind',
    'Straight Flush',
}

local function hnds_war_choose_hand(card, force_different)
    local extra = card and card.ability and card.ability.extra
    if not extra then return 'High Card' end

    local current = extra.poker_hand
    local choices = {}
    for _, hand in ipairs(HNDS_WAR_HANDS) do
        if not force_different or hand ~= current then choices[#choices + 1] = hand end
    end
    if #choices == 0 then choices = HNDS_WAR_HANDS end

    extra.roll_index = (tonumber(extra.roll_index) or 0) + 1
    local seed = 'hnds_war_' .. tostring(card.sort_id or card.ID or 0)
        .. '_' .. tostring(extra.roll_index)
        .. '_' .. tostring(G and G.GAME and G.GAME.round_resets and G.GAME.round_resets.ante or 0)
    extra.poker_hand = pseudorandom_element(choices, pseudoseed(seed)) or choices[1] or 'High Card'
    return extra.poker_hand
end

local function hnds_war_hand(card)
    local extra = card and card.ability and card.ability.extra
    if not extra then return 'High Card' end
    return extra.poker_hand or 'High Card'
end

SMODS.Joker {
    key = 'war',
    atlas = 'Jokers',
    pos = { x = 3, y = 6 },
    rarity = 2,
    cost = 6,
    unlocked = true,
    discovered = true,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,

    config = {
        extra = {
            poker_hand = nil,
            roll_index = 0,
            destroy_this_hand = false,
        },
    },

    loc_vars = function(self, info_queue, card)
        local hand = card and hnds_war_hand(card) or 'High Card'
        return { vars = { localize(hand, 'poker_hands') } }
    end,

    set_ability = function(self, card, initial, delay_sprites)
        -- Give every physical War card its target as soon as the card is
        -- initialized. This means shop/pack copies do not sit on the old
        -- High Card fallback until their first calculation.
        local extra = card and card.ability and card.ability.extra
        if extra and not extra.poker_hand and G and G.GAME then
            hnds_war_choose_hand(card, false)
        end
    end,

    add_to_deck = function(self, card, from_debuff)
        local extra = card and card.ability and card.ability.extra
        if extra and not extra.poker_hand and not from_debuff then
            hnds_war_choose_hand(card, false)
        end
    end,

    calculate = function(self, card, context)
        local extra = card.ability.extra

        -- Choose an initial target lazily inside an active run. This keeps
        -- collection/title-screen previews from consuming gameplay RNG state.
        if not extra.poker_hand and G and G.GAME then hnds_war_choose_hand(card, false) end

        if context.before and not context.blueprint
            and G.GAME.current_round and G.GAME.current_round.hands_played == 0
        then
            local hand = hnds_war_hand(card)
            -- War requires the hand's primary evaluated poker hand to be the
            -- target exactly. Do not use context.poker_hands here: composite
            -- hands (e.g. Straight Flush) also populate weaker contained-hand
            -- buckets and would incorrectly satisfy a target such as Flush.
            extra.destroy_this_hand = context.scoring_name == hand
            if extra.destroy_this_hand then
                return { message = localize('k_hnds_war'), colour = G.C.RED }
            end
        end

        -- Balatro evaluates this context after every scored card has finished
        -- scoring, so the hand still contributes its Chips/Mult before War
        -- destroys those scored cards through the normal destruction pipeline.
        if context.destroying_card and extra.destroy_this_hand and not context.blueprint then
            return { remove = true }
        end

        if context.after and extra.destroy_this_hand and not context.blueprint then
            extra.destroy_this_hand = false
            hnds_war_choose_hand(card, true)
            return { message = localize('k_hnds_war_changed'), colour = G.C.FILTER }
        end
    end,

    joker_display_def = function(JokerDisplay)
        return {
            reminder_text = {
                { text = '(' },
                { ref_table = 'card.joker_display_values', ref_value = 'hand' },
                { text = ')' },
            },
            calc_function = function(card)
                card.joker_display_values.hand = localize(hnds_war_hand(card), 'poker_hands')
            end,
        }
    end,

    attributes = { 'destroy_card', 'hand_type' },
}
