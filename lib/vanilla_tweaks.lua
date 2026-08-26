


HNDS = HNDS or {}
local MOD = SMODS.current_mod


local function take_vanilla_ownership(class, key, definition)
    return class:take_ownership(key, definition, true)
end

local function is_playing_card(card)
    local set = card and card.ability and card.ability.set
    return set == 'Default' or set == 'Enhanced'
end

local function extra_value(card, key, fallback)
    local extra = card and card.ability and card.ability.extra
    if type(extra) == 'table' and extra[key] ~= nil then return extra[key] end
    if type(extra) == 'number' then return extra end
    return fallback
end

local function is_wild(card)
    if not card then return false end
    if HNDS.is_faceless and HNDS.is_faceless(card) and HNDS.faceless_copy_target then
        local target = HNDS.faceless_copy_target(card)
        if target then return is_wild(target) end
    end
    local center = card.config and card.config.center
    if center and center.key == 'm_wild' then return true end
    if HNDS.aberrant_has_fusion then
        local ok, result = pcall(HNDS.aberrant_has_fusion, card, 'm_wild')
        if ok and result then return true end
    end
    return HNDS.is_jevil_wild and HNDS.is_jevil_wild(card) or false
end

local function active_splash()
    if not SMODS.find_card then return false end
    return next(SMODS.find_card('j_splash') or {}) ~= nil
end

local old_set_debuff = MOD.set_debuff
MOD.set_debuff = function(card)
    if old_set_debuff then
        local result = old_set_debuff(card)
        if result ~= nil then return result end
    end
    if is_playing_card(card) and (is_wild(card) or active_splash()) then
        return 'prevent_debuff'
    end
end

local function boss_blind_active()
    return G and G.GAME and G.GAME.blind and G.GAME.blind.get_type
        and G.GAME.blind:get_type() == 'Boss'
end

local function add_dollars(amount)
    if not (G and G.GAME) then return end
    G.GAME.dollar_buffer = (G.GAME.dollar_buffer or 0) + amount
    return {
        dollars = amount,
        func = function()
            G.E_MANAGER:add_event(Event({
                func = function()
                    G.GAME.dollar_buffer = 0
                    return true
                end,
            }))
        end,
    }
end

local function flower_pot_suit_cap()


    local registered = 0
    for suit_key, _ in pairs((SMODS and SMODS.Suits) or {}) do
        if suit_key ~= 'hnds_lanterns' then registered = registered + 1 end
    end
    return math.max(4, registered)
end

local function count_unique_suits(cards)
    if type(cards) ~= 'table' then return 0 end

    local cap = flower_pot_suit_cap()
    if HNDS and type(HNDS.get_unique_suits) == 'function' then
        return math.min(cap, HNDS.get_unique_suits(cards))
    end

    local suits, wilds = {}, 0
    for _, playing_card in ipairs(cards) do
        if playing_card and not playing_card.debuff
            and not (HNDS.safe_has_no_suit and HNDS.safe_has_no_suit(playing_card) or false)
        then
            if is_wild(playing_card) then
                wilds = wilds + 1
            elseif playing_card.base and playing_card.base.suit
                and playing_card.base.suit ~= 'hnds_lanterns'
            then
                suits[playing_card.base.suit] = true
            end
        end
    end
    local count = 0
    for _ in pairs(suits) do count = count + 1 end
    return math.min(cap, count + wilds)
end

