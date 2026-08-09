G.CURSE_OFFERS = {
    -- Offers are benefits
    -- They technically work like a Jokers
    -- 1. Create a copy of a random tarot card
    [1] = {
        id = 'offer_copy_random_tarot',
        func = function(card, context)
            if context.end_of_round and context.main_eval and not context.repetition and not context.blueprint then
                if G and G.E_MANAGER and Event and SMODS and SMODS.add_card then
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.1,
                        func = function()
                            if G.consumeables and G.consumeables.cards and G.consumeables.config and #G.consumeables.cards >= G.consumeables.config.card_limit then
                                card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_no_room_ex'), colour = G.C.RED})
                                return true
                            end
                            G.E_MANAGER:add_event(Event({
                                trigger = 'after',
                                delay = 0.3,
                                func = function()
                                    SMODS.add_card({set = 'Tarot', area = G.consumeables, key_append = 'hnds_curse_tarot'})
                                    return true
                                end
                            }))
                            card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_copied_ex'), colour = G.C.CHIPS})
                            return true
                        end
                    }))
                end
            end
        end
    },
    -- 2. Create 2 random Planet cards
    [2] = {
        id = 'offer_copy_random_planet',
        func = function(card, context)
            if context.end_of_round and context.main_eval and not context.repetition and not context.blueprint then
                if G and G.E_MANAGER and G.GAME and Event and SMODS and SMODS.add_card then
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.1,
                        func = function()
                            if not (G.consumeables and G.consumeables.cards and G.consumeables.config) then
                                return true
                            end

                            local buffer = tonumber(G.GAME.consumeable_buffer) or 0
                            local room = (tonumber(G.consumeables.config.card_limit) or 0)
                                - #G.consumeables.cards - buffer
                            local to_create = math.min(2, math.max(0, room))
                            if to_create == 0 then
                                card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_no_room_ex'), colour = G.C.RED})
                                return true
                            end

                            G.GAME.consumeable_buffer = buffer + to_create
                            G.E_MANAGER:add_event(Event({
                                trigger = 'after',
                                delay = 0.3,
                                func = function()
                                    for i = 1, to_create do
                                        SMODS.add_card({
                                            set = 'Planet',
                                            area = G.consumeables,
                                            key_append = 'hnds_curse_planet_' .. i,
                                        })
                                    end
                                    G.GAME.consumeable_buffer = math.max(0,
                                        (tonumber(G.GAME.consumeable_buffer) or to_create) - to_create)
                                    return true
                                end
                            }))
                            return true
                        end
                    }))
                end
            end
        end
    },
    -- 3. Give a random enhancement to 8 cards in your deck
    [3] = {
        id = 'offer_random_enhancement',
        func = function(card, context)
            if context.buying_card then
                context.hnds_curse_taken = context.hnds_curse_taken or {}
                local taken = context.hnds_curse_taken
                local pool = {}
                for _, v in ipairs(G.playing_cards) do
                    if not taken[v] then
                        pool[#pool + 1] = v
                    end
                end

                local to_enhance = math.min(8, #pool)
                if not G.P_CENTERS then return end
                local enhancement_keys = {}
                for k, v in pairs(G.P_CENTERS) do
                    if v.set == 'Enhanced' then
                        table.insert(enhancement_keys, k)
                    end
                end
                if #enhancement_keys == 0 then return end
                for i = 1, to_enhance do
                    local idx = pseudorandom('curse_enhance' .. tostring(card.ID or '') .. '_' .. i, 1, #pool)
                    local target = pool[idx]
                    table.remove(pool, idx)
                    if target then
                        taken[target] = true
                        local enhancement = pseudorandom_element(enhancement_keys, pseudoseed('curse_enhance_type' .. tostring(card.ID or '') .. '_' .. i))
                        local center = G.P_CENTERS[enhancement]
                        if center then
                            set_enhancement(target, enhancement)
                        end
                    end
                end
            end
        end
    },
    -- 4. Gives negative to itself
    [4] = {
        id = 'offer_self_negative',
        func = function(card, context)
            if context.buying_card then
                card:set_edition({negative = true})
                card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_upgrade_ex'), colour = G.C.DARK_EDITION})
            end
        end
    },
    -- 5. Retrigger this Joker (Is kinda buggy and can do some weird stuff still)
    [5] = {
        id = 'offer_retrigger',
        func = function(card, context)
            if not (card and card.config and card.config.center and card.config.center.calculate) then return end
            if context.retrigger_joker_check and not context.retrigger_joker and context.other_card == card then
                return { message = localize('k_again_ex'), repetitions = 1, card = card }
            end
        end
    },
    -- 6. Create one Spectral card each Ante.
    -- The legacy ID is retained so existing saves keep the same rolled offer.
    [6] = {
        id = 'offer_spectral_gen',
        func = function(card, context)
            if not (context and context.setting_blind) or context.repetition or context.blueprint then return end
            if not (G and G.GAME and G.GAME.round_resets and G.consumeables and G.consumeables.cards
                and G.consumeables.config and SMODS and SMODS.add_card) then return end

            card.ability = card.ability or {}
            local ante = tonumber(G.GAME.round_resets.ante) or 0
            if card.ability.hnds_curse_spectral_ante == ante then return end
            card.ability.hnds_curse_spectral_ante = ante

            local buffer = tonumber(G.GAME.consumeable_buffer) or 0
            local limit = tonumber(G.consumeables.config.card_limit) or 0
            if #G.consumeables.cards + buffer >= limit then
                card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_no_room_ex'), colour = G.C.RED})
                return
            end

            G.GAME.consumeable_buffer = buffer + 1
            G.E_MANAGER:add_event(Event({
                trigger = 'after', delay = 0.1,
                func = function()
                    SMODS.add_card({
                        set = 'Spectral',
                        area = G.consumeables,
                        key_append = 'hnds_curse_ante_spectral_' .. tostring(ante),
                    })
                    if G.GAME then
                        G.GAME.consumeable_buffer = math.max(0, (tonumber(G.GAME.consumeable_buffer) or 1) - 1)
                    end
                    return true
                end
            }))
        end
    },
    -- 7. Gain 2 free reroll for each shop
    [7] = {
        id = 'offer_free_rerolls',
        func = function(card, context)
            if not (G and G.GAME and G.GAME.current_round) then return end
            if not context then return end

            if context.buying_card or (context.starting_shop and context.main_eval and not context.repetition and not context.blueprint) then
                local cr = G.GAME.current_round
                cr.free_rerolls = tonumber(cr.free_rerolls) or 0
                cr.free_rerolls = math.max(0, cr.free_rerolls + 2)
                if calculate_reroll_cost then calculate_reroll_cost(true) end
            end
        end
    },
    [8] = {
        id = 'offer_joker_copy',
        func = function(card, context)
            if context.buying_card then
                if not (G and G.E_MANAGER and Event and G.jokers and G.GAME and G.jokers.config) then return end

                if #G.jokers.cards + (G.GAME.joker_buffer or 0) >= G.jokers.config.card_limit then
                    card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_no_room_ex'), colour = G.C.RED})
                    return
                end

                G.GAME.joker_buffer = (G.GAME.joker_buffer or 0) + 1
                local c = card
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.2,
                    func = function()
                        local copy = copy_card(c)
                        if copy then
                            copy.ability = copy.ability or {}
                            copy.ability.hnds_curse_preview = nil
                            copy.ability.hnds_curse_acquire_triggered = true -- Prevent re-triggering
                            copy.hnds_curse_acquire_triggered = true
                            copy.cursed_shake = nil
                            -- Completely remove cursed sticker from all data structures
                            if copy.stickers and type(copy.stickers) == 'table' then
                                copy.stickers.hnds_cursed = nil
                            end

                            if copy.ability.stickers and type(copy.ability.stickers) == 'table' then
                                copy.ability.stickers.hnds_cursed = nil
                            end
                            -- Set flag for Devil's Round challenge only
                            copy.ability.hnds_eternal_copy_created = true
                            -- Remove the cursed sticker from the card's sticker list
                            if copy.remove_sticker then
                                copy:remove_sticker('hnds_cursed')
                            end
                            -- Force refresh the card's sticker display
                            if copy.sticker_display then
                                copy.sticker_display:remove()
                                copy.sticker_display = nil
                            end

                            copy:add_to_deck()
                            G.jokers:emplace(copy)
                            card_eval_status_text(copy, 'extra', nil, nil, nil, {message = localize('k_copied_ex'), colour = G.C.CHIPS})
                        end

                        G.GAME.joker_buffer = math.max(0, (G.GAME.joker_buffer or 1) - 1)
                        return true
                    end
                }))
            end
        end
    }
}

