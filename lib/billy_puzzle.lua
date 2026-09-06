HNDS = HNDS or {}

local unpack_values = (table and table.unpack) or unpack
local PUZZLE_KEY = 'hnds_sarmenti_puzzle'
local MASK_KEYS = {
    [1] = 'hnds_billy_mask_tl',
    [2] = 'hnds_billy_mask_tr',
    [3] = 'hnds_billy_mask_bl',
    [4] = 'hnds_billy_mask_br',
}
local PUZZLE_UNDERLAY_ATLAS = 'hnds_PuzzleUnderlay'
local puzzle_underlay_sprite
local ADJACENT = {
    [1] = { [2] = true, [3] = true },
    [2] = { [1] = true, [4] = true },
    [3] = { [1] = true, [4] = true },
    [4] = { [2] = true, [3] = true },
}

local hnds_destroy

local function hnds_copy(value, seen)
    if type(value) ~= 'table' then return value end
    seen = seen or {}
    if seen[value] then return seen[value] end
    local out = {}
    seen[value] = out
    for k, v in pairs(value) do
        out[hnds_copy(k, seen)] = hnds_copy(v, seen)
    end
    return setmetatable(out, getmetatable(value))
end

local function hnds_center_key(card)
    return card and card.config and card.config.center and card.config.center.key
end

local function hnds_is_joker(card)
    local center = card and card.config and card.config.center
    return center and center.set == 'Joker'
end

local PUZZLE_PIECE_BLOCKLIST = {
    j_hnds_wait_what = true,
}

local function hnds_can_be_puzzle_piece(card)
    return hnds_is_joker(card) and not PUZZLE_PIECE_BLOCKLIST[hnds_center_key(card)]
end

local function hnds_puzzle(card)
    return card and card.ability and card.ability[PUZZLE_KEY]
end

function HNDS.is_sarmenti_piece(card)
    return type(hnds_puzzle(card)) == 'table'
end

local function hnds_draw_puzzle_underlay(card)
    if not (card and card.children and card.children.center) then return end
    if card.facing ~= 'front' or card.sprite_facing ~= 'front' then return end

    if not puzzle_underlay_sprite then
        if not (SMODS and type(SMODS.create_sprite) == 'function'
            and G and G.ASSET_ATLAS and G.ASSET_ATLAS[PUZZLE_UNDERLAY_ATLAS])
        then
            return
        end
        puzzle_underlay_sprite = SMODS.create_sprite(
            0, 0, G.CARD_W, G.CARD_H,
            PUZZLE_UNDERLAY_ATLAS, { x = 0, y = 0 }
        )
    end

    if puzzle_underlay_sprite.role then puzzle_underlay_sprite.role.draw_major = card end
    puzzle_underlay_sprite:draw_shader('dissolve', nil, nil, nil, card.children.center)
end

local function hnds_next_piece_order()
    if not (G and G.GAME) then return 1 end
    G.GAME.hnds_sarmenti_piece_order = (tonumber(G.GAME.hnds_sarmenti_piece_order) or 0) + 1
    return G.GAME.hnds_sarmenti_piece_order
end

local function hnds_is_runtime_atlas_name(name)
    return type(name) == 'string' and name:match('^hnds_billy_runtime_') ~= nil
end

local function hnds_resolve_atlas_name(name)
    if type(name) ~= 'string' then return nil end
    if G and G.ASSET_ATLAS then
        if G.ASSET_ATLAS[name] then return name end
        if G.ASSET_ATLAS['hnds_' .. name] then return 'hnds_' .. name end
    end
    return name
end

local function hnds_sprite_layer(sprite)
    if not (sprite and sprite.atlas) then return nil end
    local atlas_name = sprite.atlas.name
    local pos = sprite.sprite_pos or sprite.pos
    if not atlas_name or hnds_is_runtime_atlas_name(atlas_name) or type(pos) ~= 'table' then return nil end
    return {
        atlas = atlas_name,
        pos = { x = tonumber(pos.x) or 0, y = tonumber(pos.y) or 0 },
    }
end

local function hnds_center_art(center)
    local layers = {}
    if not center then return layers end
    local atlas_name = hnds_resolve_atlas_name(center.atlas)
    if atlas_name and not hnds_is_runtime_atlas_name(atlas_name) then
        layers[#layers + 1] = {
            atlas = atlas_name,
            pos = hnds_copy(center.pos or { x = 0, y = 0 }),
        }
        if center.soul_pos then
            local soul_atlas = hnds_resolve_atlas_name(center.soul_atlas or center.atlas) or atlas_name
            if not hnds_is_runtime_atlas_name(soul_atlas) then
                layers[#layers + 1] = {
                    atlas = soul_atlas,
                    pos = hnds_copy(center.soul_pos),
                }
            end
        end
    end
    return layers
end