local function highlighted_scoring_hand()
    if not (G and G.hand and G.hand.highlighted and #G.hand.highlighted > 0) then return {} end

    if active_splash() then return G.hand.highlighted end
    if not (G.FUNCS and type(G.FUNCS.get_poker_hand_info) == 'function') then return {} end
    local ok, _, _, _, scoring_hand = pcall(G.FUNCS.get_poker_hand_info, G.hand.highlighted)
    if ok and type(scoring_hand) == 'table' then return scoring_hand end
    return {}
end

local function selected_flower_pot_mult()
    return count_unique_suits(highlighted_scoring_hand())
end

local function stone_card_tally()
    local tally = 0
    for _, playing_card in ipairs((G and G.playing_cards) or {}) do
        if HNDS.card_has_stone and HNDS.card_has_stone(playing_card) then
            tally = tally + 1
        end
    end
    return tally
end

local vanilla_rank_ids = {
    ['2'] = 2, ['3'] = 3, ['4'] = 4, ['5'] = 5, ['6'] = 6, ['7'] = 7,
    ['8'] = 8, ['9'] = 9, ['10'] = 10, Jack = 11, Queen = 12, King = 13, Ace = 14,
}

local function current_mail_rank()
    local state = G and G.GAME and G.GAME.current_round and G.GAME.current_round.mail_card
    local rank = state and state.rank or 'Ace'
    local rank_obj = SMODS.Ranks and SMODS.Ranks[rank]
    return { rank = rank, id = (rank_obj and rank_obj.id) or vanilla_rank_ids[rank] or 14 }
end


take_vanilla_ownership(SMODS.Tag, 'juggle', {
    config = { type = 'round_start_bonus', h_size = 3 },
    apply = function(self, tag, context)
        if context.type == 'round_start_bonus' then
            G.GAME.hnds_juggle_bonuses = G.GAME.hnds_juggle_bonuses or {}
            G.GAME.hnds_juggle_bonuses[#G.GAME.hnds_juggle_bonuses + 1] = 3
            local lock = tag.ID
            if G.CONTROLLER and G.CONTROLLER.locks then G.CONTROLLER.locks[lock] = true end
            tag:yep('+3', G.C.BLUE, function()
                if G.hand and G.hand.change_size then G.hand:change_size(3) end
                if G.CONTROLLER and G.CONTROLLER.locks then G.CONTROLLER.locks[lock] = nil end
                return true
            end)
            tag.triggered = true
            return true
        end
    end,
})


function HNDS.cleanup_removed_reroll_tag_rework()
    if not (G and G.GAME) then return end

    if G.GAME.hnds_virtual_directors_cut
        and G.GAME.used_vouchers
    then
        G.GAME.used_vouchers.v_directors_cut = nil
    end

    if G.GAME.round_resets
        and G.GAME.hnds_boss_reroll_saved_paid_state ~= nil
    then
        G.GAME.round_resets.boss_rerolled =
            G.GAME.hnds_boss_reroll_saved_paid_state == true
    end

    G.GAME.hnds_free_boss_rerolls = nil
    G.GAME.hnds_virtual_directors_cut = nil
    G.GAME.hnds_boss_reroll_saved_ante = nil
    G.GAME.hnds_boss_reroll_saved_paid_state = nil
    G.GAME.hnds_boss_reroll_ui_refresh_pending = nil
    G.GAME.hnds_boss_reroll_ui_refresh_delay = nil
end

HNDS.cleanup_removed_reroll_tag_rework()

local function decay_juggle_tags(context)
    if not (context.end_of_round and not context.individual and not context.repetition) then return end
    if not (G and G.GAME and G.GAME.hnds_juggle_bonuses) then return end

    local token = tostring(G.GAME.round or 0) .. ':' ..
        tostring(G.GAME.round_resets and G.GAME.round_resets.ante or 0)
    if G.GAME.hnds_juggle_decay_token == token then return end
    G.GAME.hnds_juggle_decay_token = token

    local active = G.GAME.hnds_juggle_bonuses
    local shrink = 0
    for i = #active, 1, -1 do
        active[i] = (tonumber(active[i]) or 0) - 1
        shrink = shrink + 1
        if active[i] <= 0 then table.remove(active, i) end
    end
    if shrink > 0 and G.hand and G.hand.change_size then
        G.hand:change_size(-shrink)
    end
end

local function used_voucher(key)
    return G and G.GAME and G.GAME.used_vouchers and G.GAME.used_vouchers[key]
end


if SMODS and type(SMODS.poll_object) == 'function'
    and not SMODS._hnds_enhanced_shop_poll_guard
then
    SMODS._hnds_enhanced_shop_poll_guard = true
    local poll_object_ref = SMODS.poll_object
    SMODS.poll_object = function(args, ...)
        if type(args) == 'table'
            and not (args.type or args.types or args.attributes or args.pool)
            and args.guaranteed
        then
            local enhanced_shop_call = HNDS
                and HNDS._creating_smods_card_type == 'Enhanced'
            if enhanced_shop_call then
                local fixed = {}
                for key, value in pairs(args) do fixed[key] = value end
                fixed.type = 'Enhanced'
                args = fixed
            end
        end
        return poll_object_ref(args, ...)
    end
end

local function illusion_edition_options()
    local options = { 'e_foil', 'e_holo', 'e_polychrome', 'e_negative' }
    if G and G.P_CENTERS and G.P_CENTERS.e_hnds_vintage then
        options[#options + 1] = 'e_hnds_vintage'
    end
    return options
end

local function repair_shop_playing_card_ui(card, has_illusion)
    if not (card and G and G.E_MANAGER and Event) then return end
    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0,
        blockable = false,
        func = function()
            if not (card.area == G.shop_jokers and is_playing_card(card)) then return true end


            if has_illusion and card.edition and not card.hnds_illusion_edition_repolled then
                card.hnds_illusion_edition_repolled = true
                local edition = SMODS.poll_edition({
                    key = 'hnds_illusion_edition',
                    guaranteed = true,
                    options = illusion_edition_options(),
                })
                if edition then card:set_edition(edition, true, true) end
            end

            if card.set_cost then card:set_cost() end


            if card.children and not card.children.buy_button
                and type(create_shop_card_ui) == 'function'
            then
                if card.children.price and card.children.price.remove then
                    card.children.price:remove()
                    card.children.price = nil
                end
                local shop_type = card.ability and card.ability.set == 'Enhanced'
                    and 'Enhanced' or 'Base'
                create_shop_card_ui(card, shop_type, G.shop_jokers)
            end
            return true
        end,
    }))
