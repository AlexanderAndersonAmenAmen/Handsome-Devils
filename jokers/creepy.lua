HNDS = HNDS or {}

local FACELESS_STATE = 'hnds_faceless'

local FACELESS_NOPE_SOUNDS = {
    { key = 'hnds_creepy_1', volume = 0.18 },
    { key = 'hnds_creepy_2', volume = 0.45 },
    { key = 'hnds_creepy_3', volume = 0.28 },
    { key = 'hnds_creepy_4', volume = 0.25 },
}


function HNDS.is_faceless(card)
    return card and card.ability and card.ability[FACELESS_STATE] == true
end

function HNDS.faceless_is_stone(card)
    return HNDS.is_faceless(card) and HNDS.card_has_stone and HNDS.card_has_stone(card, false) or false
end

local FACELESS_RANK_X = { Jack = 0, Queen = 1, King = 2 }
local FACELESS_SUIT_Y = { Hearts = 0, Clubs = 1, Diamonds = 2, Spades = 3 }

local function hnds_faceless_uses_high_contrast(card)
    local settings = G and G.SETTINGS
    local suit = card and card.base and card.base.suit
    local palette = settings and settings.colour_palettes and suit and settings.colour_palettes[suit]
    if palette == 'hc' then return true end
    if palette == 'lc' then return false end
    return settings and settings.colourblind_option == true or false
end

local function hnds_faceless_atlas(card)
    local high_contrast = hnds_faceless_uses_high_contrast(card)
    local short_key = high_contrast and 'Faceless_opt2' or 'Faceless_opt1'
    local prefixed_key = 'hnds_' .. short_key
    if SMODS and type(SMODS.get_atlas) == 'function' then
        local atlas = SMODS.get_atlas(prefixed_key) or SMODS.get_atlas(short_key)
        if atlas then return atlas end
    end
    if G and G.ASSET_ATLAS then
        return G.ASSET_ATLAS[prefixed_key] or G.ASSET_ATLAS[short_key]
    end
end

local function hnds_faceless_visual_rank(card)
    local saved = card and card.ability and card.ability.hnds_faceless_visual_rank
    if saved then return saved end
    return card and card.base and card.base.value or 'Jack'
end