G.CURSE_PRICES = {
    -- Prices are drawbacks/penalties. all trigger immediately on buy (context.buying_card)
    -- They technically work like a Jokers

    -- 1. Destroy all Jokers
    [1] = {
        id = 'price_destroy_jokers',
        func = function(card, context)
            if context.buying_card then
                for i=#G.jokers.cards, 1, -1 do
                    if G.jokers.cards[i] ~= card and not (G.jokers.cards[i].ability and G.jokers.cards[i].ability.eternal) then
                        G.jokers.cards[i]:start_dissolve()
                    end
                end
            end
        end
    },
    -- 2. Destroy 8 random cards from your deck
    [2] = {
        id = 'price_destroy_cards',
        func = function(card, context)
            if context.buying_card then
                context.hnds_curse_taken = context.hnds_curse_taken or {}
                local taken = context.hnds_curse_taken
                local pool = {}
                if G.playing_cards then
                    for _, v in ipairs(G.playing_cards) do
                        if not taken[v] then
                            pool[#pool + 1] = v
                        end
                    end
                end

                local to_destroy = math.min(8, #pool)
                for i = 1, to_destroy do
                    local idx = pseudorandom('curse_destroy'..tostring(card.ID or '')..'_'..i, 1, #pool)
                    local target = pool[idx]
                    table.remove(pool, idx)
                    if target then
                        taken[target] = true
                        target:start_dissolve()
                    end
                end
            end
        end
    },
    -- 3. Set money to 0
    [3] = {
        id = 'price_bankrupt',
        func = function(card, context)
            if context.buying_card then
                local attempts = 0
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.1,
                    func = function()
                        attempts = attempts + 1
                        if attempts < 30 and card and card.area and (card.area == G.shop_jokers or card.area == G.shop_booster) then
                            return false
                        end
                        G.E_MANAGER:add_event(Event({
                            trigger = 'after',
                            delay = 0.1,
                            func = function()
                                local current_dollars = tonumber(G.GAME and G.GAME.dollars) or 0
                                if current_dollars > 0 then
                                    ease_dollars(-current_dollars, true)
                                end
                                return true
                            end
                        }))
                        return true
                    end
                }))
            end
        end
    },
    -- 4. Permanently increase reroll cost by $2
    [4] = {
        id = 'price_inflation', -- legacy ID retained for save compatibility
        func = function(card, context)
            if not (context and context.buying_card and G and G.GAME) then return end
            G.GAME.round_resets = G.GAME.round_resets or {}
            G.GAME.round_resets.reroll_cost = math.max(0,
                (tonumber(G.GAME.round_resets.reroll_cost) or 0) + 2)
            if calculate_reroll_cost then
                calculate_reroll_cost(true)
            elseif G.GAME.current_round then
                G.GAME.current_round.reroll_cost = math.max(0,
                    (tonumber(G.GAME.current_round.reroll_cost) or 0) + 2)
            end
        end
    },
    -- 5. -1 Hand
    [5] = {
        id = 'price_lose_hand',
        func = function(card, context)
            if not (context and context.buying_card and G and G.GAME and G.GAME.starting_params and G.GAME.round_resets) then return end

            G.GAME.starting_params.hands = math.max(0, (G.GAME.starting_params.hands or 0) - 1)
            G.GAME.round_resets.hands = math.max(0, (G.GAME.round_resets.hands or 0) - 1)
            ease_hands_played(-1)
        end
    },
    -- 6. -1 Discard
    [6] = {
        id = 'price_lose_discard',
        func = function(card, context)
            if not (context and context.buying_card and G and G.GAME and G.GAME.starting_params and G.GAME.round_resets) then return end

            G.GAME.starting_params.discards = math.max(0, (G.GAME.starting_params.discards or 0) - 1)
            G.GAME.round_resets.discards = math.max(0, (G.GAME.round_resets.discards or 0) - 1)
            ease_discard(-1)
        end
    },
    -- 7. -1 Hand size
    [7] = {
        id = 'price_lose_hand_size',
        func = function(card, context)
            if not (context and context.buying_card and G and G.GAME and G.GAME.starting_params) then return end

            if (G.GAME.starting_params.hand_size or 0) <= 1 then return end
            G.GAME.starting_params.hand_size = math.max(1, (G.GAME.starting_params.hand_size or 1) - 1)
            if G.hand and G.hand.change_size then
                G.hand:change_size(-1)
            end
        end
    },
    -- 8. Ante Scaling
    [8] = {
        id = 'price_ante_scaling',
        func = function(card, context)
            if not (context and context.buying_card and G and G.GAME and G.GAME.modifiers) then return end
            G.GAME.modifiers.hnds_base_blind_increase = (G.GAME.modifiers.hnds_base_blind_increase or 0) + 1
        end
    }
}