end

local function modify_voucher_shop_playing_card(card)
    if not card or card.hnds_voucher_shop_processed or not is_playing_card(card) then return end
    if not used_voucher('v_magic_trick') then return end
    card.hnds_voucher_shop_processed = true

    local has_illusion = used_voucher('v_illusion')


    if not has_illusion and card.config and card.config.center
        and card.config.center.key == 'c_base'
    then
        local enhancement = SMODS.poll_enhancement({
            key = 'hnds_magic_trick_enhancement',
        })
        if enhancement then
            local center = type(enhancement) == 'string'
                and G.P_CENTERS and G.P_CENTERS[enhancement]
                or enhancement
            if center then card:set_ability(center, nil, false) end
        end
    end

    if has_illusion and not card.seal then


        local seal = SMODS.poll_seal({
            key = 'hnds_illusion_seal',
            mod = 10,
        })
        if seal then card:set_seal(seal, true, true) end
    end

    repair_shop_playing_card_ui(card, has_illusion)
end

local function consumable_room_available()
    if not (G and G.GAME and G.consumeables and G.consumeables.config) then return false end
    return #G.consumeables.cards + (G.GAME.consumeable_buffer or 0)
        < (G.consumeables.config.card_limit or 0)
end

local function create_planet_copy(source, negative, must_have_room)
    if not (source and source.config and source.config.center and G and G.consumeables) then return false end
    local key = source.config.center.key
    if not key then return false end
    if must_have_room and not consumable_room_available() then return false end

    G.GAME.consumeable_buffer = (G.GAME.consumeable_buffer or 0) + 1
    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0.1,
        func = function()


            local can_create = not must_have_room
                or #G.consumeables.cards < (G.consumeables.config.card_limit or 0)
            if can_create then
                SMODS.add_card({
                    set = 'Planet',
                    key = key,
                    area = G.consumeables,
                    edition = negative and 'e_negative' or nil,
                    key_append = negative and 'hnds_planet_tycoon' or 'hnds_planet_merchant',
                })
            end
            G.GAME.consumeable_buffer = math.max(0, (G.GAME.consumeable_buffer or 1) - 1)
            return true
        end,
    }))
    return true
