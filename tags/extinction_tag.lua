SMODS.Tag {
    key = "extinction_tag",
    atlas = "HDtags",
    pos = { x = 4, y = 0 },
    discovered = true,
    apply = function(self, tag, context)
        if context.type == 'new_blind_choice' then
            local lock = tag.ID
            G.CONTROLLER.locks[lock] = true
            tag:yep('+', G.C.RED, function()
                -- Build pool filtered with the same conditions as get_current_pool
                local function build_pool(rarity)
                    local pool = {}
                    local src = G.P_JOKER_RARITY_POOLS and G.P_JOKER_RARITY_POOLS[rarity] or G.P_CENTER_POOLS['Joker']
                    for _, center in ipairs(src) do
                        local add = center.unlocked ~= false or center.rarity == 4
                        if add and center.no_pool_flag and G.GAME.pool_flags[center.no_pool_flag] then add = false end
                        if add and center.yes_pool_flag and not G.GAME.pool_flags[center.yes_pool_flag] then add = false end
                        if add and center.enhancement_gate then
                            add = false
                            for _, pc in pairs(G.playing_cards) do
                                if pc.config.center.key == center.enhancement_gate then add = true; break end
                            end
                        end
                        if add and G.GAME.banned_keys and G.GAME.banned_keys[center.key] then add = false end
                        if add and center.in_pool then
                            local ok, res = pcall(center.in_pool, center, {})
                            if not ok or not res then add = false end
                        end
                        if add then pool[#pool + 1] = center end
                    end
                    return pool
                end

                -- Pre-calculate replacements before any card is touched
                local replacements = {}
                for i, card in ipairs(G.jokers.cards) do
                    local rarity = card.config.center.rarity
                    local new_center = nil
                    local pool = build_pool(rarity)
                    local filtered = {}
                    for _, c in ipairs(pool) do
                        if c.key ~= card.config.center.key then filtered[#filtered + 1] = c end
                    end
                    if #filtered > 0 then
                        new_center = pseudorandom_element(filtered, pseudoseed('extinction' .. i))
                    end
                    replacements[i] = { card = card, center = new_center }
                end

                -- Sequential dissolve: each card is its own chained event pair
                -- instant=true makes attention_text fire immediately (no E_MANAGER enqueue)
                for i, rep in ipairs(replacements) do
                    local c = rep.card
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = i == 1 and 0 or 0.3,
                        func = function()
                            card_eval_status_text(c, 'extra', nil, nil, nil, {
                                message = localize('k_hnds_extint'),
                                colour = G.C.FILTER,
                                instant = true,
                            })
                            c:start_dissolve()
                            return true
                        end
                    }))
                end

                -- Wait for last dissolve animation (~0.5s), then spawn sequentially
                G.E_MANAGER:add_event(Event({ trigger = 'after', delay = 0.5, func = function() return true end }))

                for i, rep in ipairs(replacements) do
                    if rep.center then
                        local center = rep.center
                        G.E_MANAGER:add_event(Event({
                            trigger = 'after',
                            delay = i == 1 and 0 or 0.25,
                            func = function()
                                local new_card = Card(
                                    G.jokers.T.x + G.jokers.T.w / 2,
                                    G.jokers.T.y,
                                    G.CARD_W, G.CARD_H,
                                    nil, center,
                                    {bypass_discovery_center = true, bypass_discovery_ui = true}
                                )
                                new_card:add_to_deck()
                                G.jokers:emplace(new_card)
                                new_card:start_materialize()
                                new_card:juice_up(0.5, 0.3)
                                play_sound('card1', 1 + (i - 1) * 0.05, 0.6)
                                return true
                            end
                        }))
                    end
                end

                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.3,
                    func = function()
                        G.CONTROLLER.locks[lock] = nil
                        return true
                    end
                }))
                return true
            end)
            tag.triggered = true
            return true
        end
    end
}