local function hnds_faceless_nope(card)
    if not card or card.removed then return end
    if card.juice_up then card:juice_up(0.35, 0.35) end
    if play_sound and (not hnds_config or hnds_config.enableCustomSounds ~= false) then
        local index
        if love and love.math and type(love.math.random) == 'function' then
            index = love.math.random(#FACELESS_NOPE_SOUNDS)
        else
            index = math.random(#FACELESS_NOPE_SOUNDS)
        end
        local sound = FACELESS_NOPE_SOUNDS[index]
        play_sound(sound.key, 1, sound.volume)
    end
    if card_eval_status_text then
        card_eval_status_text(card, 'extra', nil, nil, nil, {
            message = localize and localize('k_nope_ex') or 'Nope!',
            colour = (G and G.C and (G.C.FILTER or G.C.RED)) or { 1, 0.2, 0.2, 1 },
        })
    end
end


HNDS._faceless_sort_snapshots = HNDS._faceless_sort_snapshots
    or setmetatable({}, { __mode = 'k' })

function HNDS.faceless_copy_target(card)
    if not HNDS.is_faceless(card) or HNDS.faceless_is_stone(card) then return nil end
    local area = card.area
    local cards = area and area.cards
    if type(cards) ~= 'table' then return nil end

    local snapshot = HNDS._faceless_sort_snapshots and HNDS._faceless_sort_snapshots[area]
    if snapshot then
        local frozen = rawget(snapshot, card)
        if frozen ~= nil then
            if frozen and frozen.debuff then return nil end
            return frozen or nil
        end
    end

    local index
    for i = 1, #cards do
        if cards[i] == card then
            index = i
            break
        end
    end
    if not index then return nil end

    for i = index + 1, #cards do
        local candidate = cards[i]
        if candidate and not candidate.removed then
            if candidate.debuff then return nil end
            if not HNDS.is_faceless(candidate) or HNDS.faceless_is_stone(candidate) then return candidate end
        end
    end
    return nil
end


if CardArea and type(CardArea.sort) == 'function' and not HNDS._faceless_cardarea_sort_hook then
    HNDS._faceless_cardarea_sort_hook = true
    local cardarea_sort_ref = CardArea.sort
    function CardArea:sort(...)
        local cards = self and self.cards
        if type(cards) ~= 'table' or #cards == 0 then
            return cardarea_sort_ref(self, ...)
        end

        local snapshot = setmetatable({}, { __mode = 'k' })
        local next_real = nil
        local has_faceless = false
        for i = #cards, 1, -1 do
            local candidate = cards[i]
            if candidate and not candidate.removed then
                if candidate.debuff then
                    if HNDS.is_faceless(candidate) and not HNDS.faceless_is_stone(candidate) then
                        has_faceless = true
                        snapshot[candidate] = false
                    end
                    next_real = false
                elseif HNDS.is_faceless(candidate) and not HNDS.faceless_is_stone(candidate) then
                    has_faceless = true
                    snapshot[candidate] = next_real or false
                else
                    next_real = candidate
                end
            end
        end

        if not has_faceless then
            return cardarea_sort_ref(self, ...)
        end

        local previous = HNDS._faceless_sort_snapshots[self]
        HNDS._faceless_sort_snapshots[self] = snapshot
        local packed = HNDS.pack(pcall(cardarea_sort_ref, self, ...))
        HNDS._faceless_sort_snapshots[self] = previous

        if not packed[1] then error(packed[2], 0) end
        return ((table and table.unpack) or unpack)(packed, 2, packed.n)
    end
end

local function hnds_unique_negative_id(card)
    local identity = tonumber(card and (card.playing_card or card.sort_id or card.ID)) or 0
    return -1000000 - identity
end

local function hnds_target_has_no_rank(target)
    if not target then return true end
    if HNDS.safe_has_no_rank then return HNDS.safe_has_no_rank(target) end
    if SMODS and type(SMODS.has_no_rank) == 'function' then
        local ok, value = pcall(SMODS.has_no_rank, target)
        if ok then return value == true end
    end
    return false
end

local function hnds_target_has_no_suit(target)
    if not target then return true end
    if HNDS.safe_has_no_suit then return HNDS.safe_has_no_suit(target) end
    if SMODS and type(SMODS.has_no_suit) == 'function' then
        local ok, value = pcall(SMODS.has_no_suit, target)
        if ok then return value == true end
    end
    return false
end

function HNDS.refresh_faceless_front(card, force)
    if not (HNDS.is_faceless(card) and card.children and card.children.front) then return end
    local suit = card.ability and card.ability.hnds_faceless_visual_suit
        or (card.base and card.base.suit)
    local y = FACELESS_SUIT_Y[suit]
    if y == nil then


        return
    end

    local visual_rank = hnds_faceless_visual_rank(card)
    local x = FACELESS_RANK_X[visual_rank]
    if x == nil then


        x = 0
    end
    local high_contrast = hnds_faceless_uses_high_contrast(card)
    local signature = table.concat({ high_contrast and 'hc' or 'lc', suit, tostring(visual_rank) }, ':')
    if not force and card.hnds_faceless_front_signature == signature then return end

    local atlas = hnds_faceless_atlas(card)
    if not atlas then return end
    card.children.front.atlas = atlas
    if card.children.front.set_sprite_pos then
        card.children.front:set_sprite_pos({ x = x, y = y })
    else
        card.children.front.sprite_pos = { x = x, y = y }
    end
    card.hnds_faceless_front_signature = signature
end

function HNDS.apply_faceless(card)
    if not card then return false end
    card.ability = card.ability or {}
    if card.ability[FACELESS_STATE] then
        HNDS.refresh_faceless_front(card, true)
        return false
    end
    card.ability.hnds_faceless_visual_rank = card.base and card.base.value or 'Jack'
    card.ability.hnds_faceless_visual_suit = card.base and card.base.suit or nil
    card.ability[FACELESS_STATE] = true
    card.hnds_faceless_front_signature = nil
    HNDS.refresh_faceless_front(card, true)
    return true
end

local function hnds_faceless_visual_suit(card)
    local saved = card and card.ability and card.ability.hnds_faceless_visual_suit
    if saved then return saved end
    return card and card.base and card.base.suit or nil
end

if SMODS and type(SMODS.modify_rank) == 'function' and not HNDS._faceless_modify_rank_guard then
    HNDS._faceless_modify_rank_guard = true
    local modify_rank_ref = SMODS.modify_rank
    function SMODS.modify_rank(card, amount, ...)
        if HNDS.is_faceless(card) and tonumber(amount or 0) ~= 0 then
            hnds_faceless_nope(card)
            return card
        end
        return modify_rank_ref(card, amount, ...)
    end
end

if SMODS and type(SMODS.change_base) == 'function' and not HNDS._faceless_change_base_guard then
    HNDS._faceless_change_base_guard = true
    local change_base_ref = SMODS.change_base
    function SMODS.change_base(card, suit, rank, ...)
        if HNDS.is_faceless(card) then
            local rank_change = rank ~= nil and rank ~= hnds_faceless_visual_rank(card)
            local suit_change = suit ~= nil and suit ~= hnds_faceless_visual_suit(card)
            if rank_change or suit_change then
                hnds_faceless_nope(card)
                return card
            end
        end
        return change_base_ref(card, suit, rank, ...)
    end
end

if Card and type(Card.set_base) == 'function' and not HNDS._faceless_set_base_guard then
    HNDS._faceless_set_base_guard = true
    local set_base_ref = Card.set_base
    function Card:set_base(base_card, ...)
        if HNDS.is_faceless(self) and base_card then
            local rank_change = base_card.value ~= nil and base_card.value ~= hnds_faceless_visual_rank(self)
            local suit_change = base_card.suit ~= nil and base_card.suit ~= hnds_faceless_visual_suit(self)
            if rank_change or suit_change then
                hnds_faceless_nope(self)
                self.hnds_faceless_front_signature = nil
                HNDS.refresh_faceless_front(self, true)
                return self
            end
        end
        return set_base_ref(self, base_card, ...)
    end
end


local function hnds_creepy_queue_faceless_after_score(scored_card)
    if not scored_card then return false end
    scored_card.hnds_creepy_pending_faceless = nil

    local function apply_now()
        if not scored_card or scored_card.removed or scored_card.destroyed or scored_card.shattered then
            return true
        end
        if HNDS.apply_faceless(scored_card) and scored_card.juice_up then
            scored_card:juice_up(0.35, 0.35)
        end
        return true
    end

    if G and G.E_MANAGER and Event then
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0,
            blockable = true,
            blocking = true,
            func = apply_now,
        }))
        return true
    end

    return apply_now()
