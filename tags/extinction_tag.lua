-- I hate whoever wrote this code
SMODS.Tag {
    key = "extinction_tag",
    atlas = "HDtags",
    pos = { x = 4, y = 0 },
    discovered = true,
    in_pool = function(self)
        return true
    end,
    apply = function(self, tag, context)
        if context.type == 'new_blind_choice' or context.type == 'hnds_after_hand' then
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

                -- Pre-calculate replacements and capture sticker/edition data before touching cards
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

                    -- Capture this joker's own edition (transfers to its own replacement)
                    local edition = card.edition and copy_table(card.edition) or nil

                    -- Capture cursed sticker (always transfers with same offer/price)
                    local curse_data = nil
                    if card.ability and (card.ability.hnds_curse_offer or card.ability.hnds_curse_price) then
                        curse_data = {
                            offer = card.ability.hnds_curse_offer,
                            price = card.ability.hnds_curse_price
                        }
                    end

                    -- Capture other stickers (50% chance each to transfer)
                    local other_stickers = {}
                    -- Base game stickers
                    for _, key in ipairs({'eternal', 'perishable', 'rental'}) do
                        if card.ability and card.ability[key] then
                            other_stickers[key] = true
                        end
                    end
                    -- Cursed sticker persistence (does not retrigger itself again)
                    if SMODS and SMODS.Sticker and SMODS.Sticker.obj_buffer then
                        for _, k in ipairs(SMODS.Sticker.obj_buffer) do
                            if k ~= 'hnds_cursed' and card.ability and card.ability[k] then
                                other_stickers[k] = true
                            end
                        end
                    end

                    replacements[i] = {
                        card = card,
                        center = new_center,
                        edition = edition,
                        curse_data = curse_data,
                        other_stickers = other_stickers,
                    }
                end

                -- Sequential dissolve: show text then dissolve with a short gap
                for i, rep in ipairs(replacements) do
                    local c = rep.card
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = i == 1 and 0 or 0.45,
                        func = function()
                            card_eval_status_text(c, 'extra', nil, nil, nil, {
                                message = localize('k_hnds_extint'),
                                colour = G.C.FILTER,
                                instant = true,
                            })
                            return true
                        end
                    }))
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.25,
                        func = function()
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
                        local edition = rep.edition
                        local curse_data = rep.curse_data
                        local other_stickers = rep.other_stickers
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

                                -- Transfer edition to this joker if selected
                                if edition then
                                    new_card:set_edition(edition, true, true)
                                end

                                -- Transfer cursed sticker with same offer/price
                                if curse_data then
                                  if curse_data then
                                    new_card.ability.hnds_curse_offer = curse_data.offer
                                    new_card.ability.hnds_curse_price = curse_data.price
                                    if new_card.add_sticker then
                                        pcall(new_card.add_sticker, new_card, 'hnds_cursed', true)
                                    end
                                    -- Re-trigger buying_card positive offers only (not prices)
                                    new_card.ability.hnds_curse_acquire_triggered = true
                                  end
                                end

                                -- Transfer other stickers at 50% chance each
                                for k, _ in pairs(other_stickers) do
                                    if pseudorandom('extinction_sticker' .. i .. k) > 0.5 then
                                        if k == 'eternal' then
                                            pcall(new_card.set_eternal, new_card, true)
                                        elseif k == 'perishable' then
                                            pcall(new_card.set_perishable, new_card, true)
                                        elseif k == 'rental' then
                                            if new_card.ability then new_card.ability.rental = true end
                                        elseif new_card.add_sticker then
                                            pcall(new_card.add_sticker, new_card, k, true)
                                        end
                                    end
                                end

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