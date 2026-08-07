SMODS.Joker {
    key = "pennywise",
    unlocked = false,
    unlock_condition = { type = "", extra = "", hidden = true },
    locked_loc_vars = function(self, info_queue, card)
        -- Force Steamodded's locked-Joker path to initialise specific_vars and
        -- use the same hidden Legendary message as vanilla Soul Jokers.
        return { key = "joker_locked_legendary", set = "Other", vars = {} }
    end,
    discovered = false,
    blueprint_compat = true,
    demicoloncompat = true,
    rarity = 4,
    cost = 20,
    atlas = "Jokers",
    pos = { x = 5, y = 2 },
    soul_pos = { x = 0, y = 3 },
    info_queue = function(self, info_queue, card)
        if not self.unlocked then return end
        if G.GAME.blind then
            info_queue[#info_queue + 1] = HNDS.get_blind_soul(G.GAME.blind)
        end
        info_queue[#info_queue + 1] = G.P_CENTERS.e_negative
    end,
    remove_from_deck = function(self, card, from_debuff)
        if from_debuff or not (G and G.jokers and G.jokers.cards) then return end
        local souls = {}
        for _, joker in ipairs(G.jokers.cards) do
            if joker ~= card and joker.ability and joker.ability.hnds_soul then
                souls[#souls + 1] = joker
            end
        end
        for _, soul in ipairs(souls) do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.05,
                func = function()
                    if soul and soul.area then soul:start_dissolve() end
                    return true
                end
            }))
        end
    end,
    calculate = function(self, card, context)
        if (context.end_of_round and context.beat_boss and context.main_eval and G.GAME.current_round.hands_played == 1) or (context.forcetrigger and G.GAME.blind) then
            local args = HNDS.get_blind_soul(G.GAME.blind, "hnds_pennywise")
            if args then
                args.edition = "e_negative"
                args.key_append = "hnds_pennywise_card"
                args.set = "Joker"
                G.E_MANAGER:add_event(Event({
                    func = function()
                        local c = SMODS.add_card(args)
                        c.ability.hnds_soul = true
                        c.ability.hnds_soul_owner = card.sort_id
                        c.sell_cost = 0
                        return true
                    end
                }))
            end
            return nil, true
        end
    end,
    attributes = { "joker", "generation", }
}

SMODS.Sticker {
    key = "hnds_soul",
    badge_colour = G.C.RARITY[4],
    atlas = "Stickers",
    pos = { x = 1, y = 1 },
    rate = 0,
    sets = { Joker = true },
    should_apply = function(self, card, center, area, bypass_roll)
        if card.ability.eternal or card.ability.hnds_cursed then return false end
        return SMODS.Sticker.should_apply(self, card, center, area, bypass_roll)
    end,
    apply = function(self, card, val)
        card.ability[self.key] = val
        if val then card.sell_cost = 0 end
    end,
}