end

local function planet_voucher_purchase(context)
    if not (context.buying_card and context.card and context.card.ability
        and context.card.ability.set == 'Planet')
    then
        return
    end


    if context.card.hnds_planet_voucher_purchase_processed then return end
    context.card.hnds_planet_voucher_purchase_processed = true

    if used_voucher('v_planet_merchant') then
        create_planet_copy(context.card, false, true)
    end
    if used_voucher('v_planet_tycoon') then
        create_planet_copy(context.card, true, false)
    end
end

local function migrate_old_planet_voucher_rate()
    if not (G and G.GAME and G.GAME.used_vouchers)
        or G.GAME.hnds_planet_voucher_rework_seen
    then
        return
    end
    if not used_voucher('v_planet_merchant') and not used_voucher('v_planet_tycoon') then return end

    local factor = 1
    if used_voucher('v_planet_merchant') then
        local center = G.P_CENTERS and G.P_CENTERS.v_planet_merchant
        factor = factor * (tonumber(center and center.config and center.config.extra) or 4)
    end
    if used_voucher('v_planet_tycoon') then
        local center = G.P_CENTERS and G.P_CENTERS.v_planet_tycoon
        factor = factor * (tonumber(center and center.config and center.config.extra) or 4)
    end
    G.GAME.planet_rate = (tonumber(G.GAME.planet_rate) or 4) * factor
    G.GAME.hnds_planet_voucher_rework_seen = true
end

HNDS.calculate_vanilla_tweaks = function(context)
    decay_juggle_tags(context)
    migrate_old_planet_voucher_rate()
    if context.modify_shop_card and context.card then
        modify_voucher_shop_playing_card(context.card)
    end
    planet_voucher_purchase(context)
end


take_vanilla_ownership(SMODS.Voucher, 'planet_merchant', {
    redeem = function(self, voucher)
        G.GAME.hnds_planet_voucher_rework_seen = true
    end,
    unredeem = function(self, voucher) end,
})

take_vanilla_ownership(SMODS.Voucher, 'planet_tycoon', {
    redeem = function(self, voucher)
        G.GAME.hnds_planet_voucher_rework_seen = true
    end,
    unredeem = function(self, voucher) end,
})


take_vanilla_ownership(SMODS.Enhancement, 'wild', {
    any_suit = true,
    calculate = function(self, card, context)
        if context.stay_flipped and context.other_card == card then
            return { prevent_stay_flipped = true }
        end
    end,
})


take_vanilla_ownership(SMODS.Joker, 'matador', {
    blueprint_compat = true,
    config = { extra = 8 },
    loc_vars = function(self, info_queue, card)
        return { vars = { extra_value(card, 'dollars', 8) } }
    end,
    calculate = function(self, card, context)
        if context.before and boss_blind_active() then
            return add_dollars(extra_value(card, 'dollars', 8))
        end
    end,
})

take_vanilla_ownership(SMODS.Joker, 'superposition', {
    blueprint_compat = true,
    calculate = function(self, card, context)
        if context.joker_main and context.poker_hands and next(context.poker_hands['Straight'] or {})
            and G.consumeables and #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit
        then
            local has_ace = false
            for _, scoring_card in ipairs(context.scoring_hand or {}) do
                if HNDS.imposter_rank_match(scoring_card, 14, context) then has_ace = true break end
            end
            if has_ace then
                G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                G.E_MANAGER:add_event(Event({
                    func = function()
                        SMODS.add_card({ set = 'Tarot', key = 'c_fool', key_append = 'hnds_superposition' })
                        G.GAME.consumeable_buffer = math.max(0, G.GAME.consumeable_buffer - 1)
                        return true
                    end,
                }))
                return { message = localize('k_plus_tarot'), colour = G.C.SECONDARY_SET.Tarot }
            end
        end
    end,
})

