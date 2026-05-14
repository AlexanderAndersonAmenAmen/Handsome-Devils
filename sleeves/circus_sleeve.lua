-- Circus Sleeve: Same as Circus Deck + Creates a copy of the first Joker after defeating first boss blind when paired
CardSleeves.Sleeve({
    key = "circus_sleeve",
    atlas = "hnds_sleeves",
    pos = {x = 1, y = 0},
    unlocked = false,
    unlock_condition = {deck = "b_hnds_circus", stake = "stake_green"},
    loc_vars = function(self)
        local key
        if self.get_current_deck_key() ~= "b_hnds_circus" then
            key = self.key
        else
            key = self.key .. "_alt"
        end
        local joker_name = "None"
        if G.GAME and G.GAME.hnds_circus_joker_key and type(G.GAME.hnds_circus_joker_key) == "string" then
            joker_name = localize({type = 'name_text', key = G.GAME.hnds_circus_joker_key, set = 'Joker'}) or "None"
        end
        return {key = key, vars = {joker_name, colours = {G.C.ORANGE}}}
    end,
    apply = function(self)
        -- Base effect: Set up circus deck functionality
        G.GAME.hnds_circus_joker_key = nil
        G.hnds_circus_joker = nil

        -- Sleeve additional effect: Enable joker copying after first boss blind when paired with Circus Deck
        if self.get_current_deck_key() == "b_hnds_circus" then
            G.GAME.modifiers.circus_sleeve_active = true
            G.GAME.circus_boss_defeated = false
            G.GAME.circus_copy_created = false
        end
    end,
    calculate = function(self, sleeve, context)
        -- Base effect: Random joker ability (same as deck)
        if context.end_of_round and context.main_eval and not context.blueprint then
            if G.GAME.hnds_circus_joker then
                G.hnds_circus_joker = nil
            end
            local jokers = {}
            for _, v in ipairs(G.jokers.cards) do
                if v.config.center.key ~= 'j_hnds_joker_copy' then
                    table.insert(jokers, v.config.center.key)
                end
            end
            if #jokers > 0 then
                local chosen_joker = jokers[pseudorandom(pseudoseed('circus')) % #jokers + 1]
                G.GAME.hnds_circus_joker_key = chosen_joker
                G.hnds_circus_joker = G.jokers
            end
        end
        
        -- Sleeve Stacked effect
        if self.get_current_deck_key() == "b_hnds_circus" and context.end_of_round and context.main_eval and context.beat_boss and not G.GAME.circus_copy_created then
            if G.hnds_circus_joker and G.hnds_circus_joker.cards and #G.hnds_circus_joker.cards > 0 then
                if #G.jokers.cards + (G.GAME.joker_buffer or 0) < G.jokers.config.card_limit then
                    G.GAME.circus_copy_created = true
                    local center = G.hnds_circus_joker.cards[1].config.center
                    G.GAME.joker_buffer = (G.GAME.joker_buffer or 0) + 1
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            local copy = Card(G.play.T.x, G.play.T.y, G.CARD_W, G.CARD_H, nil, center, {bypass_discovery_center = true, bypass_discovery_ui = true})
                            copy:start_materialize(nil, true)
                            copy:add_to_deck()
                            G.jokers:emplace(copy)
                            G.GAME.joker_buffer = 0
                            return true
                        end
                    }))
                end
            end
        end
    end,
})