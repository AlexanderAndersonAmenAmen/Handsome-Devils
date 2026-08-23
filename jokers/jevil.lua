HNDS = HNDS or {}

local JEVIL_STICKER = 'hnds_jevil_wild'

local function hnds_jevil_card_id(card)
    if not card then return nil end
    return tostring(card.playing_card or card.sort_id or card.ID or card)
end

local function hnds_jevil_is_target_suit(card)
    if not card then return false end
    -- Jevil only claims cards whose actual printed/base suit is Spades or Clubs.
    -- Do not use Card:is_suit here: once Jevil's Sticker is active that method
    -- intentionally reports every suit, which would make load-time cleanup
    -- unable to distinguish old Hearts/Diamonds markers.
    local suit = card.base and card.base.suit
    return suit == 'Spades' or suit == 'Clubs'
end

local function hnds_jevil_is_stone(card)
    if not card then return false end
    local center = card.config and card.config.center
    if center and center.key == 'm_stone' then return true end
    -- Aberrant's fused Stone is intentionally dominant over Wild. Jevil is a
    -- temporary Sticker/virtual Wild state, never an Enhancement, so it must
    -- neither apply to Stone-fused Aberrant cards nor touch their fusion list.
    if HNDS and HNDS.is_aberrant and HNDS.is_aberrant(card)
        and HNDS.aberrant_has_fusion and HNDS.aberrant_has_fusion(card, 'm_stone')
    then
        return true
    end
    return false
end

local function hnds_jevil_marked(card)
    if not card then return false end
    if card.ability and card.ability[JEVIL_STICKER] then return true end
    if not (G and G.GAME and type(G.GAME.hnds_jevil_round_cards) == 'table') then return false end
    local id = hnds_jevil_card_id(card)
    return id and G.GAME.hnds_jevil_round_cards[id] == true or false
end

local function hnds_jevil_apply_tooltip(card)
    if not card then return end
    card.ability = card.ability or {}
    -- add_sticker is idempotent for an already-present sticker.  Calling it
    -- again is intentional: after loading a mid-round save it rebuilds the
    -- registered Sticker state/visual even if only the serialized ability flag
    -- survived.
    if card.add_sticker then card:add_sticker(JEVIL_STICKER, true) end
    card.ability[JEVIL_STICKER] = true
    card.ability[JEVIL_STICKER .. '_applied'] = true
end

local function hnds_jevil_remove_tooltip(card)
    if not card then return end
    if card.remove_sticker and card.ability and card.ability[JEVIL_STICKER] then
        card:remove_sticker(JEVIL_STICKER)
    end
    if card.ability then
        card.ability[JEVIL_STICKER] = nil
        card.ability[JEVIL_STICKER .. '_applied'] = nil
    end
end

