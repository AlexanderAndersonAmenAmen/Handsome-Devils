SMODS.Atlas {
    key = 'fun_police',
    path = 'FunPoliceFrame.png',
    px = 95,
    py = 71,
    disable_mipmap = true,
}

local mod_path = SMODS.current_mod.path
local FRAME_ASPECT = 95 / 71
local set_sprites_ref = Card.set_sprites

function Card:set_sprites(center, ...)
    if center then
        local landscape = center.key == 'j_hnds_fun_police'
            and (center.discovered or self.bypass_discovery_center
                or (self.params and self.params.bypass_discovery_center))
        local transform = self.T
        local ratio = transform.w / transform.h
        if landscape and math.abs(ratio - FRAME_ASPECT) > 0.001 then
            local height = transform.h
            transform.w = height
            transform.h = height / FRAME_ASPECT
            self.hnds_fun_police_landscape = true
        elseif not landscape and self.hnds_fun_police_landscape then
            if math.abs(ratio - FRAME_ASPECT) < 0.001 then
                transform.w, transform.h = transform.h, transform.w
            end
            self.hnds_fun_police_landscape = nil
        end
        if self.hnds_fun_police_landscape and self.VT then
            self.VT.w, self.VT.h = transform.w, transform.h
        end
    end
    return set_sprites_ref(self, center, ...)
end

local function fun_police_renderer(atlas)
    local width, height = atlas.image:getPixelDimensions()
    local scale = width == 190 and 2 or 1
    local filesystem = SMODS.NFS or NFS
    local path = mod_path .. 'assets/' .. scale .. 'x/FunPolice.png'
    local file = filesystem and filesystem.newFileData(path)
    if not file then return end

    local sheet = love.image.newImageData(file)
    local sheet_width, sheet_height = sheet:getDimensions()
    if sheet_width ~= width * 10 or sheet_height ~= height * 18 then return end

    local renderer = {
        image = atlas.image,
        sheet = sheet,
        frame_data = love.image.newImageData(width, height),
        width = width,
        height = height,
        started = G.TIMERS.REAL,
        frame = 0,
    }
    atlas.hnds_fun_police_renderer = renderer
    return renderer
end

function HNDS.animate_fun_police(card)
    local atlas = G.ASSET_ATLAS and G.ASSET_ATLAS.hnds_fun_police
    local sprite = card.children and card.children.center
    if not (atlas and atlas.image and sprite and sprite.atlas == atlas and card.area) then return end
    if card.states.visible == false or card.sprite_facing == 'back' then return end

    local now = G.TIMERS.REAL
    local renderer = atlas.hnds_fun_police_renderer
    if not renderer or renderer.image ~= atlas.image then
        if atlas.hnds_fun_police_failed_image == atlas.image then return end
        renderer = fun_police_renderer(atlas)
        if not renderer then
            atlas.hnds_fun_police_failed_image = atlas.image
            return
        end
        atlas.hnds_fun_police_failed_image = nil
    end
    if now < renderer.started then renderer.started = now end
    local frame = math.floor((now - renderer.started) * 24) % 180
    if renderer.frame == frame then return end

    local width, height = renderer.width, renderer.height
    renderer.frame_data:paste(renderer.sheet, 0, 0,
        frame % 10 * width, math.floor(frame / 10) * height, width, height)
    renderer.image:replacePixels(renderer.frame_data, 1, 1, 0, 0, true)
    renderer.frame = frame
end

local FP_SLOTS = 5
local function fp_is(card)
    return card and card.config and card.config.center
        and card.config.center.key == 'j_hnds_fun_police'
end

local function fp_safe_slots(area)
    if #area.cards <= FP_SLOTS then return math.huge end
    local reserved = 0
    for _, joker in ipairs(area.cards) do
        if fp_is(joker) then reserved = reserved + FP_SLOTS end
    end
    if reserved == 0 then return math.huge end
    return math.max(FP_SLOTS, (tonumber(area.config.card_limit) or 0) - reserved)
end

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
        local safe_slots = fp_safe_slots(G.jokers)
        for index, joker in ipairs(G.jokers.cards) do
            -- Only refresh cards whose Fun Police slot status actually changed.
            -- Blindly recalculating all debuffs each move replays add/remove
            -- aura hooks (hands, discards, etc.), causing exploits and stutter.
            local reserved = index > safe_slots
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
    local area = G and G.jokers
    if not area or area.hnds_fp_refresh_pending then return end
    area.hnds_fp_refresh_pending = true
    if G and G.E_MANAGER and Event then
        G.E_MANAGER:add_event(Event({ trigger = 'after', delay = 0, func = function()
            area.hnds_fp_refresh_pending = nil
            if G.jokers == area then fp_refresh() end
            return true
        end }))
    else
        area.hnds_fp_refresh_pending = nil
        fp_refresh()
    end
end

local prior_debuff = SMODS.current_mod.set_debuff
SMODS.current_mod.set_debuff = function(card)
    if prior_debuff then
        local state = prior_debuff(card)
        if state == true or state == 'prevent_debuff' then return state end
    end
    local area = G and G.jokers
    if not (card and area and card.area == area and area.cards) then return end
    local safe_slots = fp_safe_slots(area)
    for index = safe_slots + 1, #area.cards do
        if area.cards[index] == card then return true end
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
    rarity = 3, cost = 10, unlocked = true, discovered = false,
    blueprint_compat = false, eternal_compat = true, perishable_compat = true,
    config = { extra = {} },
    loc_vars = function(self, info_queue, card) return { vars = { FP_SLOTS } } end,
    load = function(self, card)
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
    update = function(self, card)
        local area = G.jokers
        if not (area and area.cards and card.area == area) then return end
        fp_sync_slots(card)

        local now = G.TIMERS.REAL
        if area.hnds_fp_scan_time == now then return end
        area.hnds_fp_scan_time = now
        local cards = area.cards
        local previous = area.hnds_fp_order
        if not previous then
            previous = setmetatable({}, { __mode = 'v' })
            area.hnds_fp_order = previous
        end
        local count = area.hnds_fp_count or 0
        local limit = area.config.card_limit
        local changed = count ~= #cards or area.hnds_fp_limit ~= limit
        for i, joker in ipairs(cards) do
            if previous[i] ~= joker then
                previous[i] = joker
                changed = true
            end
        end
        for i = #cards + 1, count do previous[i] = nil end
        area.hnds_fp_count = #cards
        area.hnds_fp_limit = limit
        if changed then fp_refresh() end
    end,
    attributes = { 'debuff', 'destroy' },
}