local function hnds_snapshot_art(card)
    local layers = hnds_center_art(card and card.config and card.config.center)
    if #layers > 0 then return layers end

    if card and card.children then
        local center = hnds_sprite_layer(card.children.center)
        if center then layers[#layers + 1] = center end
        local floating = hnds_sprite_layer(card.children.floating_sprite)
        if floating then layers[#layers + 1] = floating end
    end
    return layers
end

local function hnds_snapshot_primary(card)
    local puzzle = hnds_puzzle(card)
    if not puzzle then return nil end
    local ability = hnds_copy(card.ability or {})
    ability[PUZZLE_KEY] = nil
    return {
        piece = puzzle.primary_piece,
        order = puzzle.primary_order,
        center_key = puzzle.primary_center_key or hnds_center_key(card),
        ability = ability,
        edition = hnds_copy(puzzle.primary_edition),
        art = hnds_copy(puzzle.primary_art or hnds_snapshot_art(card)),
        base_cost = card.base_cost,
        extra_cost = card.extra_cost,
        cost = card.cost,
        sell_cost = puzzle.primary_sell_cost ~= nil and puzzle.primary_sell_cost or card.sell_cost,
        sell_cost_label = puzzle.primary_sell_cost_label ~= nil and puzzle.primary_sell_cost_label or card.sell_cost_label,
    }
end

local function hnds_snapshot_component(card, piece, order)
    local ability = hnds_copy(card and card.ability or {})
    ability[PUZZLE_KEY] = nil
    return {
        piece = piece,
        order = order,
        center_key = hnds_center_key(card),
        ability = ability,
        edition = hnds_copy(card and card.edition),
        art = hnds_snapshot_art(card),
        base_cost = card and card.base_cost,
        extra_cost = card and card.extra_cost,
        cost = card and card.cost,
        sell_cost = card and card.sell_cost,
        sell_cost_label = card and card.sell_cost_label,
    }
end

local function hnds_piece_set(card)
    local set = {}
    local puzzle = hnds_puzzle(card)
    if not puzzle then return set end
    if puzzle.primary_piece then set[puzzle.primary_piece] = true end
    for _, snap in ipairs(puzzle.components or {}) do
        if snap.piece then set[snap.piece] = true end
    end
    return set
end

function HNDS.sarmenti_piece_count(card)
    local n = 0
    for _ in pairs(hnds_piece_set(card)) do n = n + 1 end
    return n
end

function HNDS.sarmenti_current_progress()
    local best = 0
    for _, joker in ipairs((G and G.jokers and G.jokers.cards) or {}) do
        if HNDS.is_sarmenti_piece(joker) and not joker.hnds_sarmenti_removed then
            best = math.max(best, HNDS.sarmenti_piece_count(joker))
        end
    end
    return math.min(4, best)
end

local function hnds_compatible_groups(a, b)
    if not (HNDS.is_sarmenti_piece(a) and HNDS.is_sarmenti_piece(b)) or a == b then return false end
    local pa, pb = hnds_piece_set(a), hnds_piece_set(b)
    for piece in pairs(pa) do
        if pb[piece] then return false end
    end
    for piece_a in pairs(pa) do
        for piece_b in pairs(pb) do
            if ADJACENT[piece_a] and ADJACENT[piece_a][piece_b] then return true end
        end
    end
    return false
end

function HNDS.sarmenti_piece_can_attach(card)
    if not (HNDS.is_sarmenti_piece(card) and G and G.jokers and G.jokers.cards) then return false end
    for _, joker in ipairs(G.jokers.cards) do
        if joker ~= card and not joker.hnds_sarmenti_removed and hnds_compatible_groups(card, joker) then
            return true
        end
    end
    return false
end

local function hnds_primary_order(card)
    local puzzle = hnds_puzzle(card)
    return puzzle and (tonumber(puzzle.primary_order) or math.huge) or math.huge
end

local function hnds_atlas(name)
    if not (G and G.ASSET_ATLAS and type(name) == 'string') then return nil end
    return G.ASSET_ATLAS[name] or G.ASSET_ATLAS['hnds_' .. name]
end

local function hnds_source_tile(layer)
    local atlas = layer and hnds_atlas(layer.atlas)
    if not (atlas and atlas.image and love and love.graphics) then return nil end
    local px = tonumber(atlas.px) or 71
    local py = tonumber(atlas.py) or 95
    local pos = layer.pos or { x = 0, y = 0 }
    local iw, ih = atlas.image:getDimensions()
    local x, y = (tonumber(pos.x) or 0) * px, (tonumber(pos.y) or 0) * py
    if x + px > iw or y + py > ih then return nil end
    local quad = love.graphics.newQuad(x, y, px, py, iw, ih)
    return atlas.image, quad, px, py
end

local function hnds_mask_shader()
    return G and G.SHADERS and (G.SHADERS.hnds_billy_mask or G.SHADERS.billy_mask)
end

local function hnds_mask_atlas(piece)
    local key = MASK_KEYS[piece]
    return key and hnds_atlas(key)
end

local function hnds_runtime_atlas_name(card)
    return 'hnds_billy_runtime_' .. tostring(card and (card.sort_id or card.ID) or 'card')
end

local hnds_composite_cards = setmetatable({}, { __mode = 'k' })

local function hnds_release_graphics_object(object)
    if not object or type(object.release) ~= 'function' then return end
    local ok, released = pcall(function()
        return type(object.isReleased) == 'function' and object:isReleased()
    end)
    if not ok or not released then pcall(object.release, object) end
end

function HNDS.sarmenti_release_composite(card)
    if not card then return end
    local canvas = card.hnds_sarmenti_composite_canvas
    local atlas_name = hnds_runtime_atlas_name(card)
    local atlas = G and G.ASSET_ATLAS and G.ASSET_ATLAS[atlas_name]

    local center_sprite = card.children and card.children.center
    if center_sprite and center_sprite.atlas and hnds_is_runtime_atlas_name(center_sprite.atlas.name) then
        local center = card.config and card.config.center
        local source_atlas = center and hnds_atlas(center.atlas)
        if source_atlas and not hnds_is_runtime_atlas_name(source_atlas.name) then
            center_sprite.atlas = source_atlas
            if center_sprite.set_sprite_pos then
                center_sprite:set_sprite_pos(center.pos or { x = 0, y = 0 })
            else
                center_sprite.sprite_pos = center.pos or { x = 0, y = 0 }
            end
        end
    end

    if atlas and (not canvas or atlas.image == canvas) then
        G.ASSET_ATLAS[atlas_name] = nil
    end
    hnds_release_graphics_object(canvas)
    card.hnds_sarmenti_composite_canvas = nil
    hnds_composite_cards[card] = nil
end

function HNDS.sarmenti_cleanup_runtime_atlases()
    if not (G and G.ASSET_ATLAS) then return end
    for card in pairs(hnds_composite_cards) do
        HNDS.sarmenti_release_composite(card)
    end
    for key, atlas in pairs(G.ASSET_ATLAS) do
        if hnds_is_runtime_atlas_name(key) then
            hnds_release_graphics_object(atlas and atlas.image)
            G.ASSET_ATLAS[key] = nil
        end
    end
end

function HNDS.sarmenti_rebuild_composite(card)
    local puzzle = hnds_puzzle(card)
    if not (puzzle and card and card.children and card.children.center and love and love.graphics) then return false end
    local shader = hnds_mask_shader()
    local first_mask = hnds_mask_atlas(1)
    if not (shader and first_mask and first_mask.image) then return false end

    if type(puzzle.primary_art) ~= 'table' or #puzzle.primary_art == 0 then
        puzzle.primary_art = hnds_center_art(card.config and card.config.center)
    end
    for _, snap in ipairs(puzzle.components or {}) do
        if type(snap.art) ~= 'table' or #snap.art == 0 then
            local center = snap.center_key and G and G.P_CENTERS and G.P_CENTERS[snap.center_key]
            snap.art = hnds_center_art(center)
        end
    end

    local w, h = first_mask.image:getDimensions()
    if not (w and h and w > 0 and h > 0) then return false end

    local final = love.graphics.newCanvas(w, h)
    local temporary_canvases = {}
    final:setFilter('nearest', 'nearest')
    local drew_any = false
    love.graphics.push('all')
    local ok = pcall(function()
        love.graphics.setCanvas(final)
        love.graphics.clear(0, 0, 0, 0)
        love.graphics.setColor(1, 1, 1, 1)

        local pieces = {
            { piece = puzzle.primary_piece, art = puzzle.primary_art },
        }
        for _, snap in ipairs(puzzle.components or {}) do
            pieces[#pieces + 1] = { piece = snap.piece, art = snap.art }
        end
        table.sort(pieces, function(a, b) return (tonumber(a.piece) or 9) < (tonumber(b.piece) or 9) end)

        for _, entry in ipairs(pieces) do
            local mask = hnds_mask_atlas(entry.piece)
            if mask and mask.image and type(entry.art) == 'table' and #entry.art > 0 then
                local temp = love.graphics.newCanvas(w, h)
                temporary_canvases[#temporary_canvases + 1] = temp
                temp:setFilter('nearest', 'nearest')
                love.graphics.setCanvas(temp)
                love.graphics.clear(0, 0, 0, 0)
                love.graphics.setShader()
                love.graphics.setColor(1, 1, 1, 1)

                local drew_piece = false
                for _, layer in ipairs(entry.art) do
                    local image, quad, sw, sh = hnds_source_tile(layer)
                    if image and quad then
                        love.graphics.draw(image, quad, 0, 0, 0, w / sw, h / sh)
                        drew_piece = true
                    end
                end

                if drew_piece then
                    love.graphics.setCanvas(final)
                    love.graphics.setShader(shader)
                    shader:send('puzzle_mask', mask.image)
                    love.graphics.setColor(1, 1, 1, 1)
                    love.graphics.draw(temp, 0, 0)
                    love.graphics.setShader()
                    drew_any = true
                end
            end
        end
    end)
    love.graphics.pop()
    for _, temp in ipairs(temporary_canvases) do
        hnds_release_graphics_object(temp)
    end
    if not ok or not drew_any then
        hnds_release_graphics_object(final)
        return false
    end

    local atlas_name = hnds_runtime_atlas_name(card)
    local runtime_atlas = {
        name = atlas_name,
        image = final,
        px = w,
        py = h,
    }
    local old_canvas = card.hnds_sarmenti_composite_canvas
    G.ASSET_ATLAS[atlas_name] = runtime_atlas
    card.hnds_sarmenti_composite_canvas = final
    hnds_composite_cards[card] = true
    card.children.center.atlas = runtime_atlas
    if card.children.center.set_sprite_pos then
        card.children.center:set_sprite_pos({ x = 0, y = 0 })
    else
        card.children.center.sprite_pos = { x = 0, y = 0 }
    end
    if old_canvas and old_canvas ~= final then
        hnds_release_graphics_object(old_canvas)
    end
    card.hnds_sarmenti_composite_dirty = nil
    return true
end

local function hnds_strip_piece_spawn_modifiers(card)
    if not card then return end
    card.ability = card.ability or {}

    if card.edition ~= nil then
        if type(card.set_edition) == 'function' then
            pcall(card.set_edition, card, nil, true, true)
        else
            card.edition = nil
        end
    end
    card.edition = nil

    local keys = { perishable = true, eternal = true, rental = true }
    if SMODS and SMODS.Sticker and type(SMODS.Sticker.obj_buffer) == 'table' then
        for _, key in ipairs(SMODS.Sticker.obj_buffer) do keys[key] = true end
    end
    if type(card.stickers) == 'table' then
        for key in pairs(card.stickers) do keys[key] = true end
    end
    if type(card.ability.stickers) == 'table' then
        for key in pairs(card.ability.stickers) do keys[key] = true end
    end

    for key in pairs(keys) do
        if type(card.remove_sticker) == 'function' then pcall(card.remove_sticker, card, key) end
        if type(card.stickers) == 'table' then card.stickers[key] = nil end
        if type(card.ability.stickers) == 'table' then card.ability.stickers[key] = nil end
        card.ability[key] = nil
    end
    card.ability.perishable = nil
    card.ability.eternal = nil
    card.ability.rental = nil
    if type(card.set_sticker_display) == 'function' then pcall(card.set_sticker_display, card) end
end

local function hnds_mark_piece(card, piece)
    if not (card and hnds_can_be_puzzle_piece(card) and not HNDS.is_sarmenti_piece(card)) then return false end
    hnds_strip_piece_spawn_modifiers(card)
    card.ability = card.ability or {}
    card.ability[PUZZLE_KEY] = {
        primary_piece = piece,
        primary_order = hnds_next_piece_order(),
        primary_center_key = hnds_center_key(card),
        primary_edition = nil,
        primary_art = hnds_snapshot_art(card),
        primary_sell_cost = 1 + (tonumber(card.ability.extra_value) or 0),
        primary_sell_cost_label = 1 + (tonumber(card.ability.extra_value) or 0),
        components = {},
        rounds_remaining = 2,
        expired = false,
        completed = false,
    }
    card.hnds_sarmenti_composite_dirty = true
    HNDS.sarmenti_rebuild_composite(card)
    if type(card.set_cost) == 'function' then card:set_cost() end
    return true
end

local function hnds_random_piece(card)
    local seed = 'hnds_sarmenti_piece_' .. tostring(G and G.GAME and (G.GAME.hnds_sarmenti_piece_order or 0) or 0)
        .. '_' .. tostring(card and (card.sort_id or card.ID) or 0)
    if pseudorandom_element and pseudoseed then
        local piece = pseudorandom_element({ 1, 2, 3, 4 }, pseudoseed(seed))
        if piece then return piece end
    end
    return math.max(1, math.min(4, math.floor((pseudorandom and pseudorandom(seed) or math.random()) * 4) + 1))
end

local SARMENTI_SHOP_PIECE_ODDS = 2

function HNDS.billy_try_roll_shop_card(target, source_billy)
    if not (G and G.GAME and target and hnds_can_be_puzzle_piece(target)) then return false end
    if G.shop_jokers and target.area and target.area ~= G.shop_jokers then return false end
    if HNDS.is_sarmenti_piece(target) then return false end

    target.ability = target.ability or {}
    if target.ability.hnds_sarmenti_shop_piece_roll_checked then return false end
    target.ability.hnds_sarmenti_shop_piece_roll_checked = true

    local roll = pseudorandom and pseudorandom('hnds_sarmenti_shop_piece') or math.random()
    if roll >= (1 / SARMENTI_SHOP_PIECE_ODDS) then return false end
    local marked = hnds_mark_piece(target, hnds_random_piece(target))
    if marked then
        local puzzle = hnds_puzzle(target)
        if puzzle then puzzle.source_billy_id = source_billy and (source_billy.sort_id or source_billy.ID) or nil end
    end
    return marked
end

local function hnds_remove_billy_after_completion()
    local targets = {}
    for _, joker in ipairs((G and G.jokers and G.jokers.cards) or {}) do
        if joker and not joker.REMOVED and not joker.removed and hnds_center_key(joker) == 'j_billy' then
            targets[#targets + 1] = joker
        end
    end
    if #targets == 0 then return 0 end

    local function remove_all()
        for _, joker in ipairs(targets) do
            if joker and not joker.REMOVED and not joker.removed then hnds_destroy(joker) end
        end
        return true
    end
    if G and G.E_MANAGER and Event then
        G.E_MANAGER:add_event(Event({ trigger = 'after', delay = 0.12, blockable = false, func = remove_all }))
    else
        remove_all()
    end
    return #targets
end

local function hnds_component_center(snap)
    return snap and snap.center_key and G and G.P_CENTERS and G.P_CENTERS[snap.center_key]
end

local function hnds_hydrate_component_snapshot(snap)
    if not snap then return snap end
    snap.ability = snap.ability or {}
    local center = hnds_component_center(snap)
    local cfg = center and center.config
    if type(cfg) == 'table' then
        for key, value in pairs(cfg) do
            if snap.ability[key] == nil then snap.ability[key] = hnds_copy(value) end
        end
    end
    if center then
        if snap.ability.set == nil then snap.ability.set = center.set or 'Joker' end
        if snap.ability.name == nil and center.name then snap.ability.name = center.name end
    end
    return snap
end

local function hnds_with_component(card, snap, callback)
    if not (card and snap and type(callback) == 'function') then return callback and callback() end
    hnds_hydrate_component_snapshot(snap)
    local config = card.config or {}
    local saved = {
        ability = card.ability,
        edition = card.edition,
        center = config.center,
        center_key = config.center_key,
        base_cost = card.base_cost,
        extra_cost = card.extra_cost,
        cost = card.cost,
        sell_cost = card.sell_cost,
        sell_cost_label = card.sell_cost_label,
        added_to_deck = card.added_to_deck,
    }

    card.ability = snap.ability or {}
    card.edition = hnds_copy(snap.edition)
    config.center = hnds_component_center(snap) or config.center
    config.center_key = snap.center_key or config.center_key
    card.base_cost = snap.base_cost
    card.extra_cost = snap.extra_cost
    card.cost = snap.cost
    card.sell_cost = snap.sell_cost
    card.sell_cost_label = snap.sell_cost_label
    card.hnds_sarmenti_component_guard = true
    card.hnds_sarmenti_component_snapshot = snap

    local packed = HNDS.pack(pcall(callback))
    local n = packed.n

    snap.ability = card.ability or snap.ability
    snap.edition = hnds_copy(card.edition)
    snap.base_cost = card.base_cost
    snap.extra_cost = card.extra_cost
    snap.cost = card.cost
    snap.sell_cost = card.sell_cost
    snap.sell_cost_label = card.sell_cost_label

    card.ability = saved.ability
    card.edition = saved.edition
    config.center = saved.center
    config.center_key = saved.center_key
    card.base_cost = saved.base_cost
    card.extra_cost = saved.extra_cost
    card.cost = saved.cost
    card.sell_cost = saved.sell_cost
    card.sell_cost_label = saved.sell_cost_label
    card.added_to_deck = saved.added_to_deck
    card.hnds_sarmenti_component_guard = nil
    card.hnds_sarmenti_component_snapshot = nil

    if not packed[1] then error(packed[2], 0) end
    return unpack_values(packed, 2, n)
end

HNDS.sarmenti_with_component = hnds_with_component

local function hnds_edition_center(edition)
    if type(edition) ~= 'table' or not (G and G.P_CENTERS) then return nil end
    if edition.key and G.P_CENTERS[edition.key] then return G.P_CENTERS[edition.key] end
    local typ = edition.type
    if typ and G.P_CENTERS['e_' .. tostring(typ)] then return G.P_CENTERS['e_' .. tostring(typ)] end
    for _, center in ipairs((G.P_CENTER_POOLS and G.P_CENTER_POOLS.Edition) or {}) do
        if center and center.key then
            local short = center.key:gsub('^e_', '')
            if edition[short] or edition[center.key] or typ == short then return center end
        end
    end
    for key, value in pairs(edition) do
        if value == true and type(key) == 'string' then
            if G.P_CENTERS['e_' .. key] then return G.P_CENTERS['e_' .. key] end
        end
    end
end

local function hnds_edition_short_key(edition)
    if type(edition) ~= 'table' then return nil end
    local center = hnds_edition_center(edition)
    if center and center.key then return center.key:gsub('^e_', '') end
    if type(edition.key) == 'string' then return edition.key:gsub('^e_', '') end
    if type(edition.type) == 'string' then return edition.type:gsub('^e_', '') end
    for key, value in pairs(edition) do
        if value == true and type(key) == 'string' then
            return key:gsub('^e_', '')
        end
    end
end

local EDITION_WEIGHT_FALLBACK = {
    negative = -1000000,
    polychrome = 3,
    poly = 3,
    vintage = 7,
    holo = 14,
    holographic = 14,
    foil = 20,
}

local function hnds_edition_weight(edition)
    local short = hnds_edition_short_key(edition)
    if short == 'negative' or (type(edition) == 'table' and edition.negative) then
        return -1000000
    end
    local center = hnds_edition_center(edition)
    local weight = center and tonumber(center.weight)
    if weight then return weight end
    return (short and EDITION_WEIGHT_FALLBACK[short]) or math.huge
end

local function hnds_visual_edition(card)
    local puzzle = hnds_puzzle(card)
    if not puzzle then return card and card.edition end
    local editions = { puzzle.primary_edition }
    for _, snap in ipairs(puzzle.components or {}) do editions[#editions + 1] = snap.edition end

    local best, best_weight
    for _, edition in ipairs(editions) do
        if type(edition) == 'table' then
            local weight = hnds_edition_weight(edition)
            if weight <= -1000000 then return hnds_copy(edition) end
            if not best or weight < best_weight then
                best, best_weight = edition, weight
            end
        end
    end
    return hnds_copy(best)
end

function HNDS.sarmenti_refresh_visual_edition(card)
    if not HNDS.is_sarmenti_piece(card) then return end
    card.edition = hnds_visual_edition(card)
end

local function hnds_sync_single_primary_sell(card)
    local puzzle = hnds_puzzle(card)
    if not puzzle or #(puzzle.components or {}) > 0 then return end
    puzzle.primary_sell_cost = card.sell_cost
    puzzle.primary_sell_cost_label = card.sell_cost_label
end

local function hnds_component_list_from_card(card)
    local puzzle = hnds_puzzle(card)
    if not puzzle then return {} end
    local list = {}
    local primary = hnds_snapshot_primary(card)
    if primary then list[#list + 1] = primary end
    for _, snap in ipairs(puzzle.components or {}) do list[#list + 1] = hnds_copy(snap) end
    return list
end

hnds_destroy = function(card)
    if not card or card.hnds_sarmenti_removed then return end
    card.hnds_sarmenti_removed = true

    if card.added_to_deck and type(card.remove_from_deck) == 'function' then
        pcall(card.remove_from_deck, card)
    end

    local area = card.area
    if area and type(area.remove_card) == 'function' then
        pcall(area.remove_card, area, card)
    end

    if type(card.remove) == 'function' then
        pcall(card.remove, card)
    elseif type(card.start_dissolve) == 'function' then
        pcall(card.start_dissolve, card, nil, true)
    end
end

local HNDS_SARMENTI_EFFECT_REFERENCE_KEYS = {
    card = true,
    juice_card = true,
    message_card = true,
    focus = true,
    other_card = true,
    scoring_card = true,
    copied_card = true,
}

local function hnds_is_x_effect_key(key)
    local lower = type(key) == 'string' and key:lower() or ''
    return lower:match('^x_') ~= nil
        or lower:find('x_mult', 1, true) ~= nil
        or lower:find('xmult', 1, true) ~= nil
        or lower:find('x_chips', 1, true) ~= nil
        or lower:find('xchips', 1, true) ~= nil
        or lower:find('x_score', 1, true) ~= nil
        or lower:find('xscore', 1, true) ~= nil
end

local function hnds_merge_effect_value(dst, src, key)
    if src == nil then return dst end
    if dst == nil then
        if HNDS_SARMENTI_EFFECT_REFERENCE_KEYS[key] then return src end
        if type(src) == 'table' then
            if getmetatable(src) ~= nil and key ~= nil then return src end
            local out = {}
            for k, v in pairs(src) do out[k] = hnds_merge_effect_value(nil, v, k) end
            return setmetatable(out, getmetatable(src))
        end
        return src
    end
    local td, ts = type(dst), type(src)
    if td == 'number' and ts == 'number' then
        if hnds_is_x_effect_key(key) then return dst * src end
        return dst + src
    end
    if td == 'boolean' and ts == 'boolean' then return dst or src end
    if td == 'function' and ts == 'function' then
        return function(...)
            local a = dst(...)
            local b = src(...)
            if a == false or b == false then return false end
            return a ~= nil and a or b
        end
    end
    if td == 'table' and ts == 'table' then
        if key == 'colour' or key == 'color' or HNDS_SARMENTI_EFFECT_REFERENCE_KEYS[key] then return dst end
        if getmetatable(dst) ~= nil or getmetatable(src) ~= nil then
            local ok, combined
            if hnds_is_x_effect_key(key) then
                ok, combined = pcall(function() return dst * src end)
            else
                ok, combined = pcall(function() return dst + src end)
            end
            if ok then return combined end
            return dst
        end
        local out = {}
        for k, v in pairs(dst) do out[k] = hnds_merge_effect_value(nil, v, k) end
        for k, v in pairs(src) do out[k] = hnds_merge_effect_value(out[k], v, k) end
        return out
    end
    return dst
end

local function hnds_merge_packed_results(base, extra)
    local n = math.max(base.n or #base, extra.n or #extra)
    base.n = n
    for i = 1, n do
        if i == 1 and type(extra[i]) == 'table' then
            base[i] = hnds_merge_effect_value(base[i], extra[i], nil)
        elseif base[i] == nil then
            base[i] = hnds_copy(extra[i])
        elseif type(base[i]) == 'boolean' and type(extra[i]) == 'boolean' then
            base[i] = base[i] or extra[i]
        elseif type(base[i]) == 'number' and type(extra[i]) == 'number' then
            base[i] = base[i] + extra[i]
        elseif type(base[i]) == 'table' and type(extra[i]) == 'table' then
            base[i] = hnds_merge_effect_value(base[i], extra[i], nil)
        end
    end
    return base
end

local function hnds_status(card, count)
    if not card or card.hnds_sarmenti_removed then return end
    local message = count >= 4 and 'Completed!' or (tostring(count) .. '/4')
    if card_eval_status_text then
        card_eval_status_text(card, 'extra', nil, nil, nil, {
            message = message,
            colour = count >= 4 and (G.C.GREEN or G.C.FILTER) or G.C.BLUE,
        })
    end
end

local function hnds_snap_remove(card, survivor)
    if not card or card.hnds_sarmenti_removed then return end
    card.hnds_sarmenti_removed = true
    if survivor and card.T and survivor.T then
        card.T.x, card.T.y = survivor.T.x, survivor.T.y
        if card.VT and survivor.VT then
            card.VT.x, card.VT.y = survivor.VT.x, survivor.VT.y
        end
    end
    if card.added_to_deck and card.remove_from_deck then card:remove_from_deck() end
    local area = card.area
    if area and type(area.remove_card) == 'function' then
        pcall(area.remove_card, area, card)
    end
    if card.remove then card:remove() end
end

local function hnds_fuse_two(a, b)
    if not hnds_compatible_groups(a, b) then return a end
    local survivor, victim = a, b
    if hnds_primary_order(b) < hnds_primary_order(a) then survivor, victim = b, a end
    local survivor_puzzle = hnds_puzzle(survivor)
    if not survivor_puzzle then return a end

    hnds_sync_single_primary_sell(survivor)
    hnds_sync_single_primary_sell(victim)
    local incoming = hnds_component_list_from_card(victim)
    hnds_snap_remove(victim, survivor)

    survivor_puzzle.components = survivor_puzzle.components or {}
    for _, snap in ipairs(incoming) do
        survivor_puzzle.components[#survivor_puzzle.components + 1] = snap
        if survivor.added_to_deck and HNDS._sarmenti_apply_component_add then
            HNDS._sarmenti_apply_component_add(survivor, snap)
        end
    end

    table.sort(survivor_puzzle.components, function(x, y)
        return (tonumber(x.order) or math.huge) < (tonumber(y.order) or math.huge)
    end)
    survivor_puzzle.rounds_remaining = 2
    survivor_puzzle.expired = false
    HNDS.sarmenti_refresh_visual_edition(survivor)
    if HNDS.sarmenti_refresh_sell_cost then HNDS.sarmenti_refresh_sell_cost(survivor) end
    if SMODS and type(SMODS.recalc_debuff) == 'function' then pcall(SMODS.recalc_debuff, survivor) end
    survivor.hnds_sarmenti_composite_dirty = true
    HNDS.sarmenti_rebuild_composite(survivor)
    if survivor.juice_up then survivor:juice_up(0.4, 0.4) end
    return survivor
end

local function hnds_fuse_all(card)
    local current = card
    local changed = true
    while changed and current and not current.hnds_sarmenti_removed do
        changed = false
        for _, other in ipairs((G and G.jokers and G.jokers.cards) or {}) do
            if other ~= current and not other.hnds_sarmenti_removed and hnds_compatible_groups(current, other) then
                current = hnds_fuse_two(current, other)
                changed = true
                break
            end
        end
    end
    return current
end

function HNDS.sarmenti_handle_bought_piece(card)
    if not (card and HNDS.is_sarmenti_piece(card) and not card.hnds_sarmenti_removed) then return end
    hnds_sync_single_primary_sell(card)
    local result = hnds_fuse_all(card)
    if not result or result.hnds_sarmenti_removed then return end
    local count = HNDS.sarmenti_piece_count(result)
    hnds_status(result, count)
    if count >= 4 then
        local puzzle = hnds_puzzle(result)
        if puzzle then
            puzzle.completed = true
            puzzle.expired = false
            puzzle.rounds_remaining = 2
        end
        if SMODS and type(SMODS.recalc_debuff) == 'function' then pcall(SMODS.recalc_debuff, result) end
        if HNDS.play_billy_sound then HNDS.play_billy_sound() end
        hnds_remove_billy_after_completion()
    end
end

local function hnds_append_component_tooltip(full_UI_table, card, snap)
    if not (full_UI_table and card and snap and type(generate_card_ui) == 'function') then return end
    local center = hnds_component_center(snap)
    if not center then return end
    hnds_with_component(card, snap, function()
        local loc_vars, main_start, main_end
        if type(card.generate_UIBox_ability_table) == 'function' then
            loc_vars, main_start, main_end = card:generate_UIBox_ability_table(true)
        end
        generate_card_ui(center, full_UI_table, loc_vars, 'Joker', nil, nil, main_start, main_end, card)
    end)
end

local function hnds_append_edition_tooltips(full_UI_table, card)
    local puzzle = hnds_puzzle(card)
    if not (puzzle and full_UI_table and type(generate_card_ui) == 'function') then return end

    local visual_center = hnds_edition_center(card.edition)
    local visual_key = visual_center and visual_center.key
    local skipped_visual = false
    local editions = { puzzle.primary_edition }
    for _, snap in ipairs(puzzle.components or {}) do editions[#editions + 1] = snap.edition end

    for _, edition in ipairs(editions) do
        local center = hnds_edition_center(edition)
        if center and center.key then
            if visual_key and center.key == visual_key and not skipped_visual then
                skipped_visual = true
            else
                generate_card_ui(center, full_UI_table, nil, 'Edition', nil, nil, nil, nil, card)
            end
        end
    end
end

if Card then
    if type(Card.remove) == 'function' and not Card._hnds_sarmenti_remove_wrapped then
        Card._hnds_sarmenti_remove_wrapped = true
        local remove_ref = Card.remove
        function Card:remove(...)
            HNDS.sarmenti_release_composite(self)
            return remove_ref(self, ...)
        end
    end

    if type(Card.draw) == 'function' and not Card._hnds_sarmenti_draw_wrapped then
        Card._hnds_sarmenti_draw_wrapped = true
        local draw_ref = Card.draw
        function Card:draw(...)
            if HNDS.is_sarmenti_piece(self) then
                if self.hnds_sarmenti_composite_dirty or not self.hnds_sarmenti_composite_canvas then
                    HNDS.sarmenti_rebuild_composite(self)
                end
                local has_composite = self.hnds_sarmenti_composite_canvas ~= nil
                    and self.children and self.children.center and self.children.center.atlas
                    and hnds_is_runtime_atlas_name(self.children.center.atlas.name)
                local floating = self.children and self.children.floating_sprite
                local old_visible = floating and floating.states and floating.states.visible
                if has_composite and floating and floating.states then floating.states.visible = false end
                hnds_draw_puzzle_underlay(self)
                local packed = HNDS.pack(draw_ref(self, ...))
                if has_composite and floating and floating.states then floating.states.visible = old_visible end
                return unpack_values(packed, 1, packed.n)
            end
            return draw_ref(self, ...)
        end
    end

    if type(Card.set_sprites) == 'function' and not Card._hnds_sarmenti_sprites_wrapped then
        Card._hnds_sarmenti_sprites_wrapped = true
        local set_sprites_ref = Card.set_sprites
        function Card:set_sprites(...)
            local packed = HNDS.pack(set_sprites_ref(self, ...))

            if self.hnds_sarmenti_component_guard then
                local snap = self.hnds_sarmenti_component_snapshot
                local art = hnds_snapshot_art(self)
                if snap and type(art) == 'table' and #art > 0 then snap.art = art end
                self.hnds_sarmenti_component_visual_dirty = true
            elseif HNDS.is_sarmenti_piece(self) then
                local puzzle = hnds_puzzle(self)
                local art = hnds_snapshot_art(self)
                if puzzle and type(art) == 'table' and #art > 0 then puzzle.primary_art = art end
                self.hnds_sarmenti_composite_dirty = true
                HNDS.sarmenti_rebuild_composite(self)
            end

            return unpack_values(packed, 1, packed.n)
        end
    end

    if type(Card.update) == 'function' and not Card._hnds_sarmenti_update_wrapped then
        Card._hnds_sarmenti_update_wrapped = true
        local update_ref = Card.update
        function Card:update(dt, ...)
            if self.hnds_sarmenti_component_guard or not HNDS.is_sarmenti_piece(self) then
                return update_ref(self, dt, ...)
            end

            local before_sell = self.sell_cost
            local before_label = self.sell_cost_label
            self.hnds_sarmenti_set_cost_during_update = nil
            local result = HNDS.pack(update_ref(self, dt, ...))
            local puzzle = hnds_puzzle(self)
            if not puzzle then return unpack_values(result, 1, result.n) end

            if not self.hnds_sarmenti_set_cost_during_update
                and (self.sell_cost ~= before_sell or self.sell_cost_label ~= before_label)
            then
                puzzle.primary_sell_cost = self.sell_cost
                puzzle.primary_sell_cost_label = self.sell_cost_label
            end
            self.hnds_sarmenti_set_cost_during_update = nil

            for _, snap in ipairs(puzzle.components or {}) do
                local center = hnds_component_center(snap)
                if center and type(center.update) == 'function' then
                    hnds_with_component(self, snap, function()
                        center:update(self, dt)
                    end)
                end
            end

            if self.hnds_sarmenti_component_visual_dirty then
                self.hnds_sarmenti_component_visual_dirty = nil
                self.hnds_sarmenti_composite_dirty = true
            end
            if self.hnds_sarmenti_composite_dirty or not self.hnds_sarmenti_composite_canvas then
                HNDS.sarmenti_rebuild_composite(self)
            end
            if HNDS.sarmenti_refresh_sell_cost then
                HNDS.sarmenti_refresh_sell_cost(self)
            end
            return unpack_values(result, 1, result.n)
        end
    end

    if type(Card.calculate_joker) == 'function' and not Card._hnds_sarmenti_calculate_wrapped then
        Card._hnds_sarmenti_calculate_wrapped = true
        local calculate_ref = Card.calculate_joker
        function Card:calculate_joker(context, ...)
            if self.hnds_sarmenti_component_guard or not HNDS.is_sarmenti_piece(self) then
                return calculate_ref(self, context, ...)
            end
            local args = HNDS.pack(...)
            local result = HNDS.pack(calculate_ref(self, context, unpack_values(args, 1, args.n)))
            local puzzle = hnds_puzzle(self)
            for _, snap in ipairs((puzzle and puzzle.components) or {}) do
                local extra = HNDS.pack(hnds_with_component(self, snap, function()
                    return calculate_ref(self, context, unpack_values(args, 1, args.n))
                end))
                hnds_merge_packed_results(result, extra)
            end

            if puzzle and context and context.end_of_round and context.main_eval
                and not context.blueprint and not context.repetition and not puzzle.completed
            then
                puzzle.rounds_remaining = math.max(0, (tonumber(puzzle.rounds_remaining) or 2) - 1)
                if puzzle.rounds_remaining <= 0 and not puzzle.expired then
                    puzzle.expired = true
                    if G and G.E_MANAGER and Event and SMODS and type(SMODS.recalc_debuff) == 'function' then
                        local puzzle_card = self
                        G.E_MANAGER:add_event(Event({
                            trigger = 'after', delay = 0, blockable = false,
                            func = function()
                                if puzzle_card and HNDS.is_sarmenti_piece(puzzle_card) then
                                    pcall(SMODS.recalc_debuff, puzzle_card)
                                end
                                return true
                            end,
                        }))
                    elseif SMODS and type(SMODS.recalc_debuff) == 'function' then
                        pcall(SMODS.recalc_debuff, self)
                    end
                end
            end

            if self.hnds_sarmenti_cost_dirty and HNDS.sarmenti_refresh_sell_cost then
                self.hnds_sarmenti_cost_dirty = nil
                HNDS.sarmenti_refresh_sell_cost(self)
            end
            return unpack_values(result, 1, result.n)
        end
    end

    if type(Card.add_to_deck) == 'function' and not Card._hnds_sarmenti_add_wrapped then
        Card._hnds_sarmenti_add_wrapped = true
        local add_ref = Card.add_to_deck

        local function apply_component_add(card, snap, from_debuff)
            if not (card and snap) then return end
            hnds_with_component(card, snap, function()
                local old_added = card.added_to_deck
                card.added_to_deck = false
                add_ref(card, from_debuff and true or false)
                card.added_to_deck = old_added
            end)
        end
        HNDS._sarmenti_apply_component_add = apply_component_add

        function Card:add_to_deck(from_debuff, ...)
            if self.hnds_sarmenti_component_guard or not HNDS.is_sarmenti_piece(self) then
                return add_ref(self, from_debuff, ...)
            end
            local puzzle = hnds_puzzle(self)
            local visual = self.edition
            self.edition = hnds_copy(puzzle.primary_edition)
            local result = HNDS.pack(add_ref(self, from_debuff, ...))
            puzzle.primary_edition = hnds_copy(self.edition)
            self.edition = visual

            for _, snap in ipairs(puzzle.components or {}) do apply_component_add(self, snap, from_debuff) end
            HNDS.sarmenti_refresh_visual_edition(self)
            self.hnds_sarmenti_composite_dirty = true

            if not from_debuff and G and G.STATE and G.STATES and G.STATE == G.STATES.SHOP
                and not self.hnds_sarmenti_purchase_queued and G.E_MANAGER and Event
            then
                self.hnds_sarmenti_purchase_queued = true
                local purchased = self
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.18,
                    func = function()
                        purchased.hnds_sarmenti_purchase_queued = nil
                        if purchased and not purchased.hnds_sarmenti_removed
                            and HNDS.is_sarmenti_piece(purchased)
                            and G.jokers and purchased.area == G.jokers
                        then
                            HNDS.sarmenti_handle_bought_piece(purchased)
                        end
                        return true
                    end,
                }))
            end
            return unpack_values(result, 1, result.n)
        end
    end

    if type(Card.remove_from_deck) == 'function' and not Card._hnds_sarmenti_remove_wrapped then
        Card._hnds_sarmenti_remove_wrapped = true
        local remove_ref = Card.remove_from_deck
        function Card:remove_from_deck(from_debuff, ...)
            if self.hnds_sarmenti_component_guard or not HNDS.is_sarmenti_piece(self) then
                return remove_ref(self, from_debuff, ...)
            end
            local puzzle = hnds_puzzle(self)
            for i = #(puzzle.components or {}), 1, -1 do
                local snap = puzzle.components[i]
                hnds_with_component(self, snap, function()
                    local old_added = self.added_to_deck
                    self.added_to_deck = true
                    remove_ref(self, from_debuff and true or false)
                    self.added_to_deck = old_added
                end)
            end
            local visual = self.edition
            self.edition = hnds_copy(puzzle.primary_edition)
            local result = HNDS.pack(remove_ref(self, from_debuff, ...))
            puzzle.primary_edition = hnds_copy(self.edition)
            self.edition = visual
            return unpack_values(result, 1, result.n)
        end
    end

    if type(Card.set_cost) == 'function' and not Card._hnds_sarmenti_cost_wrapped then
        Card._hnds_sarmenti_cost_wrapped = true
        local set_cost_ref = Card.set_cost

        local function hnds_apply_piece_discount(card)
            if not card then return end
            card.cost = 1
            local extra_value = tonumber(card.ability and card.ability.extra_value) or 0
            card.sell_cost = math.max(1, 1 + extra_value)
            card.sell_cost_label = card.facing == 'back' and '?' or card.sell_cost
        end

        function HNDS.sarmenti_refresh_sell_cost(card)
            local puzzle = hnds_puzzle(card)
            if not (card and puzzle) then return end

            local primary_sell = tonumber(puzzle.primary_sell_cost)
            if primary_sell == nil then primary_sell = tonumber(card.sell_cost) or 0 end
            local primary_label = tonumber(puzzle.primary_sell_cost_label)
            if primary_label == nil then primary_label = primary_sell end

            local total_sell, total_label = primary_sell, primary_label
            for _, snap in ipairs(puzzle.components or {}) do
                total_sell = total_sell + (tonumber(snap.sell_cost) or 0)
                total_label = total_label
                    + (tonumber(snap.sell_cost_label) or tonumber(snap.sell_cost) or 0)
            end

            card.sell_cost = total_sell
            card.sell_cost_label = total_label
            HNDS.sarmenti_refresh_visual_edition(card)
        end

        function Card:set_cost(...)
            if self.hnds_sarmenti_primary_edition_guard then
                return set_cost_ref(self, ...)
            end

            if self.hnds_sarmenti_component_guard then
                local result = HNDS.pack(set_cost_ref(self, ...))
                hnds_apply_piece_discount(self)
                self.hnds_sarmenti_cost_dirty = true
                self.hnds_sarmenti_set_cost_during_update = true
                return unpack_values(result, 1, result.n)
            end

            if not HNDS.is_sarmenti_piece(self) then return set_cost_ref(self, ...) end
            local puzzle = hnds_puzzle(self)
            local visual = self.edition
            self.edition = hnds_copy(puzzle.primary_edition)
            self.hnds_sarmenti_primary_edition_guard = true
            local result = HNDS.pack(set_cost_ref(self, ...))
            self.hnds_sarmenti_primary_edition_guard = nil
            hnds_apply_piece_discount(self)

            puzzle.primary_edition = hnds_copy(self.edition)
            puzzle.primary_sell_cost = self.sell_cost
            puzzle.primary_sell_cost_label = self.sell_cost_label
            self.edition = visual
            self.hnds_sarmenti_set_cost_during_update = true
            HNDS.sarmenti_refresh_visual_edition(self)
            HNDS.sarmenti_refresh_sell_cost(self)
            return unpack_values(result, 1, result.n)
        end
    end

    if type(Card.set_edition) == 'function' and not Card._hnds_sarmenti_edition_wrapped then
        Card._hnds_sarmenti_edition_wrapped = true
        local set_edition_ref = Card.set_edition
        function Card:set_edition(edition, immediate, silent, ...)
            if HNDS.is_sarmenti_piece(self) and edition ~= nil
                and ((G and G.shop_jokers and self.area == G.shop_jokers) or not self.added_to_deck)
            then
                return
            end
            if self.hnds_sarmenti_component_guard or not HNDS.is_sarmenti_piece(self) then
                return set_edition_ref(self, edition, immediate, silent, ...)
            end
            local puzzle = hnds_puzzle(self)
            self.edition = hnds_copy(puzzle.primary_edition)
            self.hnds_sarmenti_primary_edition_guard = true
            local result = HNDS.pack(set_edition_ref(self, edition, immediate, silent, ...))
            self.hnds_sarmenti_primary_edition_guard = nil
            puzzle.primary_edition = hnds_copy(self.edition)
            puzzle.primary_sell_cost = self.sell_cost
            puzzle.primary_sell_cost_label = self.sell_cost_label
            HNDS.sarmenti_refresh_visual_edition(self)
            if HNDS.sarmenti_refresh_sell_cost then HNDS.sarmenti_refresh_sell_cost(self) end
            return unpack_values(result, 1, result.n)
        end
    end

    if type(Card.calculate_edition) == 'function' and not Card._hnds_sarmenti_calculate_edition_wrapped then
        Card._hnds_sarmenti_calculate_edition_wrapped = true
        local calculate_edition_ref = Card.calculate_edition
        function Card:calculate_edition(context, ...)
            if self.hnds_sarmenti_component_guard or not HNDS.is_sarmenti_piece(self) then
                return calculate_edition_ref(self, context, ...)
            end

            local args = HNDS.pack(...)
            local puzzle = hnds_puzzle(self)
            local visual = self.edition

            self.edition = hnds_copy(puzzle.primary_edition)
            local result = HNDS.pack(calculate_edition_ref(
                self, context, unpack_values(args, 1, args.n)
            ))
            puzzle.primary_edition = hnds_copy(self.edition)
            self.edition = visual

            for _, snap in ipairs(puzzle.components or {}) do
                local extra = HNDS.pack(hnds_with_component(self, snap, function()
                    return calculate_edition_ref(
                        self, context, unpack_values(args, 1, args.n)
                    )
                end))
                hnds_merge_packed_results(result, extra)
            end

            HNDS.sarmenti_refresh_visual_edition(self)
            return unpack_values(result, 1, result.n)
        end
    end

    if type(Card.calc_dollar_bonus) == 'function' and not Card._hnds_sarmenti_dollar_wrapped then
        Card._hnds_sarmenti_dollar_wrapped = true
        local dollar_ref = Card.calc_dollar_bonus
        function Card:calc_dollar_bonus(...)
            if self.hnds_sarmenti_component_guard or not HNDS.is_sarmenti_piece(self) then
                return dollar_ref(self, ...)
            end

            local args = HNDS.pack(...)
            local total = tonumber(dollar_ref(self, unpack_values(args, 1, args.n))) or 0
            local puzzle = hnds_puzzle(self)
            for _, snap in ipairs((puzzle and puzzle.components) or {}) do
                local extra = hnds_with_component(self, snap, function()
                    return dollar_ref(self, unpack_values(args, 1, args.n))
                end)
                total = total + (tonumber(extra) or 0)
            end
            return total
        end
    end

    if type(Card.generate_UIBox_ability_table) == 'function' and not Card._hnds_sarmenti_ui_wrapped then
        Card._hnds_sarmenti_ui_wrapped = true
        local generate_ui_ref = Card.generate_UIBox_ability_table
        function Card:generate_UIBox_ability_table(...)
            local args = HNDS.pack(...)
            if self.hnds_sarmenti_component_guard or args[1] == true then
                return generate_ui_ref(self, unpack_values(args, 1, args.n))
            end
            local results = HNDS.pack(generate_ui_ref(self, unpack_values(args, 1, args.n)))
            local full_UI_table = results[1]
            if not (full_UI_table and HNDS.is_sarmenti_piece(self)) then
                return unpack_values(results, 1, results.n)
            end
            if full_UI_table.hnds_sarmenti_components_added then
                return unpack_values(results, 1, results.n)
            end
            full_UI_table.hnds_sarmenti_components_added = true
            local puzzle = hnds_puzzle(self)
            if type(generate_card_ui) == 'function' and not puzzle.completed then
                generate_card_ui({
                    set = 'Other',
                    key = 'hnds_puzzle_piece',
                    vars = { math.max(0, tonumber(puzzle.rounds_remaining) or 2) },
                }, full_UI_table)
            end
            for _, snap in ipairs(puzzle.components or {}) do
                hnds_append_component_tooltip(full_UI_table, self, snap)
            end
            hnds_append_edition_tooltips(full_UI_table, self)
            return unpack_values(results, 1, results.n)
        end
    end
end

if Game and type(Game.main_menu) == 'function' and not Game._hnds_sarmenti_menu_cleanup_wrapped then
    Game._hnds_sarmenti_menu_cleanup_wrapped = true
    local main_menu_ref = Game.main_menu
    function Game:main_menu(...)
        local results = HNDS.pack(main_menu_ref(self, ...))
        HNDS.sarmenti_cleanup_runtime_atlases()
        return unpack_values(results, 1, results.n)
    end
end


if SMODS and SMODS.current_mod and not HNDS._billy_puzzle_debuff_hook then
    HNDS._billy_puzzle_debuff_hook = true
    local previous_set_debuff = SMODS.current_mod.set_debuff
    SMODS.current_mod.set_debuff = function(card)
        if HNDS.is_sarmenti_piece(card) then
            local puzzle = hnds_puzzle(card)
            if puzzle and puzzle.expired and not puzzle.completed then return true end
        end
        if previous_set_debuff then return previous_set_debuff(card) end
    end
end

if Card and type(Card.add_sticker) == 'function' and not Card._hnds_billy_piece_sticker_wrapped then
    Card._hnds_billy_piece_sticker_wrapped = true
    local add_sticker_ref = Card.add_sticker
    function Card:add_sticker(key, ...)
        if HNDS.is_sarmenti_piece(self)
            and ((G and G.shop_jokers and self.area == G.shop_jokers) or not self.added_to_deck)
        then
            return
        end
        return add_sticker_ref(self, key, ...)
    end
end

if G and G.FUNCS and type(G.FUNCS.check_for_buy_space) == 'function'
    and not HNDS._billy_piece_buy_space_wrapped
then
    HNDS._billy_piece_buy_space_wrapped = true
    local check_for_buy_space_ref = G.FUNCS.check_for_buy_space
    function G.FUNCS.check_for_buy_space(card, ...)
        if HNDS.sarmenti_piece_can_attach(card) then return true end
        return check_for_buy_space_ref(card, ...)
    end
end