end

if SMODS and type(SMODS.score_card) == 'function' and not HNDS._creepy_score_card_wrapped then
    HNDS._creepy_score_card_wrapped = true
    local hnds_creepy_score_card_ref = SMODS.score_card
    local unpack_values = (table and table.unpack) or unpack

    function SMODS.score_card(scored_card, context, ...)
        local trailing = HNDS.pack(...)
        local results = HNDS.pack(hnds_creepy_score_card_ref(
            scored_card, context, unpack_values(trailing, 1, trailing.n)
        ))


        if scored_card and scored_card.hnds_creepy_pending_faceless then
            hnds_creepy_queue_faceless_after_score(scored_card)
        end

        return unpack_values(results, 1, results.n)
    end
end


local FACELESS_PERMA_KEYS = {
    'perma_bonus', 'perma_mult', 'perma_x_chips', 'perma_x_mult',
    'perma_h_chips', 'perma_h_mult', 'perma_h_x_chips', 'perma_h_x_mult',
    'perma_p_dollars', 'perma_h_dollars', 'perma_score', 'perma_x_score',
    'perma_blind_size', 'perma_x_blind_size',
}

local function hnds_clone_table(value, seen)
    if type(value) ~= 'table' then return value end
    seen = seen or {}
    if seen[value] then return seen[value] end
    local out = {}
    seen[value] = out
    for k, v in pairs(value) do
        out[hnds_clone_table(k, seen)] = hnds_clone_table(v, seen)
    end
    return setmetatable(out, getmetatable(value))
end

local hnds_faceless_state_guard = setmetatable({}, { __mode = 'k' })

function HNDS.with_faceless_copy_state(card, callback)
    if not (card and type(callback) == 'function' and HNDS.is_faceless(card)) then
        return callback(nil)
    end
    local target = HNDS.faceless_copy_target(card)
    if not target or hnds_faceless_state_guard[card] then
        return callback(target)
    end

    local config = card.config or {}
    local saved = {
        base = card.base,
        ability = card.ability,
        edition = card.edition,
        seal = card.seal,
        center = config.center,
        center_key = config.center_key,
        config_card = config.card,
        card_key = config.card_key,
    }

    local effective_ability = hnds_clone_table(target.ability or {})


    for _, key in ipairs(FACELESS_PERMA_KEYS) do
        effective_ability[key] = saved.ability and saved.ability[key] or nil
    end

    card.base = target.base or card.base
    card.ability = effective_ability
    card.edition = hnds_clone_table(target.edition)
    card.seal = target.seal
    card.config = config
    config.center = target.config and target.config.center or config.center
    config.center_key = target.config and target.config.center_key or config.center_key
    config.card = target.config and target.config.card or config.card
    config.card_key = target.config and target.config.card_key or config.card_key

    hnds_faceless_state_guard[card] = true
    local packed = HNDS.pack(pcall(callback, target))
    hnds_faceless_state_guard[card] = nil

    card.base = saved.base
    card.ability = saved.ability
    card.edition = saved.edition
    card.seal = saved.seal
    config.center = saved.center
    config.center_key = saved.center_key
    config.card = saved.config_card
    config.card_key = saved.card_key
    card.hnds_faceless_front_signature = nil
    HNDS.refresh_faceless_front(card, true)

    if not packed[1] then error(packed[2], 0) end
    return ((table and table.unpack) or unpack)(packed, 2, packed.n)
end


