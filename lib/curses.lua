--[[
Curses Logic and Implementation (Cursed Stickers, Booster Pack and Random Cursed Offer/Price System are
inside of this file and most of the code, other parts of the code are inside hooks, lovely.toml and the loc files)
This file defines the "curse" system used by the Cursed Sticker.

Data model:
- A Cursed Joker has a sticker (`hnds_cursed`) and a `card.ability.curse` table.
- `card.ability.curse.offer` is a benefit ID (from `G.CURSE_OFFERS`).
- `card.ability.curse.price` is a drawback ID (from `G.CURSE_PRICES`).

Tooltip/UI:
- The sticker provides a tooltip (using localization keys under `descriptions.Other`).
- The code also adds "Cursed Offers" and "Cursed Prices" pages to the collection.

Primary entry points (functions)
- `apply_curse(card)`
  - Assigns a random offer/price pair to a Joker and attaches the `hnds_cursed` sticker.
  - Used when generating cursed content (e.g. cursed pack, cursed shop rolls, Devil's Round challenge).

Who calls this code
- lovely patches (outside this file) call `trigger_curse`
  - add_to_deck
  - remove_from_deck
  - buying_card

- Collection UI
  - Custom collection tabs so players can browse the offers/price descriptions.
  - The collection cards are "fake" preview cards with `card.ability.hnds_curse_preview = true`.
--]]

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
    -- 2. Create a copy of a random planet card
    [2] = {
        id = 'offer_copy_random_planet',
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
                                    SMODS.add_card({set = 'Planet', area = G.consumeables, key_append = 'hnds_curse_planet'})
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
            if context.retrigger_joker_check and not context.retrigger_joker and context.other_card == card then
                return { message = localize('k_again_ex'), repetitions = 1, card = card }
            end
        end
    },
    -- 6. Raises interest cap by 5
    [6] = {
        id = 'offer_interest_cap',
        func = function(card, context)
            if context.add_to_deck and G.GAME.interest_cap then
                G.GAME.interest_cap = G.GAME.interest_cap + 25
            elseif context.remove_from_deck and G.GAME and G.GAME.interest_cap then
                G.GAME.interest_cap = G.GAME.interest_cap - 25
                if G.GAME.interest_cap < 0 then G.GAME.interest_cap = 0 end
            end
        end
    },
    -- 7. Gain 2 free rerolls for each shop
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
                            copy.ability.curse = nil
                            copy.ability.hnds_curse_preview = nil
                            copy.ability.curse_acquire_triggered = true -- Prevent re-triggering
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
                    if G.jokers.cards[i] ~= card then
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
                if G and G.E_MANAGER and Event then
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.1,
                        func = function()
                            local current_dollars = tonumber(G.GAME and G.GAME.dollars) or 0
                            if current_dollars ~= 0 then
                                ease_dollars(-current_dollars, true)
                            end
                            return true
                        end
                    }))
                else
                    local current_dollars = tonumber(G.GAME and G.GAME.dollars) or 0
                    if current_dollars ~= 0 then
                        ease_dollars(-current_dollars, true)
                    end
                end
            end
        end
    },
    -- 4. Increases Prices by 25% 
    [4] = {
        id = 'price_inflation',
        func = function(card, context)
            if not (G and G.GAME) then return end
            if not context.buying_card then return end

            G.GAME.hnds_curse_inflation_count = (G.GAME.hnds_curse_inflation_count or 0) + 1
            G.GAME.discount_percent = (G.GAME.discount_percent or 0) - 25
            
            G.GAME.hnds_price_multiplier = (G.GAME.hnds_price_multiplier or 1) * 1.25

            if G.shop_jokers and G.shop_jokers.cards then
                for _, c in ipairs(G.shop_jokers.cards) do
                    if c and c.set_cost then c:set_cost() end
                end
            end
            if G.shop_booster and G.shop_booster.cards then
                for _, c in ipairs(G.shop_booster.cards) do
                    if c and c.set_cost then c:set_cost() end
                end
            end
            if calculate_reroll_cost then calculate_reroll_cost() end
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
    [8] = {
        id = 'price_ante_scaling',
        func = function(card, context)
            if not (context and context.buying_card and G and G.GAME and G.GAME.starting_params) then return end
            G.GAME.starting_params.ante_scaling = (G.GAME.starting_params.ante_scaling or 1) * 1.50
        end
    }
}

