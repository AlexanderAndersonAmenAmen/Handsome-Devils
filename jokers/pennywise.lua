SMODS.Joker {
    key = "pennywise",
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    demicoloncompat = true,
    rarity = 4,
    cost = 20,
    atlas = "Jokers",
    pos = { x = 5, y = 2 },
    soul_pos = { x = 0, y = 3 },
    info_queue = function(self, info_queue, card)
        if G.GAME.blind then
            info_queue[#info_queue + 1] = HNDS.get_blind_soul(G.GAME.blind)
        end
        info_queue[#info_queue + 1] = G.P_CENTERS.e_negative
    end,
    calculate = function(self, card, context)
        if (context.end_of_round and context.beat_boss and context.main_eval and G.GAME.current_round.hands_played == 1) or (context.forcetrigger and G.GAME.blind) then
            G.E_MANAGER:add_event(Event({
                func = function()
                    local c = SMODS.add_card({
                        edition = 'e_negative',
                        key = HNDS.get_blind_soul(G.GAME.blind, "hnds_pennywise"),
                    })
                    c.ability.hnds_soul = true
                    return true
                end
            }))
            return nil, true
        end
        if context.retrigger_joker_check and not context.retrigger_joker and context.other_card.ability.hnds_soul then
            return {
                repetitions = 1
            }
        end
    end,
    attributes = { "retrigger", "joker", "generation", }
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
    end,
}
