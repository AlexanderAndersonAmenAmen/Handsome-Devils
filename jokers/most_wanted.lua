function HNDS.get_most_wanted_multiplier(total_jokers)
    if total_jokers > 800 then return 12 end
    if total_jokers > 500 then return 8 end
    if total_jokers > 300 then return 6 end
    return 4
end

function HNDS.get_discovered_joker_pool(previous_key)
    local pool = {}
    local total_jokers = 0
    for _, center in ipairs((G and G.P_CENTER_POOLS and G.P_CENTER_POOLS.Joker) or {}) do
        if center and not center.hidden and center.key and center.key ~= 'j_hnds_most_wanted' then
            total_jokers = total_jokers + 1
            if center.discovered and center.key ~= previous_key then
                pool[#pool + 1] = center.key
            end
        end
    end
    return pool, total_jokers
end

function HNDS.pick_discovered_joker_key(seed, previous_key)
    local pool, total_jokers = HNDS.get_discovered_joker_pool(previous_key)
    if #pool == 0 then return nil, total_jokers end
    return pseudorandom_element(pool, pseudoseed(seed)), total_jokers
end

-- Most Wanted is rendered while Steamodded is already inside tooltip
-- localization. Calling localize() again from loc_vars can create a stray/empty
-- auxiliary box in collection previews on beta-1620a. Read the already-loaded
-- center names directly instead; this has no tooltip/UI side effects.
local function hnds_most_wanted_raw_name(set, key, fallback)
    if not key then return fallback end
    local descriptions = G and G.localization and G.localization.descriptions
    local bucket = descriptions and descriptions[set]
    local entry = bucket and bucket[key]
    local name = entry and entry.name
    if type(name) == 'string' and name ~= '' then return name end
    return fallback
end

local function hnds_most_wanted_display_vars(self, card)
    local ability = card and card.ability
    local extra = ability and type(ability.extra) == 'table' and ability.extra or self.config.extra or {}

    local fallback = 'Wanted Joker'
    local target_key = extra.target
    local edition_key = extra.target_edition

    -- Fake/collection cards do not have run state. Use deterministic preview
    -- values, but never mutate the fake card while the tooltip is being built.
    if not (G and G.STAGES and G.STAGE == G.STAGES.RUN) then
        target_key = HNDS.pick_discovered_joker_key('hnds_most_wanted_collection')
        edition_key = HNDS.poll_featured_edition('hnds_most_wanted_collection_edition')
    end

    local target_name = hnds_most_wanted_raw_name('Joker', target_key, fallback)
    local edition_name = hnds_most_wanted_raw_name('Edition', edition_key, '')
    local display_name = edition_name ~= '' and (edition_name .. ' ' .. target_name) or target_name

    return { display_name, tonumber(extra.multiplier) or 4 }
end

SMODS.Joker({
    key = "most_wanted",
    atlas = "Jokers",
    pos = { x = 0, y = 4 },
    rarity = 1,
    cost = 3,
    unlocked = false,
    discovered = false,
    unlock_condition = { type = "hnds_joker_unlock", key = "most_wanted" },
    locked_loc_vars = function(self)
        return HNDS.joker_locked_loc_vars("most_wanted")
    end,
    check_for_unlock = function(self, args)
        return HNDS.joker_unlock_condition_met("most_wanted", args)
    end,
    blueprint_compat = true,
    demicoloncompat = true,
    eternal_compat = false,
    perishable_compat = true,
    config = { extra = { target = nil, target_edition = nil, multiplier = 4 } },

    loc_vars = function(self, info_queue, card)
        -- Most Wanted intentionally has no auxiliary tooltip boxes. Clear any
        -- entries a collection/fake-card path may have placed in the shared
        -- queue before this center is localized.
        if type(info_queue) == 'table' then
            for i = #info_queue, 1, -1 do info_queue[i] = nil end
        end
        return { vars = hnds_most_wanted_display_vars(self, card) }
    end,

    -- Deliberately no info_queue callback: Most Wanted should never create
    -- an auxiliary Edition tooltip. Its displayed Edition remains part of #1#.

    set_ability = function(self, card, initial, delay_sprites)
        local _, total_jokers = HNDS.get_discovered_joker_pool()
        card.ability.extra.multiplier = HNDS.get_most_wanted_multiplier(total_jokers)

        if G.STAGE == G.STAGES.RUN then
            local target, _ = HNDS.pick_discovered_joker_key('hnds_most_wanted')
            card.ability.extra.target = target

            card.ability.extra.target_edition = HNDS.poll_featured_edition('hnds_most_wanted_edition_init')
        end
    end,
    calculate = function(self, card, context)
        if context.selling_self and not context.blueprint and G.STATE == G.STATES.SHOP and G.shop_jokers and G.shop_jokers.cards then
            for _, shop_card in ipairs(G.shop_jokers.cards) do
                if shop_card.config and shop_card.config.center and shop_card.config.center.key == card.ability.extra.target then
                    shop_card.cost = 0
                    shop_card.val = 0
                    if shop_card.hud_item then shop_card.hud_item:realign() end
                end
            end
        end

        if context.modify_shop_card and context.card and card.ability.extra.target then
            local shop_card = context.card
            if shop_card.config and shop_card.config.center
                and shop_card.config.center.key == card.ability.extra.target
            then
                if not shop_card.hnds_most_wanted_announced then
                    shop_card.hnds_most_wanted_announced = true
                    if hnds_config and hnds_config.enableCustomSounds then
                        play_sound('hnds_wp_buy_inshop', 1, 0.75)
                    end
                end
                if not shop_card.edition and card.ability.extra.target_edition then
                    shop_card:set_edition(card.ability.extra.target_edition, false, false)
                    shop_card:juice_up()
                end
            end
        end

        if context.modify_weights and context.pool_types and context.pool_types.Joker then
            for _, v in ipairs(context.pool) do
                if v.key == card.ability.extra.target then
                    v.weight = (v.weight or 1) * (card.ability.extra.multiplier or 1)
                end
            end
        end

        if (context.starting_shop or context.reroll_shop) and G.shop_jokers and G.shop_jokers.cards then
            G.E_MANAGER:add_event(Event({
                func = function()
                    for _, shop_card in ipairs(G.shop_jokers.cards) do
                        if shop_card.config and shop_card.config.center and shop_card.config.center.key == card.ability.extra.target then
                            if not shop_card.hnds_most_wanted_announced then
                                shop_card.hnds_most_wanted_announced = true
                                if hnds_config and hnds_config.enableCustomSounds then
                                    play_sound('hnds_wp_buy_inshop', 1, 0.75)
                                end
                            end

                            if not shop_card.edition and card.ability.extra.target_edition then
                                shop_card:set_edition(card.ability.extra.target_edition, false, false)
                                shop_card:juice_up()
                            end
                        end
                    end
                    return true
                end
            }))
        end

        if context.starting_shop and not card.ability.extra.target then
            local target, total_jokers = HNDS.pick_discovered_joker_key('hnds_most_wanted_fallback', card.ability.extra.target)
            card.ability.extra.target = target
            card.ability.extra.multiplier = HNDS.get_most_wanted_multiplier(total_jokers)

            card.ability.extra.target_edition = HNDS.poll_featured_edition('hnds_most_wanted_edition_fallback')
        end
    end,
    attributes = { "joker", "passive", }
})