if type(eval_card) == 'function' and not HNDS._faceless_eval_card_hook then
    HNDS._faceless_eval_card_hook = true
    local eval_card_ref = eval_card
    function eval_card(card, context, ...)
        if HNDS.is_faceless(card) and HNDS.faceless_copy_target(card) then
            local args = HNDS.pack(...)
            return HNDS.with_faceless_copy_state(card, function()
                return eval_card_ref(card, context, ((table and table.unpack) or unpack)(args, 1, args.n))
            end)
        end
        return eval_card_ref(card, context, ...)
    end
end


if Card and type(Card.draw) == 'function' and not HNDS._faceless_front_draw_hook then
    HNDS._faceless_front_draw_hook = true
    local draw_ref = Card.draw
    function Card:draw(...)
        if HNDS.is_faceless(self) then HNDS.refresh_faceless_front(self, false) end
        return draw_ref(self, ...)
    end
end

if Card and type(Card.set_sprites) == 'function' and not HNDS._faceless_set_sprites_hook then
    HNDS._faceless_set_sprites_hook = true
    local set_sprites_ref = Card.set_sprites
    function Card:set_sprites(...)
        local was_faceless = HNDS.is_faceless(self)
        local results = HNDS.pack(set_sprites_ref(self, ...))
        if was_faceless then
            self.hnds_faceless_front_signature = nil
            HNDS.refresh_faceless_front(self, true)
        end
        return ((table and table.unpack) or unpack)(results, 1, results.n)
    end
end


if Card and type(Card.set_ability) == 'function' and not HNDS._faceless_set_ability_hook then
    HNDS._faceless_set_ability_hook = true
    local set_ability_ref = Card.set_ability
    function Card:set_ability(...)
        local was_faceless = HNDS.is_faceless(self)
        local visual_rank = self.ability and self.ability.hnds_faceless_visual_rank
        local visual_suit = self.ability and self.ability.hnds_faceless_visual_suit
        local results = HNDS.pack(set_ability_ref(self, ...))
        if was_faceless then
            self.ability = self.ability or {}
            self.ability[FACELESS_STATE] = true
            self.ability.hnds_faceless_visual_rank = visual_rank or (self.base and self.base.value) or 'Jack'
            self.ability.hnds_faceless_visual_suit = visual_suit or (self.base and self.base.suit) or nil
            self.hnds_faceless_front_signature = nil
            HNDS.refresh_faceless_front(self, true)
        end
        return ((table and table.unpack) or unpack)(results, 1, results.n)
    end
end


if Card and type(Card.get_id) == 'function' and not HNDS._faceless_get_id_hook then
    HNDS._faceless_get_id_hook = true
    local get_id_ref = Card.get_id
    function Card:get_id(...)
        if HNDS.is_faceless(self) then
            local target = HNDS.faceless_copy_target(self)
            if target and type(target.get_id) == 'function' then
                return target:get_id(...)
            end
            return hnds_unique_negative_id(self)
        end
        return get_id_ref(self, ...)
    end
end

if Card and type(Card.is_suit) == 'function' and not HNDS._faceless_is_suit_hook then
    HNDS._faceless_is_suit_hook = true
    local is_suit_ref = Card.is_suit
    function Card:is_suit(suit, ...)
        if HNDS.is_faceless(self) then
            local target = HNDS.faceless_copy_target(self)
            if target and type(target.is_suit) == 'function' then
                return target:is_suit(suit, ...)
            end
            return false
        end
        return is_suit_ref(self, suit, ...)
    end
end

if Card and type(Card.is_face) == 'function' and not HNDS._faceless_is_face_hook then
    HNDS._faceless_is_face_hook = true
    local is_face_ref = Card.is_face
    function Card:is_face(...)
        if HNDS.is_faceless(self) then
            local target = HNDS.faceless_copy_target(self)
            if target and type(target.is_face) == 'function' then
                return target:is_face(...)
            end
            return false
        end
        return is_face_ref(self, ...)
    end
end

if Card and type(Card.get_nominal) == 'function' and not HNDS._faceless_nominal_hook then
    HNDS._faceless_nominal_hook = true
    local get_nominal_ref = Card.get_nominal
    function Card:get_nominal(...)
        if HNDS.is_faceless(self) then
            local target = HNDS.faceless_copy_target(self)
            if target and type(target.get_nominal) == 'function' then
                return target:get_nominal(...)
            end
            return -1000
        end
        return get_nominal_ref(self, ...)
    end
end


