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

local FUN_POLICE_RANKS = {
    { id = 2, label = '2s' },
    { id = 3, label = '3s' },
    { id = 4, label = '4s' },
    { id = 5, label = '5s' },
    { id = 6, label = '6s' },
    { id = 7, label = '7s' },
    { id = 8, label = '8s' },
    { id = 9, label = '9s' },
    { id = 10, label = '10s' },
    { id = 11, label = 'Jacks' },
    { id = 12, label = 'Queens' },
    { id = 13, label = 'Kings' },
    { id = 14, label = 'Aces' },
}

local function hnds_fun_police_extra(card)
    local extra = card and card.ability and card.ability.extra
    if type(extra) ~= 'table' then
        extra = {}
        if card and card.ability then card.ability.extra = extra end
    end
    extra.rank_index = math.floor(tonumber(extra.rank_index) or 1)
    if extra.rank_index < 1 or extra.rank_index > #FUN_POLICE_RANKS then extra.rank_index = 1 end
    extra.cards_drawn = tonumber(extra.cards_drawn) or 0
    extra.cards_per_rank = 4
    return extra
end

local function hnds_fun_police_rank(extra)
    return FUN_POLICE_RANKS[extra.rank_index]
end

local function hnds_fun_police_matches(card, rank)
    return card and not card.debuff and type(card.get_id) == 'function' and card:get_id() == rank.id
end

local function hnds_fun_police_destroy_rank(rank)
    if not (G and G.hand and type(G.hand.cards) == 'table') then return 0 end
    local targets = {}
    for _, playing_card in ipairs(G.hand.cards) do
        if hnds_fun_police_matches(playing_card, rank) then targets[#targets + 1] = playing_card end
    end
    if #targets > 0 and SMODS and type(SMODS.destroy_cards) == 'function' then SMODS.destroy_cards(targets) end
    return #targets
end

SMODS.Joker {
    key = 'fun_police',
    atlas = 'fun_police',
    pos = { x = 0, y = 0 },
    sprite_args = { start_pos = { x = 0, y = 0 }, frames = 180, fps = 24 },
    pixel_size = { w = 95, h = 71 },
    display_size = { w = 95, h = 71 },
    rarity = 3,
    cost = 8,
    unlocked = true,
    discovered = false,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    config = { extra = { rank_index = 1, cards_drawn = 0, cards_per_rank = 4 } },
    loc_vars = function(self, info_queue, card)
        local extra = hnds_fun_police_extra(card)
        local rank = hnds_fun_police_rank(extra)
        local remaining = math.max(1, extra.cards_per_rank - extra.cards_drawn)
        return { vars = { rank.label, extra.cards_per_rank, remaining } }
    end,
    set_sprites = function(self, card, front) hnds_fun_police_reset_animation(card) end,
    set_ability = function(self, card, initial, delay_sprites) hnds_fun_police_reset_animation(card) end,
    load = function(self, card, card_table, other_card) hnds_fun_police_reset_animation(card) end,
    calculate = function(self, card, context)
        if context.hand_drawn and type(context.hand_drawn) == 'table' and not context.blueprint then
            local extra = hnds_fun_police_extra(card)
            local rank = hnds_fun_police_rank(extra)
            local count = 0
            for _, playing_card in ipairs(context.hand_drawn) do
                if hnds_fun_police_matches(playing_card, rank) then count = count + 1 end
            end
            if count > 0 then
                extra.cards_drawn = extra.cards_drawn + count
                if extra.cards_drawn >= extra.cards_per_rank then
                    extra.cards_drawn = 0
                    hnds_fun_police_destroy_rank(rank)
                    extra.rank_index = extra.rank_index % #FUN_POLICE_RANKS + 1
                    return { message = localize('k_hnds_rank_up'), colour = G.C.RED }
                end
            end
        end
    end,
    attributes = { 'rank', 'destroy' },
}
