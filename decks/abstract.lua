HNDS = HNDS or {}

local ABSTRACT_SUIT = {
    smiles = 'hnds_smiles',
    bananas = 'hnds_bananas',
    dices = 'hnds_dices',
    rubies = 'hnds_rubies',
    flowers = 'hnds_flowers',
    petals = 'hnds_petals',
    free_parking_spots = 'hnds_free_parking_spots',
    wraiths = 'hnds_wraiths',
    beans = 'hnds_beans',
}

HNDS.ABSTRACT_SUITS = ABSTRACT_SUIT

local function abstract_suit_pool_enabled(args)
    if args and args.initial_deck then return false end
    if not (G and G.STAGES and G.STAGE == G.STAGES.RUN and G.GAME) then return false end
    if hnds_config and hnds_config.enableChaosSuits == true then return true end
    return G.GAME.modifiers ~= nil and G.GAME.modifiers.hnds_abstract_deck == true or false
end

HNDS.abstract_suit_pool_enabled = abstract_suit_pool_enabled
HNDS.is_abstract_run_active = abstract_suit_pool_enabled

local suit_defs = {
    { key = 'smiles', card_key = 'M', y = 0, ui_x = 0, colour = 'c9a500', tooltip = 'hnds_suit_smiles' },
    { key = 'bananas', card_key = 'B', y = 1, ui_x = 1, colour = '9bb031', tooltip = 'hnds_suit_bananas' },
    { key = 'dices', card_key = 'I', y = 2, ui_x = 2, colour = '479d7a', tooltip = 'hnds_suit_dices' },
    { key = 'rubies', card_key = 'R', y = 3, ui_x = 3, colour = 'ff5d9b', tooltip = 'hnds_suit_rubies' },
    { key = 'flowers', card_key = 'F', y = 4, ui_x = 4, colour = '6CA2A6', tooltip = 'hnds_suit_flowers' },
    { key = 'petals', card_key = 'P', y = 5, ui_x = 5, colour = '7a73bb', tooltip = 'hnds_suit_petals' },
    { key = 'free_parking_spots', card_key = 'G', y = 6, ui_x = 6, colour = '4189e9', tooltip = 'hnds_suit_free_parking_spots' },
    { key = 'wraiths', card_key = 'W', y = 7, ui_x = 7, colour = '4f6367', tooltip = 'hnds_suit_wraiths' },
    { key = 'beans', card_key = 'E', y = 8, ui_x = 8, colour = '6e8965', tooltip = 'hnds_suit_beans' },
}