function HNDS.jevil_mark_starting_hand(cards)
    if not (G and G.GAME) then return false end
    local owned = SMODS and SMODS.find_card and SMODS.find_card('j_hnds_jevil') or {}
    if type(owned) ~= 'table' or #owned == 0 then return false end

    -- Jevil deliberately reads the hand *now*, after the start-of-round event
    -- queue has finished its draw effects.  Do not use the original
    -- first_hand_drawn list here: Jokers such as Jokestone may have added more
    -- cards to G.hand in the meantime.
    local drawn = type(cards) == 'table' and cards or ((G.hand and G.hand.cards) or {})
    if #drawn == 0 then return false end

    local marked = {}
    local visible_cards = {}
    for _, playing_card in ipairs(drawn) do
        if playing_card and not playing_card.removed
            and hnds_jevil_is_target_suit(playing_card)
            and not hnds_jevil_is_stone(playing_card)
        then
            local id = hnds_jevil_card_id(playing_card)
            if id then
                marked[id] = true
                visible_cards[#visible_cards + 1] = playing_card
                hnds_jevil_apply_tooltip(playing_card)
            end
        end
    end
    if not next(marked) then return false end

    G.GAME.hnds_jevil_round_cards = marked

    -- The indicator happens at the same moment Jevil claims the final opening
    -- hand.  At this point the cards are already visible, so juice_up cannot be
    -- swallowed by the opening draw animation.
    for _, playing_card in ipairs(visible_cards) do
        if playing_card and not playing_card.removed and playing_card.juice_up then
            playing_card:juice_up(0.55, 0.45)
        end
    end

    -- One status popup per Jevil that actually supplied the round effect.
    for _, jevil in ipairs(owned) do
        if jevil and not jevil.removed then
            if jevil.juice_up then jevil:juice_up(0.3, 0.3) end
            if type(card_eval_status_text) == 'function' then
                card_eval_status_text(jevil, 'extra', nil, nil, nil, {
                    message = localize('k_hnds_jevil_chaos'),
                    colour = G.C.PURPLE,
                })
            end
        end
    end

    -- Jevil resolves after the normal opening-hand autosave boundary. Persist
    -- the marked card IDs + Sticker ability flags now so leaving/re-entering
    -- the run does not erase the temporary Wild state.
    if type(save_run) == 'function' then save_run() end

    return true
end

local function hnds_jevil_any_pending_draws()
    if not (G and G.playing_cards) then return false end
    for _, playing_card in ipairs(G.playing_cards) do
        if playing_card and playing_card.ability and playing_card.ability.hnds_drawing then
            return true
        end
    end
    return false
end

-- first_hand_drawn is emitted before every Joker's start-of-round draw Events
-- have necessarily finished.  Queue two non-blocking tail sentinels.  The
-- first lets all calculate callbacks enqueue their work; the second is placed
-- behind those parent Events and then puts the final Jevil application behind
-- any draw Events those parents created.  The final Event is blockable and
-- waits for Handsome Devils' explicit draw-in-progress markers as an extra
-- safeguard, but never blocks the draw queue itself.
function HNDS.jevil_schedule_starting_hand()
    if not (G and G.GAME and G.E_MANAGER and Event) then
        return HNDS.jevil_mark_starting_hand((G and G.hand and G.hand.cards) or {})
    end
    if G.GAME.hnds_jevil_round_cards or G.GAME.hnds_jevil_pending_start then return false end

    local owned = SMODS and SMODS.find_card and SMODS.find_card('j_hnds_jevil') or {}
    if type(owned) ~= 'table' or #owned == 0 then return false end
    G.GAME.hnds_jevil_pending_start = true

    local pending_draw_waits = 0
    G.E_MANAGER:add_event(Event({
        blocking = false,
        blockable = true,
        func = function()
            G.E_MANAGER:add_event(Event({
                blocking = false,
                blockable = true,
                func = function()
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.08,
                        blocking = false,
                        blockable = true,
                        func = function()
                            if hnds_jevil_any_pending_draws() then
                                pending_draw_waits = pending_draw_waits + 1
                                -- Never leave an Event resident forever if a draw
                                -- marker is stranded by another mod or a bad save.
                                if pending_draw_waits < 240 then return false end
                            end
                            if not (G and G.GAME) then return true end
                            G.GAME.hnds_jevil_pending_start = nil
                            HNDS.jevil_mark_starting_hand((G.hand and G.hand.cards) or {})
                            return true
                        end,
                    }))
                    return true
                end,
            }))
            return true
        end,
    }))
    return true
end

function HNDS.jevil_clear_round()
    if G and G.playing_cards then
        for _, playing_card in ipairs(G.playing_cards) do
            hnds_jevil_remove_tooltip(playing_card)
        end
    end
    if G and G.GAME then
        G.GAME.hnds_jevil_round_cards = nil
        G.GAME.hnds_jevil_wild_cards = nil
        G.GAME.hnds_jevil_pending_start = nil
    end
end

SMODS.Sticker {
    key = 'jevil_wild',
    atlas = 'Stickers',
    pos = { x = 3, y = 4 },
    badge_colour = G.C.PURPLE,
    rate = 0,
    default_compat = true,
    sets = { Default = true, Enhanced = true },
    hide_badge = true,
    apply = function(self, card, val)
        SMODS.Sticker.apply(self, card, val)
        card.ability = card.ability or {}
        if val then
            card.ability[JEVIL_STICKER] = true
            card.ability[JEVIL_STICKER .. '_applied'] = true
        else
            card.ability[JEVIL_STICKER] = nil
            card.ability[JEVIL_STICKER .. '_applied'] = nil
        end
    end,
    -- Vanilla Tweaks makes Wild cards immune to being flipped. Jevil's Wild is
    -- virtual rather than the m_wild center, so mirror that clause while its
    -- temporary Sticker is active.
    calculate = function(self, card, context)
        if hnds_config and hnds_config.enableVanillaTweaks
            and context and context.stay_flipped
            and context.other_card == card
            and hnds_jevil_marked(card)
        then
            return { prevent_stay_flipped = true }
        end
    end,
}