local function hnds_wrap_faceless_card_method(method_name, flag_name)
    if not (Card and type(Card[method_name]) == 'function') or HNDS[flag_name] then return end
    HNDS[flag_name] = true
    local method_ref = Card[method_name]
    Card[method_name] = function(self, ...)
        if HNDS.is_faceless(self) then
            local target = HNDS.faceless_copy_target(self)
            if target then
                local args = HNDS.pack(...)
                local packed = HNDS.pack(HNDS.with_faceless_copy_state(self, function()


                    if method_name == 'get_chip_bonus'
                        and HNDS.is_jack_of_lanterns and HNDS.is_jack_of_lanterns(target)
                        and self.base
                    then
                        local old_nominal = self.base.nominal
                        self.base.nominal = 0
                        local inner = HNDS.pack(pcall(method_ref, self,
                            ((table and table.unpack) or unpack)(args, 1, args.n)))
                        self.base.nominal = old_nominal
                        if not inner[1] then error(inner[2], 0) end
                        return ((table and table.unpack) or unpack)(inner, 2, inner.n)
                    end
                    return method_ref(self, ((table and table.unpack) or unpack)(args, 1, args.n))
                end))


                if method_name == 'get_chip_x_mult'
                    and HNDS.is_jack_of_lanterns and HNDS.is_jack_of_lanterns(target)
                then
                    local native_xmult = HNDS.jack_of_lanterns_native_xmult
                        and HNDS.jack_of_lanterns_native_xmult(target)
                    if native_xmult == 5 then
                        packed[1] = 5
                    elseif native_xmult == 3 then
                        local value = packed[1]
                        if type(value) == 'number' and value ~= 0 then
                            packed[1] = value * 3
                        else
                            packed[1] = 3
                        end
                    end
                end
                return ((table and table.unpack) or unpack)(packed, 1, packed.n)
            end
        end
        return method_ref(self, ...)
    end
end

hnds_wrap_faceless_card_method('get_chip_bonus', '_faceless_chip_bonus_hook')
hnds_wrap_faceless_card_method('get_chip_mult', '_faceless_chip_mult_hook')
hnds_wrap_faceless_card_method('get_chip_x_mult', '_faceless_chip_x_mult_hook')
hnds_wrap_faceless_card_method('get_chip_x_bonus', '_faceless_chip_x_bonus_hook')
hnds_wrap_faceless_card_method('get_chip_h_bonus', '_faceless_chip_h_bonus_hook')
hnds_wrap_faceless_card_method('get_chip_h_mult', '_faceless_chip_h_mult_hook')
hnds_wrap_faceless_card_method('get_chip_h_x_mult', '_faceless_chip_h_x_mult_hook')
hnds_wrap_faceless_card_method('get_chip_h_x_bonus', '_faceless_chip_h_x_bonus_hook')
hnds_wrap_faceless_card_method('get_p_dollars', '_faceless_p_dollars_hook')
hnds_wrap_faceless_card_method('get_h_dollars', '_faceless_h_dollars_hook')

if SMODS and type(SMODS.get_enhancements) == 'function' and not HNDS._faceless_get_enhancements_hook then
    HNDS._faceless_get_enhancements_hook = true
    local get_enhancements_ref = SMODS.get_enhancements
    function SMODS.get_enhancements(card, ...)
        if HNDS.is_faceless(card) then
            local target = HNDS.faceless_copy_target(card)
            if target then return get_enhancements_ref(target, ...) end
        end
        return get_enhancements_ref(card, ...)
    end
end

if SMODS and type(SMODS.has_enhancement) == 'function' and not HNDS._faceless_has_enhancement_hook then
    HNDS._faceless_has_enhancement_hook = true
    local has_enhancement_ref = SMODS.has_enhancement
    function SMODS.has_enhancement(card, key, ...)
        if HNDS.is_faceless(card) then
            local target = HNDS.faceless_copy_target(card)
            if target then return has_enhancement_ref(target, key, ...) end
        end
        return has_enhancement_ref(card, key, ...)
    end
end

if SMODS and type(SMODS.calculate_quantum_enhancements) == 'function' and not HNDS._faceless_quantum_enhancements_hook then
    HNDS._faceless_quantum_enhancements_hook = true
    local calculate_quantum_enhancements_ref = SMODS.calculate_quantum_enhancements
    function SMODS.calculate_quantum_enhancements(card, effects, context, ...)
        if HNDS.is_faceless(card) and HNDS.faceless_copy_target(card) then
            local args = HNDS.pack(...)
            return HNDS.with_faceless_copy_state(card, function()
                return calculate_quantum_enhancements_ref(
                    card, effects, context, ((table and table.unpack) or unpack)(args, 1, args.n)
                )
            end)
        end
        return calculate_quantum_enhancements_ref(card, effects, context, ...)
    end
end

if Card and type(Card.get_seal) == 'function' and not HNDS._faceless_get_seal_hook then
    HNDS._faceless_get_seal_hook = true
    local get_seal_ref = Card.get_seal
    function Card:get_seal(...)
        if HNDS.is_faceless(self) then
            local target = HNDS.faceless_copy_target(self)
            if target and type(target.get_seal) == 'function' then return target:get_seal(...) end
            if target then return target.seal end
        end
        return get_seal_ref(self, ...)
    end
