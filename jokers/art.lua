SMODS.Joker {
    key = "art",
    unlocked = true,
    discovered = true,
    rarity = 4,
    cost = 20,
    atlas = "Jokers",
    pos = { x = 6, y = 2 },
    soul_pos = { x = 1, y = 3 },
    config = { extra = { tags = 1 } },
    loc_vars = function (self, info_queue, card)
        return { vars = { card.ability.extra.tags } }
    end,
    calculate = function (self, card, context)
        if context.selling_self then
            for _ = 1, card.ability.extra.tags do
                G.E_MANAGER:add_event(Event({
                    func = function ()
                        add_tag(HNDS.poll_tag("_hnds_art"))
                        play_sound("generic1", 0.9 + math.random() * 0.1, 0.8)
                        play_sound('holo1', 1.2 + math.random() * 0.1, 0.4)
                        return true
                    end
                }))
            end
            G.GAME.art_queue = G.GAME.art_queue + 1
            return nil, true
        end
    end
}