-- Shared helper: strip every sticker except hnds_cursed from all of a
-- card's data structures. Used by apply_curse and the sticker safety-net.
local function hnds_strip_foreign_stickers(card)
    if not card then return false end
    local to_remove = {}
    for _, k in ipairs({ 'perishable', 'eternal', 'rental' }) do
        if (card.ability and card.ability[k])
            or (card.stickers and card.stickers[k])
            or (card.ability and card.ability.stickers and card.ability.stickers[k])
        then
            to_remove[k] = true
        end
    end
    if SMODS and SMODS.Sticker and SMODS.Sticker.obj_buffer then
        for _, k in ipairs(SMODS.Sticker.obj_buffer) do
            if k ~= 'hnds_cursed' and card.ability and card.ability[k] then
                to_remove[k] = true
            end
        end
    end
    if card.stickers and type(card.stickers) == 'table' then
        for k, _ in pairs(card.stickers) do
            if k ~= 'hnds_cursed' then to_remove[k] = true end
        end
    end
    if card.ability and card.ability.stickers and type(card.ability.stickers) == 'table' then
        for k, _ in pairs(card.ability.stickers) do
            if k ~= 'hnds_cursed' then to_remove[k] = true end
        end
    end
    local any_removed = false
    for k, _ in pairs(to_remove) do
        any_removed = true
        if card.remove_sticker then pcall(card.remove_sticker, card, k) end
        if card.stickers then card.stickers[k] = nil end
        if card.ability then card.ability[k] = nil end
        if card.ability and card.ability.stickers then card.ability.stickers[k] = nil end
    end
    if card.ability then
        card.ability.perishable = nil
        card.ability.eternal = nil
        card.ability.rental = nil
    end
    if any_removed and card.set_sticker_display then
        pcall(card.set_sticker_display, card)
    end
    return any_removed
