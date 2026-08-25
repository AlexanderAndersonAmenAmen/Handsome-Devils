HNDS = HNDS or {}

local MS_FORTUNE_KEY = 'j_hnds_ms_fortune'
local MS_FORTUNE_SELL_GAIN = 15
local MS_FORTUNE_SHOP_ODDS = 6

local function hnds_ms_fortune_is_card(card)
    return card and card.config and card.config.center
        and card.config.center.key == MS_FORTUNE_KEY
end


function HNDS.ms_fortune_ensure_cursed(card)
    if not hnds_ms_fortune_is_card(card) then return false end
    if not (G and G.STAGES and G.STAGE == G.STAGES.RUN) then return false end

    card.ability = card.ability or {}
    if not card.ability.hnds_cursed then
        if card.add_sticker then
            card:add_sticker('hnds_cursed', true)
        else
            card.ability.hnds_cursed = true
            if HNDS.assign_curse_data then HNDS.assign_curse_data(card) end
        end
    elseif not (card.ability.hnds_curse_offer and card.ability.hnds_curse_price)
        and HNDS.assign_curse_data
    then


        HNDS.assign_curse_data(card)
    end
    return true
end

function HNDS.ms_fortune_sync_sell_value(card)
    if not hnds_ms_fortune_is_card(card) or not (G and G.GAME) then return false end
    card.ability = card.ability or {}

    local target = math.max(0, tonumber(G.GAME.hnds_ms_fortune_sell_bonus) or 0)
    local applied = math.max(0, tonumber(card.ability.hnds_ms_fortune_sell_applied) or 0)
    local delta = target - applied

    if delta ~= 0 then


        card.ability.extra_value = (tonumber(card.ability.extra_value) or 0) + delta
        card.ability.hnds_ms_fortune_sell_applied = target
        if card.set_cost then card:set_cost() end
    end
    return delta ~= 0
end

function HNDS.ms_fortune_sync_all()
    if not (G and G.GAME) then return end
    local seen = {}
    for _, area in ipairs({ G.jokers, G.shop_jokers, G.pack_cards }) do
        for _, candidate in ipairs((area and area.cards) or {}) do
            if candidate and not seen[candidate] and hnds_ms_fortune_is_card(candidate) then
                seen[candidate] = true
                HNDS.ms_fortune_sync_sell_value(candidate)
                HNDS.ms_fortune_ensure_cursed(candidate)
            end
        end
    end
end

function HNDS.ms_fortune_obtained(card, from_debuff)
    if not hnds_ms_fortune_is_card(card) or not (G and G.GAME) then return false end
    HNDS.ms_fortune_ensure_cursed(card)
    card.ability = card.ability or {}

    G.GAME.hnds_ms_fortune_shop_active = true

    if from_debuff then
        HNDS.ms_fortune_sync_sell_value(card)
        return false
    end

    local token = tostring(card.ID or card.sort_id or card)
    G.GAME.hnds_ms_fortune_obtained = G.GAME.hnds_ms_fortune_obtained or {}
    local already_claimed = card.ability.hnds_ms_fortune_claim_token == token
        or G.GAME.hnds_ms_fortune_obtained[token]

    card.ability.hnds_ms_fortune_claim_token = token
    G.GAME.hnds_ms_fortune_obtained[token] = true

    if not already_claimed then
        G.GAME.hnds_ms_fortune_sell_bonus =
            math.max(0, tonumber(G.GAME.hnds_ms_fortune_sell_bonus) or 0) + MS_FORTUNE_SELL_GAIN
    end

    HNDS.ms_fortune_sync_all()
    return not already_claimed
end


function HNDS.ms_fortune_shop_create_flags(context)
    if not (context and context.create_shop_card and context.set == 'Joker') then return nil end
    if not (G and G.GAME and G.GAME.hnds_ms_fortune_shop_active) then return nil end


    if pseudorandom('hnds_ms_fortune_shop_replace') < (1 / MS_FORTUNE_SHOP_ODDS) then
        return {
            key = MS_FORTUNE_KEY,
            area = context.area or G.shop_jokers,
            key_append = 'hnds_ms_fortune_shop_replace',
        }
    end
end

SMODS.Joker({
    key = "ms_fortune",
    unlocked = false,
    discovered = false,
    unlock_condition = { type = "hnds_joker_unlock", key = "ms_fortune" },
    locked_loc_vars = function(self)
        return HNDS.joker_locked_loc_vars("ms_fortune")
    end,
    check_for_unlock = function(self, args)
        return HNDS.joker_unlock_condition_met("ms_fortune", args)
    end,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    config = { extra = { sell_gain = MS_FORTUNE_SELL_GAIN } },
    loc_vars = function(self, info_queue, card)


        local in_collection = card and card.area and card.area.config
            and card.area.config.collection
        if in_collection and info_queue then


            _G.HNDS_CURRENT_CURSE_CARD = nil
            info_queue[#info_queue + 1] = { set = 'Other', key = 'hnds_cursed' }
        end
        return { vars = { card.ability.extra.sell_gain } }
    end,
    rarity = 3,
    cost = 10,
    atlas = "Jokers",
    pos = { x = 1, y = 1 },

    set_ability = function(self, card, initial, delay_sprites)
        if G and G.STAGES and G.STAGE == G.STAGES.RUN then
            HNDS.ms_fortune_ensure_cursed(card)
            HNDS.ms_fortune_sync_sell_value(card)
        end
    end,

    update = function(self, card, dt)
        local in_collection = card and card.area and card.area.config
            and card.area.config.collection
        if in_collection then
            local has_cursed = (card.ability and card.ability.hnds_cursed)
                or (card.stickers and card.stickers.hnds_cursed)
                or (card.ability and card.ability.stickers
                    and card.ability.stickers.hnds_cursed)
            if not has_cursed then return end

            if card.remove_sticker then
                card:remove_sticker('hnds_cursed')
            end
            if card.ability then
                card.ability.hnds_cursed = nil
                card.ability.hnds_curse = nil
                card.ability.hnds_curse_offer = nil
                card.ability.hnds_curse_price = nil
                if card.ability.stickers then
                    card.ability.stickers.hnds_cursed = nil
                end
            end
            if card.stickers then
                card.stickers.hnds_cursed = nil
            end
            return
        end

        if G and G.GAME and G.jokers and card and card.area == G.jokers and not card.debuff then
            local token = tostring(card.ID or card.sort_id or card)
            if not card.ability or card.ability.hnds_ms_fortune_claim_token ~= token then
                HNDS.ms_fortune_obtained(card, false)
            else
                G.GAME.hnds_ms_fortune_shop_active = true
                HNDS.ms_fortune_sync_sell_value(card)
            end
        end
    end,

    add_to_deck = function(self, card, from_debuff)
        HNDS.ms_fortune_obtained(card, from_debuff)
    end,

    attributes = { "economy", "generation" },
})
