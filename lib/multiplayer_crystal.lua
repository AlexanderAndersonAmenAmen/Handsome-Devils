local pack = HNDS.pack
local unpack_values = table.unpack or unpack
local source = 'hnds_mp_crystal'

local function key(blind)
    if not (blind and blind.hnds_crystal_key and not blind.disabled and not blind.hnds_crystal_disabled
        and HNDS.mp_is_pvp(blind)) then return end
    return blind.hnds_crystal_key
end

local function clear_popup(sprite)
    if not (sprite and sprite.hnds_mp_effect_popup) then return end
    sprite.hnds_mp_effect_popup = nil
    sprite.hovering = false
    if sprite.config then sprite.config.h_popup = nil end
    Node.stop_hover(sprite)
end

local function clean(blind)
    if not blind then return end
    clear_popup(blind)
    clear_popup(blind.children and blind.children.animatedSprite)
    if not blind.hnds_crystal_key then return end
    for _, card in ipairs(G.playing_cards or {}) do
        SMODS.debuff_card(card, false, source)
        if card.ability.hnds_crystal_forced then
            card.ability.hnds_crystal_forced = nil
            card.ability.forced_selection = nil
        end
    end
    for _, card in ipairs(G.jokers and G.jokers.cards or {}) do
        SMODS.debuff_card(card, false, source)
        if blind.hnds_crystal_key == 'bl_final_acorn' and card.facing == 'back' then card:flip() end
    end
    blind.hnds_crystal_heart = nil
end

function HNDS.mp_queue_crystal_reward()
    local game = G.GAME
    local blind = game and game.blind
    if not (blind and HNDS.mp_is_pvp(blind)) then return false end
    local api = HNDS.mp_backend()
    local spectator = api and api.SPECTATOR
    if spectator and (spectator.is_spectating or spectator.is_spectator_role) then return false end

    local crystal = blind.hnds_crystal_key
    if not crystal and blind.hnds_crystal_pvp_slot and blind.hnds_crystal_pvp_slot == game.blind_on_deck
        and game.round_resets and blind.hnds_crystal_pvp_ante == game.round_resets.ante then
        crystal = HNDS.MP.crystal_for_round(game.blind_on_deck)
    end
    if not crystal then return false end

    if not blind.hnds_crystal_rewarded then
        blind.hnds_crystal_rewarded = true
        game.hnds_crystal_queued = true
    end
    return true
end

function HNDS.mp_defer_crystal_match_end(finish)
    local game = G.GAME
    if not (game and G.STAGE == G.STAGES.RUN and HNDS.open_crystal_pack) then return false end
    if game.hnds_crystal_match_end_pending then return true end
    if not (HNDS.mp_queue_crystal_reward() and game.hnds_crystal_queued) then return false end

    local state, state_complete = game.PACK_INTERRUPT or G.STATE, G.STATE_COMPLETE
    local opening = false
    local function prepare_pack()
        local blind = game.blind
        if HNDS.stop_platinum_boss_stack then
            HNDS.stop_platinum_boss_stack({ blind_defeated = true })
        end
        if blind then
            blind.hnds_crystal_disabled = true
            clean(blind)
        end
        opening = true
        G.STATE = G.STATES.PLAY_TAROT
        G.STATE_COMPLETE = true
    end
    if not HNDS.open_crystal_pack(prepare_pack) then return false end

    game.hnds_crystal_queued = nil
    game.hnds_crystal_match_end_pending = true
    if not game.PACK_INTERRUPT then
        G.STATE = G.STATES.PLAY_TAROT
        G.STATE_COMPLETE = true
    end
    G.E_MANAGER:add_event(Event({
        blocking = false,
        blockable = false,
        func = function()
            if G.GAME ~= game or G.STAGE ~= G.STAGES.RUN then return true end
            if not opening or game.PACK_INTERRUPT then return false end
            game.hnds_crystal_match_end_pending = nil
            G.STATE, G.STATE_COMPLETE = state, state_complete
            finish()
            return true
        end,
    }))
    return true
end

local win_game_ref = win_game
function win_game(...)
    local args = pack(...)
    if HNDS.mp_defer_crystal_match_end(function() win_game_ref(unpack_values(args, 1, args.n)) end) then return end
    return win_game_ref(...)
