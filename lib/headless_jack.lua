HNDS = HNDS or {}

local JOL_RANK_KEY = 'Jack'
local LEGACY_JOL_RANK_KEY = 'hnds_jack_of_lanterns'
local JOL_SUIT_KEY = 'hnds_lanterns'
local JOL_OWNER_FIELD = 'hnds_jack_of_lanterns_owner'

local function hnds_jol_owner(card)
    return card and card.ability and card.ability[JOL_OWNER_FIELD] or nil
end

function HNDS.is_jack_of_lanterns(card)
    return hnds_jol_owner(card) ~= nil
end

local function hnds_jol_has_enhancement(card, key)
    if not card then return false end
    local center = card.config and card.config.center
    if center and center.key == key then return true end
    local fusions = card.ability and card.ability.hnds_aberrant_fusions
    if type(fusions) == 'table' then
        for _, fusion_key in ipairs(fusions) do
            if fusion_key == key then return true end
        end
    end
    return false
end

function HNDS.jack_of_lanterns_native_xmult(card)
    if not HNDS.is_jack_of_lanterns(card) or hnds_jol_has_enhancement(card, 'm_stone') then return nil end
    if hnds_jol_has_enhancement(card, 'm_glass') then return 5 end
    return 3
end

local function hnds_card_identity(card)
    if not card then return nil end
    return tostring(card.playing_card or card.sort_id or card.ID or card)
end

function HNDS.is_jevil_wild(card)
    if not card then return false end


    local suit = card.base and card.base.suit
    if suit ~= 'Spades' and suit ~= 'Clubs' then return false end
    if card.ability and card.ability.hnds_jevil_wild then return true end
    if not (G and G.GAME) then return false end
    local id = hnds_card_identity(card)
    if not id then return false end
    if type(G.GAME.hnds_jevil_round_cards) == 'table' and G.GAME.hnds_jevil_round_cards[id] then
        return true
    end

    if type(G.GAME.hnds_jevil_wild_cards) == 'table' then
        for _, marked in pairs(G.GAME.hnds_jevil_wild_cards) do
            if type(marked) == 'table' and marked[id] then return true end
        end
    end
    return false
end

local function hnds_no_suit(card)


    if HNDS.safe_has_no_suit then return HNDS.safe_has_no_suit(card) end
    return SMODS and SMODS.has_no_suit and SMODS.has_no_suit(card) or false
end

local function hnds_no_rank(card)
    if HNDS.safe_has_no_rank then return HNDS.safe_has_no_rank(card) end
    return SMODS and SMODS.has_no_rank and SMODS.has_no_rank(card) or false
end


if SMODS and SMODS.Suit and SMODS.Suits and not SMODS.Suits[JOL_SUIT_KEY] then
    SMODS.Suit {
        key = 'lanterns',
        card_key = 'L',
        pos = { y = 0 },
        ui_pos = { x = 0, y = 0 },
        lc_atlas = 'JackOfLanterns',
        hc_atlas = 'JackOfLanterns',
        lc_colour = (G.C and G.C.ORANGE) or HEX('F5A623'),
        hc_colour = (G.C and G.C.ORANGE) or HEX('F5A623'),
        in_pool = function(self, args) return false end,
    }
end


if SMODS and SMODS.Rank and SMODS.Ranks and not SMODS.Ranks[LEGACY_JOL_RANK_KEY] then
    SMODS.Rank {
        key = 'jack_of_lanterns',
        card_key = 'JOL',
        pos = { x = 0 },
        nominal = 10,
        shorthand = 'J',
        face = true,
        next = { 'Queen' },
        strength_effect = { ignore = true },
        lc_atlas = 'JackOfLanterns',
        hc_atlas = 'JackOfLanterns',
        suit_map = { [JOL_SUIT_KEY] = 0 },
        in_pool = function(self, args) return false end,
    }
end

local function hnds_jol_nope(card)
    if not card or card.removed then return end
    if card.juice_up then card:juice_up(0.35, 0.35) end
    if play_sound then play_sound('hnds_curse_used', 1, 0.75) end
    if card_eval_status_text then
        card_eval_status_text(card, 'extra', nil, nil, nil, {
            message = localize and localize('k_nope_ex') or 'Nope!',
            colour = (G and G.C and (G.C.FILTER or G.C.RED)) or { 1, 0.2, 0.2, 1 },
        })
    end
end