-- Rebuild a saved mid-round Jevil marker after Game:start_run finishes loading
-- the serialized playing cards. This also migrates saves created by versions
-- that stored only G.GAME.hnds_jevil_round_cards and not the Sticker flag.
function HNDS.jevil_rehydrate_round()
    if not (G and G.GAME and type(G.GAME.hnds_jevil_round_cards) == 'table'
        and type(G.playing_cards) == 'table')
    then
        return false
    end

    local restored = false
    for _, playing_card in ipairs(G.playing_cards) do
        local id = hnds_jevil_card_id(playing_card)
        if id and G.GAME.hnds_jevil_round_cards[id] then
            if hnds_jevil_is_stone(playing_card) or not hnds_jevil_is_target_suit(playing_card) then
                -- Migrate older mid-round saves that may have marked Stone,
                -- Stone-fused Aberrant, Heart, Diamond, or other-suit cards
                -- before Jevil was restricted to Spades and Clubs.
                G.GAME.hnds_jevil_round_cards[id] = nil
                hnds_jevil_remove_tooltip(playing_card)
            else
                hnds_jevil_apply_tooltip(playing_card)
                restored = true
            end
        end
    end
    return restored
end

if Game and type(Game.start_run) == 'function' and not HNDS._jevil_start_run_restore_hook then
    HNDS._jevil_start_run_restore_hook = true
    local hnds_jevil_start_run_ref = Game.start_run
    function Game:start_run(...)
        local pack = HNDS.pack
        local unpack_values = table.unpack or unpack
        local result = pack(hnds_jevil_start_run_ref(self, ...))
        if G and G.GAME and type(G.GAME.hnds_jevil_round_cards) == 'table' then
            if G.E_MANAGER and Event then
                local rehydrate_waits = 0
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.05,
                    blocking = false,
                    blockable = true,
                    func = function()
                        if not (G and type(G.playing_cards) == 'table') then
                            rehydrate_waits = rehydrate_waits + 1
                            if rehydrate_waits < 240 then return false end
                            return true
                        end
                        HNDS.jevil_rehydrate_round()
                        return true
                    end,
                }))
            else
                HNDS.jevil_rehydrate_round()
            end
        end
        return unpack_values(result, 1, result.n)
    end
end

SMODS.Joker {
    key = 'jevil',
    atlas = 'Jokers',
    pos = { x = 3, y = 7 },
    rarity = 1,
    cost = 4,
    unlocked = false,
    discovered = false,
    unlock_condition = { type = "hnds_joker_unlock", key = "jevil" },
    locked_loc_vars = function(self)
        return HNDS.joker_locked_loc_vars("jevil")
    end,
    check_for_unlock = function(self, args)
        return HNDS.joker_unlock_condition_met("jevil", args)
    end,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    calculate = function(self, card, context) end,
    attributes = { 'suit', 'modify_card' },
}


-- Guarantee a hover tooltip without relying on Sticker UI timing.  Steamodded's
-- normal card UI builder uses generate_card_ui for info-queue descriptors, so
-- append our Other descriptor after the base playing-card tooltip is built.
if Card and Card.generate_UIBox_ability_table and not HNDS._jevil_card_tooltip_hook then
    local hnds_jevil_generate_ui_ref = Card.generate_UIBox_ability_table
    function Card:generate_UIBox_ability_table(...)
        local full_UI_table = hnds_jevil_generate_ui_ref(self, ...)
        if full_UI_table and HNDS.is_jevil_wild and HNDS.is_jevil_wild(self)
            and not full_UI_table.hnds_jevil_info_added
            and type(generate_card_ui) == 'function'
        then
            full_UI_table.hnds_jevil_info_added = true
            generate_card_ui({ set = 'Other', key = 'hnds_jevil_wild', vars = {} }, full_UI_table)
        end
        return full_UI_table
    end
    HNDS._jevil_card_tooltip_hook = true
end

-- Round-boundary triggers for Jevil's starting-hand marking. These contexts
-- fire outside any single card's calculate, so they ride the mod-level
-- context registry; the marked hand stays Wild even if Jevil is sold.
HNDS.on_context(function(context)
    -- Defer until every start-of-round draw effect has had a chance to
    -- resolve, then mark the final cards actually present in hand.
    if context.first_hand_drawn and HNDS.jevil_schedule_starting_hand then
        HNDS.jevil_schedule_starting_hand()
    end
    -- The temporary tooltip marker is cleared only at round end.
    if context.end_of_round and context.main_eval and HNDS.jevil_clear_round then
        HNDS.jevil_clear_round()
    end
end)