end

local update_game_over_ref = Game.update_game_over
function Game:update_game_over(dt, ...)
    if not G.STATE_COMPLETE then
        local args = pack(...)
        if HNDS.mp_defer_crystal_match_end(function() update_game_over_ref(self, dt, unpack_values(args, 1, args.n)) end) then return end
    end
    return update_game_over_ref(self, dt, ...)
end

local set_ref = Blind.set_blind
function Blind:set_blind(center, reset, silent, ...)
    local game = G.GAME
    if not (game and game.blind == self and center and not reset) then
        return set_ref(self, center, reset, silent, ...)
    end
    self.hnds_crystal_disabled = true
    clean(self)
    self.hnds_crystal_key = nil
    self.hnds_crystal_rewarded = nil
    self.hnds_crystal_pvp_slot = nil
    self.hnds_crystal_pvp_ante = nil
    self.hnds_crystal_disabled = nil
    self.hnds_crystal_prepped = true
    game.hnds_mp_result = nil
    game.hnds_mp_authoritative_result = nil
    local result = pack(set_ref(self, center, reset, silent, ...))
    if HNDS.mp_is_pvp(self) then
        self.hnds_crystal_key = game.hnds_mp_crystal_key
        self.hnds_crystal_pvp_slot = game.blind_on_deck
        self.hnds_crystal_pvp_ante = game.round_resets and game.round_resets.ante
        local active = key(self)
        if active == 'bl_final_acorn' then
            G.jokers:unhighlight_all()
            for _, card in ipairs(G.jokers.cards) do
                if card.facing ~= 'back' then card:flip() end
            end
            G.jokers:shuffle('hnds_mp_crystal_acorn')
        elseif active == 'bl_final_leaf' then
            for _, card in ipairs(G.playing_cards or {}) do SMODS.debuff_card(card, true, source) end
        end
    else
        game.hnds_mp_crystal_key = nil
    end
    return unpack_values(result, 1, result.n)
end

local draw_ref = Blind.drawn_to_hand
function Blind:drawn_to_hand(...)
    local result = pack(draw_ref(self, ...))
    local active = key(self)
    if active == 'bl_final_bell' and G.hand and #G.hand.cards > 0 then
        local forced = false
        for _, card in ipairs(G.hand.cards) do forced = forced or card.ability.forced_selection end
        if not forced then
            G.hand:unhighlight_all()
            local card = pseudorandom_element(G.hand.cards, pseudoseed('hnds_mp_crystal_bell'))
            if card then
                card.ability.forced_selection = true
                card.ability.hnds_crystal_forced = true
                G.hand:add_to_highlighted(card)
            end
        end
    elseif active == 'bl_final_heart' and self.hnds_crystal_prepped then
        local choices = {}
        for _, card in ipairs(G.jokers.cards) do
            SMODS.debuff_card(card, false, source)
            if card ~= self.hnds_crystal_heart or #G.jokers.cards < 2 then choices[#choices + 1] = card end
        end
        local card = #choices > 0 and pseudorandom_element(choices, pseudoseed('hnds_mp_crystal_heart'))
        self.hnds_crystal_heart = card or nil
        if card then SMODS.debuff_card(card, true, source); card:juice_up() end
        self.hnds_crystal_prepped = false
    end
    return unpack_values(result, 1, result.n)
end

local press_ref = Blind.press_play
function Blind:press_play(...)
    if key(self) == 'bl_final_heart' then self.hnds_crystal_prepped = true end
    return press_ref(self, ...)
end

local debuff_ref = Blind.debuff_card
function Blind:debuff_card(card, ...)
    if card and key(self) == 'bl_final_leaf' and card.area ~= G.jokers then
        card.ability.debuff_sources = card.ability.debuff_sources or {}
        card.ability.debuff_sources[source] = true
    end
    return debuff_ref(self, card, ...)
end

for _, method in ipairs({'disable', 'defeat'}) do
    local ref = Blind[method]
    Blind[method] = function(self, ...)
        if self.hnds_crystal_key then
            self.hnds_crystal_disabled = true
            clean(self)
        else
            clear_popup(self)
            clear_popup(self.children and self.children.animatedSprite)
        end
        return ref(self, ...)
    end
