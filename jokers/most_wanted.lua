


local function most_wanted_multiplier(total_jokers)
    if total_jokers > 800 then return 12 end
    if total_jokers > 500 then return 8 end
    if total_jokers > 300 then return 6 end
    return 4
end

local function most_wanted_pool(previous_key)
    local pool = {}
    local total = 0

    for _, center in ipairs((G and G.P_CENTER_POOLS and G.P_CENTER_POOLS.Joker) or {}) do
        if center and center.key and not center.hidden and center.key ~= 'j_hnds_most_wanted' then
            total = total + 1
            if center.discovered and center.key ~= previous_key then
                pool[#pool + 1] = center.key
            end
        end
    end

    table.sort(pool)
    return pool, total
end

local function choose_target(seed, previous_key)
    local pool, total = most_wanted_pool(previous_key)
    if #pool == 0 then return nil, total end
    return pseudorandom_element(pool, pseudoseed(seed)), total
end

local function localization_name(set, key, fallback)
    if not key then return fallback end
    local descriptions = G and G.localization and G.localization.descriptions
    local entry = descriptions and descriptions[set] and descriptions[set][key]
    local name = entry and entry.name

    if type(name) == 'string' and name ~= '' then
        return name
    elseif type(name) == 'table' then
        local parts = {}
        for _, line in ipairs(name) do
            if type(line) == 'string' and line ~= '' then parts[#parts + 1] = line end
        end
        if #parts > 0 then return table.concat(parts, ' ') end
    end

    return fallback
end

local function preview_target()
    local pool = most_wanted_pool(nil)
    return pool[1]
end

local function display_vars(self, card)
    local extra = card and card.ability and type(card.ability.extra) == 'table'
        and card.ability.extra
        or self.config.extra

    local target_key = extra and extra.target or nil
    local edition_key = extra and extra.target_edition or nil
    local multiplier = tonumber(extra and extra.multiplier) or 4


    local in_run = G and G.STAGES and G.STAGE == G.STAGES.RUN
    if not in_run then
        target_key = target_key or preview_target()
        edition_key = edition_key or (G and G.P_CENTERS and G.P_CENTERS.e_foil and 'e_foil' or nil)
        local _, total = most_wanted_pool(nil)
        multiplier = most_wanted_multiplier(total)
    end

    local target_name = localization_name('Joker', target_key, 'Wanted Joker')
    local edition_name = localization_name('Edition', edition_key, '')
    local display_name = edition_name ~= '' and (edition_name .. ' ' .. target_name) or target_name

    return { display_name, multiplier }
end

local function ensure_state(card, seed)
    if not card or not card.ability then return end
    if type(card.ability.extra) ~= 'table' then
        card.ability.extra = { target = nil, target_edition = nil, multiplier = 4 }
    end

    local extra = card.ability.extra
    local _, total = most_wanted_pool(nil)
    extra.multiplier = most_wanted_multiplier(total)

    if not extra.target then
        extra.target = choose_target(seed or 'hnds_most_wanted_target', nil)
    end
    if not extra.target_edition and HNDS.poll_featured_edition then
        extra.target_edition = HNDS.poll_featured_edition((seed or 'hnds_most_wanted') .. '_edition')
    end
end

local function is_target(card, target_key)
    return card
        and target_key
        and card.config
        and card.config.center
        and card.config.center.key == target_key
end

local function apply_target_edition(owner, shop_card)
    if not owner or not owner.ability or type(owner.ability.extra) ~= 'table' then return end
    local extra = owner.ability.extra
    if not is_target(shop_card, extra.target) then return end

    if not shop_card.hnds_most_wanted_announced then
        shop_card.hnds_most_wanted_announced = true
        if hnds_config and hnds_config.enableCustomSounds then
            play_sound('hnds_wp_buy_inshop', 1, 0.75)
        end
    end

    if not shop_card.edition and extra.target_edition then
        shop_card:set_edition(extra.target_edition, false, false)
        shop_card:juice_up()
    end
end

SMODS.Joker({
    key = 'most_wanted',
    atlas = 'Jokers',
    pos = { x = 0, y = 4 },
    rarity = 1,
    cost = 3,
    unlocked = false,
    discovered = false,
    unlock_condition = { type = 'hnds_joker_unlock', key = 'most_wanted' },

    locked_loc_vars = function(self)
        return HNDS.joker_locked_loc_vars('most_wanted')
    end,

    check_for_unlock = function(self, args)
        return HNDS.joker_unlock_condition_met('most_wanted', args)
    end,

    blueprint_compat = true,
    demicoloncompat = true,
    eternal_compat = false,
    perishable_compat = true,

    config = {
        extra = {
            target = nil,
            target_edition = nil,
            multiplier = 4,
        }
    },


    loc_vars = function(self, info_queue, card)
        return { vars = display_vars(self, card) }
    end,

    set_ability = function(self, card, initial, delay_sprites)
        if G and G.STAGES and G.STAGE == G.STAGES.RUN then
            ensure_state(card, 'hnds_most_wanted_init')
        end
    end,

    calculate = function(self, card, context)
        if not card or not card.ability then return end
        if type(card.ability.extra) ~= 'table' then
            card.ability.extra = { target = nil, target_edition = nil, multiplier = 4 }
        end
        local extra = card.ability.extra


        if (context.starting_shop or context.reroll_shop or context.modify_weights or context.modify_shop_card)
            and not extra.target
        then
            ensure_state(card, 'hnds_most_wanted_repair')
            extra = card.ability.extra
        end

        if context.selling_self and not context.blueprint
            and G.STATE == G.STATES.SHOP
            and G.shop_jokers and G.shop_jokers.cards
        then
            for _, shop_card in ipairs(G.shop_jokers.cards) do
                if is_target(shop_card, extra.target) then
                    shop_card.cost = 0
                    shop_card.val = 0
                    if shop_card.hud_item then shop_card.hud_item:realign() end
                end
            end
        end

        if context.modify_shop_card and context.card then
            apply_target_edition(card, context.card)
        end

        if context.modify_weights and context.pool_types and context.pool_types.Joker
            and context.pool and extra.target
        then
            for _, entry in ipairs(context.pool) do
                if entry.key == extra.target then
                    entry.weight = (entry.weight or 1) * (extra.multiplier or 1)
                end
            end
        end

        if (context.starting_shop or context.reroll_shop)
            and G.shop_jokers and G.shop_jokers.cards
        then
            G.E_MANAGER:add_event(Event({
                func = function()
                    if G.shop_jokers and G.shop_jokers.cards then
                        for _, shop_card in ipairs(G.shop_jokers.cards) do
                            apply_target_edition(card, shop_card)
                        end
                    end
                    return true
                end
            }))
        end
    end,

    attributes = { 'joker', 'passive' },
})
