SMODS.Atlas {
    key = 'fun_police',
    path = 'FunPolice.png',
    px = 95,
    py = 71,
    frames = 180,
    fps = 24,
    atlas_table = 'ANIMATION_ATLAS',
}

local FUN_POLICE_COLUMNS = 10
local FUN_POLICE_ROWS = 18
local FUN_POLICE_FRAMES = FUN_POLICE_COLUMNS * FUN_POLICE_ROWS
local FUN_POLICE_FPS = 24

local function hnds_is_fun_police_atlas(atlas)
    if not atlas then return false end
    local name = tostring(atlas.name or atlas.key or ''):lower()
    return name == 'hnds_fun_police' or name == 'fun_police' or name:find('hnds_fun_police', 1, true) ~= nil
end

if AnimatedSprite and type(AnimatedSprite.animate) == 'function'
    and not AnimatedSprite._hnds_fun_police_multiline_animation
then
    AnimatedSprite._hnds_fun_police_multiline_animation = true
    local animated_sprite_animate_ref = AnimatedSprite.animate
    function AnimatedSprite:animate(...)
        if not hnds_is_fun_police_atlas(self.atlas) then return animated_sprite_animate_ref(self, ...) end
        -- Collection previews have no gameplay animation state; skip the 24 FPS
        -- viewport churn when this Joker is displayed in a collection grid.
        local major = self.role and self.role.draw_major
        if major and major.area and major.area.config and major.area.config.collection then return end
        if not (self.sprite and self.atlas and self.atlas.image) then return end
        local now = G and G.TIMERS and G.TIMERS.REAL or 0
        local start = tonumber(self.offset_seconds) or now
        local elapsed = math.max(0, now - start)
        local frame = math.floor(elapsed * FUN_POLICE_FPS) % FUN_POLICE_FRAMES
        if self._hnds_fun_police_frame ~= frame then
            self._hnds_fun_police_frame = frame
            local x = frame % FUN_POLICE_COLUMNS
            local y = math.floor(frame / FUN_POLICE_COLUMNS)
            local w = self.animation and self.animation.w or self.scale and self.scale.x or self.atlas.px
            local h = self.animation and self.animation.h or self.scale and self.scale.y or self.atlas.py
            self.frame_offset = x * w
            self.sprite:setViewport(x * w, y * h, w, h)
            self.animation = self.animation or {}
            self.animation.x = x
            self.animation.y = y
            self.animation.frames = FUN_POLICE_FRAMES
            self.current_animation = self.current_animation or {}
            self.current_animation.current = x
            self.current_animation.frames = FUN_POLICE_FRAMES
            self.current_animation.w = w
            self.current_animation.h = h
        end
        if self.float and G and G.TIMERS then
            self.T.r = 0.02 * math.sin(2 * G.TIMERS.REAL + self.T.x)
            self.offset = self.offset or { x = 0, y = 0 }
            self.shadow_parrallax = self.shadow_parrallax or { x = 0, y = 0 }
            self.offset.y = -(1 + 0.3 * math.sin(0.666 * G.TIMERS.REAL + self.T.y)) * self.shadow_parrallax.y
            self.offset.x = -(0.7 + 0.2 * math.sin(0.666 * G.TIMERS.REAL + self.T.x)) * self.shadow_parrallax.x
        end
    end
end

local function hnds_fun_police_reset_animation(card)
    local sprite = card and card.children and card.children.center
    if not (sprite and hnds_is_fun_police_atlas(sprite.atlas)) then return end
    sprite.offset_seconds = G and G.TIMERS and G.TIMERS.REAL or 0
    sprite._hnds_fun_police_frame = nil
    local w = sprite.animation and sprite.animation.w or sprite.scale and sprite.scale.x or sprite.atlas.px
    local h = sprite.animation and sprite.animation.h or sprite.scale and sprite.scale.y or sprite.atlas.py
    if sprite.sprite and w and h then sprite.sprite:setViewport(0, 0, w, h) end
    if sprite.animation then sprite.animation.x = 0; sprite.animation.y = 0 end
    if sprite.current_animation then sprite.current_animation.current = 0 end
end

-- Five actual Joker slots are added by each Fun Police. The original five
-- occupied positions are always safe, even with fewer than five Jokers.
local FP_SLOTS = 5
local function fp_is(card)
    return card and card.config and card.config.center
        and card.config.center.key == 'j_hnds_fun_police'
end

local fp_reserved_index
local fp_previous_membership = setmetatable({}, { __mode = 'k' })

local function fp_refresh()
    if not (G and G.jokers and G.jokers.cards and SMODS and SMODS.recalc_debuff) then return end
    if HNDS._fp_refreshing then return end
    HNDS._fp_refreshing = true
    -- Snapshot the remaining resources before *all* debuffs are recalculated.
    -- In particular, a Joker leaving a debuffed slot must not instantly refund
    -- hands/discards that were already unavailable during the current round.
    local round = G.GAME and G.GAME.current_round
    local hands_before = round and tonumber(round.hands_left)
    local discards_before = round and tonumber(round.discards_left)
    local ok, err = pcall(function()
        for _, joker in ipairs(G.jokers.cards) do
            -- Only refresh cards whose Fun Police slot status actually changed.
            -- Blindly recalculating all debuffs each move replays add/remove
            -- aura hooks (hands, discards, etc.), causing exploits and stutter.
            local reserved = fp_reserved_index(joker)
            if fp_previous_membership[joker] == nil
                or fp_previous_membership[joker] ~= reserved then
                fp_previous_membership[joker] = reserved
                SMODS.recalc_debuff(joker)
            end
            -- Defend against debuff hooks that grant resources immediately,
            -- including chained hooks from third-party aura Jokers.
            if round then
                if hands_before and tonumber(round.hands_left)
                    and round.hands_left > hands_before then
                    round.hands_left = hands_before
                end
                if discards_before and tonumber(round.discards_left)
                    and round.discards_left > discards_before then
                    round.discards_left = discards_before
                end
            end
        end
    end)
    HNDS._fp_refreshing = false
    if not ok then error(err, 0) end
