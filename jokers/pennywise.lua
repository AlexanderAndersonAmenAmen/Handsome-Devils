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
    loc_vars = function(self, info_queue, card)
        -- In Steamodded BETA-1620a, Joker auxiliary tooltips must be queued
        -- from loc_vars. A standalone `info_queue` callback is ignored.
        -- Always show the Soul sticker explanation on an unlocked Pennywise.
        info_queue[#info_queue + 1] = { set = "Other", key = "hnds_soul", vars = {} }

        if G and G.GAME and G.GAME.blind and HNDS and HNDS.get_blind_souls then
            for _, soul in ipairs(HNDS.get_blind_souls(G.GAME.blind, "hnds_pennywise_preview") or {}) do
                -- Soul generation recipes are also used as tooltip descriptors,
                -- but some fallback recipes only contain `key`. BETA-1620a's
                -- generate_card_ui requires a set for these descriptor tables.
                -- Normalize keyed Joker recipes here and never queue an invalid
                -- recipe/filter table into info_queue.
                if type(soul) == "table" and soul.key then
                    local preview_center = G and G.P_CENTERS and G.P_CENTERS[soul.key]
                    if preview_center then
                        -- Queue the registered Center itself. This guarantees
                        -- generate_card_ui receives a complete set/key/config
                        -- object rather than a partial Soul generation recipe.
                        info_queue[#info_queue + 1] = preview_center
                    elseif G and G.P_CENTERS and G.P_CENTERS.j_joker then
                        info_queue[#info_queue + 1] = G.P_CENTERS.j_joker
                    end
                end
            end
        end
        if G and G.P_CENTERS and G.P_CENTERS.e_negative then
            info_queue[#info_queue + 1] = G.P_CENTERS.e_negative
        end
        return { vars = {} }
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
            local souls = HNDS.get_blind_souls(G.GAME.blind, "hnds_pennywise") or {}
            for i, soul_args in ipairs(souls) do
                local args = {}
                for k, v in pairs(soul_args) do args[k] = v end
                args.edition = "e_negative"
                args.key_append = "hnds_pennywise_card_" .. tostring(i)
                args.set = "Joker"
                G.E_MANAGER:add_event(Event({
                    func = function()
                        local c = SMODS.add_card(args)
                        if c then
                            c.ability = c.ability or {}
                            -- Apply the actual registered Sticker instead of
                            -- only toggling its ability flag. This gives the
                            -- generated Joker the Soul badge/tooltip through
                            -- Steamodded's normal sticker UI path.
                            if c.add_sticker then
                                c:add_sticker('hnds_soul', true)
                            else
                                c.ability.hnds_soul = true
                                c.sell_cost = 0
                            end
                            c.ability.hnds_soul_owner = card.sort_id
                        end
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
        local ability = card and card.ability or {}
        if ability.eternal or ability.hnds_cursed then return false end
        return SMODS.Sticker.should_apply(self, card, center, area, bypass_roll)
    end,
    loc_vars = function(self, info_queue, card)
        return { vars = {} }
    end,
    apply = function(self, card, val)
        card.ability[self.key] = val
        if val then card.sell_cost = 0 end
    end,
}