end


for _, helper in ipairs({ 'always_scores', 'never_scores', 'shatters' }) do
    if SMODS and type(SMODS[helper]) == 'function' and not HNDS['_faceless_' .. helper .. '_hook'] then
        HNDS['_faceless_' .. helper .. '_hook'] = true
        local helper_ref = SMODS[helper]
        SMODS[helper] = function(card, ...)
            if HNDS.is_faceless(card) then
                local target = HNDS.faceless_copy_target(card)
                if target then return helper_ref(target, ...) end
            end
            return helper_ref(card, ...)
        end
    end
end


if SMODS and type(SMODS.has_no_rank) == 'function' and not HNDS._faceless_no_rank_hook then
    HNDS._faceless_no_rank_hook = true
    local has_no_rank_ref = SMODS.has_no_rank
    function SMODS.has_no_rank(card, ...)
        if HNDS.is_faceless(card) then
            local target = HNDS.faceless_copy_target(card)
            if not target then return true end
            if HNDS.safe_has_no_rank then return HNDS.safe_has_no_rank(target) end
            return has_no_rank_ref(target, ...)
        end
        return has_no_rank_ref(card, ...)
    end
end

if SMODS and type(SMODS.has_no_suit) == 'function' and not HNDS._faceless_no_suit_hook then
    HNDS._faceless_no_suit_hook = true
    local has_no_suit_ref = SMODS.has_no_suit
    function SMODS.has_no_suit(card, ...)
        if HNDS.is_faceless(card) then
            local target = HNDS.faceless_copy_target(card)
            if not target then return true end
            if HNDS.safe_has_no_suit then return HNDS.safe_has_no_suit(target) end
            return has_no_suit_ref(target, ...)
        end
        return has_no_suit_ref(card, ...)
    end
end

if SMODS and type(SMODS.has_any_suit) == 'function' and not HNDS._faceless_any_suit_hook then
    HNDS._faceless_any_suit_hook = true
    local has_any_suit_ref = SMODS.has_any_suit
    function SMODS.has_any_suit(card, ...)
        if HNDS.is_faceless(card) then
            local target = HNDS.faceless_copy_target(card)
            if not target then return false end
            if HNDS.safe_has_any_suit then return HNDS.safe_has_any_suit(target) end
            return has_any_suit_ref(target, ...)
        end
        return has_any_suit_ref(card, ...)
    end
end