if SMODS then
    SMODS.Sticker{
        key = 'hnds_cursed',
        atlas = 'Stickers',
        pos = { x = 0, y = 0 },
        badge_colour = G.C.RED,

        loc_vars = function(self, info_queue, card)
            return { vars = { '', '' } }
        end,

        -- This builds the tooltip text for the sticker.
        -- The cursed sticker tooltip is composed from `descriptions.Other` localization keys:
        -- - `hnds_cursed_offer_title`
        -- - `<offer_id>`
        -- - `hnds_cursed_price_title`
        -- - `<price_id>`
        generate_ui = function(self, info_queue, card, desc_nodes, specific_vars, full_UI_table)
            if not (card and G and G.localization and desc_nodes) then return end

            for i = #desc_nodes, 1, -1 do
                desc_nodes[i] = nil
            end

            local function append_other_key(key)
                -- Render a `descriptions.Other[key]` localization entry into `desc_nodes`.
                -- We parse text lazily (text_parsed) so formatting tokens like {C:...} work.
                if not key then return end
                local loc = (G.localization and G.localization.descriptions and G.localization.descriptions.Other) and G.localization.descriptions.Other[key] or nil

                if type(loc) == 'table' and not loc.text_parsed and type(loc.text) == 'table' and loc_parse_string then
                    loc.text_parsed = {}
                    for _, line in ipairs(loc.text) do
                        loc.text_parsed[#loc.text_parsed + 1] = loc_parse_string(line)
                    end
                end

                local vars = specific_vars
                if vars == nil then vars = {} end
                if vars.colours == nil then vars.colours = {} end

                if type(loc) ~= 'table' then
                    desc_nodes[#desc_nodes + 1] = {
                        { n = G.UIT.T, config = { text = tostring(key), colour = G.C.UI.TEXT_DARK, scale = 0.32, shadow = false } }
                    }
                    return
                end

                localize ( { type = 'other', key = key, nodes = desc_nodes, vars = vars, shadow = false, default_col = G.C.UI.TEXT_DARK, } )
            end

            local is_collection = card and card.area and card.area.config and card.area.config.collection
            local is_preview = card and card.ability and card.ability.hnds_curse_preview
            if (not (card.ability and card.ability.curse)) then
                append_other_key('hnds_cursed')
                return
            end

            if is_collection and not is_preview then
                append_other_key('hnds_cursed')
                return
            end

            local display_mode = card.ability.curse and card.ability.curse.hnds_collection_display
            if display_mode == 'offer' then
                append_other_key(card.ability.curse.offer)
                return
            elseif display_mode == 'price' then
                append_other_key(card.ability.curse.price)
                return
            end

            append_other_key('hnds_cursed_offer_title')
            append_other_key(card.ability.curse.offer)
            desc_nodes[#desc_nodes + 1] = { { n = G.UIT.B, config = { h = 0.05, w = 0 } } }
            append_other_key('hnds_cursed_price_title')
            append_other_key(card.ability.curse.price)
        end,

        calculate = function(self, card, context)
            -- This runs during normal Joker evaluation.
            -- We use it to enforce curse invariants (strip conflicting stickers/modifiers)
            -- and to forward evaluation to `trigger_curse`.
            if card and card.ability and card.ability.curse then
                card.ability.perishable = nil
                card.ability.eternal = nil

                if card.stickers and type(card.stickers) == 'table' then
                    for k, _ in pairs(card.stickers) do
                        if k ~= 'hnds_cursed' then
                            card.stickers[k] = nil
                        end
                    end
                end

                if card.ability and card.ability.stickers and type(card.ability.stickers) == 'table' then
                    for k, _ in pairs(card.ability.stickers) do
                        if k ~= 'hnds_cursed' then
                            card.ability.stickers[k] = nil
                        end
                    end
                end
            end

            if card and card.ability and card.ability.curse then
                return trigger_curse(card, context)
            end
        end,
    }
end

if not _G.HNDS_generate_card_ui_wrap and type(generate_card_ui) == 'function' then
    _G.HNDS_generate_card_ui_wrap = true

    local _HNDS_generate_card_ui_prev_card = nil
    local _HNDS_generate_card_ui_ref = generate_card_ui
    generate_card_ui = function(_c, full_UI_table, specific_vars, card_type, badges, hide_desc, main_start, main_end, card)
        -- Sticker tooltips are rendered via `generate_card_ui` using a special `Other` center.
        -- We only provide a "previous card" fallback for our cursed sticker so we don't leak
        -- a stale card into unrelated tooltips (this previously caused hover crashes).
        if card ~= nil and type(card) == 'table' and card.ability ~= nil then _HNDS_generate_card_ui_prev_card = card end
        local use_card = card
        if use_card == nil and _HNDS_generate_card_ui_prev_card ~= nil and type(_HNDS_generate_card_ui_prev_card) == 'table' and _HNDS_generate_card_ui_prev_card.ability ~= nil then
            use_card = _HNDS_generate_card_ui_prev_card
        end

        if SMODS and SMODS.Stickers and type(_c) == 'table' and _c.set == 'Other' and type(_c.key) == 'string' then
            local st = SMODS.Stickers[_c.key]
            if st and type(st.generate_ui) == 'function' then
                local vars = specific_vars
                if vars == nil and type(_c.vars) == 'table' then vars = _c.vars end
                local pass_card = card
                if _c.key == 'hnds_cursed' then pass_card = use_card end
                local ok, ret_or_err = pcall(_HNDS_generate_card_ui_ref, st, full_UI_table, vars, card_type, badges, hide_desc, main_start, main_end, pass_card)
                if ok then return ret_or_err end
                print('HNDS generate_card_ui sticker error: '..tostring(ret_or_err))
                return full_UI_table
            end
        end

        local ok, ret_or_err = pcall(_HNDS_generate_card_ui_ref, _c, full_UI_table, specific_vars, card_type, badges, hide_desc, main_start, main_end, card)
        if ok then return ret_or_err end
        print('HNDS generate_card_ui error: '..tostring(ret_or_err))
        return full_UI_table
    end
end

if not _G.HNDS_curse_collections and SMODS and SMODS.current_mod then
    _G.HNDS_curse_collections = true

    HNDS = HNDS or {}
    HNDS.CURSE_OFFERS_COLLECTION = HNDS.CURSE_OFFERS_COLLECTION or {}
    HNDS.CURSE_PRICES_COLLECTION = HNDS.CURSE_PRICES_COLLECTION or {}

    for i = #HNDS.CURSE_OFFERS_COLLECTION, 1, -1 do HNDS.CURSE_OFFERS_COLLECTION[i] = nil end
    for i = #HNDS.CURSE_PRICES_COLLECTION, 1, -1 do HNDS.CURSE_PRICES_COLLECTION[i] = nil end

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
        return SMODS.card_collection_UIBox(HNDS.CURSE_OFFERS_COLLECTION, {5,5}, {
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
                card.ability.curse = { offer = center.id, price = nil, hnds_collection_display = 'offer' }
            end,
        })
    end

    create_UIBox_your_collection_hnds_curse_prices = function()
        return SMODS.card_collection_UIBox(HNDS.CURSE_PRICES_COLLECTION, {5,5}, {
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
                card.ability.curse = { offer = nil, price = center.id, hnds_collection_display = 'price' }
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
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.15, func = function() card:highlight(true); card:flip(); play_sound('generic1', 0.7, 0.35); card:juice_up(0.3,0.3); return true; end}))
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4,
            func = function()
                card:set_ability(G.P_CENTERS[key])
                card:juice_up()
                return true
            end
        }))
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.15, func = function() card:highlight(false); card:flip(); play_sound('tarot2', 0.85, 0.6); card:juice_up(0.3,0.3); return true; end}))
    else
        card:set_ability(G.P_CENTERS[key])
        if SMODS and SMODS.enh_cache and SMODS.enh_cache.clear then SMODS.enh_cache:write(card, nil) end
    end
