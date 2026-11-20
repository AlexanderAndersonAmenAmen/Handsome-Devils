SMODS.Joker({
    key = "balloons",
    config = {
        extra = { balloons = 3, balloons_ammount = 3 },
    },
    rarity = 1,
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.balloons, card.ability.extra.balloons_ammount } }
    end,
    atlas = "Jokers",
    pos = { x = 9, y = 1 },
    cost = 5,
    unlocked = false,
    discovered = false,
    unlock_condition = { type = "hnds_joker_unlock", key = "balloons" },
    locked_loc_vars = function(self)
        return HNDS.joker_locked_loc_vars("balloons")
    end,
    check_for_unlock = function(self, args)
        return HNDS.joker_unlock_condition_met("balloons", args)
    end,
    blueprint_compat = false,
    demicoloncompat = true,
    eternal_compat = false,

    calculate = function(self, card, context)


        if context.end_of_round and context.main_eval
            and not context.game_over
            and not context.blueprint
            and not card.ability.hnds_balloons_popped
            and G and G.GAME and G.GAME.current_round
            and G.GAME.current_round.hands_played == 1
        then
            local seed_modifier = 'balloons_seed_' .. tostring(card.ability.extra.balloons)
            local chosen_tag_key = HNDS.poll_registered_tag_key(seed_modifier)

            if chosen_tag_key then
                local game = G.GAME
                G.E_MANAGER:add_event(Event({
                    func = function()
                        if G.GAME == game and G.P_TAGS[chosen_tag_key] and not HNDS.is_tag_banned(chosen_tag_key) then
                            local tag = HNDS.poll_tag(seed_modifier .. '_reward', { chosen_tag_key })
                            if tag then
                                add_tag(tag)
                                play_sound('generic1')
                            end
                        end
                        return true
                    end
                }))
            end

            card.ability.extra.balloons = card.ability.extra.balloons - 1

            if card.ability.extra.balloons <= 0 then
                card.ability.hnds_balloons_popped = true
                G.E_MANAGER:add_event(Event({
                    func = function()
                        if card and not card.removed and not card.REMOVED then
                            play_sound('tarot1')
                            SMODS.destroy_cards({ card }, { pinch_anim = true })
                        end
                        return true
                    end
                }))
                return {
                    message = "Popped!",
                    colour = G.C.FILTER
                }
            end

            return {
                message = "Pop!",
                colour = G.C.FILTER
            }
        end
    end
})