end

-- Shared helper: ensure card.ability.extra exists, seeded from the center config.
local function hnds_ensure_extra(card)
    if not card.ability then card.ability = {} end
    if card.ability.extra ~= nil then return end
    local center_extra = card.config and card.config.center and card.config.center.config and card.config.center.config.extra
    if type(center_extra) == 'table' then
        card.ability.extra = copy_table(center_extra)
    elseif center_extra ~= nil then
        card.ability.extra = center_extra
    else
        card.ability.extra = {}
    end
end

SMODS.Sound{
    key = "curse_used",
    path = "CursedLaugh.ogg",
}

SMODS.Sticker {
    key = 'hnds_cursed',
    atlas = 'Stickers',
    pos = { x = 0, y = 0 },
    badge_colour = G.C.RED,
    rate = 0.12,
    needs_enable_flag = false,
    sets = { Joker = true },
    -- Natural Cursed rolls are intentionally limited to purchasable Joker
    -- sources: the shop, Buffoon packs, Cursed packs, and Magic packs.
    should_apply = function(self, card, center, area, bypass_roll)
        if not (G and G.GAME and G.GAME.modifiers and G.GAME.modifiers.enable_curses) then return false end
        if not (center and center.set == 'Joker') then return false end
        if center.key == 'j_hnds_art' then return false end

        local source_name
        if area == G.shop_jokers then
            source_name = 'shop'
        elseif area == G.pack_cards then
            local source = HNDS and HNDS._creating_card_source or {}
            local append = tostring(source.key_append or ''):lower()
            if append == 'cur' or append:find('cursed', 1, true) then
                source_name = 'cursed_pack'
            elseif append == 'hnds_magic_card' or append:find('magic', 1, true) then
                source_name = 'magic_pack'
            elseif append == 'buf' or append:find('buffoon', 1, true)
                or append:match('^buf')
            then
                source_name = 'buffoon_pack'
            end
        end
        if not source_name then return false end
        if bypass_roll ~= nil then return bypass_roll end

        return pseudorandom('hnds_blood_curse_' .. source_name .. '_'
            .. tostring(G.GAME.round_resets.ante)) > (1 - self.rate)
    end,
    apply = function(self, card, val)
        card.ability = card.ability or {}
        card.ability[self.key] = val or nil
        if val and HNDS and HNDS.assign_curse_data
            and not (card.ability.hnds_curse_offer and card.ability.hnds_curse_price)
        then
            HNDS.assign_curse_data(card)
        end
    end,
    -- Dynamic tooltip using loc_vars with global state
    -- Store current card data in globals for loc_vars to access
    loc_vars = function(self, info_queue, card)
        -- Store reference for potential use
        _G.HNDS_CURRENT_CURSE_CARD = card
        return { vars = {} }
    end,

    calculate = function(self, card, context)
        if card and card.ability and (card.ability.hnds_curse_offer or card.ability.hnds_curse_price) then
            -- Continuous safety net: generation paths such as Buffoon Packs may
            -- apply their stickers after the curse was assigned.
            hnds_strip_foreign_stickers(card)
            return trigger_curse(card, context)
        end
    end,
}
-- Setup hook to capture card reference during loc_vars evaluation
HNDS_setup_cursed_sticker_hook(SMODS.Stickers['hnds_cursed'])