local function hnds_suit_objects()
    if SMODS and SMODS.Suit and type(SMODS.Suit.obj_list) == 'function' then
        local ok, list = pcall(SMODS.Suit.obj_list, SMODS.Suit, true)
        if ok and type(list) == 'table' then return list end
    end
    local out = {}
    for _, key in ipairs({ 'Spades', 'Hearts', 'Clubs', 'Diamonds' }) do
        out[#out + 1] = { key = key }
    end
    return out
end

local function hnds_localized_rank(target)
    if not target or hnds_target_has_no_rank(target) then return 'No rank' end
    local key = target.base and target.base.value
    if key then
        local ok, value = pcall(localize, key, 'ranks')
        if ok and type(value) == 'string' and value ~= '' then return value end
    end
    return tostring(key or 'No rank')
end

local function hnds_effective_suits(target)
    if not target or hnds_target_has_no_suit(target) then return {}, nil end
    local keys, names = {}, {}
    for _, suit in ipairs(hnds_suit_objects()) do
        local key = suit and suit.key
        if key and type(target.is_suit) == 'function' then
            local ok, matches = pcall(target.is_suit, target, key)
            if ok and matches then
                keys[#keys + 1] = key
                local ok_loc, loc = pcall(localize, key, 'suits_plural')
                names[#names + 1] = ok_loc and loc or tostring(key)
            end
        end
    end


    local base_suit = target.base and target.base.suit
    if #keys == 0 and base_suit then
        keys[1] = base_suit
        local ok_loc, loc = pcall(localize, base_suit, 'suits_plural')
        names[1] = ok_loc and loc or tostring(base_suit)
    end
    return names, keys
end

local function hnds_clean_object_name(value)
    if type(value) ~= 'string' then return nil end
    value = value:gsub(' Card$', '')
    if value == '' or value:upper():match('^ERROR') then return nil end
    return value
end

local function hnds_object_name(set_name, key, fallback)
    if not key then return nil end
    if localize then
        local ok, value = pcall(localize, { type = 'name_text', set = set_name, key = key })
        value = ok and hnds_clean_object_name(value) or nil
        if value then return value end
    end


    local fallback_name = fallback and hnds_clean_object_name(fallback.name)
    if not fallback_name and fallback and type(fallback.loc_txt) == 'table' then
        fallback_name = hnds_clean_object_name(fallback.loc_txt.name)
    end
    if fallback_name then return fallback_name end

    local raw = tostring(key):gsub('^[ems]_', '')
    raw = raw:gsub('_', ' '):gsub('(%a)([%w]*)', function(a, b)
        return a:upper() .. b
    end)
    return raw
end

local function hnds_target_edition_name(target)
    local edition = target and target.edition
    if type(edition) ~= 'table' then return nil end
    local key = edition.key or (edition.type and ('e_' .. tostring(edition.type)))
    local obj = key and ((SMODS and SMODS.Editions and SMODS.Editions[key]) or (G and G.P_CENTERS and G.P_CENTERS[key]))
    return hnds_object_name('Edition', key, obj)
end

local function hnds_target_seal_name(target)
    local key = target and target.seal
    if not key then return nil end
    local obj = (SMODS and SMODS.Seals and SMODS.Seals[key]) or (G and G.P_SEALS and G.P_SEALS[key])


    local name = obj and hnds_clean_object_name(obj.name)
    if not name and obj and type(obj.loc_txt) == 'table' then
        name = hnds_clean_object_name(obj.loc_txt.name)
    end
    if not name and localize then
        for _, label_key in ipairs({ tostring(key) .. '_seal', tostring(key):lower() .. '_seal' }) do
            local ok, value = pcall(localize, label_key, 'labels')
            value = ok and hnds_clean_object_name(value) or nil
            if value then name = value break end
        end
    end
    if not name then name = hnds_object_name('Seal', key, obj) end
    if name and not name:lower():find('seal$', 1, false) then name = name .. ' Seal' end
    return name
end

local function hnds_target_enhancement_name(target)


    if HNDS.is_faceless(target) and not HNDS.faceless_is_stone(target) then return nil end
    local center = target and target.config and target.config.center
    if not center or center.set ~= 'Enhanced' then return nil end
    return hnds_object_name('Enhanced', center.key, center)
end

function HNDS.faceless_display_abilities(card)
    local target = HNDS.faceless_copy_target(card)
    if not target then
        return nil, nil, nil, (G and G.C and (G.C.RED or G.C.FILTER)) or { 0.8, 0.2, 0.2, 1 }
    end

    local edition_name = hnds_target_edition_name(target)
    local seal_name = hnds_target_seal_name(target)
    local modifier_parts = {}
    if edition_name then modifier_parts[#modifier_parts + 1] = edition_name end
    if seal_name then modifier_parts[#modifier_parts + 1] = seal_name end
    local modifier_line = #modifier_parts > 0 and table.concat(modifier_parts, ' ') or nil

    local rank_name = hnds_localized_rank(target)
    local suit_names, suit_keys = hnds_effective_suits(target)
    local suit_text = #suit_names > 0 and table.concat(suit_names, ' / ') or 'No suit'
    local enhancement_name = hnds_target_enhancement_name(target)
    local center_key = target.config and target.config.center and target.config.center.key
    local identity_line
    if center_key == 'm_wild' then
        identity_line = (enhancement_name or 'Wild') .. ' ' .. rank_name
    else
        identity_line = (enhancement_name and (enhancement_name .. ' ') or '') .. rank_name .. ' of ' .. suit_text
    end

    local base_suit = target.base and target.base.suit
    local colour = G and G.C and G.C.SUITS and base_suit and G.C.SUITS[base_suit]
    if not colour and suit_keys and suit_keys[1] and G and G.C and G.C.SUITS then colour = G.C.SUITS[suit_keys[1]] end
    colour = colour or (G and G.C and G.C.INACTIVE) or { 0.5, 0.5, 0.5, 1 }
    return modifier_line, identity_line, target, colour
end

local function hnds_faceless_status_pill(label, colour)
    if not (label and G and G.UIT and G.C) then return nil end
    return {
        n = G.UIT.C,
        config = { align = 'cm', padding = 0.02 },
        nodes = {{
            n = G.UIT.C,
            config = { align = 'm', colour = colour, r = 0.05, padding = 0.05 },
            nodes = {{
                n = G.UIT.T,
                config = { text = ' ' .. label .. ' ', colour = G.C.UI.TEXT_LIGHT, scale = 0.3, shadow = false },
            }},
        }},
    }
end

local function hnds_faceless_ability_nodes(card)
    local modifier_line, identity_line, target, colour = HNDS.faceless_display_abilities(card)
    local nodes = {}
    if not target then
        nodes[#nodes + 1] = hnds_faceless_status_pill('incompatible', colour)
        return nodes
    end
    if modifier_line then nodes[#nodes + 1] = hnds_faceless_status_pill(modifier_line, colour) end
    if identity_line then nodes[#nodes + 1] = hnds_faceless_status_pill(identity_line, colour) end
    return nodes
end

local function hnds_faceless_name(card)
    local rank = hnds_faceless_visual_rank(card)
    local ok, localized = pcall(localize, rank, 'ranks')
    if not ok or type(localized) ~= 'string' or localized == '' then localized = tostring(rank) end
    return localized .. ' of Nothing'
end

local function hnds_replace_name_text(root, replacement)


    if type(root) ~= 'table' then return false end
    local seen, wrote = {}, false

    local function assign(value_setter)
        if not wrote then
            value_setter(replacement)
            wrote = true
        else
            value_setter('')
        end
    end

    local function walk(node)
        if type(node) ~= 'table' or seen[node] then return end
        seen[node] = true
        local cfg = node.config
        if type(cfg) == 'table' then
            local object_cfg = cfg.object and cfg.object.config
            if type(object_cfg) == 'table' and object_cfg.string ~= nil then
                assign(function(value) object_cfg.string = { value } end)
            end
            if type(cfg.text) == 'string' then
                assign(function(value) cfg.text = value end)
            end
        end
        if type(node.nodes) == 'table' then
            for i = 1, #node.nodes do walk(node.nodes[i]) end
        end
        for i = 1, #node do walk(node[i]) end
    end

    walk(root)
    return wrote
end


if Card and type(Card.generate_UIBox_ability_table) == 'function' and not HNDS._faceless_ui_hook then
    HNDS._faceless_ui_hook = true
    local generate_ability_ui_ref = Card.generate_UIBox_ability_table

    function Card:generate_UIBox_ability_table(...)
        if not HNDS.is_faceless(self) or not self.base then
            return generate_ability_ui_ref(self, ...)
        end

        local args = HNDS.pack(...)
        local function build_ui()
            local old_nominal = self.base and self.base.nominal
            if self.base then self.base.nominal = 0 end
            local packed = HNDS.pack(pcall(generate_ability_ui_ref, self, ((table and table.unpack) or unpack)(args, 1, args.n)))
            if self.base then self.base.nominal = old_nominal end
            if not packed[1] then error(packed[2], 0) end
            return packed[2]
        end


        local result = build_ui()

        if result and result.main and not result.hnds_faceless_main_added then
            result.hnds_faceless_main_added = true
            if not HNDS.faceless_is_stone(self) then
                local desc_nodes = {}
                localize {
                    type = 'descriptions',
                    set = 'Other',
                    key = 'hnds_faceless_card',
                    nodes = desc_nodes,
                    vars = {},
                }

                local prefix = {}
                for i = 1, #desc_nodes do prefix[#prefix + 1] = desc_nodes[i] end
                for _, status_node in ipairs(hnds_faceless_ability_nodes(self)) do
                    if status_node then prefix[#prefix + 1] = { status_node } end
                end
                for i = #prefix, 1, -1 do table.insert(result.main, 1, prefix[i]) end
            end
        end

        if result and type(result.name) == 'table' then
            hnds_replace_name_text(result.name, hnds_faceless_name(self))
        end
        return result
    end
end

SMODS.Joker({
    key = 'creepy',
    atlas = 'Jokers',
    pos = { x = 7, y = 3 },
    rarity = 2,
    cost = 5,
    unlocked = false,
    discovered = false,
    unlock_condition = { type = 'hnds_joker_unlock', key = 'creepy' },
    locked_loc_vars = function(self)
        return HNDS.joker_locked_loc_vars('creepy')
    end,
    check_for_unlock = function(self, args)
        return HNDS.joker_unlock_condition_met('creepy', args)
    end,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    config = { extra = { odds = 4 } },
    loc_vars = function(self, info_queue, card)
        if info_queue then
            info_queue[#info_queue + 1] = { set = 'Other', key = 'hnds_faceless' }
        end
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, 'hnds_creepy')
        return { vars = { numerator, denominator } }
    end,
    calculate = function(self, card, context)
        local target = context and context.other_card
        if not (context and context.individual and context.cardarea == G.play and target)
            or target.debuff or HNDS.is_faceless(target)
            or not (target.is_face and target:is_face())
        then
            return
        end


        local identity = target.playing_card or target.sort_id or target.ID or 0
        if SMODS.pseudorandom_probability(card, 'hnds_creepy', 1, card.ability.extra.odds,
                'hnds_creepy_' .. tostring(identity))
        then
            target.hnds_creepy_pending_faceless = true
        end
    end,
    joker_display_def = function(JokerDisplay)
        return {
            text = {},
            extra = {
                {
                    { text = '(' },
                    { ref_table = 'card.joker_display_values', ref_value = 'odds' },
                    { text = ')' },
                },
            },
            calc_function = function(card)
                card.joker_display_values.odds = localize {
                    type = 'variable', key = 'jdis_odds',
                    vars = { (G.GAME and G.GAME.probabilities.normal or 1), card.ability.extra.odds },
                }
            end,
        }
    end,
    attributes = { 'chance', 'modify_card' },
})