end

local sell_ref = Card.sell_card
function Card:sell_card(...)
    local blind = G.GAME and G.GAME.blind
    if self.ability and self.ability.set == 'Joker' and key(blind) == 'bl_final_leaf' then
        blind.hnds_crystal_disabled = true
        clean(blind)
    end
    return sell_ref(self, ...)
end

local preview_sprites = setmetatable({}, {__mode = 'k'})
local function attach(sprite, blind, slot)
    if not sprite or sprite.hnds_mp_effect_hover then return end
    local hover_ref = sprite.hover
    local stop_ref = sprite.stop_hover
    sprite.states.hover.can = true
    sprite.states.collide.can = true
    sprite.hover = function(self, ...)
        if self.hovering and self.hnds_mp_effect_popup then return end
        local game = G.GAME
        local ante = game and game.round_resets and game.round_resets.ante
        local pvp_preview = slot and HNDS.mp_slot_is_pvp(slot)
        local crystal = pvp_preview and slot == game.blind_on_deck and game.hnds_mp_crystal_key or key(blind)
        local stacked = ante and HNDS.blind_upgrade_active and HNDS.blind_upgrade_active()
            and ((blind and not blind.disabled and blind.hnds_platinum_boss_stack_active)
                or (pvp_preview and HNDS.platinum_boss_upgrade_count_for_ante(ante) > 0))
        local popup
        if stacked then
            popup = HNDS.create_blind_stack_tooltip(ante, crystal)
        elseif crystal then
            popup = create_UIBox_blind_popup(G.P_BLINDS[crystal], true)
        end
        if not popup then return (hover_ref or Node.hover)(self, ...) end
        self.hovering = true
        self.hnds_mp_effect_popup = true
        self.config = self.config or {}
        self.config.h_popup = popup
        self.config.h_popup_config = { align = 'cr', offset = {x = 0.1, y = 0}, parent = self }
        Node.hover(self)
    end
    sprite.hnds_mp_effect_hover = true
    sprite.stop_hover = function(self, ...)
        self.hovering = false
        if self.hnds_mp_effect_popup then
            self.hnds_mp_effect_popup = nil
            if self.config then self.config.h_popup = nil end
        end
        if stop_ref then return stop_ref(self, ...) end
        return Node.stop_hover(self)
    end
end

if type(create_UIBox_blind_choice) == 'function' then
    local choice_ref = create_UIBox_blind_choice
    function create_UIBox_blind_choice(slot, ...)
        local result = pack(choice_ref(slot, ...))
        if HNDS.mp_slot_is_pvp(slot) then
            local function visit(node)
                if type(node) ~= 'table' then return end
                local sprite = node.config and node.config.object
                local atlases = G.ANIMATION_ATLAS
                if sprite and sprite.set_sprite_pos and sprite.atlas
                    and (sprite.atlas == atlases.mp_player_blind_col or sprite.atlas == atlases.player_blind_col) then
                    preview_sprites[sprite] = slot
                    attach(sprite, nil, slot)
                end
                for _, child in ipairs(node.nodes or {}) do visit(child) end
            end
            visit(result[1])
        end
        return unpack_values(result, 1, result.n)
    end
end

function HNDS.mp_refresh_crystal_tooltip()
    local active = G.GAME and G.GAME.hnds_mp_crystal_key
    for sprite, slot in pairs(preview_sprites) do
        if active and slot == G.GAME.blind_on_deck and sprite.hnds_crystal_sprite_key ~= active then
            sprite.hnds_crystal_sprite_key = active
            sprite.atlas = G.ANIMATION_ATLAS.mp_player_blind_col or sprite.atlas
            sprite:set_sprite_pos(G.P_BLINDS[active].pos)
        end
    end
    local blind = G.GAME and G.GAME.blind
    if not (HNDS.mp_is_pvp(blind) and blind and (key(blind) or blind.hnds_platinum_boss_stack_active)) then return end
    attach(blind, blind)
    attach(blind.children and blind.children.animatedSprite, blind)
end