for _, def in ipairs(suit_defs) do
    local suit_key = def.key
    local card_key = def.card_key
    local row = def.y
    local colour = def.colour
    local ui_x = def.ui_x or row
    local tooltip = def.tooltip
    local full_key = 'hnds_' .. suit_key
    if SMODS and SMODS.Suit and SMODS.Suits and not SMODS.Suits[full_key] then
        SMODS.Suit {
            key = suit_key,
            card_key = card_key,
            pos = { y = row },
            ui_pos = { x = ui_x, y = 0 },
            lc_atlas = 'SUITS',
            hc_atlas = 'SUITS',
            lc_ui_atlas = 'SUITS_UI',
            hc_ui_atlas = 'SUITS_UI',
            lc_colour = colour,
            hc_colour = colour,
            in_pool = function(self, args) return abstract_suit_pool_enabled(args) end,
            loc_vars = function(self, info_queue, card)
                if info_queue then
                    local vars = nil
                    if suit_key == 'free_parking_spots' or suit_key == 'bananas' then
                        local denominator = suit_key == 'bananas' and 6 or 2
                        local probability_key = suit_key == 'bananas'
                            and 'hnds_abstract_bananas'
                            or 'hnds_abstract_free_parking'
                        local numerator = 1
                        if SMODS and type(SMODS.get_probability_vars) == 'function' then
                            numerator, denominator = SMODS.get_probability_vars(
                                card or self, 1, denominator, probability_key
                            )
                        elseif G and G.GAME and G.GAME.probabilities then
                            numerator = G.GAME.probabilities.normal or numerator
                        end
                        vars = { numerator, denominator }
                    end
                    info_queue[#info_queue + 1] = { set = 'Other', key = tooltip, vars = vars }
                end
            end,
        }
    end
end

local abstract_suit_colours = {}
for _, def in ipairs(suit_defs) do
    abstract_suit_colours['hnds_' .. def.key] = HEX(def.colour)
end

local function apply_abstract_suit_colours()
    if not G or not G.C then return end
    G.C.SO_1 = G.C.SO_1 or {}
    G.C.SO_2 = G.C.SO_2 or {}
    G.C.SUITS = G.C.SUITS or {}
    for key, colour in pairs(abstract_suit_colours) do
        local suit = SMODS and SMODS.Suits and SMODS.Suits[key]
        if suit then
            suit.lc_colour = colour
            suit.hc_colour = colour
        end
        G.C.SO_1[key] = colour
        G.C.SO_2[key] = colour
        G.C.SUITS[key] = colour
        if G.ARGS and G.ARGS.LOC_COLOURS then
            G.ARGS.LOC_COLOURS[key] = colour
        end
    end
end

apply_abstract_suit_colours()
HNDS.apply_abstract_suit_colours = apply_abstract_suit_colours

if loc_colour and not HNDS._abstract_loc_colour_hook then
    local abstract_loc_colour_ref = loc_colour
    function loc_colour(_c, _default)
        local colour = abstract_suit_colours[_c]
        if colour then return colour end
        return abstract_loc_colour_ref(_c, _default)
    end
    HNDS._abstract_loc_colour_hook = true
end

local function abstract_ability_source(card)
    if card and HNDS.is_faceless and HNDS.is_faceless(card) and HNDS.faceless_copy_target then
        return HNDS.faceless_copy_target(card) or card
    end
    return card
end

local function base_suit(card, suit_key)
    local source = abstract_ability_source(card)
    return source and source.base and source.base.suit == suit_key
end

local function active_suit(card, suit_key)
    return base_suit(card, suit_key) and not card.debuff
end

local abstract_suit_bridge_runtime = nil

local function abstract_has_no_suit(card)
    if HNDS.safe_has_no_suit then return HNDS.safe_has_no_suit(card) end
    if SMODS and type(SMODS.has_no_suit) == 'function' then
        local ok, result = pcall(SMODS.has_no_suit, card)
        if ok then return result == true end
    end
    return false
end

local function abstract_bridge_trigger(card, suit_key)
    return active_suit(card, suit_key) and not abstract_has_no_suit(card)
end

local function abstract_bridge_state(played)
    local state = {
        rubies = false,
        petals = false,
        cards = setmetatable({}, { __mode = 'k' }),
    }
    for _, card in ipairs(played or {}) do
        state.cards[card] = true
        if abstract_bridge_trigger(card, ABSTRACT_SUIT.rubies) then state.rubies = true end
        if abstract_bridge_trigger(card, ABSTRACT_SUIT.petals) then state.petals = true end
    end
    if not state.rubies and not state.petals then return nil end
    return state
end

local function abstract_bridge_matches(card, suit, first, second, trigger_suit)
    local source = abstract_ability_source(card)
    local printed = source and source.base and source.base.suit
    return (printed == first or printed == second or printed == trigger_suit)
        and (suit == first or suit == second)
end

local function abstract_current_bridge_state()
    if G and G.play and type(G.play.cards) == 'table' and #G.play.cards > 0 then
        return abstract_bridge_state(G.play.cards)
    end
    if G and G.hand and type(G.hand.highlighted) == 'table' and #G.hand.highlighted > 0 then
        return abstract_bridge_state(G.hand.highlighted)
    end
end

local abstract_is_suit_ref = Card.is_suit
if abstract_is_suit_ref and not HNDS._abstract_is_suit_hook then
    function Card:is_suit(suit, bypass_debuff, flush_calc, ...)
        local state = abstract_suit_bridge_runtime or abstract_current_bridge_state()
        if state and state.cards[self] and not abstract_has_no_suit(self)
            and (not self.debuff or bypass_debuff or flush_calc)
        then
            if state.rubies and abstract_bridge_matches(self, suit, 'Hearts', 'Diamonds', ABSTRACT_SUIT.rubies) then return true end
            if state.petals and abstract_bridge_matches(self, suit, 'Spades', 'Clubs', ABSTRACT_SUIT.petals) then return true end
        end
        return abstract_is_suit_ref(self, suit, bypass_debuff, flush_calc, ...)
    end
    HNDS._abstract_is_suit_hook = true
end

if type(evaluate_poker_hand) == 'function' and not HNDS._abstract_evaluate_poker_hand_hook then
    HNDS._abstract_evaluate_poker_hand_hook = true
    local abstract_evaluate_poker_hand_ref = evaluate_poker_hand
    function evaluate_poker_hand(hand, ...)
        local previous = abstract_suit_bridge_runtime
        abstract_suit_bridge_runtime = abstract_bridge_state(hand)
        local results = HNDS.pack(abstract_evaluate_poker_hand_ref(hand, ...))
        abstract_suit_bridge_runtime = previous
        return unpack(results, 1, results.n)
    end
end

if G and G.FUNCS and type(G.FUNCS.get_poker_hand_info) == 'function'
    and not HNDS._abstract_suit_bridge_hand_info_hook
then
    HNDS._abstract_suit_bridge_hand_info_hook = true
    local abstract_get_poker_hand_info_ref = G.FUNCS.get_poker_hand_info
    function G.FUNCS.get_poker_hand_info(...)
        local previous = abstract_suit_bridge_runtime
        local selected = select(1, ...)
        if type(selected) == 'table' then
            abstract_suit_bridge_runtime = abstract_bridge_state(selected)
        end
        local results = HNDS.pack(abstract_get_poker_hand_info_ref(...))
        abstract_suit_bridge_runtime = previous
        return unpack(results, 1, results.n)
    end
end

if G and G.FUNCS and type(G.FUNCS.evaluate_play) == 'function'
    and not HNDS._abstract_suit_bridge_evaluate_play_hook
then
    HNDS._abstract_suit_bridge_evaluate_play_hook = true
    local abstract_evaluate_play_ref = G.FUNCS.evaluate_play
    function G.FUNCS.evaluate_play(...)
        local previous = abstract_suit_bridge_runtime
        local played = G and G.play and G.play.cards or {}
        abstract_suit_bridge_runtime = abstract_bridge_state(played)
        local results = HNDS.pack(abstract_evaluate_play_ref(...))
        abstract_suit_bridge_runtime = previous
        return unpack(results, 1, results.n)
    end
end

local function played_cards(context)
    if context and type(context.full_hand) == 'table' and #context.full_hand > 0 then
        return context.full_hand
    end
    return G and G.play and G.play.cards or {}
end

local function probability_dice_cards(context)
    if context and type(context.full_hand) == 'table' and #context.full_hand > 0 then
        return context.full_hand
    end
    if context and not context.from_roll and G and G.hand and type(G.hand.highlighted) == 'table'
        and #G.hand.highlighted > 0
    then
        return G.hand.highlighted
    end
    return G and G.play and G.play.cards or {}
end

local function scoring_cards(context)
    if context and type(context.scoring_hand) == 'table' then return context.scoring_hand end
    return {}
end

local function unique_printed_suits(cards)
    local seen = {}
    for _, card in ipairs(cards or {}) do
        local source = abstract_ability_source(card)
        if source and source.base and source.base.suit and not (SMODS and SMODS.has_no_suit and SMODS.has_no_suit(card)) then
            seen[source.base.suit] = true
        end
    end
    local count = 0
    for _ in pairs(seen) do count = count + 1 end
    return count
end

local function count_active_dices(cards)
    local count = 0
    for _, card in ipairs(cards or {}) do
        if active_suit(card, ABSTRACT_SUIT.dices) then count = count + 1 end
    end
    return count
end

function HNDS.calculate_abstract_suits(context)
    if type(context) ~= 'table' then return nil end

    if context.mod_probability then
        local count = count_active_dices(probability_dice_cards(context))
        if count > 0 then
            return { numerator = (tonumber(context.numerator) or 0) + count }
        end
    end

    if context.individual and context.cardarea == G.play and context.other_card and not context.repetition then
        local card = context.other_card

        if active_suit(card, ABSTRACT_SUIT.bananas) then
            return { mult = 3 }
        end

        if active_suit(card, ABSTRACT_SUIT.smiles) then
            local faces = 0
            for _, played_card in ipairs(played_cards(context)) do
                if played_card and not played_card.debuff and played_card.is_face and played_card:is_face() then
                    faces = faces + 1
                end
            end
            if faces > 0 then return { mult = faces } end
        end

        if active_suit(card, ABSTRACT_SUIT.flowers) then
            local gain = unique_printed_suits(played_cards(context)) * 3
            if gain > 0 then
                card.ability = card.ability or {}
                card.ability.perma_bonus = (tonumber(card.ability.perma_bonus) or 0) + gain
                return {
                    chips = gain,
                    remove_default_message = true,
                    message = localize('k_upgrade_ex'),
                    colour = G.C.CHIPS,
                }
            end
        end
    end

    if context.destroy_card and active_suit(context.destroy_card, ABSTRACT_SUIT.bananas)
        and type(context.scoring_hand) == 'table'
        and not context.repetition
    then
        local scored = false
        for _, scoring_card in ipairs(context.scoring_hand) do
            if scoring_card == context.destroy_card then
                scored = true
                break
            end
        end
        if scored
            and SMODS and type(SMODS.pseudorandom_probability) == 'function'
            and SMODS.pseudorandom_probability(context.destroy_card, 'hnds_abstract_bananas', 1, 6)
        then
            return { remove = true }
        end
    end

    if context.individual and context.cardarea == G.hand and context.other_card and not context.repetition
        and not context.end_of_round
        and type(context.full_hand) == 'table' and #context.full_hand > 0
        and active_suit(context.other_card, ABSTRACT_SUIT.free_parking_spots)
        and SMODS and type(SMODS.pseudorandom_probability) == 'function'
        and SMODS.pseudorandom_probability(context.other_card, 'hnds_abstract_free_parking', 1, 2)
    then
        return { dollars = 1 }
    end
end

local abstract_wraith_state = setmetatable({}, { __mode = 'k' })
local abstract_wraith_refresh_pending = setmetatable({}, { __mode = 'k' })

local function abstract_runtime_area(area)
    return area ~= nil and G ~= nil and ((G.hand ~= nil and area == G.hand) or (G.play ~= nil and area == G.play))
end

local function abstract_recalc_debuff(card)
    if not (card and SMODS and type(SMODS.recalc_debuff) == 'function') then return end
    if not (G and G.GAME and G.GAME.blind) then return end
    SMODS.recalc_debuff(card)
end

local function abstract_card_id(card, fallback)
    return tostring(card and (card.playing_card or card.sort_id or card.ID) or fallback)
end

local function abstract_area_signature(area)
    if not (area and type(area.cards) == 'table') then return '' end
    local parts = {}
    for i, card in ipairs(area.cards) do
        parts[i] = abstract_card_id(card, i)
    end
    return table.concat(parts, '|')
end

local function abstract_build_wraith_state(area)
    local state = abstract_wraith_state[area] or {}
    local adjacent = setmetatable({}, { __mode = 'k' })
    local cards = area and area.cards or {}
    local has_wraith = false
    for i, card in ipairs(cards) do
        if base_suit(card, ABSTRACT_SUIT.wraiths) then has_wraith = true end
        if base_suit(cards[i - 1], ABSTRACT_SUIT.wraiths) or base_suit(cards[i + 1], ABSTRACT_SUIT.wraiths) then
            adjacent[card] = true
        end
    end
    state.adjacent = adjacent
    state.has_wraith = has_wraith
    state.signature = has_wraith and abstract_area_signature(area) or ''
    abstract_wraith_state[area] = state
    return state
end

local function abstract_needs_order_tracking(area)
    local state = abstract_wraith_state[area]
    if state and state.has_wraith then return true end
    for _, card in ipairs(area and area.cards or {}) do
        if base_suit(card, ABSTRACT_SUIT.wraiths) then return true end
    end
    return false
end

function HNDS.abstract_wraith_adjacent(card)
    local area = card and card.area
    if not abstract_runtime_area(area) then return false end
    local state = abstract_wraith_state[area] or abstract_build_wraith_state(area)
    return state.adjacent[card] == true
end

function HNDS.abstract_deck_preview_is_suit(card, suit)
    if not (card and card.is_suit) then return false end
    if HNDS.abstract_wraith_adjacent(card) then
        return card:is_suit(suit, true)
    end
    return card:is_suit(suit)
end

local abstract_set_debuff_ref = SMODS.current_mod.set_debuff
SMODS.current_mod.set_debuff = function(card)
    if abstract_set_debuff_ref then
        local result = abstract_set_debuff_ref(card)
        if result == true or result == 'prevent_debuff' then return result end
    end
    if HNDS.abstract_wraith_adjacent(card) then return true end
end

local function strip_legacy_bean_limit(card)
    if not (card and card.ability and card.ability.hnds_bean_card_limit) then return end
    local value = (tonumber(card.ability.card_limit) or 0) - 1
    card.ability.card_limit = value ~= 0 and value or nil
    card.ability.hnds_bean_card_limit = nil
end

local function set_bean_hand_bonus(card, enabled)
    if not (card and G and G.hand and G.hand.config) then return end
    card.ability = card.ability or {}
    strip_legacy_bean_limit(card)
    local applied = card.ability.hnds_bean_hand_bonus == true
    enabled = enabled == true
    if enabled == applied then return end
    G.hand.config.card_limit = math.max(0, (tonumber(G.hand.config.card_limit) or 0) + (enabled and 1 or -1))
    card.ability.hnds_bean_hand_bonus = enabled or nil
end

local function sync_bean_hand_bonus(card)
    set_bean_hand_bonus(card, card and card.area == (G and G.hand) and base_suit(card, ABSTRACT_SUIT.beans))
end

function HNDS.refresh_abstract_area(area)
    if not abstract_runtime_area(area) then return end
    local previous = abstract_wraith_state[area]
    local previous_adjacent = previous and previous.adjacent or {}
    local state = abstract_build_wraith_state(area)
    if area == G.hand then
        for _, card in ipairs(area.cards or {}) do sync_bean_hand_bonus(card) end
    end
    for _, card in ipairs(area.cards or {}) do
        if (previous_adjacent[card] == true) ~= (state.adjacent[card] == true) then
            abstract_recalc_debuff(card)
        end
    end
end

local function schedule_abstract_area_refresh(area)
    if area == nil or not abstract_runtime_area(area) or abstract_wraith_refresh_pending[area] then return end
    abstract_wraith_refresh_pending[area] = true
    local function refresh()
        abstract_wraith_refresh_pending[area] = nil
        HNDS.refresh_abstract_area(area)
        return true
    end
    if G and G.E_MANAGER and Event then
        G.E_MANAGER:add_event(Event({ trigger = 'immediate', blockable = false, func = refresh }))
    else
        refresh()
    end
end

if CardArea and type(CardArea.emplace) == 'function' and not HNDS._abstract_area_emplace_hook then
    HNDS._abstract_area_emplace_hook = true
    local abstract_emplace_ref = CardArea.emplace
    function CardArea:emplace(card, ...)
        local bean_bonus = self == (G and G.hand) and base_suit(card, ABSTRACT_SUIT.beans)
        if bean_bonus then set_bean_hand_bonus(card, true) end
        local results = HNDS.pack(abstract_emplace_ref(self, card, ...))
        if bean_bonus and card.area ~= self then set_bean_hand_bonus(card, false) end
        if abstract_runtime_area(self) then schedule_abstract_area_refresh(self) end
        return ((table and table.unpack) or unpack)(results, 1, results.n)
    end
end

if CardArea and type(CardArea.remove_card) == 'function' and not HNDS._abstract_area_remove_hook then
    HNDS._abstract_area_remove_hook = true
    local abstract_remove_ref = CardArea.remove_card
    function CardArea:remove_card(card, ...)
        local was_runtime = abstract_runtime_area(self)
        local was_hand = self == (G and G.hand) and card and card.ability and card.ability.hnds_bean_hand_bonus
        local results = HNDS.pack(abstract_remove_ref(self, card, ...))
        if was_hand then set_bean_hand_bonus(card, false) end
        if was_runtime then
            schedule_abstract_area_refresh(self)
            abstract_recalc_debuff(card)
        end
        return ((table and table.unpack) or unpack)(results, 1, results.n)
    end
end

if CardArea and type(CardArea.align_cards) == 'function' and not HNDS._abstract_area_align_hook then
    HNDS._abstract_area_align_hook = true
    local abstract_align_ref = CardArea.align_cards
    function CardArea:align_cards(...)
        local results = HNDS.pack(abstract_align_ref(self, ...))
        if self == (G and G.hand) and abstract_needs_order_tracking(self) then
            local state = abstract_wraith_state[self]
            local signature = abstract_area_signature(self)
            if not state or state.signature ~= signature then schedule_abstract_area_refresh(self) end
        end
        return ((table and table.unpack) or unpack)(results, 1, results.n)
    end
end

if Card and type(Card.set_base) == 'function' and not HNDS._abstract_set_base_hook then
    HNDS._abstract_set_base_hook = true
    local abstract_set_base_ref = Card.set_base
    function Card:set_base(base_card, ...)
        local results = HNDS.pack(abstract_set_base_ref(self, base_card, ...))
        if self.area == (G and G.hand) then sync_bean_hand_bonus(self) end
        if abstract_runtime_area(self.area) then schedule_abstract_area_refresh(self.area) end
        return ((table and table.unpack) or unpack)(results, 1, results.n)
    end
end

if Card and type(Card.load) == 'function' and not HNDS._abstract_card_load_hook then
    HNDS._abstract_card_load_hook = true
    local abstract_card_load_ref = Card.load
    function Card:load(...)
        local results = HNDS.pack(abstract_card_load_ref(self, ...))
        strip_legacy_bean_limit(self)
        if self.area == (G and G.hand) then sync_bean_hand_bonus(self) end
        if abstract_runtime_area(self.area) then schedule_abstract_area_refresh(self.area) end
        return ((table and table.unpack) or unpack)(results, 1, results.n)
    end
end

local abstract_cards = {
    { suit = ABSTRACT_SUIT.smiles, ranks = { '10', '9', '8', '7' } },
    { suit = ABSTRACT_SUIT.bananas, ranks = { '6', '5', '4', '3' } },
    { suit = ABSTRACT_SUIT.dices, ranks = { '2', '10', '9', '8' } },
    { suit = ABSTRACT_SUIT.rubies, ranks = { '7', '6', '5', '4' } },
    { suit = ABSTRACT_SUIT.flowers, ranks = { '3', '2', '10', '9' } },
    { suit = ABSTRACT_SUIT.petals, ranks = { '8', '7', '6', '5' } },
    { suit = ABSTRACT_SUIT.free_parking_spots, ranks = { '4', '3', '2', '10' } },
    { suit = ABSTRACT_SUIT.wraiths, ranks = { '9', '8', '7', '6' } },
    { suit = ABSTRACT_SUIT.beans, ranks = { '5', '4', '3', '2' } },
}

local function abstract_starting_specs()
    local specs = {}
    for _, group in ipairs(abstract_cards) do
        for _, rank in ipairs(group.ranks) do
            specs[#specs + 1] = { suit = group.suit, rank = rank }
        end
    end
    return specs
end

local function add_abstract_starting_cards()
    if not (G and G.GAME and G.deck and G.playing_cards and SMODS and type(SMODS.change_base) == 'function') then
        return false
    end
    if G.GAME.hnds_abstract_cards_added then return true end

    local numbered = {}
    for _, card in ipairs(G.playing_cards) do
        local id = card and card.base and tonumber(card.base.id)
        if id and id >= 2 and id <= 10 then numbered[#numbered + 1] = card end
    end

    local specs = abstract_starting_specs()
    if #numbered ~= #specs then return false end
    for i, card in ipairs(numbered) do
        SMODS.change_base(card, specs[i].suit, specs[i].rank)
    end

    if G.deck.set_ranks then G.deck:set_ranks() end
    if G.deck.align_cards then G.deck:align_cards() end
    if G.deck.hard_set_cards then G.deck:hard_set_cards() end
    if type(check_for_unlock) == 'function' then check_for_unlock({ type = 'modify_deck', deck = G.deck }) end
    G.GAME.hnds_abstract_cards_added = true
    return true
end

local ABSTRACT_SUIT_SET = {}
for _, suit_key in pairs(ABSTRACT_SUIT) do ABSTRACT_SUIT_SET[suit_key] = true end


local CHAOS_TAROTS = {
    c_sun = {
        vanilla = 'Hearts',
        suits = { 'Hearts', ABSTRACT_SUIT.rubies, ABSTRACT_SUIT.flowers },
        pos = { x = 4, y = 2 },
        seed = 'hnds_chaos_tarot_sun',
    },
    c_star = {
        vanilla = 'Diamonds',
        suits = { 'Diamonds', ABSTRACT_SUIT.rubies, ABSTRACT_SUIT.bananas, ABSTRACT_SUIT.smiles },
        pos = { x = 0, y = 3 },
        seed = 'hnds_chaos_tarot_star',
    },
    c_moon = {
        vanilla = 'Clubs',
        suits = { 'Clubs', ABSTRACT_SUIT.petals, ABSTRACT_SUIT.free_parking_spots },
        pos = { x = 3, y = 2 },
        seed = 'hnds_chaos_tarot_moon',
    },
    c_world = {
        vanilla = 'Spades',
        suits = { 'Spades', ABSTRACT_SUIT.petals, ABSTRACT_SUIT.beans, ABSTRACT_SUIT.wraiths },
        pos = { x = 2, y = 2 },
        seed = 'hnds_chaos_tarot_world',
    },
}

HNDS.CHAOS_TAROTS = CHAOS_TAROTS

local function chaos_tarots_enabled()
    return abstract_suit_pool_enabled({ source = 'hnds_chaos_tarot' })
end

HNDS.chaos_tarots_enabled = chaos_tarots_enabled

local function chaos_tarot_definition(card_or_center)
    local center = card_or_center
    if card_or_center and card_or_center.config and card_or_center.config.center then
        center = card_or_center.config.center
    end
    local key = center and center.key
    return key and CHAOS_TAROTS[key] or nil, key
end

local function chaos_tarot_valid_target(def, target)
    if not (def and target) then return false end
    for _, suit in ipairs(def.suits) do
        if suit == target then return true end
    end
    return false
end

local function chaos_tarot_roll_target(def)
    if not def then return nil end
    if type(pseudorandom_element) == 'function' and type(pseudoseed) == 'function' then
        return pseudorandom_element(def.suits, pseudoseed(def.seed))
    end
    return def.suits[math.random(#def.suits)]
end

local function chaos_tarot_detach_consumeable(card, center, target)
    if not (card and card.ability and center and center.config) then return end
    local config = {}
    for k, v in pairs(center.config) do config[k] = v end
    config.suit_conv = target
    card.ability.consumeable = config
end

local function chaos_tarot_refresh_ability(card, reroll)
    local def = chaos_tarot_definition(card)
    if not def or not card.ability then return end
    if chaos_tarots_enabled() then
        local target = card.ability.hnds_chaos_tarot_suit or card.hnds_chaos_tarot_suit
        if reroll or not chaos_tarot_valid_target(def, target) then
            target = chaos_tarot_roll_target(def)
        end
        card.hnds_chaos_tarot_suit = target
        card.ability.hnds_chaos_tarot_suit = target
        chaos_tarot_detach_consumeable(card, card.config and card.config.center, target)
    else
        card.hnds_chaos_tarot_suit = nil
        card.ability.hnds_chaos_tarot_suit = nil
        chaos_tarot_detach_consumeable(card, card.config and card.config.center, def.vanilla)
    end
end

local function chaos_tarot_sprite_pos_available(atlas, pos)
    if not (atlas and pos) then return false end
    local image = atlas.image
    if image and type(image.getDimensions) == 'function' then
        local width, height = image:getDimensions()
        if width and height and width > 0 and height > 0 then
            local scale = math.max(1, math.floor(width / 426 + 0.5))
            local columns = math.floor(width / (71 * scale))
            local rows = math.floor(height / (95 * scale))
            return pos.x >= 0 and pos.x < columns and pos.y >= 0 and pos.y < rows
        end
    end
    return pos.x >= 0 and pos.x < 6 and pos.y >= 0 and pos.y < 4
end

local function chaos_tarot_apply_sprite(card)
    local def = chaos_tarot_definition(card)
    if not (def and card and card.children and card.children.center) then return end
    if not chaos_tarots_enabled() then return end
    local atlas = G and G.ASSET_ATLAS and (G.ASSET_ATLAS.hnds_Consumables or G.ASSET_ATLAS.Consumables)
    if not chaos_tarot_sprite_pos_available(atlas, def.pos) then return end
    card.children.center.atlas = atlas
    if card.children.center.set_sprite_pos then
        card.children.center:set_sprite_pos(def.pos)
    end
end

local function chaos_tarot_loc_vars(center, card)
    local def = chaos_tarot_definition(center)
    if not def then return {} end
    local target = def.vanilla
    if chaos_tarots_enabled() and card and card.ability then
        target = card.ability.hnds_chaos_tarot_suit or target
    end
    local max_highlighted = center.config and center.config.max_highlighted or 3
    local suit_name = localize(target, 'suits_plural')
    local colour = G and G.C and G.C.SUITS and G.C.SUITS[target] or nil
    colour = colour or (G and G.C and (G.C.FILTER or G.C.ATTENTION or G.C.WHITE)) or { 1, 1, 1, 1 }
    return { vars = { max_highlighted, suit_name, colours = { colour } } }
end

if Card and type(Card.change_suit) == 'function' and not HNDS._abstract_change_suit_hook then
    HNDS._abstract_change_suit_hook = true
    local abstract_change_suit_ref = Card.change_suit
    function Card:change_suit(new_suit, ...)
        if ABSTRACT_SUIT_SET[new_suit] and SMODS and type(SMODS.change_base) == 'function' then
            SMODS.change_base(self, new_suit, nil)
            if G and G.GAME and G.GAME.blind and G.GAME.blind.debuff_card then
                G.GAME.blind:debuff_card(self)
            end
            return
        end
        return abstract_change_suit_ref(self, new_suit, ...)
    end
end

if SMODS and SMODS.Consumable and type(SMODS.Consumable.take_ownership) == 'function'
    and not HNDS._chaos_tarot_ownership
then
    HNDS._chaos_tarot_ownership = true
    local ownership_keys = { 'sun', 'star', 'moon', 'world' }
    for _, short_key in ipairs(ownership_keys) do
        SMODS.Consumable:take_ownership(short_key, {
            set_ability = function(self, card, initial, delay_sprites)
                local reroll = chaos_tarots_enabled() and not chaos_tarot_valid_target(chaos_tarot_definition(self), card.hnds_chaos_tarot_suit)
                chaos_tarot_refresh_ability(card, reroll)
            end,
            loc_vars = function(self, info_queue, card)
                return chaos_tarot_loc_vars(self, card)
            end,
            set_sprites = function(self, card, front)
                chaos_tarot_apply_sprite(card)
                card.hnds_chaos_tarot_visual = chaos_tarots_enabled()
            end,
            load = function(self, card, card_table, other_card)
                chaos_tarot_refresh_ability(card, false)
                chaos_tarot_apply_sprite(card)
                card.hnds_chaos_tarot_visual = chaos_tarots_enabled()
            end,
            update = function(self, card, dt)
                local active = chaos_tarots_enabled()
                if card.hnds_chaos_tarot_visual ~= active then
                    chaos_tarot_refresh_ability(card, active)
                    card.hnds_chaos_tarot_visual = active
                    if card.set_sprites and card.config and card.config.center then
                        card:set_sprites(card.config.center)
                    end
                    card.ability_UIBox_table = nil
                    if card.config then
                        card.config.h_popup = nil
                        card.config.h_popup_config = nil
                    end
                elseif active and card.ability and not chaos_tarot_valid_target(chaos_tarot_definition(self), card.ability.hnds_chaos_tarot_suit) then
                    chaos_tarot_refresh_ability(card, true)
                    card.ability_UIBox_table = nil
                    if card.config then
                        card.config.h_popup = nil
                        card.config.h_popup_config = nil
                    end
                end
            end,
        }, true)
    end
end

function HNDS.has_abstract_suit_in_list(list)
    if type(list) ~= 'table' then return false end
    for _, suit in ipairs(list) do
        if ABSTRACT_SUIT_SET[suit] then return true end
    end
    return false
end

function HNDS.get_pollable_suit_keys(source, excluded)
    local out = {}
    local buffer = SMODS and SMODS.Suit and SMODS.Suit.obj_buffer or {}
    local abstract_enabled = abstract_suit_pool_enabled({ source = source })
    for _, key in ipairs(buffer) do
        if key ~= excluded then
            local suit = SMODS and SMODS.Suits and SMODS.Suits[key]
            local allowed = suit ~= nil and (not ABSTRACT_SUIT_SET[key] or abstract_enabled)
            if allowed and SMODS and type(SMODS.add_to_pool) == 'function' then
                local ok, result = pcall(SMODS.add_to_pool, suit, { rank = '', source = source })
                allowed = ok and result == true
            elseif allowed and type(suit.in_pool) == 'function' then
                local ok, result = pcall(suit.in_pool, suit, { rank = '', source = source })
                allowed = ok and result ~= false
            end
            if allowed then out[#out + 1] = key end
        end
    end
    return out
end

function HNDS.poll_abstract_suit(source, excluded, seed_key)
    local suits = HNDS.get_pollable_suit_keys(source, excluded)
    if #suits == 0 then
        for _, suit in ipairs({ 'Spades', 'Hearts', 'Diamonds', 'Clubs' }) do
            if suit ~= excluded then suits[#suits + 1] = suit end
        end
    end
    if #suits == 0 then return nil end
    return pseudorandom_element(suits, pseudoseed(seed_key or source or 'hnds_abstract_suit'))
end

function HNDS.get_front_for_suit_rank(suit_key, rank_card_key)
    if not (G and G.P_CARDS and suit_key and rank_card_key) then return nil end
    local direct = G.P_CARDS[tostring(suit_key) .. '_' .. tostring(rank_card_key)]
    if direct then return direct end
    local suit = SMODS and SMODS.Suits and SMODS.Suits[suit_key]
    if suit and suit.card_key then
        return G.P_CARDS[tostring(suit.card_key) .. '_' .. tostring(rank_card_key)]
    end
end

local function abstract_apply_generated_suit(card, source, seed_key)
    if not (card and card.base and SMODS and type(SMODS.change_base) == 'function') then return card end
    if not abstract_suit_pool_enabled({ source = source }) then return card end
    local suit = HNDS.poll_abstract_suit(source, nil, seed_key)
    if suit and suit ~= card.base.suit then
        SMODS.change_base(card, suit, nil)
    end
    return card
end

if type(create_card) == 'function' and not HNDS._abstract_create_card_suit_hook then
    local abstract_create_card_ref = create_card
    function create_card(_type, area, legendary, rarity, skip_materialize, soulable, forced_key, key_append, ...)
        local card = abstract_create_card_ref(_type, area, legendary, rarity, skip_materialize, soulable, forced_key, key_append, ...)
        if forced_key == nil and (_type == 'Base' or _type == 'Enhanced') then
            abstract_apply_generated_suit(card, 'hnds_abstract_create_card_' .. tostring(key_append or _type), 'hnds_abstract_front_' .. tostring(key_append or _type))
        end
        return card
    end
    HNDS._abstract_create_card_suit_hook = true
end

if SMODS and type(SMODS.create_card) == 'function' and not HNDS._abstract_smods_create_card_suit_hook then
    local abstract_smods_create_card_ref = SMODS.create_card
    function SMODS.create_card(args, ...)
        local card = abstract_smods_create_card_ref(args, ...)
        local set = type(args) == 'table' and args.set or nil
        local playing_card_request = set == 'Playing Card' or set == 'Base' or set == 'Enhanced'
        if playing_card_request and type(args) == 'table' and args.front == nil and args.suit == nil then
            abstract_apply_generated_suit(card, 'hnds_abstract_smods_create_' .. tostring(args.key_append or set), 'hnds_abstract_smods_front_' .. tostring(args.key_append or set))
        end
        return card
    end
    HNDS._abstract_smods_create_card_suit_hook = true
end

if type(create_playing_card) == 'function' and not HNDS._abstract_create_playing_card_suit_hook then
    local abstract_create_playing_card_ref = create_playing_card
    function create_playing_card(card_init, area, skip_materialize, silent, colours, ...)
        local card = abstract_create_playing_card_ref(card_init, area, skip_materialize, silent, colours, ...)
        if type(card_init) == 'table' and card_init.front == nil then
            abstract_apply_generated_suit(card, 'hnds_abstract_create_playing_card', 'hnds_abstract_create_playing_card')
        end
        return card
    end
    HNDS._abstract_create_playing_card_suit_hook = true
end

if type(reset_ancient_card) == 'function' and not HNDS._abstract_ancient_suit_hook then
    local abstract_reset_ancient_card_ref = reset_ancient_card
    function reset_ancient_card(...)
        if not abstract_suit_pool_enabled({ source = 'hnds_abstract_ancient' }) then
            return abstract_reset_ancient_card_ref(...)
        end
        if not (G and G.GAME and G.GAME.current_round and G.GAME.current_round.ancient_card) then
            return abstract_reset_ancient_card_ref(...)
        end
        local current = G.GAME.current_round.ancient_card.suit
        local suit = HNDS.poll_abstract_suit('hnds_abstract_ancient', current, 'anc' .. tostring(G.GAME.round_resets and G.GAME.round_resets.ante or 0))
        if suit then
            G.GAME.current_round.ancient_card.suit = suit
            return
        end
        return abstract_reset_ancient_card_ref(...)
    end
    HNDS._abstract_ancient_suit_hook = true
end

local function selected_abstract_back()
    if not (G and G.GAME) then return false end
    if G.GAME.modifiers and G.GAME.modifiers.hnds_abstract_deck then return true end
    local selected = G.GAME.selected_back
    if selected then
        local center = selected.effect and selected.effect.center or selected.config and selected.config.center
        if center and center.key == 'b_hnds_abstract' then return true end
        if selected.key == 'b_hnds_abstract' then return true end
    end
    local viewed = G.GAME.viewed_back
    if viewed then
        local center = viewed.effect and viewed.effect.center or viewed.config and viewed.config.center
        if center and center.key == 'b_hnds_abstract' then return true end
        if viewed.key == 'b_hnds_abstract' then return true end
    end
    return false
end

local function abstract_cards_present()
    if not (G and type(G.playing_cards) == 'table') then return false end
    for _, card in ipairs(G.playing_cards) do
        if card and card.base and ABSTRACT_SUIT_SET[card.base.suit] then return true end
    end
    return false
end

function HNDS.is_abstract_deck()
    return selected_abstract_back()
end

function HNDS.is_abstract_preview_active()
    return selected_abstract_back() or abstract_cards_present()
end

function HNDS.is_abstract_config_view_active(list)
    if selected_abstract_back() then return false end
    if not (hnds_config and hnds_config.enableChaosSuits == true) then return false end
    if type(list) == 'table' and HNDS.has_abstract_suit_in_list(list) then return true end
    return abstract_cards_present()
end

function HNDS.is_abstract_suit_key(suit_key)
    return ABSTRACT_SUIT_SET[suit_key] == true
end

function HNDS.abstract_view_should_render_initial_suit(suit_key, index, num_suits, suits_per_page, visible_suit)
    if selected_abstract_back() then return false end
    if HNDS.is_abstract_config_view_active(visible_suit) then
        return not ABSTRACT_SUIT_SET[suit_key]
    end
    suits_per_page = suits_per_page or 4
    return (index >= 1 and index <= suits_per_page) or num_suits <= suits_per_page
end

function HNDS.abstract_view_page_count(visible_suit, suits_per_page)
    if selected_abstract_back() then return 1 end
    if HNDS.is_abstract_config_view_active(visible_suit) then return 2 end
    suits_per_page = suits_per_page or 4
    return math.max(1, math.ceil(#(visible_suit or {}) / suits_per_page))
end

function HNDS.abstract_view_show_page_cycle(visible_suit, suits_per_page)
    if selected_abstract_back() then return false end
    if HNDS.is_abstract_config_view_active(visible_suit) then return true end
    suits_per_page = suits_per_page or 4
    return type(visible_suit) == 'table' and #visible_suit > suits_per_page
end

function HNDS.abstract_config_page_two(visible_suit, current_option)
    return current_option == 2 and HNDS.is_abstract_config_view_active(visible_suit)
end

local function abstract_deck_owns_suit(suit_key)
    if not (G and type(G.playing_cards) == 'table') then return false end
    for _, card in ipairs(G.playing_cards) do
        if card and card.base and card.base.suit == suit_key then return true end
    end
    return false
end

function HNDS.hide_unused_abstract_preview_suits(hidden_suits, suit_tallies)
    if selected_abstract_back() or type(hidden_suits) ~= 'table' then return end
    for suit_key in pairs(ABSTRACT_SUIT_SET) do
        if not abstract_deck_owns_suit(suit_key) then
            hidden_suits[suit_key] = true
        end
    end
end

local function poll_abstract_first_shop_standard_pack()
    if not (G and G.P_CENTER_POOLS and G.P_CENTER_POOLS.Booster) then return nil end
    local choices = {}
    local total_weight = 0
    for _, center in ipairs(G.P_CENTER_POOLS.Booster) do
        if center and center.kind == 'Standard'
            and not (G.GAME and G.GAME.banned_keys and G.GAME.banned_keys[center.key])
        then
            local weight = tonumber(center.weight) or 0
            if weight > 0 then
                choices[#choices + 1] = { center = center, weight = weight }
                total_weight = total_weight + weight
            end
        end
    end
    if total_weight <= 0 then return nil end

    local roll = pseudorandom('hnds_abstract_first_shop_standard') * total_weight
    local cumulative = 0
    for _, entry in ipairs(choices) do
        cumulative = cumulative + entry.weight
        if roll < cumulative then return entry.center end
    end
    return choices[#choices] and choices[#choices].center or nil
end

function HNDS.abstract_force_first_shop_standard()
    if not (G and G.GAME and G.GAME.modifiers and G.GAME.modifiers.hnds_abstract_deck) then return end
    if G.GAME.hnds_abstract_first_shop_standard_done then return end
    if not (G.GAME.round_resets and G.GAME.round_resets.ante == 1) then return end
    if not (G.E_MANAGER and Event) then return end

    local attempts = 0
    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0,
        blockable = false,
        func = function()
            attempts = attempts + 1
            if G.GAME.hnds_abstract_first_shop_standard_done then return true end
            if not (G.shop_booster and type(G.shop_booster.cards) == 'table' and #G.shop_booster.cards >= 2) then
                return attempts >= 120
            end

            local buffoon = nil
            for _, booster in ipairs(G.shop_booster.cards) do
                if booster and booster.config and booster.config.center
                    and booster.config.center.kind == 'Buffoon'
                then
                    buffoon = booster
                    break
                end
            end

            local target = nil
            for _, booster in ipairs(G.shop_booster.cards) do
                if booster ~= buffoon then
                    target = booster
                    break
                end
            end
            target = target or G.shop_booster.cards[#G.shop_booster.cards]
            if not target then return true end

            if target.config and target.config.center and target.config.center.kind ~= 'Standard' then
                local center = poll_abstract_first_shop_standard_pack()
                if center then
                    local booster_pos = target.ability and target.ability.booster_pos
                    local couponed = target.ability and target.ability.couponed
                    target:set_ability(center, nil, false)
                    target.ability = target.ability or {}
                    target.ability.booster_pos = booster_pos
                    if couponed then target.ability.couponed = true end
                    if target.set_cost then target:set_cost() end
                    if booster_pos and G.GAME.current_round and type(G.GAME.current_round.used_packs) == 'table' then
                        G.GAME.current_round.used_packs[booster_pos] = center.key
                    end
                end
            end

            G.GAME.hnds_abstract_first_shop_standard_done = true
            return true
        end,
    }))
end

local abstract_vanilla_suit_order = { 'Hearts', 'Clubs', 'Spades', 'Diamonds' }
local abstract_custom_suit_order = {
    ABSTRACT_SUIT.smiles, ABSTRACT_SUIT.bananas, ABSTRACT_SUIT.dices,
    ABSTRACT_SUIT.rubies, ABSTRACT_SUIT.flowers, ABSTRACT_SUIT.petals,
    ABSTRACT_SUIT.free_parking_spots, ABSTRACT_SUIT.wraiths, ABSTRACT_SUIT.beans,
}

local function reorder_abstract_suits(list)
    if type(list) ~= 'table' then return end
    local original = {}
    local present = {}
    for _, suit in ipairs(list) do
        original[#original + 1] = suit
        present[suit] = true
    end
    for i = #list, 1, -1 do list[i] = nil end
    local added = {}
    local function add(suit)
        if present[suit] and not added[suit] then
            list[#list + 1] = suit
            added[suit] = true
        end
    end
    for _, suit in ipairs(abstract_vanilla_suit_order) do add(suit) end
    for _, suit in ipairs(original) do
        if not ABSTRACT_SUIT_SET[suit] then add(suit) end
    end
    for _, suit in ipairs(abstract_custom_suit_order) do add(suit) end
    for _, suit in ipairs(original) do add(suit) end
end

function HNDS.prepare_abstract_full_preview_suit_map(suit_map)
    if not HNDS.is_abstract_preview_active() and not HNDS.has_abstract_suit_in_list(suit_map) then return end
    reorder_abstract_suits(suit_map)
end

function HNDS.prepare_abstract_view_suit_order(visible_suit)
    if not HNDS.is_abstract_preview_active() and not HNDS.has_abstract_suit_in_list(visible_suit) then return end
    reorder_abstract_suits(visible_suit)
end

if G and G.UIDEF and type(G.UIDEF.deck_preview) == 'function' and not HNDS._deck_preview_popup_definition_hook then
    local hnds_deck_preview_ref = G.UIDEF.deck_preview
    function G.UIDEF.deck_preview(...)
        local definition = hnds_deck_preview_ref(...)
        if type(definition) == 'table' then
            definition.hnds_deck_preview_popup = true
        end
        return definition
    end
    HNDS._deck_preview_popup_definition_hook = true
end

if UIBox and type(UIBox.init) == 'function' and not HNDS._deck_preview_popup_uibox_hook then
    local hnds_uibox_init_ref = UIBox.init
    function UIBox:init(args)
        if args and type(args.definition) == 'table' and args.definition.hnds_deck_preview_popup then
            args.config = args.config or {}
            args.config.instance_type = 'POPUP'
        end
        return hnds_uibox_init_ref(self, args)
    end
    HNDS._deck_preview_popup_uibox_hook = true
end

if type(create_option_cycle) == 'function' and not HNDS._abstract_view_deck_page_cycle_hook then
    local hnds_create_option_cycle_ref = create_option_cycle
    function create_option_cycle(args)
        if args and args.opt_callback == 'your_suits_page' and selected_abstract_back() then
            return { n = G.UIT.R, config = { align = 'cm', minh = 0, minw = 0, padding = 0 }, nodes = {} }
        end
        return hnds_create_option_cycle_ref(args)
    end
    HNDS._abstract_view_deck_page_cycle_hook = true
end

local preview_groups = {
    { 'Hearts', 'Clubs', 'Spades', 'Diamonds' },
    { ABSTRACT_SUIT.smiles, ABSTRACT_SUIT.bananas, ABSTRACT_SUIT.dices },
    { ABSTRACT_SUIT.rubies, ABSTRACT_SUIT.flowers, ABSTRACT_SUIT.petals },
    { ABSTRACT_SUIT.free_parking_spots, ABSTRACT_SUIT.wraiths, ABSTRACT_SUIT.beans },
}

local abstract_config_preview_groups = {
    { ABSTRACT_SUIT.smiles, ABSTRACT_SUIT.bananas, ABSTRACT_SUIT.dices },
    { ABSTRACT_SUIT.rubies, ABSTRACT_SUIT.flowers, ABSTRACT_SUIT.petals },
    { ABSTRACT_SUIT.free_parking_spots, ABSTRACT_SUIT.wraiths, ABSTRACT_SUIT.beans },
}

local function append_abstract_card_rows(deck_tables, suit_cards, unplayed_only, groups)
    if type(deck_tables) ~= 'table' or type(suit_cards) ~= 'table' then return false end
    local before = #deck_tables
    for _, group in ipairs(groups) do
        local cards = {}
        for _, suit_key in ipairs(group) do
            local source = suit_cards[suit_key]
            if type(source) == 'table' then
                for _, card in ipairs(source) do cards[#cards + 1] = card end
            end
        end
        if #cards > 0 then
            local view_deck = CardArea(
                G.ROOM.T.x + 0.2 * G.ROOM.T.w / 2, G.ROOM.T.h,
                6.5 * G.CARD_W,
                0.6 * G.CARD_H,
                {
                    card_limit = #cards,
                    type = 'title',
                    view_deck = true,
                    highlight_limit = 0,
                    card_w = G.CARD_W * 0.7,
                    draw_layers = { 'card' },
                    negative_info = 'playing_card'
                }
            )
            deck_tables[#deck_tables + 1] = { n = G.UIT.R, config = { align = 'cm', padding = 0 }, nodes = {
                { n = G.UIT.O, config = { object = view_deck } }
            } }
            for _, original in ipairs(cards) do
                local greyed = nil
                if unplayed_only and not ((original.area and original.area == G.deck) or original.ability.wheel_flipped) then greyed = true end
                local copy = copy_card(original, nil, 0.7)
                copy.greyed = greyed
                if HNDS.abstract_wraith_adjacent(original) then copy.debuff = false end
                copy.T.x = view_deck.T.x + view_deck.T.w / 2
                copy.T.y = view_deck.T.y
                copy:hard_set_T()
                view_deck:emplace(copy)
            end
        end
    end
    return #deck_tables > before
end

function HNDS.append_abstract_view_deck_rows(deck_tables, suit_cards, unplayed_only)
    if not selected_abstract_back() then return false end
    return append_abstract_card_rows(deck_tables, suit_cards, unplayed_only, preview_groups)
end

function HNDS.append_abstract_config_view_deck_rows(deck_tables, suit_cards, unplayed_only, visible_suit, current_option)
    if not HNDS.abstract_config_page_two(visible_suit, current_option) then return false end
    return append_abstract_card_rows(deck_tables, suit_cards, unplayed_only, abstract_config_preview_groups)
end

function HNDS.append_abstract_config_tally_rows(tally_ui, suit_tallies, mod_suit_tallies, flip_col, visible_suit, current_option)
    if not HNDS.abstract_config_page_two(visible_suit, current_option) then return false end
    if type(tally_ui) ~= 'table' or type(suit_tallies) ~= 'table' or type(mod_suit_tallies) ~= 'table' then return false end
    if type(tally_sprite) ~= 'function' then return false end
    local added = false
    for _, group in ipairs(abstract_config_preview_groups) do
        local nodes = {}
        for _, suit_key in ipairs(group) do
            if (suit_tallies[suit_key] or 0) > 0 and SMODS and SMODS.Suits and SMODS.Suits[suit_key] then
                nodes[#nodes + 1] = tally_sprite(
                    SMODS.Suits[suit_key].ui_pos,
                    {
                        { string = '' .. (suit_tallies[suit_key] or 0), colour = flip_col },
                        { string = '' .. (mod_suit_tallies[suit_key] or 0), colour = G.C.BLUE }
                    },
                    { localize(suit_key, 'suits_plural') },
                    suit_key
                )
            end
        end
        if #nodes > 0 then
            tally_ui[#tally_ui + 1] = { n = G.UIT.R, config = { align = 'cm', minh = 0.05, padding = 0.05 }, nodes = nodes }
            added = true
        end
    end
    return added
end

SMODS.Back {
    key = 'abstract',
    atlas = 'Extras',
    pos = { x = 0, y = 3 },
    unlocked = false,
    discovered = true,
    check_for_unlock = function(self, args)
        return HNDS.unlock_condition_met('abstract', args)
    end,
    apply = function(self, back)
        G.GAME.modifiers.hnds_abstract_deck = true
        G.GAME.hnds_abstract_cards_added = false
        G.GAME.hnds_abstract_first_shop_standard_done = false
        G.E_MANAGER:add_event(Event({
            trigger = 'immediate',
            delay = 0,
            blockable = false,
            func = add_abstract_starting_cards,
        }))
    end,
}
