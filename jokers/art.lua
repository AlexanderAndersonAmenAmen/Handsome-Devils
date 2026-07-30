SMODS.Joker {
    key = "art",
    unlocked = false,
    unlock_condition = { type = "", extra = "", hidden = true },
    locked_loc_vars = function(self, info_queue, card)
        -- Force Steamodded's locked-Joker path to initialise specific_vars and
        -- use the same hidden Legendary message as vanilla Soul Jokers.
        return { key = "joker_locked_legendary", set = "Other", vars = {} }
    end,
    discovered = false,
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
                        play_sound('holo1', 1.2 + math.random() * 0.1, 0.4)
                        return true
                    end
                }))
            end
            G.GAME.art_queue = (G.GAME.art_queue or 0) + card.ability.extra.tags
            return nil, true
        end
    end,
    attributes = { "generation", "on_sell", "tag" }
}