end

local function fp_refresh_after_removal()
    if HNDS._fp_refresh_after_removal then return end
    HNDS._fp_refresh_after_removal = true
    if G and G.E_MANAGER and Event then
        G.E_MANAGER:add_event(Event({ trigger = 'after', delay = 0, func = function()
            HNDS._fp_refresh_after_removal = false
            fp_refresh()
            return true
        end }))
    else
        HNDS._fp_refresh_after_removal = false
        fp_refresh()
    end
end

local function fp_active_count()
    local total = 0
    for _, joker in ipairs((G and G.jokers and G.jokers.cards) or {}) do
        if fp_is(joker) then total = total + 1 end
    end
    return total
end

fp_reserved_index = function(joker)
    local cards = G and G.jokers and G.jokers.cards or {}
    local limit = G and G.jokers and G.jokers.config and tonumber(G.jokers.config.card_limit) or 0
    local reserved = fp_active_count() * FP_SLOTS
    if reserved == 0 or #cards <= 5 then return false end
    local safe_slots = math.max(5, limit - reserved)
    for i, current in ipairs(cards) do
        if current == joker then return i > safe_slots end
    end
    return false
end

local prior_debuff = SMODS.current_mod.set_debuff
SMODS.current_mod.set_debuff = function(card)
    if prior_debuff then
        local state = prior_debuff(card)
        if state == true or state == 'prevent_debuff' then return state end
    end
    if card and card.area == (G and G.jokers) and fp_reserved_index(card) then
        return true
    end
end

local function fp_sync_slots(card)
    if not (card and G and G.jokers and G.jokers.config and card.ability) then return end
    local desired = card.area == G.jokers and FP_SLOTS or 0
    local current = tonumber(card.ability.hnds_fun_police_slots_applied) or 0
    if desired ~= current then
        G.jokers.config.card_limit = math.max(0, G.jokers.config.card_limit + desired - current)
        card.ability.hnds_fun_police_slots_applied = desired
        fp_refresh()
    end
end

local function fp_destroy_reserve(card)
    if not (G and G.jokers and G.jokers.cards) then return end
    local cards = G.jokers.cards
    local start = math.max(1, (G.jokers.config.card_limit or #cards) - FP_SLOTS + 1)
    local victims = {}
    for i = start, #cards do
        if cards[i] and cards[i] ~= card then victims[#victims+1] = cards[i] end
    end
    for _, target in ipairs(victims) do
        if SMODS and SMODS.destroy_cards then SMODS.destroy_cards(target)
        elseif target.start_dissolve then target:start_dissolve() end
    end
end

SMODS.Joker {
    key = 'fun_police', atlas = 'fun_police', pos = { x = 0, y = 0 },
    sprite_args = { start_pos = { x = 0, y = 0 }, frames = 180, fps = 24 },
    pixel_size = { w = 95, h = 71 }, display_size = { w = 95, h = 71 },
    rarity = 3, cost = 10, unlocked = true, discovered = false,
    blueprint_compat = false, eternal_compat = true, perishable_compat = true,
    config = { extra = {} },
    loc_vars = function(self, info_queue, card) return { vars = { FP_SLOTS } } end,
    set_sprites = function(self, card) hnds_fun_police_reset_animation(card) end,
    set_ability = function(self, card) hnds_fun_police_reset_animation(card) end,
    load = function(self, card)
        hnds_fun_police_reset_animation(card)
        -- Save state carries the existing card_limit; restore the applied flag.
        card.ability.hnds_fun_police_slots_applied = tonumber(card.ability.hnds_fun_police_slots_applied) or 0
    end,
    add_to_deck = function(self, card, from_debuff)
        fp_sync_slots(card)
    end,
    remove_from_deck = function(self, card, from_debuff)
        -- Debuff transitions are not loss of the source Joker: keep its slots
        -- reserved until it actually leaves the Joker area.
        if from_debuff then return end
        fp_destroy_reserve(card)
        local applied = card.ability and tonumber(card.ability.hnds_fun_police_slots_applied) or 0
        if G and G.jokers and G.jokers.config then
            G.jokers.config.card_limit = math.max(0, G.jokers.config.card_limit - applied)
        end
        if card.ability then card.ability.hnds_fun_police_slots_applied = 0 end
        fp_refresh_after_removal()
    end,
    update = function(self, card, dt)
        if not (G and G.jokers and card.area == G.jokers) then return end
        fp_sync_slots(card)
        local ids = {}
        for i, joker in ipairs(G.jokers.cards) do
            ids[#ids+1] = tostring(joker.sort_id or joker.ID or joker) .. ':' .. tostring(joker.debuff)
        end
        local signature = table.concat(ids, '|')
        if card.ability.hnds_fp_signature ~= signature then
            card.ability.hnds_fp_signature = signature
            fp_refresh()
        end
    end,
    attributes = { 'debuff', 'destroy' },
}