end

function apply_curse(card)
    -- Assign a random offer + price to a card, then attach the cursed sticker.
    -- This is used when generating cursed pack cards.
    if card and card.config and card.config.center and card.config.center.key then
        local center_key = card.config.center.key
        if center_key == 'c_hnds_dream' or center_key == 'j_hnds_art' then
            return
        end
    end

    if not card.ability then card.ability = {} end

    if card.ability then
        card.ability.perishable = nil
        card.ability.eternal = nil
        card.ability.rental = nil
    end

    if card.stickers and type(card.stickers) == 'table' then
        for sticker_key, _ in pairs(card.stickers) do
            if sticker_key ~= 'hnds_cursed' then
                card.stickers[sticker_key] = nil
            end
        end
    end

    if card.ability and card.ability.stickers and type(card.ability.stickers) == 'table' then
        for sticker_key, _ in pairs(card.ability.stickers) do
            if sticker_key ~= 'hnds_cursed' then
                card.ability.stickers[sticker_key] = nil
            end
        end
    end

    local offer_index
    local price_index
    local attempt_count = 0

    while attempt_count < 10 do
        attempt_count = attempt_count + 1
        -- Use unique seed per attempt
        offer_index = pseudorandom('curse_offer'..(card.ID or '')..attempt_count, 1, #G.CURSE_OFFERS)
        price_index = pseudorandom('curse_price'..(card.ID or '')..attempt_count, 1, #G.CURSE_PRICES)

        local offer_entry = G.CURSE_OFFERS[offer_index]
        local price_entry = G.CURSE_PRICES[price_index]

        if offer_entry and price_entry then
            card.ability.curse = {
                offer = offer_entry.id,
                price = price_entry.id
            }
            if card.add_sticker then
                card:add_sticker('hnds_cursed', true)
            else
                print("ERROR: add_sticker method not found on card")
                card.ability.hnds_cursed = true
            end

            card.cursed_shake = true
            break
        end
    end
end

-- Cursed Pack Definition
if SMODS then
    SMODS.Booster{
        key = 'cursed_pack',
        kind = 'Joker',
        atlas = 'Extras',
        pos = { x = 3, y = 2 },
        group_key = 'k_hnds_cursed_pack',
        config = {extra = 4, choose = 1},
        cost = 6,
        weight = 0.10,
        ease_background_colour = function(self)
            local cursed_col = mix_colours(G.C.RED, G.C.BLACK, 0.75)
            ease_colour(G.C.DYN_UI.MAIN, cursed_col)
            ease_background_colour { new_colour = cursed_col, special_colour = darken(G.C.BLACK, 0.2), contrast = 2.5 }
        end,
        create_card = function(self, card)
            local c = create_card("Joker", G.pack_cards, nil, nil, true, true, nil, 'cur')
            apply_curse(c)
            return c
        end
    }
end

function trigger_curse(card, context)
    -- Central dispatcher: looks up the selected offer/price by ID and executes them.
    -- This is called from:
    -- - lovely card.lua hooks (add_to_deck/remove_from_deck)
    -- - lovely button callback hook (buying_card)
    -- - cursed sticker calculate (normal evaluation)
    if not card.ability or not card.ability.curse then return end
    
    -- Prevent re-triggering on eternal copies or when negative edition is being applied by curse
    if card.ability.hnds_eternal_copy_created or card.ability.hnds_curse_negative_applying then return end

    -- Prevent curse re-triggering when vouchers are bought (vouchers trigger buying_card context on all jokers)
    if context and context.buying_card and context.card and context.card.ability and context.card.ability.set == 'Voucher' then
        return
    end

    if context and context.buying_card and not context.challenge_creation then
        if not context.card or context.card ~= card then
            return
        end
        if (card.ability and card.ability.curse_acquire_triggered) or card.hnds_curse_acquire_triggered then
            return
        end
        card.ability = card.ability or {}
        card.ability.curse_acquire_triggered = true
        card.hnds_curse_acquire_triggered = true
    end

    -- Find definitions
    local offer_def, price_def
    for _, offer_definition in pairs(G.CURSE_OFFERS) do if offer_definition.id == card.ability.curse.offer then offer_def = offer_definition break end end
    for _, price_definition in pairs(G.CURSE_PRICES) do if price_definition.id == card.ability.curse.price then price_def = price_definition break end end

    local acquire_ret
    -- Handle challenge creation separately to avoid double-triggering
    if context and context.challenge_creation then
        -- For challenge jokers, trigger both offer and price immediately
        card.ability = card.ability or {}
        card.ability.curse_acquire_triggered = true -- Set this flag to prevent re-triggering
        card.hnds_curse_acquire_triggered = true
        local offer_ret, price_ret
        if offer_def and offer_def.func then
            local ok, ret_or_err = pcall(offer_def.func, card, context)
            if not ok then print('HNDS CURSE offer error: '..tostring(card.ability.curse.offer)..' -> '..tostring(ret_or_err)) end
            if ok then offer_ret = ret_or_err end
        end

        if price_def and price_def.func then
            local ok, ret_or_err = pcall(price_def.func, card, context)
            if not ok then print('HNDS CURSE price error: '..tostring(card.ability.curse.price)..' -> '..tostring(ret_or_err)) end
            if ok then price_ret = ret_or_err end
        end
        acquire_ret = offer_ret or price_ret
        -- Skip the normal add_to_deck logic for challenge creations to prevent double-triggering
        return acquire_ret
    elseif context and context.add_to_deck and not ((card.ability and card.ability.curse_acquire_triggered) or card.hnds_curse_acquire_triggered) then
        -- When a Joker is first added to the deck, we simulate a single "buy" trigger
        -- so offers/prices that are keyed to context.buying_card still fire once.
        card.ability = card.ability or {}
        card.ability.curse_acquire_triggered = true
        card.hnds_curse_acquire_triggered = true
        local acquire_context = {}
        for context_key, context_value in pairs(context) do acquire_context[context_key] = context_value end

        acquire_context.buying_card = true
        acquire_context.add_to_deck = nil
        acquire_context.remove_from_deck = nil

        local offer_ret, price_ret
        if offer_def and offer_def.func then
            local ok, ret_or_err = pcall(offer_def.func, card, acquire_context)
            if not ok then print('HNDS CURSE offer error: '..tostring(card.ability.curse.offer)..' -> '..tostring(ret_or_err)) end
            if ok then offer_ret = ret_or_err end
        end

        if price_def and price_def.func then
            local ok, ret_or_err = pcall(price_def.func, card, acquire_context)
            if not ok then print('HNDS CURSE price error: '..tostring(card.ability.curse.price)..' -> '..tostring(ret_or_err)) end
            if ok then price_ret = ret_or_err end
        end
        acquire_ret = offer_ret or price_ret
        -- Do NOT return here; we still need to process passive add_to_deck effects
    end

    local offer_ret, price_ret
    if offer_def and offer_def.func then
        local ok, ret_or_err = pcall(offer_def.func, card, context)
        if not ok then print('HNDS CURSE offer error: '..tostring(card.ability.curse.offer)..' -> '..tostring(ret_or_err)) end
        if ok then offer_ret = ret_or_err end
    end
    if price_def and price_def.func then
        local ok, ret_or_err = pcall(price_def.func, card, context)
        if not ok then print('HNDS CURSE price error: '..tostring(card.ability.curse.price)..' -> '..tostring(ret_or_err)) end
        if ok then price_ret = ret_or_err end
    end
    return acquire_ret or offer_ret or price_ret
end