if SMODS and type(SMODS.modify_rank) == 'function' and not HNDS._jol_modify_rank_guard then
    HNDS._jol_modify_rank_guard = true
    local modify_rank_ref = SMODS.modify_rank
    function SMODS.modify_rank(card, amount, ...)
        if HNDS.is_jack_of_lanterns(card) and tonumber(amount or 0) ~= 0 then
            hnds_jol_nope(card)
            return card
        end
        return modify_rank_ref(card, amount, ...)
    end
end

if SMODS and type(SMODS.change_base) == 'function' and not HNDS._jol_change_base_guard then
    HNDS._jol_change_base_guard = true
    local change_base_ref = SMODS.change_base
    function SMODS.change_base(card, suit, rank, ...)
        if HNDS.is_jack_of_lanterns(card) then
            local rank_change = rank ~= nil
                and rank ~= JOL_RANK_KEY and rank ~= LEGACY_JOL_RANK_KEY
            local suit_change = suit ~= nil and suit ~= JOL_SUIT_KEY
            if rank_change or suit_change then
                hnds_jol_nope(card)


                return card
            end
        end
        return change_base_ref(card, suit, rank, ...)
    end
end

if Card and type(Card.set_base) == 'function' and not HNDS._jol_set_base_guard then
    HNDS._jol_set_base_guard = true
    local set_base_ref = Card.set_base
    function Card:set_base(base_card, ...)
        if HNDS.is_jack_of_lanterns(self) and base_card then
            local requested_rank = base_card.value
            local requested_suit = base_card.suit
            local rank_change = requested_rank ~= nil
                and requested_rank ~= JOL_RANK_KEY and requested_rank ~= LEGACY_JOL_RANK_KEY
            local suit_change = requested_suit ~= nil and requested_suit ~= JOL_SUIT_KEY
            if rank_change or suit_change then
                hnds_jol_nope(self)


                base_card = self.config and self.config.card or base_card
            end
        end
        return set_base_ref(self, base_card, ...)
    end
end


if Card and type(Card.get_id) == 'function' and not HNDS._jol_get_id_guard then
    HNDS._jol_get_id_guard = true
    local get_id_ref = Card.get_id
    function Card:get_id(...)
        if HNDS.is_jack_of_lanterns(self) and not hnds_no_rank(self) then return 11 end
        return get_id_ref(self, ...)
    end
end


if Card and Card.is_suit and not HNDS._special_any_suit_card_hook then
    local is_suit_ref = Card.is_suit
    function Card:is_suit(suit, ...)
        if HNDS.is_jevil_wild(self) and not hnds_no_suit(self) then return true end
        return is_suit_ref(self, suit, ...)
    end
    HNDS._special_any_suit_card_hook = true
end

if SMODS and SMODS.has_any_suit and not HNDS._special_any_suit_smods_hook then
    local has_any_suit_ref = SMODS.has_any_suit
    function SMODS.has_any_suit(card, ...)
        if HNDS.is_jevil_wild(card) and not hnds_no_suit(card) then return true end
        return has_any_suit_ref(card, ...)
    end
    HNDS._special_any_suit_smods_hook = true
end


if Card and type(Card.get_chip_x_mult) == 'function' and not HNDS._jol_xmult_hook then
    HNDS._jol_xmult_hook = true
    local get_chip_x_mult_ref = Card.get_chip_x_mult
    function Card:get_chip_x_mult(...)
        local value = get_chip_x_mult_ref(self, ...)
        if HNDS.is_jack_of_lanterns(self) and not self.debuff then
            local native_xmult = HNDS.jack_of_lanterns_native_xmult(self)
            if native_xmult == 5 then return 5 end
            if native_xmult == 3 then
                if type(value) == 'number' and value ~= 0 then return value * 3 end
                return 3
            end
        end
        return value
    end
end


if Card and type(Card.get_chip_bonus) == 'function' and not HNDS._jol_chip_bonus_hook then
    HNDS._jol_chip_bonus_hook = true
    local get_chip_bonus_ref = Card.get_chip_bonus
    function Card:get_chip_bonus(...)
        if not (HNDS.is_jack_of_lanterns(self) and self.base) then
            return get_chip_bonus_ref(self, ...)
        end

        local old_nominal = self.base.nominal
        self.base.nominal = 0
        local results = HNDS.pack(pcall(get_chip_bonus_ref, self, ...))
        self.base.nominal = old_nominal
        if not results[1] then error(results[2], 0) end
        return ((table and table.unpack) or unpack)(results, 2, results.n)
    end
end