if not _G.HNDS_curse_collections then
    _G.HNDS_curse_collections = true

    HNDS = HNDS or {}
    -- Guarded by _G.HNDS_curse_collections, so this block runs exactly once.
    HNDS.CURSE_OFFERS_COLLECTION = {}
    HNDS.CURSE_PRICES_COLLECTION = {}

    for i, v in ipairs(G.CURSE_OFFERS or {}) do
        if v and v.id then
            HNDS.CURSE_OFFERS_COLLECTION[#HNDS.CURSE_OFFERS_COLLECTION + 1] = { id = v.id, order = i, mod = SMODS.current_mod }
        end
    end
    for i, v in ipairs(G.CURSE_PRICES or {}) do
        if v and v.id then
            HNDS.CURSE_PRICES_COLLECTION[#HNDS.CURSE_PRICES_COLLECTION + 1] = { id = v.id, order = i, mod = SMODS.current_mod }
        end
    end

    SMODS.current_mod.custom_collection_tabs = function()
        -- Adds pages to the collection for browsing curse offer/price descriptions.
        return {
            UIBox_button({button = 'your_collection_hnds_curse_offers', label = {localize('k_hnds_cursed_offers')}, minw = 5, minh = 1, id = 'your_collection_hnds_curse_offers', focus_args = {snap_to = true}}),
            UIBox_button({button = 'your_collection_hnds_curse_prices', label = {localize('k_hnds_cursed_prices')}, minw = 5, minh = 1, id = 'your_collection_hnds_curse_prices', focus_args = {snap_to = true}}),
        }
    end

    create_UIBox_your_collection_hnds_curse_offers = function()
        return SMODS.card_collection_UIBox(HNDS.CURSE_OFFERS_COLLECTION, {4,4}, {
            snap_back = true,
            hide_single_page = true,
            collapse_single_page = true,
            center = 'c_base',
            h_mod = 1.03,
            back_func = 'your_collection_other_gameobjects',
            modify_card = function(card, center)
                card.ignore_pinned = true
                if card.add_sticker then card:add_sticker('hnds_cursed', true) end
                card.ability = card.ability or {}
                card.ability.hnds_curse_preview = true
                card.ability.hnds_curse_offer = center.id
                card.ability.hnds_curse_price = nil
                card.ability.hnds_curse_display_mode = 'offer'
            end,
        })
    end

    create_UIBox_your_collection_hnds_curse_prices = function()
        return SMODS.card_collection_UIBox(HNDS.CURSE_PRICES_COLLECTION, {4,4}, {
            snap_back = true,
            hide_single_page = true,
            collapse_single_page = true,
            center = 'c_base',
            h_mod = 1.03,
            back_func = 'your_collection_other_gameobjects',
            modify_card = function(card, center)
                card.ignore_pinned = true
                if card.add_sticker then card:add_sticker('hnds_cursed', true) end
                card.ability = card.ability or {}
                card.ability.hnds_curse_preview = true
                card.ability.hnds_curse_offer = nil
                card.ability.hnds_curse_price = center.id
                card.ability.hnds_curse_display_mode = 'price'
            end,
        })
    end

    G.FUNCS.your_collection_hnds_curse_offers = function(e)
        G.SETTINGS.paused = true
        G.FUNCS.overlay_menu{
            definition = create_UIBox_your_collection_hnds_curse_offers(),
        }
    end

    G.FUNCS.your_collection_hnds_curse_prices = function(e)
        G.SETTINGS.paused = true
        G.FUNCS.overlay_menu{
            definition = create_UIBox_your_collection_hnds_curse_prices(),
        }
    end
end

function set_enhancement(card, key)
    if card.area == G.hand then
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.05, func = function() card:highlight(true); card:flip(); play_sound('generic1', 0.7, 0.35); card:juice_up(0.3,0.3); return true; end}))
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.15,
            func = function()
                card:set_ability(G.P_CENTERS[key])
                card:juice_up()
                return true
            end
        }))
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.05, func = function() card:highlight(false); card:flip(); play_sound('tarot2', 0.85, 0.6); card:juice_up(0.3,0.3); return true; end}))
    else
        card:set_ability(G.P_CENTERS[key])
    end
