HNDS = HNDS or {}

local LEGACY_DETERMINATION_KEY = 'hnds_determination'
local BASE_ATLAS = 'Jokers'
local BOSS_ATLAS = 'BadTime'
local BASE_POS = { x = 3, y = 8 }
local QUARTER_TURN = math.pi * 0.5
local FLIP_DURATION = 0.28
local scored_nines = setmetatable({}, { __mode = 'k' })

local function bad_time_is_boss_blind(blind)
    blind = blind or (G and G.GAME and G.GAME.blind)
    if not blind then return false end
    if blind.boss then return true end
    local center = blind.config and (blind.config.blind or blind.config.center)
    return center and center.boss and true or false
end

local function bad_time_is_nine(card)
    if not card then return false end
    if type(card.get_id) == 'function' then
        local ok, id = pcall(card.get_id, card)
        if ok then return id == 9 end
    end
    local base = card.base
    return base and (tonumber(base.id) == 9 or tostring(base.value) == '9') or false
end

local function bad_time_reset_scored(source)
    if not source then return end
    scored_nines[source] = {
        cards = {},
        seen = setmetatable({}, { __mode = 'k' }),
    }
end

local function bad_time_remember_nine(source, playing_card)
    if not (source and playing_card) then return end
    local pending = scored_nines[source]
    if not pending then
        bad_time_reset_scored(source)
        pending = scored_nines[source]
    end
    if pending.seen[playing_card] then return end
    pending.seen[playing_card] = true
    pending.cards[#pending.cards + 1] = playing_card
end

local function bad_time_clear_legacy_determination()
    for _, playing_card in ipairs((G and G.playing_cards) or {}) do
        local ability = playing_card and playing_card.ability
        if ability and ability[LEGACY_DETERMINATION_KEY] ~= nil then
            ability[LEGACY_DETERMINATION_KEY] = nil
            playing_card.ability_UIBox_table = nil
            if playing_card.config then
                playing_card.config.h_popup = nil
                playing_card.config.h_popup_config = nil
            end
        end
    end
end

local function bad_time_apply_red_seals(cards)
    local sealed = 0
    for _, playing_card in ipairs(cards or {}) do
        if playing_card and not playing_card.removed and not playing_card.REMOVED
            and type(playing_card.set_seal) == 'function'
        then
            if playing_card.ability then
                playing_card.ability[LEGACY_DETERMINATION_KEY] = nil
            end
            playing_card:set_seal('Red', nil, true)
            sealed = sealed + 1
        end
    end
    return sealed
end

local function bad_time_report_red_seals(card)
    if not (card and not card.removed and not card.REMOVED
        and type(card_eval_status_text) == 'function')
    then
        return
    end
    card_eval_status_text(card, 'extra', nil, nil, nil, {
        message = localize('k_hnds_red_seal'),
        colour = G.C.RED,
    })
end

local function bad_time_atlas(short_key)
    local prefixed = 'hnds_' .. short_key
    if SMODS and type(SMODS.get_atlas) == 'function' then
        local atlas = SMODS.get_atlas(prefixed) or SMODS.get_atlas(short_key)
        if atlas then return atlas end
    end
    return G and G.ASSET_ATLAS and (G.ASSET_ATLAS[prefixed] or G.ASSET_ATLAS[short_key]) or nil
end

local function bad_time_visual_active(card)
    local extra = card and card.ability and card.ability.extra
    return type(extra) == 'table' and extra.boss_visual == true
end

local function bad_time_target_rotation(active)
    return active and QUARTER_TURN or 0
end

local function bad_time_set_rotation(sprite, angle)
    if not sprite then return end
    if sprite.T then sprite.T.r = angle end
    if sprite.VT then sprite.VT.r = angle end
end

local function bad_time_apply_sprite(card)
    local sprite = card and card.children and card.children.center
    if not sprite then return false end
    local active = bad_time_visual_active(card)
    local atlas = bad_time_atlas(active and BOSS_ATLAS or BASE_ATLAS)
    if not atlas then return false end
    sprite.atlas = atlas
    local pos = active and { x = 0, y = 0 } or { x = BASE_POS.x, y = BASE_POS.y }
    if type(sprite.set_sprite_pos) == 'function' then
        sprite:set_sprite_pos(pos)
    else
        sprite.sprite_pos = pos
    end
    bad_time_set_rotation(sprite, bad_time_target_rotation(active))
    return true
end

local function bad_time_finish_flip(card, active)
    local extra = card and card.ability and card.ability.extra
    if type(extra) == 'table' then extra.boss_visual = active == true end
    bad_time_apply_sprite(card)
end

local function bad_time_begin_flip(card, active)
    if not card then return end
    active = active == true
    local state = card.hnds_bad_time_flip
    if state and state.target == active then return end
    card.hnds_bad_time_flip = nil
    if bad_time_visual_active(card) == active then
        bad_time_apply_sprite(card)
        return
    end
    local sprite = card.children and card.children.center
    if not (sprite and sprite.T) then
        bad_time_finish_flip(card, active)
        return
    end
    local current_active = bad_time_visual_active(card)
    local current_rotation = sprite.VT and tonumber(sprite.VT.r)
        or sprite.T and tonumber(sprite.T.r)
        or bad_time_target_rotation(current_active)
    card.hnds_bad_time_flip = {
        target = active,
        elapsed = 0,
        from = current_rotation,
        to = bad_time_target_rotation(active),
    }
end

local function bad_time_advance_flip(card, dt)
    local state = card and card.hnds_bad_time_flip
    if not state then return end
    local sprite = card.children and card.children.center
    if not (sprite and sprite.T) then
        bad_time_finish_flip(card, state.target)
        card.hnds_bad_time_flip = nil
        return
    end

    state.elapsed = state.elapsed + math.max(0, tonumber(dt) or 0)
    local progress = math.min(1, state.elapsed / FLIP_DURATION)
    bad_time_set_rotation(sprite, state.from + (state.to - state.from) * progress)
    if progress >= 1 then
        card.hnds_bad_time_flip = nil
        bad_time_finish_flip(card, state.target)
    end
end

SMODS.Joker {
    key = 'bad_time',
    atlas = BASE_ATLAS,
    pos = BASE_POS,
    rarity = 2,
    cost = 4,
    unlocked = true,
    discovered = false,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    config = { extra = { boss_visual = false } },

    set_sprites = function(self, card, front)
        bad_time_apply_sprite(card)
    end,

    add_to_deck = function(self, card, from_debuff)
        if not from_debuff then bad_time_clear_legacy_determination() end
    end,

    load = function(self, card, card_table, other_card)
        card.hnds_bad_time_flip = nil
        card.hnds_bad_time_round_ending = nil
        scored_nines[card] = nil
        bad_time_clear_legacy_determination()
        bad_time_apply_sprite(card)
    end,

    remove_from_deck = function(self, card, from_debuff)
        scored_nines[card] = nil
    end,

    update = function(self, card, dt)
        if card and card.area and card.area.config and card.area.config.collection then return end
        bad_time_advance_flip(card, dt)
        if card.hnds_bad_time_flip or not (G and card.area == G.jokers) then return end

        bad_time_set_rotation(
            card.children and card.children.center,
            bad_time_target_rotation(bad_time_visual_active(card))
        )

        local blind = G.GAME and G.GAME.blind
        if card.hnds_bad_time_round_ending then
            if not (blind and blind.in_blind) then card.hnds_bad_time_round_ending = nil end
            return
        end

        local should_be_active = blind and blind.in_blind and bad_time_is_boss_blind(blind) or false
        if bad_time_visual_active(card) ~= should_be_active then
            bad_time_begin_flip(card, should_be_active)
        end
    end,

    calculate = function(self, card, context)
        if not context.blueprint then
            if context.setting_blind then
                card.hnds_bad_time_round_ending = nil
                bad_time_begin_flip(card, bad_time_is_boss_blind(context.blind))
            elseif context.end_of_round and context.main_eval then
                card.hnds_bad_time_round_ending = true
                bad_time_begin_flip(card, false)
            end
        end

        if context.repetition and context.cardarea == G.play
            and context.other_card and not context.other_card.debuff
            and bad_time_is_nine(context.other_card)
        then
            return {
                repetitions = 1,
                message = localize('k_again_ex'),
                card = context.blueprint_card or card,
            }
        end

        if context.before and context.cardarea == G.jokers and not context.blueprint then
            bad_time_reset_scored(card)
            return
        end

        if context.individual and context.cardarea == G.play and context.other_card
            and not context.blueprint
            and not context.repetition and not context.repetition_only
            and not context.other_card.debuff and bad_time_is_nine(context.other_card)
        then
            bad_time_remember_nine(card, context.other_card)
            return
        end

        if context.after and not context.blueprint then
            local pending = scored_nines[card]
            scored_nines[card] = nil
            if not (pending and #pending.cards > 0 and SMODS.last_hand_oneshot
                and bad_time_is_boss_blind())
            then
                return
            end

            local cards = pending.cards
            if G and G.E_MANAGER and Event then
                local source = card
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.15,
                    func = function()
                        if bad_time_apply_red_seals(cards) > 0 then
                            bad_time_report_red_seals(source)
                        end
                        return true
                    end,
                }))
                return
            end

            local sealed = bad_time_apply_red_seals(cards)
            if sealed == 0 then return end
            return {
                message = localize('k_hnds_red_seal'),
                colour = G.C.RED,
                card = card,
            }
        end
    end,

    attributes = { 'rank', 'retrigger', 'modify_card', 'boss_blind' },
}