if Card and type(Card.generate_UIBox_ability_table) == 'function' and not HNDS._jol_ui_hook then
    HNDS._jol_ui_hook = true
    local generate_ability_ui_ref = Card.generate_UIBox_ability_table

    local function hnds_jol_enhancement_xmult(card)
        if not card or not card.ability then return 1 end
        local xmult = tonumber(card.ability.x_mult) or 1
        local cfg = card.config and card.config.center and card.config.center.config
        local cfg_xmult = cfg and tonumber(cfg.Xmult or cfg.x_mult)
        if cfg_xmult and cfg_xmult ~= 1 then xmult = cfg_xmult end
        return xmult
    end

    local function hnds_jol_localized_nodes(key, xmult)
        local nodes = {}
        localize {
            type = 'descriptions',
            set = 'Other',
            key = key,
            nodes = nodes,
            vars = { xmult or 3 },
        }
        return nodes
    end

    local function hnds_jol_prepend(dst, src, index)
        if type(dst) ~= 'table' or type(src) ~= 'table' then return end
        index = math.max(1, math.min(tonumber(index) or 1, #dst + 1))
        for i = #src, 1, -1 do table.insert(dst, index, src[i]) end
    end

    function Card:generate_UIBox_ability_table(...)
        if not (HNDS.is_jack_of_lanterns(self) and self.base) then
            return generate_ability_ui_ref(self, ...)
        end

        local args = HNDS.pack(...)
        local old_nominal = self.base.nominal
        local native_xmult = HNDS.jack_of_lanterns_native_xmult(self)
        local stone = native_xmult == nil
        local glass = native_xmult == 5
        local enhancement_xmult = hnds_jol_enhancement_xmult(self)
        local folds_xmult = not stone and enhancement_xmult ~= 1
        local old_ability_xmult = self.ability and self.ability.x_mult
        local old_ability_Xmult = self.ability and self.ability.Xmult
        local center = self.config and self.config.center
        local center_cfg = center and center.config
        local old_center_Xmult = center_cfg and center_cfg.Xmult
        local old_center_x_mult = center_cfg and center_cfg.x_mult
        local old_loc_vars = center and center.loc_vars

        self.base.nominal = 0
        if folds_xmult then
            local combined = glass and 5 or enhancement_xmult * 3
            if self.ability then
                self.ability.x_mult = combined
                self.ability.Xmult = combined
            end
            if center_cfg then
                center_cfg.Xmult = combined
                center_cfg.x_mult = combined
            end
            if glass and type(old_loc_vars) == 'function' then
                center.loc_vars = function(center_self, info_queue, card)
                    local ret = old_loc_vars(center_self, info_queue, card) or {}
                    ret.vars = ret.vars or {}
                    ret.vars[1] = 5
                    return ret
                end
            end
        end

        local results = HNDS.pack(pcall(generate_ability_ui_ref, self,
            ((table and table.unpack) or unpack)(args, 1, args.n)))

        self.base.nominal = old_nominal
        if self.ability then
            self.ability.x_mult = old_ability_xmult
            self.ability.Xmult = old_ability_Xmult
        end
        if center_cfg then
            center_cfg.Xmult = old_center_Xmult
            center_cfg.x_mult = old_center_x_mult
        end
        if center then center.loc_vars = old_loc_vars end

        if not results[1] then error(results[2], 0) end
        local result = results[2]
        if result and result.main and not result.hnds_jol_main_added then
            result.hnds_jol_main_added = true
            if not stone then
                if folds_xmult then
                    hnds_jol_prepend(result.main,
                        hnds_jol_localized_nodes('hnds_jack_of_lanterns_removed_only', glass and 5 or enhancement_xmult * 3),
                        math.min(2, #result.main + 1))
                else
                    hnds_jol_prepend(result.main,
                        hnds_jol_localized_nodes('hnds_jack_of_lanterns_card', native_xmult or 3), 1)
                end
            end
        end
        return result
    end
end


if Card and Card.set_ability and not HNDS._jol_set_ability_hook then
    local set_ability_ref = Card.set_ability
    function Card:set_ability(...)
        local owner = hnds_jol_owner(self)
        local results = HNDS.pack(set_ability_ref(self, ...))
        if owner and self.ability then self.ability[JOL_OWNER_FIELD] = owner end
        return ((table and table.unpack) or unpack)(results, 1, results.n)
    end
    HNDS._jol_set_ability_hook = true
end


if type(copy_card) == 'function' and not HNDS._jol_copy_card_hook then
    local copy_card_ref = copy_card
    function copy_card(source, ...)
        local copied = copy_card_ref(source, ...)
        if copied and copied.ability then
            copied.ability[JOL_OWNER_FIELD] = hnds_jol_owner(source)
        end
        return copied
    end
    HNDS._jol_copy_card_hook = true
end

function HNDS.add_jack_of_lanterns(source_joker, owner)
    if source_joker and (source_joker.removed or not source_joker.config
        or not source_joker.config.center or source_joker.config.center.key ~= 'j_hnds_headless_joker')
    then
        return nil
    end
    if not (G and G.deck and G.playing_cards and SMODS and SMODS.create_card) then return nil end
    local new_card = SMODS.create_card({
        set = 'Base',
        area = G.deck,
        rank = 'Jack',
        suit = JOL_SUIT_KEY,
        key_append = 'hnds_headless',
        skip_materialize = true,
    })
    if not new_card then return nil end

    new_card.ability = new_card.ability or {}
    new_card.ability[JOL_OWNER_FIELD] = owner
    G.playing_card = (tonumber(G.playing_card) or 0) + 1
    new_card.playing_card = G.playing_card
    if new_card.add_to_deck then new_card:add_to_deck() end
    G.deck.config.card_limit = (G.deck.config.card_limit or #G.deck.cards) + 1
    table.insert(G.playing_cards, new_card)
    G.deck:emplace(new_card)
    if new_card.start_materialize then new_card:start_materialize() end
    if playing_card_joker_effects then playing_card_joker_effects({ new_card }) end
    if source_joker and source_joker.juice_up then source_joker:juice_up(0.4, 0.4) end
    return new_card
end

function HNDS.remove_jack_of_lanterns(owner)
    if not (owner and G and G.playing_cards) then return end
    local targets = {}
    for _, playing_card in ipairs(G.playing_cards) do
        if hnds_jol_owner(playing_card) == owner then
            targets[#targets + 1] = playing_card
        end
    end
    if #targets == 0 then return end

    if SMODS and SMODS.destroy_cards then
        SMODS.destroy_cards(targets)
    else
        for _, playing_card in ipairs(targets) do
            if playing_card.start_dissolve then playing_card:start_dissolve() end
        end
    end
end


if type(create_UIBox_customize_deck) == 'function' and not HNDS._jol_customize_deck_options_hook then
    HNDS._jol_customize_deck_options_hook = true
    local create_UIBox_customize_deck_ref = create_UIBox_customize_deck
    function create_UIBox_customize_deck(...)
        local suit_class = SMODS and SMODS.Suit
        local obj_list_ref = suit_class and suit_class.obj_list
        local scoped_obj_list

        if type(obj_list_ref) == 'function' then
            scoped_obj_list = function(self, ...)
                local results = HNDS.pack(obj_list_ref(self, ...))
                local list = results[1]
                if type(list) == 'table' then
                    local filtered = {}
                    for _, suit in ipairs(list) do
                        if not (suit and suit.key == JOL_SUIT_KEY) then
                            filtered[#filtered + 1] = suit
                        end
                    end
                    results[1] = filtered
                end
                return ((table and table.unpack) or unpack)(results, 1, results.n)
            end
            suit_class.obj_list = scoped_obj_list
        end

        local results = HNDS.pack(pcall(create_UIBox_customize_deck_ref, ...))


        if suit_class and scoped_obj_list and suit_class.obj_list == scoped_obj_list then
            suit_class.obj_list = obj_list_ref
        end

        if not results[1] then error(results[2], 0) end
        return ((table and table.unpack) or unpack)(results, 2, results.n)
    end
end


function HNDS.prepare_jol_deck_preview(visible_suit)
    if type(visible_suit) ~= 'table' then return 4 end

    local lanterns_index = nil
    for i, suit_key in ipairs(visible_suit) do
        if suit_key == JOL_SUIT_KEY then
            lanterns_index = i
            break
        end
    end
    if not lanterns_index then return 4 end

    table.remove(visible_suit, lanterns_index)
    table.insert(visible_suit, math.min(5, #visible_suit + 1), JOL_SUIT_KEY)
    return 4
end

function HNDS.hide_jol_suit_tally(hidden_suits)
    if type(hidden_suits) == 'table' then
        hidden_suits[JOL_SUIT_KEY] = true
    end
end


function HNDS.jol_preview_rank_key(card)
    if card and HNDS.is_jack_of_lanterns(card) then return 'Jack' end
    return card and card.base and card.base.value or nil
end