end

local function hnds_assign_curse_data(card, attach_sticker)
    -- Assign a random offer + price to a card, then attach the cursed sticker.
    -- This is used when generating cursed pack cards.
    -- Guard: only apply to Jokers
    if not (card and card.config and card.config.center and card.config.center.set == 'Joker') then return end
    if card.config.center.key then
        local center_key = card.config.center.key
        if center_key == 'c_hnds_dream' or center_key == 'j_hnds_art' then
            return
        end
    end

    hnds_ensure_extra(card)

    -- Strip every existing sticker before applying the curse. The helper also
    -- clears direct built-in flags used by vanilla generation paths.
    hnds_strip_foreign_stickers(card)

    local offer_index
    local price_index
    local attempt_count = 0

    -- Check if a Joker have a "calculate" function is a bit generic way to prevent passive joker
    -- from obtaining the trigger again effect
    local can_be_retriggered = card.config and card.config.center and card.config.center.calculate ~= nil

    -- Whether the joker already has an edition. If so, offer_self_negative
    -- would overwrite it on purchase, so we reroll to a different offer.
    local has_existing_edition = false
    if card.edition then
        for k, _ in pairs(card.edition) do
            if k ~= 'type' then has_existing_edition = true break end
        end
    end

    while attempt_count < 10 do
        attempt_count = attempt_count + 1
        -- Use unique seed per attempt
        offer_index = pseudorandom('curse_offer'..(card.ID or '')..attempt_count, 1, #G.CURSE_OFFERS)
        price_index = pseudorandom('curse_price'..(card.ID or '')..attempt_count, 1, #G.CURSE_PRICES)

        local offer_entry = G.CURSE_OFFERS[offer_index]
        local price_entry = G.CURSE_PRICES[price_index]

        -- Reroll if offer_retrigger landed on a non-retriggerable joker.
        if offer_entry and offer_entry.id == 'offer_retrigger' and not can_be_retriggered then
            offer_entry = nil
        end

        -- Reroll if offer_self_negative landed on a joker that already has an edition
        if offer_entry and offer_entry.id == 'offer_self_negative' and has_existing_edition then
            offer_entry = nil
        end

        -- Mutually exclusive curse combinations. These effects directly cancel
        -- or undermine each other and must never be assigned to the same Joker.
        if offer_entry and price_entry then
            local incompatible =
                (offer_entry.id == 'offer_free_rerolls' and price_entry.id == 'price_inflation')
                or (offer_entry.id == 'offer_random_enhancement' and price_entry.id == 'price_destroy_cards')
            if incompatible then
                offer_entry = nil
                price_entry = nil
            end
        end

        if offer_entry and price_entry then
            card.ability.hnds_curse_offer = offer_entry.id
            card.ability.hnds_curse_price = price_entry.id
            if attach_sticker and not (card.ability and card.ability.hnds_cursed) then
                card:add_sticker('hnds_cursed', true)
            else
                card.ability.hnds_cursed = true
            end

            -- add_sticker may call set_ability internally, which can wipe extra
            -- and re-apply foreign stickers via should_apply, so re-run both.
            hnds_ensure_extra(card)
            hnds_strip_foreign_stickers(card)

            card.cursed_shake = true
            break
        end
    end
end


HNDS = HNDS or {}
function HNDS.assign_curse_data(card)
    return hnds_assign_curse_data(card, false)
end

function apply_curse(card)
    return hnds_assign_curse_data(card, true)
end

-- Cursed Pack Definition
SMODS.Booster{
    key = 'cursed_pack',
    kind = 'Joker',
    atlas = 'Extras',
    pos = { x = 3, y = 2 },
    group_key = 'k_hnds_cursed_pack',
    config = {extra = 4, choose = 1},
    cost = 6,
    weight = 0.8,
    ease_background_colour = function(self)
        local cursed_col = mix_colours(G.C.RED, G.C.BLACK, 0.75)
        ease_colour(G.C.DYN_UI.MAIN, cursed_col)
        ease_background_colour { new_colour = cursed_col, special_colour = darken(G.C.BLACK, 0.2), contrast = 2.5 }
    end,
    create_card = function(self, card)
        local c = create_card("Joker", G.pack_cards, nil, nil, true, true, nil, 'cur')
        apply_curse(c)
        return c
    end,
    in_pool = function (self, args)
        local blood_active = G and G.GAME and G.GAME.modifiers
            and G.GAME.modifiers.hnds_blood_stake == true
        self.weight = blood_active and 1.6 or 0.8
        return hnds_config.enableCursedPackSpawning
    end
}

local hnds_offer_lookup, hnds_price_lookup
local function hnds_build_lookups()
    if hnds_offer_lookup then return end
    hnds_offer_lookup = {}
    hnds_price_lookup = {}
    for _, def in pairs(G.CURSE_OFFERS) do
        hnds_offer_lookup[def.id] = def
    end
    for _, def in pairs(G.CURSE_PRICES) do
        hnds_price_lookup[def.id] = def
    end
end

-- Run the offer and price funcs under pcall, log failures, return the combined effect.
local function hnds_run_defs(card, ctx, offer_def, price_def)
    local offer_ret, price_ret
    if offer_def and offer_def.func then
        local ok, ret = pcall(offer_def.func, card, ctx)
        if not ok then print('HNDS CURSE offer error: '..tostring(card.ability.hnds_curse_offer)..' -> '..tostring(ret)) end
        if ok then offer_ret = ret end
    end
    if price_def and price_def.func then
        local ok, ret = pcall(price_def.func, card, ctx)
        if not ok then print('HNDS CURSE price error: '..tostring(card.ability.hnds_curse_price)..' -> '..tostring(ret)) end
        if ok then price_ret = ret end
    end
    return offer_ret or price_ret
end

function trigger_curse(card, context)
    -- Central dispatcher: looks up the selected offer/price by ID and executes them.
    -- This is called from:
    -- - lovely card.lua hooks (add_to_deck/remove_from_deck)
    -- - lovely button callback hook (buying_card)
    -- - cursed sticker calculate (normal evaluation)
    if not card.ability or not (card.ability.hnds_curse_offer or card.ability.hnds_curse_price) then return end
    
    -- Prevent re-triggering on eternal copies (Devil's Round joker copies).
    if card.ability.hnds_eternal_copy_created then return end

    -- Prevent curse re-triggering when vouchers are bought (vouchers trigger buying_card context on all jokers)
    if context and context.buying_card and context.card and context.card.ability and context.card.ability.set == 'Voucher' then
        return
    end

    if context and context.buying_card then
        if not context.card or context.card ~= card then
            return
        end
        if (card.ability and card.ability.hnds_curse_acquire_triggered) or card.hnds_curse_acquire_triggered then
            return
        end
        card.ability = card.ability or {}
        card.ability.hnds_curse_acquire_triggered = true
        card.hnds_curse_acquire_triggered = true
    end

    hnds_build_lookups()
    local offer_def = hnds_offer_lookup[card.ability.hnds_curse_offer]
    local price_def = hnds_price_lookup[card.ability.hnds_curse_price]

    local acquire_ret
    -- When a Joker is first added to the deck, we simulate a single "buy" trigger
    -- so offers/prices that are keyed to context.buying_card still fire once.
    if context and context.add_to_deck and not ((card.ability and card.ability.hnds_curse_acquire_triggered) or card.hnds_curse_acquire_triggered) then
        card.ability = card.ability or {}
        card.ability.hnds_curse_acquire_triggered = true
        card.hnds_curse_acquire_triggered = true
        local acquire_context = {}
        for context_key, context_value in pairs(context) do acquire_context[context_key] = context_value end

        acquire_context.buying_card = true
        acquire_context.add_to_deck = nil
        acquire_context.remove_from_deck = nil

        acquire_ret = hnds_run_defs(card, acquire_context, offer_def, price_def)
        -- Do NOT return here; we still need to process passive add_to_deck effects
    end

    return acquire_ret or hnds_run_defs(card, context, offer_def, price_def)
end