take_vanilla_ownership(SMODS.Joker, 'splash', {
    blueprint_compat = false,
    calculate = function(self, card, context)
        if context.modify_scoring_hand and not context.blueprint then
            return { add_to_hand = true }
        end
    end,
})

take_vanilla_ownership(SMODS.Joker, 'erosion', { rarity = 1, cost = 4 })

take_vanilla_ownership(SMODS.Joker, 'flower_pot', {
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        local current = selected_flower_pot_mult()
        return {
            key = current > 0 and 'j_flower_pot' or 'j_hnds_flower_pot_none',
            vars = { current },
        }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local unique = count_unique_suits(context.scoring_hand)
            if unique > 0 then return { xmult = unique } end
        end
    end,
})

take_vanilla_ownership(SMODS.Joker, 'baron', { rarity = 2 })
take_vanilla_ownership(SMODS.Joker, 'mime', { rarity = 3 })

take_vanilla_ownership(SMODS.Joker, 'mail', {
    rarity = 2,
    blueprint_compat = true,
    config = { extra = 3 },
    loc_vars = function(self, info_queue, card)
        local mail = current_mail_rank()
        return { vars = { extra_value(card, 'dollars', 3), localize(mail.rank, 'ranks') } }
    end,
    calculate = function(self, card, context)
        local mail = current_mail_rank()
        if context.discard and context.other_card and not context.other_card.debuff
            and context.other_card:get_id() == mail.id
        then
            return add_dollars(extra_value(card, 'dollars', 3))
        end
    end,
})

