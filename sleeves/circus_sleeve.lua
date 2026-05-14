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
            self.config = {matching = true}
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
        
        -- Sleeve additional effect: Enable joker copying after first boss blind
        if self.config.matching then
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
        
        -- Sleeve additional effect: Create copy after defeating first boss blind
        if self.config.matching and context.end_of_round and context.main_eval and context.beat_boss and not G.GAME.circus_copy_created then
            G.GAME.circus_boss_defeated = true
            -- Create copy of first joker
            if G.jokers and G.jokers.cards and #G.jokers.cards > 0 then
                local first_joker = G.jokers.cards[1]
                G.E_MANAGER:add_event(Event({
                    func = function()
                        local copy = Card(G.play.T.x + G.play.T.w/2 - G.CARD_W*1.5, G.play.T.y + G.play.T.h/2 - G.CARD_H/2, G.CARD_W, G.CARD_H, G.P_CARDS.empty, first_joker.config.center, {playing_card = first_joker.config.center})
                        copy:set_edition(first_joker.edition or nil, true, true)
                        copy:add_to_deck()
                        G.jokers:emplace(copy)
                        G.GAME.circus_copy_created = true
                        return true
                    end
                }))
            end
        end
    end,
})

-- Hook into joker creation for Circus Sleeve
local orig_card_add_to_deck = Card.add_to_deck
function Card.add_to_deck(self, from_debuff)
    local result = orig_card_add_to_deck(self, from_debuff)
    if self.ability.set == 'Joker' and G.GAME.modifiers.circus_sleeve_active and not G.GAME.circus_copy_created then
        G.GAME.circus_copy_created = true
        -- Create a copy of the joker
        local copy_card = Card(G.play.T.x + G.play.T.w/2 - G.CARD_W*1.5, G.play.T.y + G.play.T.h/2 - G.CARD_H/2, G.CARD_W, G.CARD_H, G.P_CARDS.empty, G.P_CENTERS[self.config.center.key], {playing_card = self.config.center})
        copy_card:set_edition(self.edition or nil, true, true)
        copy_card:add_to_deck()
        G.jokers:emplace(copy_card)
    end
    return result
end