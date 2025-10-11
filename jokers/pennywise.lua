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
            info_queue[#info_queue+1] = HNDS.get_blind_soul(G.GAME.blind)
        end
        info_queue[#info_queue+1] = G.P_CENTERS.e_negative
    end,
    calculate = function (self, card, context)
        if (context.end_of_round and context.beat_boss and context.main_eval) or (context.forcetrigger and G.GAME.blind) then
            G.E_MANAGER:add_event(Event({
                func = function ()
                    SMODS.add_card({
                        edition = 'e_negative',
                        key = HNDS.get_blind_soul(G.GAME.blind),
                        stickers = { "hnds_soul" }
                    })
                    return true
                end
            }))
        end
        if context.retrigger_joker_check and not context.retrigger_joker and context.other_card.ability.hnds_soul then
            return {
                repetitions = 1
            }
        end
    end
}

SMODS.Sticker {
    key = "hnds_soul",
    badge_colour = G.C.RARITY[4],
    pos = { x = 10, y = 10 }, --make it not have a sprite
    rate = 0,
    apply = function (self, card, val)
        card.ability[self.key] = val
    end,
    sets = { Joker = true }
}