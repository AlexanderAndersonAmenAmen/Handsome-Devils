local pack = HNDS.pack
local unpack_values = table.unpack or unpack
local source = 'hnds_mp_crystal'

local function key(blind)
    if not (HNDS.mp_is_pvp(blind) and blind and not blind.disabled and not blind.hnds_crystal_disabled) then return end
    return blind.hnds_crystal_key
end

local function clean(blind)
    if not blind then return end
    for _, sprite in ipairs({blind, blind.children and blind.children.animatedSprite}) do
        if sprite.hnds_crystal_popup_key then
            sprite.hnds_crystal_popup_key = nil
            sprite.hovering = false
            if sprite.config then sprite.config.h_popup = nil end
            Node.stop_hover(sprite)
        end
    end
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

local set_ref = Blind.set_blind
function Blind:set_blind(center, reset, silent, ...)
    if center and not reset then
        self.hnds_crystal_disabled = true
        clean(self)
        self.hnds_crystal_key = nil
        self.hnds_crystal_disabled = nil
        self.hnds_crystal_prepped = true
        if G.GAME then G.GAME.hnds_mp_result = nil; G.GAME.hnds_mp_authoritative_result = nil end
    end
    local result = pack(set_ref(self, center, reset, silent, ...))
    if center and not reset and not HNDS.mp_is_pvp(self) then G.GAME.hnds_mp_crystal_key = nil end
    if center and not reset and HNDS.mp_is_pvp(self) then
        self.hnds_crystal_key = G.GAME.hnds_mp_crystal_key
        if key(self) == 'bl_final_acorn' then
            G.jokers:unhighlight_all()
            for _, card in ipairs(G.jokers.cards) do
                if card.facing ~= 'back' then card:flip() end
            end
            G.jokers:shuffle('hnds_mp_crystal_acorn')
        end
        if key(self) == 'bl_final_leaf' then
            for _, card in ipairs(G.playing_cards or {}) do SMODS.debuff_card(card, true, source) end
        end
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
    if not sprite or sprite.hover == sprite.hnds_crystal_hover then return end
    local hover_ref = sprite.hover
    local stop_ref = sprite.stop_hover
    sprite.states.hover.can = true
    sprite.states.collide.can = true
    sprite.hover = function(self, ...)
        local active = slot and HNDS.mp_slot_is_pvp(slot) and slot == G.GAME.blind_on_deck
            and G.GAME.hnds_mp_crystal_key or (not slot and key(blind))
        if not active then return hover_ref(self, ...) end
        if self.hovering and self.hnds_crystal_popup_key == active then return end
        self.hovering = true
        self.hnds_crystal_popup_key = active
        self.config = self.config or {}
        self.config.h_popup = create_UIBox_blind_popup(G.P_BLINDS[active], true)
        self.config.h_popup_config = { align = 'cr', offset = {x = 0.1, y = 0}, parent = self }
        Node.hover(self)
    end
    sprite.hnds_crystal_hover = sprite.hover
    sprite.stop_hover = function(self, ...)
        self.hovering = false
        self.hnds_crystal_popup_key = nil
        if self.config then self.config.h_popup = nil end
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
                if sprite and sprite.set_sprite_pos and sprite.atlas and sprite.atlas.px == 34 then
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
    if not key(blind) then return end
    attach(blind, blind)
    attach(blind.children and blind.children.animatedSprite, blind)
end
