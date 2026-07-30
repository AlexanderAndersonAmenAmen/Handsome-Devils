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
        if context.end_of_round and not context.individual and not context.repetition and not context.blueprint then
            
            if SMODS.last_hand_oneshot then
                
                local pool = {}
                for tag_key, _ in pairs(G.P_TAGS) do
                    table.insert(pool, tag_key)
                end
                
                local seed_modifier = 'balloons_seed_' .. tostring(card.ability.extra.balloons)
                local chosen_tag_key = pseudorandom_element(pool, seed_modifier)
                
                G.E_MANAGER:add_event(Event({
                    func = function()
                        add_tag(Tag(chosen_tag_key))
                        play_sound('generic1')
                        return true
                    end
                }))
                
                card.ability.extra.balloons = card.ability.extra.balloons - 1
                
                if card.ability.extra.balloons <= 0 then
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            play_sound('tarot1')
                            card:start_dissolve() 
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
    end
})