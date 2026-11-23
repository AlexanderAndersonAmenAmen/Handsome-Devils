HNDS = HNDS or {}

local BLACK_DRAW_THRESHOLD = 10

local function set_black_seal_progress(ability, previous)
    ability.hnds_black_drawn = previous and previous.hnds_black_drawn
    ability.hnds_black_used = previous and previous.hnds_black_used
    ability.hnds_black_armed = previous and previous.hnds_black_armed
end

local function arm_black_seal(card)
    if card.seal == 'hnds_black' and card.ability then
        card.ability.hnds_black_armed = true
    end
end

local function reset_black_seal_progress()
    for _, playing_card in ipairs((G and G.playing_cards) or {}) do
        if playing_card and playing_card.ability then
            set_black_seal_progress(playing_card.ability)
        end
    end
end

local unpack_values = table.unpack or unpack

local set_seal_ref = Card.set_seal
function Card:set_seal(...)
    local results = HNDS.pack(set_seal_ref(self, ...))
    arm_black_seal(self)
    return unpack_values(results, 1, results.n)
end

local set_ability_ref = Card.set_ability
function Card:set_ability(...)
    local previous = self.ability
    if not (previous and previous.hnds_black_armed) then
        return set_ability_ref(self, ...)
    end
    local results = HNDS.pack(set_ability_ref(self, ...))
    set_black_seal_progress(self.ability, previous)
    return unpack_values(results, 1, results.n)
end

local copy_card_ref = copy_card
function copy_card(source, target, ...)
    local previous = target and target.ability
    local copied = copy_card_ref(source, target, ...)
    if copied and copied.ability then
        set_black_seal_progress(copied.ability, previous)
        arm_black_seal(copied)
    end
    return copied
end

local load_area_ref = CardArea.load
function CardArea:load(...)
    if not (G and self == G.hand) then return load_area_ref(self, ...) end
    local results = HNDS.pack(load_area_ref(self, ...))
    for _, card in ipairs(self.cards) do arm_black_seal(card) end
    return unpack_values(results, 1, results.n)
end

local function create_temporary_black_seal_joker()
    if not (G and G.jokers and SMODS and type(SMODS.add_card) == 'function') then return end
    local key
    if type(SMODS.poll_object) == 'function' then
        key = SMODS.poll_object({
            type = 'Joker', append = 'hnds_black_seal', seed = 'hnds_black_seal_joker',
            filter = function(pool)
                local available = {}
                for _, item in ipairs(pool or {}) do
                    local candidate = type(item) == 'table' and item.key or item
                    if candidate and candidate ~= 'j_hnds_formosana' and candidate ~= 'UNAVAILABLE'
                        and G.P_CENTERS and G.P_CENTERS[candidate] then
                        available[#available + 1] = item
                    end
                end
                if #available == 0 then available[1] = { key = 'j_joker', type = 'Joker' } end
                return available
            end,
        })
    end
    if type(key) == 'table' then key = key.key end
    if not key or key == 'j_hnds_formosana' or key == 'UNAVAILABLE' then key = 'j_joker' end
    local joker = SMODS.add_card({
        set = 'Joker',
        key = key,
        area = G.jokers,
        edition = 'e_negative',
        key_append = 'hnds_black_seal',
    })
    if joker then
        joker.ability = joker.ability or {}
        joker.ability.hnds_black_temporary = true
        if not (joker.edition and joker.edition.negative) and joker.set_edition then
            joker:set_edition('e_negative', true, true)
        end
        if joker.add_sticker then joker:add_sticker('hnds_shadow', true) end
        joker.ability.hnds_shadow = true
    end
end

local function cleanup_temporary_black_seal_jokers()
    if not (G and G.jokers and G.jokers.cards) then return end
    local temporary = {}
    for _, joker in ipairs(G.jokers.cards) do
        if joker and joker.ability and joker.ability.hnds_black_temporary then
            temporary[#temporary + 1] = joker
        end
    end
    for _, joker in ipairs(temporary) do
        if SMODS and type(SMODS.destroy_cards) == 'function' then
            SMODS.destroy_cards(joker, { immediate = true, bypass_eternal = true })
        elseif joker.start_dissolve then
            joker:start_dissolve()
        end
    end
end

function HNDS.note_black_seal_card_drawn(drawn_card)
    if not (drawn_card and drawn_card.playing_card and G and G.GAME and G.hand
        and G.hand.cards and G.GAME.blind and drawn_card.area == G.hand)
    then return end
    for _, playing_card in ipairs(G.hand.cards) do
        if playing_card and playing_card ~= drawn_card and playing_card.seal == 'hnds_black'
            and playing_card.ability and playing_card.ability.hnds_black_armed
            and not playing_card.debuff and not playing_card.ability.hnds_black_used then
            local updated = math.min(BLACK_DRAW_THRESHOLD,
                math.max(0, tonumber(playing_card.ability.hnds_black_drawn) or 0) + 1)
            playing_card.ability.hnds_black_drawn = updated
            if updated >= BLACK_DRAW_THRESHOLD then
                playing_card.ability.hnds_black_used = true
                if G.E_MANAGER and Event then
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.05,
                        func = function()
                            create_temporary_black_seal_joker()
                            return true
                        end,
                    }))
                else
                    create_temporary_black_seal_joker()
                end
                if playing_card.juice_up then playing_card:juice_up(0.3, 0.5) end
            end
        end
    end