take_vanilla_ownership(SMODS.Joker, 'stone', {
    blueprint_compat = true,
    in_pool = function(self, args)
        if HNDS.stone_joker_in_pool then return HNDS.stone_joker_in_pool(args) end
		return true
    end,
    config = { extra = 30 },
    loc_vars = function(self, info_queue, card)
        if G and G.P_CENTERS and G.P_CENTERS.m_stone then
            info_queue[#info_queue + 1] = G.P_CENTERS.m_stone
        end
        local chips = extra_value(card, 'chips', 30)
        local tally = stone_card_tally()
        return { vars = { chips, chips * tally } }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            return { chips = extra_value(card, 'chips', 30) * stone_card_tally() }
        end
    end,
})

-- Single mapping for the four suit Jokers, keyed by full center key.
local suit_jokers = {
    j_greedy_joker = 'Diamonds',
    j_lusty_joker = 'Hearts',
    j_wrathful_joker = 'Spades',
    j_gluttenous_joker = 'Clubs',
}

local function normalize_suit_joker_extra(card)
    local center_key = card and card.config and card.config.center and card.config.center.key
    local suit = suit_jokers[center_key]
    if not suit or not card.ability then return end

    if type(card.ability.extra) ~= 'table' then
        card.ability.extra = {
            s_mult = tonumber(card.ability.extra) or 4,
            suit = suit,
        }
    else
        card.ability.extra.s_mult = tonumber(card.ability.extra.s_mult) or 4
        card.ability.extra.suit = card.ability.extra.suit or suit
    end
end


if Card and Card.generate_UIBox_ability_table and not HNDS._suit_joker_tooltip_fix then
    local hnds_generate_UIBox_ability_table = Card.generate_UIBox_ability_table
    function Card:generate_UIBox_ability_table(...)
        normalize_suit_joker_extra(self)
        local full_UI_table = hnds_generate_UIBox_ability_table(self, ...)

        return full_UI_table
    end
    HNDS._suit_joker_tooltip_fix = true
end
for center_key, suit in pairs(suit_jokers) do
    take_vanilla_ownership(SMODS.Joker, center_key:sub(3), {
        blueprint_compat = true,
        -- Vanilla Card:generate_UIBox_ability_table indexes
        -- ability.extra.s_mult and ability.extra.suit for these four Jokers.
        -- Keep that native table shape or hovering the card crashes.
        config = { extra = { s_mult = 4, suit = suit } },
        loc_vars = function(self, info_queue, card)
            return { vars = { extra_value(card, 's_mult', 4) } }
        end,
        calculate = function(self, card, context)
            if context.individual and context.cardarea == G.play and context.other_card
                and context.other_card:is_suit(suit)
            then
                return { mult = extra_value(card, 's_mult', 4) }
            end
        end,
    })
end

take_vanilla_ownership(SMODS.Joker, 'throwback', {
    blueprint_compat = true,
    config = { extra = 0.5, x_mult = 1 },
    loc_vars = function(self, info_queue, card)
        local skips = G and G.GAME and G.GAME.skips or 0
        local gain = extra_value(card, 'xmult', 0.5)
        return { vars = { gain, 1 + skips * gain } }
    end,
    calculate = function(self, card, context)
        local gain = extra_value(card, 'xmult', 0.5)
        if context.skip_blind and not context.blueprint then
            return { message = localize({ type = 'variable', key = 'a_xmult', vars = { 1 + G.GAME.skips * gain } }) }
        end
        if context.joker_main then return { xmult = 1 + G.GAME.skips * gain } end
    end,
})

take_vanilla_ownership(SMODS.Joker, 'seeing_double', {
    blueprint_compat = true,
    config = { extra = 1 },
    loc_vars = function() return { vars = {} } end,
    calculate = function(self, card, context)
        if context.repetition
            and (context.cardarea == G.play or context.cardarea == G.hand)
            and context.other_card and HNDS.imposter_rank_match(context.other_card, 7, context)
            and not context.other_card.debuff
        then
            local repetitions = extra_value(card, 'repetitions', 1)
            if context.other_card:is_suit('Clubs') then repetitions = repetitions + 1 end
            return { repetitions = repetitions }
        end
    end,
})

take_vanilla_ownership(SMODS.Joker, 'ring_master', {
    blueprint_compat = false,
    calculate = function(self, card, context)
        if context.modify_weights and context.pool then
            local owned = {}
            for _, area in ipairs({ G.jokers, G.consumeables }) do
                for _, owned_card in ipairs((area and area.cards) or {}) do
                    local key = owned_card.config and owned_card.config.center and owned_card.config.center.key
                    if key then owned[key] = true end
                end
            end
            for key in pairs(owned) do
                local entry = context.pool[key]
                if entry and entry.weight then entry.weight = entry.weight * 2 end
            end
        end
    end,
})

take_vanilla_ownership(SMODS.Joker, 'hiker', {
    blueprint_compat = true,
    config = { extra = 5 },


    attributes = { 'modify_card', 'chips', 'perma_bonus' },
    loc_vars = function(self, info_queue, card)
        return { vars = { 5 } }
    end,
    calculate = function(self, card, context)


        if context.individual and context.cardarea == G.play
            and context.other_card and not context.other_card.debuff
        then
            local amount = tonumber(card.ability.extra) or 5
            context.other_card.ability = context.other_card.ability or {}
            context.other_card.ability.perma_bonus =
                (tonumber(context.other_card.ability.perma_bonus) or 0) + amount
            return {
                chips = amount,
                remove_default_message = true,
                message = localize('k_upgrade_ex'),
                colour = G.C.CHIPS,
            }
        end
    end,
})


local HNDS_BLUE_STAKE_HAND_VALUES = {
    ['High Card']       = { mult = 1,  chips = 1,   l_mult = 1, l_chips = 5  },
    ['Pair']            = { mult = 1,  chips = 10,  l_mult = 1, l_chips = 10 },
    ['Two Pair']        = { mult = 2,  chips = 10,  l_mult = 1, l_chips = 15 },
    ['Three of a Kind'] = { mult = 3,  chips = 20,  l_mult = 2, l_chips = 15 },
    ['Straight']        = { mult = 4,  chips = 25,  l_mult = 3, l_chips = 25 },
    ['Flush']           = { mult = 4,  chips = 30,  l_mult = 2, l_chips = 10 },
    ['Full House']      = { mult = 4,  chips = 30,  l_mult = 4, l_chips = 25 },
    ['Four of a Kind']  = { mult = 6,  chips = 60,  l_mult = 3, l_chips = 25 },
    ['Straight Flush']  = { mult = 7,  chips = 100, l_mult = 6, l_chips = 50 },
    ['Five of a Kind']  = { mult = 11, chips = 110, l_mult = 3, l_chips = 30 },
    ['Flush House']     = { mult = 13, chips = 130, l_mult = 5, l_chips = 40 },
    ['Flush Five']      = { mult = 15, chips = 150, l_mult = 3, l_chips = 40 },
    ['hnds_stone_ocean']= { mult = 1,  chips = 200, l_mult = 1, l_chips = 40 },
}

function HNDS.apply_blue_stake_hand_rework()
    if not (G and G.GAME and G.GAME.hands and G.GAME.modifiers
        and G.GAME.modifiers.hnds_blue_stake_rework)
    then
        return
    end

    for hand_key, values in pairs(HNDS_BLUE_STAKE_HAND_VALUES) do
        local hand = G.GAME.hands[hand_key]
        if hand then
            local level = math.max(1, tonumber(hand.level) or 1)
            hand.l_mult = values.l_mult
            hand.l_chips = values.l_chips


            hand.mult = values.mult + (level - 1) * values.l_mult
            hand.chips = values.chips + (level - 1) * values.l_chips
        end
    end
end


if not (HNDS.mod_loaded and HNDS.mod_loaded('allinjest')) then
    take_vanilla_ownership(SMODS.Stake, 'blue', {
        modifiers = function(self)
            G.GAME.modifiers = G.GAME.modifiers or {}
            G.GAME.modifiers.hnds_blue_stake_rework = true
            HNDS.apply_blue_stake_hand_rework()
        end,
    })
end


if Game and type(Game.start_run) == 'function' and not HNDS._blue_stake_start_run_hook then
    HNDS._blue_stake_start_run_hook = true
    local hnds_blue_stake_start_run_ref = Game.start_run
    function Game:start_run(...)
        local pack = HNDS.pack
        local unpack_values = table.unpack or unpack
        local result = pack(hnds_blue_stake_start_run_ref(self, ...))
        HNDS.apply_blue_stake_hand_rework()
        return unpack_values(result, 1, result.n)
    end
end


take_vanilla_ownership(SMODS.Consumable, 'black_hole', {
    use = function(self, card, area, copier)
        update_hand_text(
            { sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3 },
            { handname = localize('k_all_hands'), chips = '...', mult = '...', level = '' }
        )
        G.E_MANAGER:add_event(Event({
            trigger = 'after', delay = 0.2,
            func = function()
                play_sound('tarot1')
                card:juice_up(0.8, 0.5)
                G.TAROT_INTERRUPT_PULSE = true
                return true
            end,
        }))
        update_hand_text({ delay = 0 }, { mult = 'X2', chips = 'X2', StatusText = true })
        delay(1.0)
        for _, hand in ipairs(G.handlist or {}) do
            local data = G.GAME.hands[hand]
            if data and data.level and data.level > 0 then
                SMODS.smart_level_up_hand(card, hand, true, data.level)
            end
        end
        G.TAROT_INTERRUPT_PULSE = nil
        update_hand_text(
            { sound = 'button', volume = 0.7, pitch = 1.1, delay = 0 },
            { mult = 0, chips = 0, handname = '', level = '' }
        )
    end,
    can_use = function() return true end,
})

take_vanilla_ownership(SMODS.PokerHand, 'Full House', { mult = 4, chips = 45, l_mult = 4, l_chips = 30 })
take_vanilla_ownership(SMODS.PokerHand, 'Flush House', { l_mult = 5, l_chips = 50 })
take_vanilla_ownership(SMODS.PokerHand, 'Straight Flush', { l_mult = 6, l_chips = 60 })
