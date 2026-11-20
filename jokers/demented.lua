local function animate_demented_cards(cards, hand, game, joker)
    G.E_MANAGER:add_event(Event({
        trigger = 'after', delay = 0.4,
        func = function()
            if G.GAME == game and not (joker.removed or joker.REMOVED) then
                play_sound('tarot1')
                joker:juice_up(0.3, 0.5)
            end
            return true
        end,
    }))
    for i, state in ipairs(cards) do
        local pitch = 1.15 - (i - 0.999) / (#cards - 0.998) * 0.3
        G.E_MANAGER:add_event(Event({
            trigger = 'after', delay = 0.15,
            func = function()
                local card = state.card
                if card.hnds_demented_flip == state and G.GAME == game
                    and not (card.removed or card.REMOVED) and card.area == hand and card.facing == 'front'
                then
                    card:flip()
                    card:juice_up(0.3, 0.3)
                    play_sound('card1', pitch)
                    state.turned = true
                end
                return true
            end,
        }))
    end
    delay(0.2)
    G.E_MANAGER:add_event(Event({
        func = function()
            for _, state in ipairs(cards) do
                local card = state.card
                if card.hnds_demented_flip == state and G.GAME == game and not (card.removed or card.REMOVED) then
                    card:set_sprites(nil, card.config.card)
                end
            end
            return true
        end,
    }))
    for i, state in ipairs(cards) do
        local pitch = 0.85 + (i - 0.999) / (#cards - 0.998) * 0.3
        G.E_MANAGER:add_event(Event({
            trigger = 'after', delay = 0.15,
            func = function()
                local card = state.card
                if card.hnds_demented_flip == state then
                    if G.GAME == game and not (card.removed or card.REMOVED)
                        and state.turned and card.facing == 'back'
                    then
                        card:flip()
                        card:juice_up(0.3, 0.3)
                        play_sound('tarot2', pitch, 0.6)
                    end
                    card.hnds_demented_flip = nil
                end
                return true
            end,
        }))
    end
    delay(0.5)
end

SMODS.Joker {
    key = 'demented',
    rarity = 3,
    cost = 5,
    blueprint_compat = false,
    atlas = 'Jokers',
    pos = { x = 6, y = 3 },
    unlocked = false,
    discovered = false,
    unlock_condition = { type = 'hnds_joker_unlock', key = 'demented' },
    locked_loc_vars = function(self)
        return HNDS.joker_locked_loc_vars('demented')
    end,
    check_for_unlock = function(self, args)
        return HNDS.joker_unlock_condition_met('demented', args)
    end,
    calculate = function(self, card, context)
        local hand = G.hand
        if not ((context.before or context.debuffed_hand) and context.cardarea == G.jokers
            and G.STATE == G.STATES.HAND_PLAYED and hand and #hand.cards > 0
            and G.play and #G.play.cards > 0 and context.full_hand == G.play.cards
            and G.GAME.current_round.hands_played == 0 and not SMODS.no_resolve
            and not context.blueprint and not context.retrigger_joker)
        then
            return
        end

        local fronts = {}
        for _, suit in ipairs(HNDS.get_pollable_suit_keys('hnds_demented')) do
            for _, key in ipairs(SMODS.Rank.obj_buffer) do
                local rank = SMODS.Ranks[key]
                local front = HNDS.get_front_for_suit_rank(suit, rank.card_key)
                if front and SMODS.add_to_pool(rank, { suit = suit, source = 'hnds_demented' }) then
                    fronts[#fronts + 1] = front
                end
            end
        end
        if #fronts == 0 then return end

        local held = {}
        for i, playing_card in ipairs(hand.cards) do held[i] = playing_card end
        local changed, animated = false, {}
        for _, playing_card in ipairs(held) do
            if playing_card.base and playing_card.area == hand then
                local front = pseudorandom_element(fronts, pseudoseed('hnds_demented'))
                local state = playing_card.hnds_demented_flip
                local animate = G.E_MANAGER and (state ~= nil or playing_card.facing == 'front')
                if SMODS.change_base(playing_card, front.suit, front.value, animate) then
                    changed = true
                    if animate and not state then
                        state = {card = playing_card}
                        playing_card.hnds_demented_flip = state
                        animated[#animated + 1] = state
                    end
                end
            end
        end
        if #animated > 0 then animate_demented_cards(animated, hand, G.GAME, card) end
        if changed then
            return { message = localize('k_hnds_converted'), colour = G.C.FILTER }
        end
    end,
    attributes = { 'rank', 'suit', 'modify_card' },
}