end

function HNDS.install_black_seal_draw_hook()
    if HNDS._black_seal_draw_hook_installed then return true end
    if not (CardArea and type(CardArea.emplace) == 'function') then return false end
    local emplace_ref = CardArea.emplace
    function CardArea:emplace(card, ...)
        local entering = card and G and self == G.hand and card.area ~= G.hand
        local result = emplace_ref(self, card, ...)
        if entering and card.area == G.hand and HNDS.note_black_seal_card_drawn then
            HNDS.note_black_seal_card_drawn(card)
        end
        return result
    end
    HNDS._black_seal_draw_hook_installed = true
    return true
end

function HNDS.process_black_seal_context(context)
    if not (context and G and G.GAME) then return end
    if context.setting_blind then
        reset_black_seal_progress()
        return
    end
    local drawn = context.hand_drawn or context.other_drawn
    if type(drawn) == 'table' and G.hand then
        for _, card in ipairs(drawn) do
            if card.area == G.hand then arm_black_seal(card) end
        end
    end
    if context.end_of_round and context.main_eval and not context.individual and not context.repetition then
        reset_black_seal_progress()
        if G.E_MANAGER and Event then
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.1,
                func = function()
                    cleanup_temporary_black_seal_jokers()
                    return true
                end,
            }))
        else
            cleanup_temporary_black_seal_jokers()
        end
    end
end

SMODS.Seal({
    key = 'black',
    badge_colour = HEX('545454'),
    atlas = 'Extras',
    pos = { x = 3, y = 1 },
    unlocked = true,
    loc_vars = function(self, info_queue, card)
        if info_queue then
            info_queue[#info_queue + 1] = { set = 'Other', key = 'hnds_shadow' }
        end
        local ability = card and card.ability or {}
        local drawn = math.max(0, tonumber(ability.hnds_black_drawn) or 0)
        return { vars = { BLACK_DRAW_THRESHOLD, math.max(0, BLACK_DRAW_THRESHOLD - drawn) } }
    end,
})

SMODS.Sticker({
    key = 'shadow',
    no_collection = true,
    atlas = 'Stickers',
    pos = { x = 2, y = 1 },
    badge_colour = HEX('545454'),
    rate = 0,
    default_compat = true,
    sets = { Joker = true },
    draw = function(self, card, layer) end,
})

HNDS.install_black_seal_draw_hook()
