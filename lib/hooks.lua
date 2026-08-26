--[[
We have a lot of hooks here, they do global stuff and helps with specifit effects from Jokers, Blinds and more

Wraps policy: raw function wraps are kept only where Steamodded offers no
covering API (boss selection, blind lifecycle, rank spoofing, sticker
exclusivity, cost mods, UI stability). When an SMODS API exists, prefer it:
see the Contagion tooltip section for a take_ownership example.

Sections:
  Ante-10 showdown boss pool & global boss support (get_new_boss)
  Wasted Wish state machine (Card:redeem)
  Nightmare Stake: cursed-joker shop exit (G.FUNCS.toggle_shop + Lovely fallback)
  Tag pop counter (Forbidden Fruit, Tag:apply_to_run)
  Badge colour + localize tooltip workaround (Carcosa, Cursed Sticker)
  Cursed Sticker exclusivity (Card:add_sticker)
  Contagion selection sync + runtime safety net (Card:update)
  Contagion multi-target use (Card:use_consumeable)
  Contagion can-use validation (Card:can_use_consumeable)
  Spectral Seal progress reset (Card:set_seal)
  Contagion tooltip swap (generate_card_ui)
  Platinum Stake (no-op here; see stakes/platinum.lua modifiers())
  Card destruction unlocks (SMODS.destroy_cards; Energized, Last Laugh)
  Black Seal & voucher card destruction / scoring
  Card cost modifications (Coffee Break, Art, Premium Deck, Curses)
  Joker creation safety nets (Blood Stake curses via SMODS.create_card,
    Devil's Round via create_card, DNA Tag copy + Devil's Round via add_to_deck)
  Circus Deck (find_joker extension)
  Crystal Deck (double-showdown boss selection)
  Gambling Opportunity challenge tab edition patch
  Impostor rank-spoofing system (Card:calculate_joker)
  Excommunicado boss-blind replacement (Blind:get_type)
  Cursed Sticker tooltip workaround setup (sticker loc_vars capture)
  Base blind increase curse (get_blind_amount, price_ante_scaling)
  Main-menu locked hint suppression (CardArea:emplace)
  Tooltip position stability (Card:align_h_popup)
]]
HNDS = HNDS or {}


local get_new_boss_ref = get_new_boss

HNDS.ANTE_10_BOSS_POOL = HNDS.ANTE_10_BOSS_POOL or {
    "bl_hnds_blind_devil",
    "bl_hnds_forbidden_fruit",
    "bl_hnds_perilous_pact",
    "bl_hnds_sinful_soul",
    "bl_hnds_wasted_wish",
}

local function get_ante_10_boss()
    local pool = {}
    for _, key in ipairs(HNDS.ANTE_10_BOSS_POOL) do
        if G.P_BLINDS and G.P_BLINDS[key] then
            pool[#pool + 1] = key
        end
    end

    if #pool == 0 then return get_new_boss_ref() end

    local chosen = pseudorandom_element(pool, pseudoseed("hnds_ante_10_boss"))
        or pool[1]

    if HNDS.set_wasted_wish_active then
        HNDS.set_wasted_wish_active(chosen == "bl_hnds_wasted_wish")
    end

    if chosen == "bl_hnds_blind_devil" and HNDS.prepare_devil_encounter then
        HNDS.prepare_devil_encounter()
    end

    return chosen
end

local function hnds_crystal_replaces_ante_8_showdown()
    if not (G and G.GAME and G.GAME.round_resets) then return false end
    local modifiers = G.GAME.modifiers or {}
    local selected_back = G.GAME.selected_back and G.GAME.selected_back.effect
        and G.GAME.selected_back.effect.center
    local crystal_deck = modifiers.hnds_crystal_ante_8_replacement == true
        or (selected_back and selected_back.key == "b_hnds_crystal")


    return crystal_deck
        and G.GAME.round_resets.ante == 8
        and G.GAME.win_ante == 8
end

function get_new_boss(...)
    if G and G.GAME
        and not G.GAME.hnds_bypass_ante_10_force
        and G.GAME.round_resets
        and (hnds_crystal_replaces_ante_8_showdown()
            or (G.GAME.round_resets.ante == 10 and G.GAME.win_ante == 10))
    then
        return get_ante_10_boss()
    end

    return get_new_boss_ref(...)
end

HNDS.get_new_boss_unforced = function()
    if not (G and G.GAME) then return get_new_boss_ref() end

    local previous = G.GAME.hnds_bypass_ante_10_force
    G.GAME.hnds_bypass_ante_10_force = true
    local ok, boss = pcall(get_new_boss)
    G.GAME.hnds_bypass_ante_10_force = previous
    if not ok then error(boss) end
    return boss
end


-- Perilous Pact calls this from blinds/blind_perilous_pact.lua (both the
-- modify_hand and final hand-score paths). Keeping the cap here makes it
-- compatible with ordinary numbers
-- and with Big-number mods that overload comparison/arithmetic operators.
function HNDS.cap_perilous_pact_score(score)
    if not (G and G.GAME and G.GAME.blind and not G.GAME.blind.disabled) then
        return score
    end

    local blind_center = G.GAME.blind.config and G.GAME.blind.config.blind
    local blind_key = blind_center and blind_center.key
    local is_perilous = G.GAME.hnds_perilous_pact_active
        or blind_key == "bl_hnds_perilous_pact"
        or blind_key == "perilous_pact"
    if not is_perilous then return score end

    local fraction = tonumber(G.GAME.hnds_perilous_pact_cap) or 0.50
    local cap = G.GAME.blind.chips * fraction
    local ok, exceeds = pcall(function()
        local lhs = type(to_big) == "function" and to_big(score) or score
        local rhs = type(to_big) == "function" and to_big(cap) or cap
        return lhs > rhs
    end)
    if ok and exceeds then return cap end
    return score
end

local function hnds_wasted_wish_fake_voucher(center, key)
    local config = center and center.config or {}
    -- Vanilla global; always present at runtime.
    local ability = copy_table(config)
    return {
        ability = ability,
        config = { center = center, center_key = key },
    }
end

local function hnds_wasted_wish_unredeem_custom_vouchers(vouchers)
    local undone = {}
    for key, owned in pairs(vouchers or {}) do
        local center = owned and G.P_CENTERS and G.P_CENTERS[key]
        local slot_voucher = key == "v_crystal_ball"
            or key == "v_antimatter"
        if not slot_voucher
            and center and type(center.unredeem) == "function"
        then
            local fake = hnds_wasted_wish_fake_voucher(center, key)
            local ok = pcall(center.unredeem, center, fake)
            if ok then undone[key] = true end
        end
    end
    return undone
end

local function hnds_wasted_wish_redeem_custom_vouchers(vouchers, undone)
    for key, was_undone in pairs(undone or {}) do
        local center = was_undone and vouchers and vouchers[key]
            and G.P_CENTERS and G.P_CENTERS[key]
        if center and type(center.redeem) == "function" then
            local fake = hnds_wasted_wish_fake_voucher(center, key)
            pcall(center.redeem, center, fake)
        end
    end
end

local function hnds_wasted_wish_has(vouchers, key)
    return vouchers and vouchers[key] and true or false
end

local function hnds_wasted_wish_extra(key, fallback)
    local center = G and G.P_CENTERS and G.P_CENTERS[key]
    local extra = center and center.config and center.config.extra
    if type(extra) == "number" then return extra end
    if type(extra) == "table" then
        return tonumber(extra.hands or extra.discards or extra.slots
            or extra.size or extra.deduction or extra.shop_size) or fallback
    end
    return fallback
end

local function hnds_wasted_wish_build_adjustments(vouchers)
    local adjustments = {
        hands = 0,
        discards = 0,
        hand_size = 0,
        consumable_slots = 0,
        joker_slots = 0,
        shop_size = 0,
        reroll_cost = 0,
    }

    for _, key in ipairs({ "v_grabber", "v_nacho_tong" }) do
        if hnds_wasted_wish_has(vouchers, key) then
            adjustments.hands = adjustments.hands
                - hnds_wasted_wish_extra(key, 1)
        end
    end
    if hnds_wasted_wish_has(vouchers, "v_hieroglyph") then
        adjustments.hands = adjustments.hands
            + hnds_wasted_wish_extra("v_hieroglyph", 1)
    end

    for _, key in ipairs({ "v_wasteful", "v_recyclomancy" }) do
        if hnds_wasted_wish_has(vouchers, key) then
            adjustments.discards = adjustments.discards
                - hnds_wasted_wish_extra(key, 1)
        end
    end
    if hnds_wasted_wish_has(vouchers, "v_petroglyph") then
        adjustments.discards = adjustments.discards
            + hnds_wasted_wish_extra("v_petroglyph", 1)
    end

    for _, key in ipairs({ "v_paint_brush", "v_palette" }) do
        if hnds_wasted_wish_has(vouchers, key) then
            adjustments.hand_size = adjustments.hand_size
                - hnds_wasted_wish_extra(key, 1)
        end
    end

    if hnds_wasted_wish_has(vouchers, "v_crystal_ball") then
        adjustments.consumable_slots = adjustments.consumable_slots - 1
    end
    if hnds_wasted_wish_has(vouchers, "v_antimatter") then
        adjustments.joker_slots = adjustments.joker_slots - 1
    end

    for _, key in ipairs({ "v_overstock_norm", "v_overstock_plus" }) do
        if hnds_wasted_wish_has(vouchers, key) then
            adjustments.shop_size = adjustments.shop_size
                - hnds_wasted_wish_extra(key, 1)
        end
    end

    for _, key in ipairs({ "v_reroll_surplus", "v_reroll_glut" }) do
        if hnds_wasted_wish_has(vouchers, key) then
            adjustments.reroll_cost = adjustments.reroll_cost
                + hnds_wasted_wish_extra(key, 2)
        end
    end

    return adjustments
end

local function hnds_wasted_wish_snapshot_overrides(vouchers)
    local snapshot = {}
    local function save(field)
        snapshot[field] = G.GAME[field]
    end

    if hnds_wasted_wish_has(vouchers, "v_clearance_sale")
        or hnds_wasted_wish_has(vouchers, "v_liquidation")
    then
        save("discount_percent")
        G.GAME.discount_percent = 0
        for _, card in pairs(G.I and G.I.CARD or {}) do
            if card.set_cost then card:set_cost() end
        end
    end

    if hnds_wasted_wish_has(vouchers, "v_hone")
        or hnds_wasted_wish_has(vouchers, "v_glow_up")
    then
        save("edition_rate")
        G.GAME.edition_rate = 1
    end

    if hnds_wasted_wish_has(vouchers, "v_tarot_merchant")
        or hnds_wasted_wish_has(vouchers, "v_tarot_tycoon")
    then
        save("tarot_rate")
        G.GAME.tarot_rate = 4
    end

    if hnds_wasted_wish_has(vouchers, "v_planet_merchant")
        or hnds_wasted_wish_has(vouchers, "v_planet_tycoon")
    then
        save("planet_rate")
        G.GAME.planet_rate = 4
    end

    if hnds_wasted_wish_has(vouchers, "v_magic_trick")
        or hnds_wasted_wish_has(vouchers, "v_illusion")
    then
        save("playing_card_rate")
        G.GAME.playing_card_rate = 0
    end

    if hnds_wasted_wish_has(vouchers, "v_seed_money")
        or hnds_wasted_wish_has(vouchers, "v_money_tree")
    then
        save("interest_cap")
        G.GAME.interest_cap = 25
    end

    return snapshot
end

local function hnds_wasted_wish_restore_overrides(snapshot)
    for field, value in pairs(snapshot or {}) do
        G.GAME[field] = value
    end
    if snapshot and snapshot.discount_percent ~= nil then
        for _, card in pairs(G.I and G.I.CARD or {}) do
            if card.set_cost then card:set_cost() end
        end
    end
end

local function hnds_wasted_wish_apply_adjustments(adjustments, direction)
    adjustments = adjustments or {}
    direction = direction or 1

    local hands = direction * (adjustments.hands or 0)
    local discards = direction * (adjustments.discards or 0)
    local hand_size = direction * (adjustments.hand_size or 0)
    local shop_size = direction * (adjustments.shop_size or 0)
    local reroll_cost = direction * (adjustments.reroll_cost or 0)

    if G.GAME.round_resets then
        G.GAME.round_resets.hands = math.max(1,
            (G.GAME.round_resets.hands or 0) + hands)
        G.GAME.round_resets.discards = math.max(0,
            (G.GAME.round_resets.discards or 0) + discards)
        G.GAME.round_resets.reroll_cost = math.max(0,
            (G.GAME.round_resets.reroll_cost or 0) + reroll_cost)
    end

    if G.hand and hand_size ~= 0 then G.hand:change_size(hand_size) end
    if shop_size ~= 0 and type(change_shop_size) == "function" then
        change_shop_size(shop_size)
    end
    if G.GAME.current_round and G.GAME.current_round.reroll_cost ~= nil then
        G.GAME.current_round.reroll_cost = math.max(0,
            G.GAME.current_round.reroll_cost + reroll_cost)
    end
end


local function hnds_wasted_wish_disable_slot_bonuses(adjustments)
    if not (G and G.GAME) then return end
    adjustments = adjustments or {}

    local state = G.GAME.hnds_wasted_wish_slot_state or {}
    G.GAME.hnds_wasted_wish_slot_state = state

    local consumable_bonus = math.max(0,
        -(tonumber(adjustments.consumable_slots) or 0))
    local joker_bonus = math.max(0,
        -(tonumber(adjustments.joker_slots) or 0))

    state.consumable_bonus = state.consumable_bonus or consumable_bonus
    state.joker_bonus = state.joker_bonus or joker_bonus

    if consumable_bonus > 0 and state.consumable_processed == nil then
        local area = G.consumeables
        local limit = area and area.config
            and tonumber(area.config.card_limit)
        if limit and limit > consumable_bonus then
            area.config.card_limit = math.max(1, limit - consumable_bonus)
            state.consumable_processed = true
        else


            state.consumable_processed = false
        end
    end

    if joker_bonus > 0 and state.joker_processed == nil then
        local area = G.jokers
        local limit = area and area.config
            and tonumber(area.config.card_limit)
        if limit and limit > joker_bonus then
            area.config.card_limit = math.max(1, limit - joker_bonus)
            state.joker_processed = true
        else
            state.joker_processed = false
        end
    end
end

local function hnds_wasted_wish_restore_slot_bonuses()
    if not (G and G.GAME) then return end
    local state = G.GAME.hnds_wasted_wish_slot_state or {}

    local consumable_bonus = tonumber(state.consumable_bonus) or 0
    if consumable_bonus > 0 and G.consumeables and G.consumeables.config then
        local limit = tonumber(G.consumeables.config.card_limit)
        if limit then
            G.consumeables.config.card_limit = math.max(1,
                limit + consumable_bonus)
        end
    end

    local joker_bonus = tonumber(state.joker_bonus) or 0
    if joker_bonus > 0 and G.jokers and G.jokers.config then
        local limit = tonumber(G.jokers.config.card_limit)
        if limit then
            G.jokers.config.card_limit = math.max(1,
                limit + joker_bonus)
        end
    end

    G.GAME.hnds_wasted_wish_slot_state = nil
end

local function hnds_install_wasted_wish_voucher_proxy()
    if not (G and G.GAME and G.GAME.hnds_wasted_wish_active) then return end
    local backup = G.GAME.hnds_wasted_wish_used_vouchers or {}
    G.GAME.hnds_wasted_wish_used_vouchers = backup

    local current = G.GAME.used_vouchers
    if type(current) == "table" then
        for key, value in pairs(current) do
            if value ~= nil then backup[key] = value end
        end
    end

    local proxy = {}
    setmetatable(proxy, {
        __newindex = function(_, key, value)
            backup[key] = value
        end,
    })
    G.GAME.used_vouchers = proxy
end

function HNDS.set_wasted_wish_active(active)
    if not (G and G.GAME) then return end
    active = active and true or false

    if active then
        if not G.GAME.hnds_wasted_wish_active then
            local vouchers = copy_table(G.GAME.used_vouchers)
            G.GAME.hnds_wasted_wish_used_vouchers = vouchers
            G.GAME.hnds_wasted_wish_adjustments =
                hnds_wasted_wish_build_adjustments(vouchers)
            G.GAME.hnds_wasted_wish_overrides =
                hnds_wasted_wish_snapshot_overrides(vouchers)
            G.GAME.hnds_wasted_wish_unredeemed =
                hnds_wasted_wish_unredeem_custom_vouchers(vouchers)
            hnds_wasted_wish_apply_adjustments(
                G.GAME.hnds_wasted_wish_adjustments, 1)
            hnds_wasted_wish_disable_slot_bonuses(
                G.GAME.hnds_wasted_wish_adjustments)
        end
        G.GAME.hnds_wasted_wish_active = true
        G.GAME.hnds_wasted_wish_ante =
            G.GAME.round_resets and G.GAME.round_resets.ante or nil
        hnds_install_wasted_wish_voucher_proxy()
    elseif G.GAME.hnds_wasted_wish_active
        or G.GAME.hnds_wasted_wish_used_vouchers
    then
        local restored = G.GAME.hnds_wasted_wish_used_vouchers or {}
        for key, value in pairs(G.GAME.used_vouchers or {}) do
            restored[key] = value
        end
        G.GAME.used_vouchers = restored

        hnds_wasted_wish_apply_adjustments(
            G.GAME.hnds_wasted_wish_adjustments, -1)
        hnds_wasted_wish_restore_slot_bonuses()
        hnds_wasted_wish_restore_overrides(
            G.GAME.hnds_wasted_wish_overrides)
        hnds_wasted_wish_redeem_custom_vouchers(
            restored,
            G.GAME.hnds_wasted_wish_unredeemed)

        G.GAME.hnds_wasted_wish_used_vouchers = nil
        G.GAME.hnds_wasted_wish_adjustments = nil
        G.GAME.hnds_wasted_wish_overrides = nil
        G.GAME.hnds_wasted_wish_unredeemed = nil
        G.GAME.hnds_wasted_wish_slot_state = nil
        G.GAME.hnds_wasted_wish_active = nil
        G.GAME.hnds_wasted_wish_ante = nil
    end
end


if Card and Card.redeem and not Card._hnds_wasted_wish_redeem then
    Card._hnds_wasted_wish_redeem = true
    local hnds_wasted_wish_redeem_ref = Card.redeem

    function Card:redeem(...)
        local refresh_after = G and G.GAME
            and G.GAME.hnds_wasted_wish_active
            and self.ability and self.ability.set == "Voucher"

        local results = HNDS.pack(hnds_wasted_wish_redeem_ref(self, ...))

        if refresh_after and G and G.E_MANAGER then
            G.E_MANAGER:add_event(Event({
                trigger = "after",
                delay = 0.05,
                func = function()
                    if G.GAME and G.GAME.hnds_wasted_wish_active then
                        HNDS.set_wasted_wish_active(false)
                        HNDS.set_wasted_wish_active(true)
                    end
                    return true
                end,
            }))
        end

        return ((table and table.unpack) or unpack)(results, 1, results.n)
    end
end

local function hnds_update_ante_10_runtime()
    if not (G and G.GAME) then return end
    local now = G.TIMERS and G.TIMERS.REAL or os.clock()
    if now < (G.GAME.hnds_ante_10_next_runtime_update or 0) then return end
    G.GAME.hnds_ante_10_next_runtime_update = now + 0.10

    local active_blind_key = G.GAME.blind and G.GAME.blind.config
        and G.GAME.blind.config.blind and G.GAME.blind.config.blind.key

    if G.GAME.hnds_perilous_pact_active
        and active_blind_key ~= "bl_hnds_perilous_pact"
    then
        G.GAME.hnds_perilous_pact_active = nil
    end

    if G.GAME.hnds_sinful_soul_active
        and active_blind_key ~= "bl_hnds_sinful_soul"
        and HNDS.clear_sinful_soul
    then
        HNDS.clear_sinful_soul()
    end

    if G.GAME.hnds_wasted_wish_active then
        local ante = G.GAME.round_resets and G.GAME.round_resets.ante
        if ante ~= G.GAME.hnds_wasted_wish_ante then
            HNDS.set_wasted_wish_active(false)
        else


            local mt = type(G.GAME.used_vouchers) == "table"
                and getmetatable(G.GAME.used_vouchers)
            if not (mt and mt.__newindex) then
                hnds_install_wasted_wish_voucher_proxy()
            end


            hnds_wasted_wish_disable_slot_bonuses(
                G.GAME.hnds_wasted_wish_adjustments)
        end
    end
end


local function hnds_nightmare_stake_active()
    return G and G.GAME and G.GAME.modifiers
        and G.GAME.modifiers.hnds_nightmare_stake == true
end

local function hnds_table_has_cursed_sticker(stickers)
    if type(stickers) ~= "table" then return false end
    for key, value in pairs(stickers) do
        if key == "hnds_cursed" or value == "hnds_cursed" then
            return true
        end
    end
    return false
end

local function hnds_shop_has_cursed_joker()
    if not (G and G.shop_jokers and G.shop_jokers.cards) then return false end

    for _, card in ipairs(G.shop_jokers.cards) do
        local center = card and card.config and card.config.center
        local ability = card and card.ability
        local is_joker = card and (
            (ability and ability.set == "Joker")
            or (center and center.set == "Joker")
        )
        local cursed = is_joker and (
            (ability and ability.hnds_cursed == true)
            or (ability and ability.hnds_curse ~= nil)
            or (ability and ability.hnds_curse_offer ~= nil)
            or (ability and ability.hnds_curse_price ~= nil)
            or hnds_table_has_cursed_sticker(card.stickers)
            or hnds_table_has_cursed_sticker(ability and ability.stickers)
        )

        if cursed then return true end
    end

    return false
end

local function hnds_next_small_or_big_blind()
    if not (G and G.GAME and G.GAME.round_resets) then return nil end

    local resets = G.GAME.round_resets
    local states = resets.blind_states or {}
    local choices = resets.blind_choices or {}
    local on_deck = G.GAME.blind_on_deck

    if (on_deck == "Small" or on_deck == "Big")
        and states[on_deck] ~= "Defeated"
        and states[on_deck] ~= "Skipped"
        and choices[on_deck]
    then
        return on_deck
    end

    for _, choice in ipairs({ "Small", "Big" }) do
        if states[choice] == "Select" and choices[choice] then
            return choice
        end
    end

    for _, choice in ipairs({ "Small", "Big" }) do
        local state = states[choice]
        if choices[choice]
            and state ~= "Defeated"
            and state ~= "Skipped"
        then
            return choice
        end
    end

    return nil
end


HNDS.handle_nightmare_cursed_shop_exit = function()
    if not (G and G.GAME and G.shop) then return false end
    if G.STATES and G.STATES.SHOP and G.STATE ~= G.STATES.SHOP then return false end
    if not hnds_nightmare_stake_active() then return false end


    if G.GAME.hnds_nightmare_shop_upgrade_pending then return false end
    if G.shop.hnds_nightmare_cursed_upgrade_queued then return false end
    if not hnds_shop_has_cursed_joker() then return false end

    local shop_ref = G.shop
    shop_ref.hnds_nightmare_cursed_upgrade_queued = true
    if G.E_MANAGER and Event then
        G.E_MANAGER:add_event(Event({
            trigger = 'immediate',
            func = function()
                if shop_ref then
                    shop_ref.hnds_nightmare_cursed_upgrade_queued = nil
                end
                return true
            end,
        }))
    end

    G.GAME.hnds_nightmare_shop_upgrade_pending = true
    G.GAME.hnds_nightmare_shop_upgrade_target = hnds_next_small_or_big_blind()
    G.GAME.hnds_nightmare_shop_upgrade_source_ante =
        G.GAME.round_resets and G.GAME.round_resets.ante or nil
    return true
end


if G and G.FUNCS and type(G.FUNCS.toggle_shop) == "function"
    and not _G._hnds_nightmare_toggle_shop_wrapped
then
    _G._hnds_nightmare_toggle_shop_wrapped = true
    local hnds_toggle_shop_ref = G.FUNCS.toggle_shop

    G.FUNCS.toggle_shop = function(e)
        if HNDS and HNDS.handle_nightmare_cursed_shop_exit then
            HNDS.handle_nightmare_cursed_shop_exit()
        end
        return hnds_toggle_shop_ref(e)
    end
end


local function hnds_tag_key(tag)
    if not tag then return nil end
    return tag.key
        or (tag.config and tag.config.key)
        or (tag.config and tag.config.center and tag.config.center.key)
end

local function hnds_is_investment_tag(tag)
    local key = hnds_tag_key(tag)
    return key == 'tag_investment'
        or key == 'investment'
        or (tag and tag.name == 'Investment Tag')
end

if Tag and type(Tag.apply_to_run) == "function" and not HNDS._tag_pop_hooked then
    HNDS._tag_pop_hooked = true
    local tag_apply_to_run_ref = Tag.apply_to_run

    function Tag:apply_to_run(context, ...)
        local was_triggered = self.triggered == true
        local result

        if hnds_is_investment_tag(self) then


            result = false
        else
            result = tag_apply_to_run_ref(self, context, ...)
        end

        -- Counts a Tag pop on the apply_to_run path. The direct Investment
        -- payout in lib/vanilla_investment_tag.lua counts its own path; the
        -- per-tag hnds_pop_counted guard makes the two sites mutually
        -- exclusive, so one physical Tag is never counted twice.
        if not was_triggered
            and self.triggered == true
            and not self.hnds_pop_counted
            and G and G.GAME
        then
            self.hnds_pop_counted = true
            G.GAME.hnds_tags_popped = (G.GAME.hnds_tags_popped or 0) + 1
        end

        return result
    end
end


local hnds_loc_colours_injected = false
local function HNDS_ensure_loc_colours()
	if hnds_loc_colours_injected then return end
	if G and G.ARGS and G.ARGS.LOC_COLOURS and G.C and G.C.HNDS_CARCOSA then
		G.ARGS.LOC_COLOURS.hnds_carcosa = G.C.HNDS_CARCOSA
		hnds_loc_colours_injected = true
	end
end

if type(localize) == 'function' and not _G._hnds_wrapped_localize_colours then
	_G._hnds_wrapped_localize_colours = true
	local localize_ref = localize
	local unpack_values = (table and table.unpack) or unpack

	function localize(args, misc_cat, misc_loc, silent, ...)
		HNDS_ensure_loc_colours()
		local trailing = HNDS.pack(...)


		if type(args) == 'table' and args.key == 'hnds_cursed' and args.type == 'other' then
			local card = _G.HNDS_CURRENT_CURSE_CARD
			if card and card.ability and G and G.localization and G.localization.descriptions then
				local offer = card.ability.hnds_curse_offer
				local price = card.ability.hnds_curse_price
				local display_mode = card.ability.hnds_curse_display_mode
				local other = G.localization.descriptions.Other
				local loc_entry = other and other.hnds_cursed


				if (offer or price) and type(loc_entry) == 'table' and type(loc_parse_string) == 'function' then
					local desc_lines, offer_lines_count = {}, 0
					local function append_entry(key, count_offer)
						local source = key and other and other[key]
						if type(source) == 'table' and type(source.text) == 'table' then
							for _, line in ipairs(source.text) do
								desc_lines[#desc_lines + 1] = line
								if count_offer then offer_lines_count = offer_lines_count + 1 end
							end
						end
					end

					if display_mode == 'offer' and offer then
						append_entry(offer, false)
					elseif display_mode == 'price' and price then
						append_entry(price, false)
					else
						append_entry(offer, true)
						append_entry(price, false)
					end

					if #desc_lines > 0 then
						local original_text = loc_entry.text
						local original_text_parsed = loc_entry.text_parsed
						loc_entry.text = desc_lines
						loc_entry.text_parsed = {}
						for _, line in ipairs(desc_lines) do
							loc_entry.text_parsed[#loc_entry.text_parsed + 1] = loc_parse_string(line)
						end

						local packed = HNDS.pack(pcall(function()
							return localize_ref(args, misc_cat, misc_loc, silent, unpack_values(trailing, 1, trailing.n))
						end))

						loc_entry.text = original_text
						loc_entry.text_parsed = original_text_parsed
						if _G.HNDS_CURRENT_CURSE_CARD == card then _G.HNDS_CURRENT_CURSE_CARD = nil end

						if not packed[1] then error(packed[2], 0) end
						if offer_lines_count > 0 and type(args.nodes) == 'table'
							and G.UIT and G.C and G.C.UI and G.C.UI.TEXT_INACTIVE
						then
							local separator_line = {
								{ n = G.UIT.C, config = { align = 'cm', minh = 0.03, minw = 2.4, colour = G.C.UI.TEXT_INACTIVE } }
							}
							table.insert(args.nodes, math.min(offer_lines_count + 1, #args.nodes + 1), separator_line)
						end
						return unpack_values(packed, 2, packed.n)
					end
				end
			end
			if _G.HNDS_CURRENT_CURSE_CARD == card then _G.HNDS_CURRENT_CURSE_CARD = nil end
		end
		return localize_ref(args, misc_cat, misc_loc, silent, unpack_values(trailing, 1, trailing.n))
	end
end


local function hnds_card_has_cursed(card)
	if not card then return false end
	return (card.ability and card.ability.hnds_cursed)
		or (card.stickers and card.stickers.hnds_cursed)
		or (card.ability and card.ability.stickers and card.ability.stickers.hnds_cursed)
end

local function hnds_cursed_needs_strip(card)
    if not (card and card.ability) then return false end
    if card.ability.perishable or card.ability.eternal or card.ability.rental then return true end
    if SMODS and SMODS.Sticker and SMODS.Sticker.obj_buffer then
        for _, k in ipairs(SMODS.Sticker.obj_buffer) do
            if k ~= 'hnds_cursed' and card.ability[k] then return true end
        end
    end
    if type(card.stickers) == 'table' then
        for k, v in pairs(card.stickers) do
            if k ~= 'hnds_cursed' and v then return true end
        end
    end
    if type(card.ability.stickers) == 'table' then
        for k, v in pairs(card.ability.stickers) do
            if k ~= 'hnds_cursed' and v then return true end
        end
    end
    return false
end

local function hnds_strip_other_stickers(card)
	if not hnds_card_has_cursed(card) then return end
	if not card.ability then return end

	local to_remove = {}
	for _, k in ipairs({ 'perishable', 'eternal', 'rental' }) do
		if card.ability[k]
			or (card.stickers and card.stickers[k])
			or (card.ability.stickers and card.ability.stickers[k])
		then
			to_remove[k] = true
		end
	end

	if SMODS and SMODS.Sticker and SMODS.Sticker.obj_buffer then
		for _, k in ipairs(SMODS.Sticker.obj_buffer) do
			if k ~= 'hnds_cursed' and card.ability[k] then
				to_remove[k] = true
			end
		end
	end

	if card.stickers and type(card.stickers) == 'table' then
		for k, _ in pairs(card.stickers) do
			if k ~= 'hnds_cursed' then to_remove[k] = true end
		end
	end
	if card.ability.stickers and type(card.ability.stickers) == 'table' then
		for k, _ in pairs(card.ability.stickers) do
			if k ~= 'hnds_cursed' then to_remove[k] = true end
		end
	end

	local any_removed = false
	for k, _ in pairs(to_remove) do
		any_removed = true
		if card.remove_sticker then
			pcall(card.remove_sticker, card, k)
		end
		if card.stickers then card.stickers[k] = nil end
		card.ability[k] = nil
		if card.ability.stickers then card.ability.stickers[k] = nil end
	end


	card.ability.perishable = nil
	card.ability.eternal = nil
	card.ability.rental = nil
	if any_removed and card.set_sticker_display then
		pcall(card.set_sticker_display, card)
	end
end


if Card and Card.add_sticker and not _G._hnds_wrapped_add_sticker_cursed then
	_G._hnds_wrapped_add_sticker_cursed = true
	local add_sticker_ref = Card.add_sticker
	function Card:add_sticker(key, ...)


		if self.ability and self.ability.hnds_bizarre_owner
			and key ~= 'hnds_fighting_spirit'
		then
			return
		end
		if key ~= 'hnds_cursed' and hnds_card_has_cursed(self) then return end
		local results = HNDS.pack(add_sticker_ref(self, key, ...))
		if key == 'hnds_cursed' then
			hnds_strip_other_stickers(self)
		end
		return ((table and table.unpack) or unpack)(results, 1, results.n)
	end
end

HNDS.strip_other_stickers = hnds_strip_other_stickers

-------------------------------------------------------------------
-- CONTAGION CONSUMABLE SELECTION + RUNTIME STICKER SAFETY NET
-------------------------------------------------------------------

local hnds_contagion_cache_time = nil
local hnds_contagion_cache_bonus = 0
local function hnds_contagion_bonus()
    local now = G and G.TIMERS and (G.TIMERS.REAL or G.TIMERS.TOTAL)
    if now ~= nil and now == hnds_contagion_cache_time then
        return hnds_contagion_cache_bonus
    end

    local bonus = 0
    if G and G.jokers and G.jokers.cards then
        for _, joker in ipairs(G.jokers.cards) do
            if joker and not joker.debuff and joker.config and joker.config.center then
                local key = joker.config.center.key
                local jack_contagion = key == 'j_hnds_jack_in_the_box'
                    and joker.ability and joker.ability.extra
                    and joker.ability.extra.active == true
                    and joker.ability.extra.rare_key == 'j_hnds_contagion'
                if key == 'j_hnds_contagion' or jack_contagion then
                    bonus = bonus + 1
                end
            end
        end
    end
    hnds_contagion_cache_time = now
    hnds_contagion_cache_bonus = bonus
    return bonus
end


HNDS.get_contagion_bonus = hnds_contagion_bonus

local function hnds_sync_contagion_container(container, bonus, forced_base)
    if type(container) ~= 'table' then return false end


    if forced_base then
        if bonus > 0 then
            container.max_highlighted = forced_base + bonus
            container.mod_num = forced_base + bonus
            container.hnds_contagion_bonus = bonus
            container.hnds_contagion_forced_targeting = true
            return true
        end
        if container.hnds_contagion_forced_targeting then
            container.max_highlighted = nil
            container.mod_num = nil
            container.hnds_contagion_bonus = nil
            container.hnds_contagion_forced_targeting = nil
        end
        return false
    end

    local previous_bonus = tonumber(container.hnds_contagion_bonus) or 0


    if type(container.max_highlighted) ~= 'number' then
        if previous_bonus ~= 0 and type(container.mod_num) == 'number' then
            container.mod_num = math.max(0, container.mod_num - previous_bonus)
        end
        container.hnds_contagion_bonus = nil
        return false
    end


    local base_max = math.max(0, container.max_highlighted - previous_bonus)
    container.max_highlighted = base_max + bonus

    if type(container.mod_num) == 'number' then
        local base_mod = math.max(0, container.mod_num - previous_bonus)
        container.mod_num = base_mod + bonus
    end

    container.hnds_contagion_bonus = bonus
    return true
end

local function hnds_sync_contagion_selection(card)
    if not (card and card.ability) then return end

    local center_key = card.config and card.config.center and card.config.center.key
    local is_death = center_key == 'c_death' or card.ability.name == 'Death'
    local bonus = hnds_contagion_bonus()


    if is_death then bonus = bonus > 0 and 1 or 0 end
    local is_aura = center_key == 'c_aura' or card.ability.name == 'Aura'


    if is_aura then
        card.ability.consumeable = card.ability.consumeable or {}
        hnds_sync_contagion_container(card.ability.consumeable, bonus, 1)
    else
        hnds_sync_contagion_container(card.ability.consumeable, bonus)
    end


    if card.ability.consumable ~= card.ability.consumeable then
        if is_aura then
            card.ability.consumable = card.ability.consumable or {}
            hnds_sync_contagion_container(card.ability.consumable, bonus, 1)
        else
            hnds_sync_contagion_container(card.ability.consumable, bonus)
        end
    end


    hnds_sync_contagion_container(card.ability, bonus)
end

local function hnds_card_needs_contagion_sync(card)
    if not (card and card.ability) then return false end
    local center = card.config and card.config.center
    local set = center and center.set or card.ability.set
    return set == 'Tarot' or set == 'Spectral'
        or card.ability.consumeable ~= nil
        or card.ability.consumable ~= nil
        or card.ability.max_highlighted ~= nil
        or card.ability.hnds_contagion_bonus ~= nil
end

local function hnds_runtime_maintenance_due(card, field, interval)
    local timers = G and G.TIMERS
    local now = timers and (timers.REAL or timers.TOTAL)
    if type(now) ~= 'number' then return true end
    local next_time = card and card[field]
    if type(next_time) == 'number' and now < next_time then return false end
    if card then card[field] = now + (interval or 0.25) end
    return true
end

if Card and Card.update and not Card._hnds_wrapped_update_runtime then
    Card._hnds_wrapped_update_runtime = true
    local card_update_ref = Card.update
    function Card:update(dt, ...)
        local ret = card_update_ref(self, dt, ...)


        local area_config = self.area and self.area.config
        if area_config and area_config.collection then
            return ret
        end

        if hnds_card_has_cursed(self)
            and hnds_runtime_maintenance_due(self, '_hnds_next_cursed_sticker_scan', 0.25)
            and hnds_cursed_needs_strip(self)
        then
            hnds_strip_other_stickers(self)
        end


        if self.ability and self.ability.hnds_bizarre_owner
            and HNDS and HNDS.strip_bizarre_child_stickers
            and hnds_runtime_maintenance_due(self, '_hnds_next_bizarre_sticker_scan', 0.25)
        then
            HNDS.strip_bizarre_child_stickers(self)
        end


        if hnds_card_needs_contagion_sync(self) then
            hnds_sync_contagion_selection(self)
        end
        return ret
    end
end


if Game and Game.update and not Game._hnds_wrapped_update_runtime then
    Game._hnds_wrapped_update_runtime = true
    local game_update_runtime_ref = Game.update
    local hnds_runtime_game_ref = nil
    function Game:update(dt, ...)
        local ret = game_update_runtime_ref(self, dt, ...)
        hnds_update_ante_10_runtime()


        if hnds_runtime_game_ref ~= (G and G.GAME) then
            hnds_runtime_game_ref = G and G.GAME or nil
            if HNDS and HNDS.cleanup_removed_reroll_tag_rework then
                HNDS.cleanup_removed_reroll_tag_rework()
            end
            if HNDS and HNDS.install_investment_blind_hooks then
                HNDS.install_investment_blind_hooks()
            end
        end
        return ret
    end
end


local hnds_contagion_seal_spectrals = {
    c_talisman = 'Gold',
    c_deja_vu = 'Red',
    c_trance = 'Blue',
    c_medium = 'Purple',
}

local function hnds_contagion_center_key(card)
    return card and card.config and card.config.center and card.config.center.key
end

local function hnds_copy_highlighted_cards()
    local selected = {}
    if G and G.hand and G.hand.highlighted then
        for i = 1, #G.hand.highlighted do
            selected[i] = G.hand.highlighted[i]
        end
    end
    return selected
end

local function hnds_rightmost_selected_card(selected)
    local rightmost, rightmost_index = nil, -1
    if not (G and G.hand and G.hand.cards) then return selected and selected[#selected] end
    local selected_lookup = {}
    for _, card in ipairs(selected or {}) do selected_lookup[card] = true end
    for index, card in ipairs(G.hand.cards) do
        if selected_lookup[card] and index > rightmost_index then
            rightmost, rightmost_index = card, index
        end
    end
    return rightmost or (selected and selected[#selected])
end

local function hnds_contagion_copy_count(card)
    local extra = card and card.ability and card.ability.extra
    if type(extra) == 'number' then return math.max(0, math.floor(extra)) end
    if type(extra) == 'table' and type(extra.cards) == 'number' then
        return math.max(0, math.floor(extra.cards))
    end
    return 2
end

if Card and Card.use_consumeable and not Card._hnds_wrapped_contagion_use then
    Card._hnds_wrapped_contagion_use = true
    local use_consumeable_contagion_ref = Card.use_consumeable

    function Card:use_consumeable(area, copier, ...)
        local center_key = hnds_contagion_center_key(self)
        local bonus = hnds_contagion_bonus()
        local supported = hnds_contagion_seal_spectrals[center_key]
            or center_key == 'c_aura'
            or center_key == 'c_cryptid'
            or center_key == 'c_death'
        local selected = (bonus > 0 and supported) and hnds_copy_highlighted_cards() or nil
        local death_source = center_key == 'c_death' and selected and hnds_rightmost_selected_card(selected) or nil

        local results = HNDS.pack(use_consumeable_contagion_ref(self, area, copier, ...))
        local unpack_values = (table and table.unpack) or unpack

        if not selected or #selected <= 1 then return unpack_values(results, 1, results.n) end

        local seal = hnds_contagion_seal_spectrals[center_key]
        if seal then
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.1,
                func = function()
                    for i = 2, #selected do
                        local target = selected[i]
                        if target and not target.removed and target.set_seal then target:set_seal(seal, nil, true) end
                    end
                    return true
                end,
            }))
        elseif center_key == 'c_aura' then
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.4,
                func = function()
                    for i = 2, #selected do
                        local target = selected[i]
                        if target and not target.removed and not target.edition and target.set_edition then
                            target:set_edition(HNDS.poll_non_vintage_edition('hnds_contagion_aura_' .. tostring(i), nil, true, true), true)
                        end
                    end
                    return true
                end,
            }))
        elseif center_key == 'c_death' and death_source and #selected == 3 then
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    for _, target in ipairs(selected) do
                        if target and not target.removed and target ~= death_source
                            and death_source and not death_source.removed
                        then
                            copy_card(death_source, target)
                        end
                    end
                    return true
                end,
            }))
        elseif center_key == 'c_cryptid' then
            local copies_per_card = hnds_contagion_copy_count(self)
            G.E_MANAGER:add_event(Event({
                func = function()
                    local first_materialize = nil
                    local new_cards = {}
                    for target_index = 2, #selected do
                        local target = selected[target_index]
                        if target and not target.removed then
                            for _ = 1, copies_per_card do
                                G.playing_card = (G.playing_card and G.playing_card + 1) or 1
                                local copied = copy_card(target, nil, nil, G.playing_card)
                                if copied then
                                    copied:add_to_deck()
                                    G.deck.config.card_limit = G.deck.config.card_limit + 1
                                    table.insert(G.playing_cards, copied)
                                    G.hand:emplace(copied)
                                    copied:start_materialize(nil, first_materialize)
                                    first_materialize = true
                                    new_cards[#new_cards + 1] = copied
                                end
                            end
                        end
                    end
                    if #new_cards > 0 then playing_card_joker_effects(new_cards) end
                    return true
                end,
            }))
        end

        return unpack_values(results, 1, results.n)
    end
end


if Card and Card.can_use_consumeable and not Card._hnds_wrapped_contagion_can_use then
    Card._hnds_wrapped_contagion_can_use = true
    local can_use_consumeable_contagion_ref = Card.can_use_consumeable

    function Card:can_use_consumeable(any_state, skip_check, ...)
        local vanilla_result = can_use_consumeable_contagion_ref(self, any_state, skip_check, ...)
        if hnds_contagion_center_key(self) == 'c_aura' and hnds_contagion_bonus() > 0
            and G and G.hand and G.hand.highlighted and #G.hand.highlighted > 0
        then
            if not skip_check and ((G.play and #G.play.cards > 0)
                or (G.CONTROLLER and G.CONTROLLER.locked)
                or (G.GAME and G.GAME.STOP_USE and G.GAME.STOP_USE > 0))
            then
                return false
            end
            local valid_state = any_state or G.STATE == G.STATES.SELECTING_HAND
                or G.STATE == G.STATES.TAROT_PACK
                or G.STATE == G.STATES.SPECTRAL_PACK
                or G.STATE == G.STATES.PLANET_PACK
            if not valid_state then return false end

            local ability = self.ability and (self.ability.consumeable or self.ability.consumable or self.ability)
            local max_highlighted = ability and tonumber(ability.max_highlighted) or 1
            local count = #G.hand.highlighted
            if count > max_highlighted then return false end
            for i = 1, count do
                if not G.hand.highlighted[i] or G.hand.highlighted[i].edition then return false end
            end
            return true
        end
        if hnds_contagion_center_key(self) == 'c_death' and hnds_contagion_bonus() > 0 then
            if not skip_check and ((G.play and #G.play.cards > 0)
                or (G.CONTROLLER and G.CONTROLLER.locked)
                or (G.GAME and G.GAME.STOP_USE and G.GAME.STOP_USE > 0))
            then
                return false
            end
            local valid_state = any_state or G.STATE == G.STATES.SELECTING_HAND
                or G.STATE == G.STATES.TAROT_PACK
                or G.STATE == G.STATES.SPECTRAL_PACK
            return valid_state and G.hand and G.hand.highlighted
                and #G.hand.highlighted == 3
        end
        return vanilla_result
    end
end


if Card and Card.set_seal and not Card._hnds_wrapped_spectral_progress then
    Card._hnds_wrapped_spectral_progress = true
    local set_seal_spectral_ref = Card.set_seal
    function Card:set_seal(seal, silent, ...)
        local old_seal = self.seal
        local results = HNDS.pack(set_seal_spectral_ref(self, seal, silent, ...))
        if old_seal == 'hnds_spectralseal' and self.seal ~= 'hnds_spectralseal' and self.ability then
            self.ability.hnds_spectral_hands = nil
            self.ability.hnds_spectral_last_token = nil
        end
        return ((table and table.unpack) or unpack)(results, 1, results.n)
    end
end


local hnds_contagion_loc_targets = {
    c_talisman = 'Gold',
    c_deja_vu = 'Red',
    c_trance = 'Blue',
    c_medium = 'Purple',
    c_aura = 'Aura',
    c_cryptid = 'Cryptid',
    c_death = 'Death',
}

local function hnds_add_contagion_spectral_info(info_queue, kind)
    if not info_queue then return end
    if kind == 'Gold' then
        info_queue[#info_queue + 1] = { key = 'gold_seal', set = 'Other' }
    elseif kind == 'Red' then
        info_queue[#info_queue + 1] = { key = 'red_seal', set = 'Other' }
    elseif kind == 'Blue' then
        info_queue[#info_queue + 1] = { key = 'blue_seal', set = 'Other' }
    elseif kind == 'Purple' then
        info_queue[#info_queue + 1] = { key = 'purple_seal', set = 'Other' }
    elseif kind == 'Aura' then
        info_queue[#info_queue + 1] = G.P_CENTERS.e_foil
        info_queue[#info_queue + 1] = G.P_CENTERS.e_holo
        info_queue[#info_queue + 1] = G.P_CENTERS.e_polychrome
    end
end

-- Bonus-aware loc_vars installed on every target center. Ownership reroutes
-- tooltip rendering away from vanilla's per-key generate_card_ui chain, so
-- when the Contagion bonus is zero this reproduces the exact vanilla output
-- (Cryptid/Death placeholders, Aura's edition extras, fixed text otherwise).
local function hnds_contagion_center_loc_vars(self, info_queue, card)
    local kind = hnds_contagion_loc_targets[self.key]
    local bonus = hnds_contagion_bonus()

    if bonus > 0 then
        hnds_add_contagion_spectral_info(info_queue, kind)
        if self.key == 'c_cryptid' then
            local copies = (card and card.ability and tonumber(card.ability.extra))
                or (self.config and tonumber(self.config.extra))
                or 2
            return { key = 'c_hnds_contagion_cryptid', vars = { copies, 1 + bonus } }
        end
        return { key = 'c_hnds_contagion_' .. self.key:sub(3), vars = { 1 + bonus } }
    end

    if self.key == 'c_cryptid' then
        local copies = (card and card.ability and tonumber(card.ability.extra))
            or (self.config and tonumber(self.config.extra))
            or 2
        return { vars = { copies } }
    elseif self.key == 'c_death' then
        return { vars = { self.config.max_highlighted } }
    elseif self.key == 'c_aura' then
        info_queue[#info_queue + 1] = G.P_CENTERS.e_foil
        info_queue[#info_queue + 1] = G.P_CENTERS.e_holo
        info_queue[#info_queue + 1] = G.P_CENTERS.e_polychrome
    end
end

-- Bonus-aware loc_vars for the generate_card_ui proxy path. The proxy center
-- never reaches the take_ownership chain, so this reproduces exactly what
-- hnds_contagion_center_loc_vars returns while the Contagion bonus is active.
local function hnds_contagion_proxy_loc_vars(self, info_queue, card)
    return hnds_contagion_center_loc_vars(self, info_queue, card)
end

local function hnds_contagion_make_proxy(orig_center)
    return setmetatable({
        key = orig_center.key,
        set = orig_center.set or 'Spectral',
        config = orig_center.config or {},
        loc_vars = hnds_contagion_proxy_loc_vars,
    }, { __index = SMODS.Center })
end

if not _G._hnds_contagion_generate_card_ui_wrapped then
    _G._hnds_contagion_generate_card_ui_wrapped = true
    local generate_card_ui_ref = generate_card_ui

    function generate_card_ui(_c, full_UI_table, specific_vars, card_type, badges, hide_desc, main_start, main_end, card, ...)
        if _c and (_c.set == 'Spectral' or _c.key == 'c_death') and _c.key
            and not _c.generate_ui
            and hnds_contagion_bonus() > 0
            and hnds_contagion_loc_targets[_c.key]
        then
            _c = hnds_contagion_make_proxy(_c)
        end
        return generate_card_ui_ref(_c, full_UI_table, specific_vars, card_type, badges, hide_desc, main_start, main_end, card, ...)
    end
end


local function hnds_card_list(cards)
    if type(cards) ~= "table" then return {} end
    if cards[1] ~= nil then return cards end

    if cards.base or cards.playing_card or cards.config then return { cards } end
    return {}
end

local function hnds_count_confirmed_destroyed(cards)
    local counted = 0
    for _, card in ipairs(hnds_card_list(cards)) do
        if card and (card.getting_sliced or card.destroyed or card.shattered)
            and HNDS and HNDS.count_destroyed_playing_card
            and HNDS.count_destroyed_playing_card(card)
        then
            counted = counted + 1
        end
    end
    return counted
end

if SMODS and SMODS.destroy_cards and not SMODS._hnds_wrapped_destroy_cards_stat_v3 then
    SMODS._hnds_wrapped_destroy_cards_stat_v3 = true
    local destroy_cards_stat_ref = SMODS.destroy_cards
    function SMODS.destroy_cards(cards, ...)
        local candidates = hnds_card_list(cards)
        local queued = destroy_cards_stat_ref(cards, ...)


        local confirmed = type(queued) == "table" and queued or candidates
        local counted = hnds_count_confirmed_destroyed(confirmed)


        if counted == 0 and G and G.E_MANAGER and Event and #candidates > 0 then
            G.E_MANAGER:add_event(Event({
                trigger = "immediate",
                blockable = false,
                func = function()
                    hnds_count_confirmed_destroyed(candidates)
                    return true
                end,
            }))
        end
        return queued
    end
end


HNDS.should_hand_destroy = function(card)
	if not (card and type(card.get_seal) == 'function' and G and G.GAME) then return false end
	local vouchers = G.GAME.used_vouchers or {}
	local hand_cards = G.hand and G.hand.cards or {}
	return card:get_seal() == "hnds_black"
		or (vouchers.v_hnds_soaked and card == hand_cards[1])
		or (vouchers.v_hnds_beyond and card == hand_cards[#hand_cards])
end

local destroy_cards_ref = SMODS.calculate_destroying_cards

function SMODS.calculate_destroying_cards(context, cards_destroyed, scoring_hand, ...)
	local result = destroy_cards_ref(context, cards_destroyed, scoring_hand, ...)
	if type(context) ~= 'table' or type(cards_destroyed) ~= 'table' then return result end
	for _, card in ipairs((G and G.hand and G.hand.cards) or {}) do
		if HNDS.should_hand_destroy(card) then
			local destroyed = nil
			local new_context = {}
			for k, v in pairs(context) do
				new_context[k] = v
			end
			new_context.destroy_card = card
			new_context.cardarea = G.play
			new_context.destroying_card = card
			new_context.hnds_hand_trigger = true
			new_context.full_hand = G.hand.cards
			local flags = SMODS.calculate_context(new_context)
			if flags and flags.remove then destroyed = true end
			if destroyed then
				card.getting_sliced = true
				if SMODS.shatters(card) then
					card.shattered = true
				else
					card.destroyed = true
				end
				cards_destroyed[#cards_destroyed + 1] = card
			end
		end
	end
	return result
end


local score_card_ref = SMODS.score_card
function SMODS.score_card(card, context, ...)
	if type(context) ~= 'table' then return score_card_ref(card, context, ...) end
	if (not (G and G.scorehand)) and HNDS.should_hand_destroy(card) and G and context.cardarea == G.hand then
		if card:get_seal() == "hnds_black" and HNDS.record_held_effects then
			HNDS.record_held_effects(1, "hnds_black_seal")
		end
		local original_area = context.cardarea
		G.scorehand = true
		context.cardarea = G.play
		local ok, err = pcall(score_card_ref, card, context, ...)
		context.cardarea = original_area
		G.scorehand = nil
		if not ok then error(err) end
	end
	return score_card_ref(card, context, ...)
end


local set_cost_ref = Card.set_cost
function Card.set_cost(self, ...)
	local results = HNDS.pack(set_cost_ref(self, ...))
	local unpack_values = (table and table.unpack) or unpack
	if not self then return unpack_values(results, 1, results.n) end
	local key = self.config and self.config.center and self.config.center.key
	local set = self.config and self.config.center and self.config.center.set


	if key == "j_hnds_coffee_break" then self.sell_cost = 0 end
	if key == "j_hnds_art" then self.sell_cost = -5 end


	if set == "Joker"
		and G.GAME and G.GAME.selected_back
		and G.GAME.selected_back.effect and G.GAME.selected_back.effect.center
		and G.GAME.selected_back.effect.center.key == "b_hnds_premiumdeck"
		and G.GAME.round_resets and G.GAME.round_resets.ante then
		self.cost = math.floor(self.cost + G.GAME.round_resets.ante)
	end


	if G and G.GAME and G.GAME.hnds_price_multiplier and G.GAME.hnds_price_multiplier > 1 then
		if set == "Joker" or set == "Booster" or set == "Consumable" then
			self.cost = math.max(0, math.floor(self.cost * G.GAME.hnds_price_multiplier))
		end
	end
	return unpack_values(results, 1, results.n)
end


local function hnds_finalize_generated_curse(card)
	if hnds_card_has_cursed(card) then hnds_strip_other_stickers(card) end
end

if SMODS and SMODS.create_card and not SMODS._hnds_wrapped_create_card_shop then
	SMODS._hnds_wrapped_create_card_shop = true
	local smods_create_card_ref = SMODS.create_card
	function SMODS.create_card(args, ...)
		HNDS = HNDS or {}
        local pack = HNDS.pack
        local unpack_values = table.unpack or unpack
		local previous_type = HNDS._creating_smods_card_type
		HNDS._creating_smods_card_type = type(args) == 'table' and args.type or nil
		local packed = pack(pcall(smods_create_card_ref, args, ...))
		HNDS._creating_smods_card_type = previous_type
		if not packed[1] then error(packed[2]) end
		local created_card = packed[2]
		hnds_finalize_generated_curse(created_card)


		return unpack_values(packed, 2, packed.n)
	end
end


if not _G._hnds_wrapped_create_card then
	_G._hnds_wrapped_create_card = true
	local create_card_ref = create_card
	function create_card(_type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append, ...)


		local previous_source = HNDS and HNDS._creating_card_source
		HNDS = HNDS or {}
		HNDS._creating_card_source = {
			type = _type,
			area = area,
			forced_key = forced_key,
			key_append = key_append,
		}
        local pack = HNDS.pack
        local unpack_values = table.unpack or unpack
		local packed = pack(pcall(create_card_ref, _type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append, ...))
		HNDS._creating_card_source = previous_source
		if not packed[1] then error(packed[2]) end
        local card = packed[2]


		if HNDS and HNDS.try_devils_round_curse then
			HNDS.try_devils_round_curse(card)
		end


		hnds_finalize_generated_curse(card)
		return unpack_values(packed, 2, packed.n)
	end
end


if not Card._hnds_wrapped_add_to_deck then
	Card._hnds_wrapped_add_to_deck = true
	local add_to_deck_ref = Card.add_to_deck
	function Card:add_to_deck(from_debuff, ...)
		local results = HNDS.pack(add_to_deck_ref(self, from_debuff, ...))
		local unpack_values = (table and table.unpack) or unpack

		if not from_debuff then


			if self.ability and self.ability.hnds_copies_to_create
				and G and G.GAME and G.jokers and G.jokers.cards and G.jokers.config
			then
				G.GAME.joker_buffer = G.GAME.joker_buffer or 0
				local pending_original = self.area == G.jokers and 0 or 1
				for _ = 1, self.ability.hnds_copies_to_create do
					local occupied = #G.jokers.cards + G.GAME.joker_buffer + pending_original
					if occupied < G.jokers.config.card_limit then
						G.GAME.joker_buffer = G.GAME.joker_buffer + 1
						local c = self
						G.E_MANAGER:add_event(Event {
							func = function()
								G.GAME.joker_buffer = math.max(0, (G.GAME.joker_buffer or 1) - 1)
								if G.jokers and G.jokers.cards and G.jokers.config
									and #G.jokers.cards < G.jokers.config.card_limit
									and c and not c.removed
								then
									local copy = copy_card(c)
									if copy then
										copy.ability.hnds_copies_to_create = nil
										copy:add_to_deck()
										G.jokers:emplace(copy)
									end
								end
								return true
							end
						})
					end
				end
				self.ability.hnds_copies_to_create = nil
			end


			if HNDS and HNDS.try_devils_round_curse then
				HNDS.try_devils_round_curse(self)
			end

			if hnds_card_has_cursed(self) then hnds_strip_other_stickers(self) end


			-- Play sound when cursed jokers are added (general, not just Devil's Round)
			-- Suppressed for internal remove/add cycles like Joker Reverse flips.
			if self.ability and (self.ability.hnds_curse_offer or self.ability.hnds_curse_price)
				and not (HNDS and HNDS._suppress_curse_sound) then
				play_sound("hnds_curse_used", 1, 0.75)
			end
		end

		return unpack_values(results, 1, results.n)
	end
end


local find_joker_ref = find_joker
function find_joker(name, non_debuff, ...)
	local jokers = find_joker_ref(name, non_debuff, ...)
	if type(jokers) ~= 'table' then jokers = {} end
	local circus_cards = G and G.hnds_circus_joker and G.hnds_circus_joker.cards
	if type(circus_cards) == 'table' then
		for _, v in pairs(circus_cards) do
			local ability = v and type(v) == 'table' and v.ability
			if ability and ability.name == name and (non_debuff or not v.debuff) then
				table.insert(jokers, v)
			end
		end
	end
	return jokers
end


local get_new_boss_ref = get_new_boss

local function hnds_crystal_forces_showdown(ante)
    if not (G and G.GAME and G.GAME.modifiers) then return false end
    local modifiers = G.GAME.modifiers
    if modifiers.crystal_sleeve_active then
        return ante == 2 or ante == 4 or ante == 6
    end
    return (modifiers.hnds_crystal_showdown or modifiers.hnds_double_showdown) and ante == 4
end

function get_new_boss(...)
    if not (G and G.GAME and G.GAME.round_resets) then return get_new_boss_ref(...) end

    local win_ante = G.GAME.win_ante
    local ante = G.GAME.round_resets.ante
    if not G.GAME.hnds_bypass_ante_10_force and hnds_crystal_forces_showdown(ante) and ante < win_ante then


        G.GAME.win_ante = ante
    end

    local boss_args = { n = select('#', ...), ... }
    local unpack_values = table.unpack or unpack
    local function invoke_boss_ref()
        return get_new_boss_ref(unpack_values(boss_args, 1, boss_args.n))
    end
    local function select_boss()
        if HNDS and HNDS.call_with_platinum_reroll_bans then
            return HNDS.call_with_platinum_reroll_bans(invoke_boss_ref)
        end
        return invoke_boss_ref()
    end

    local pack = HNDS.pack
    local unpack_values2 = table.unpack or unpack
    local packed = pack(pcall(select_boss))
    G.GAME.win_ante = win_ante
    if not packed[1] then error(packed[2]) end
    return unpack_values2(packed, 2, packed.n)
end


if G and G.UIDEF and G.UIDEF.challenge_description_tab and not G.UIDEF._hnds_wrapped_challenge_description_tab then
	G.UIDEF._hnds_wrapped_challenge_description_tab = true
	local challenge_description_tab_ref = G.UIDEF.challenge_description_tab
	function G.UIDEF.challenge_description_tab(args, ...)
		local ret = challenge_description_tab_ref(args, ...)
		if not (args and args._tab == 'Restrictions') then
			return ret
		end
		if not (G and G.P_CENTERS and G.P_CENTERS.j_joker) then
			return ret
		end

		local function patch_node(node)
			if type(node) ~= 'table' then return end
			local obj = node.config and node.config.object
			if obj and type(obj) == 'table' and obj.cards and type(obj.cards) == 'table' then
				for i = 1, #obj.cards do
					local c = obj.cards[i]
					if c and c.config and c.config.center and c.config.center.set == 'Edition' and c.config.center.key then
						local edition_key = c.config.center.key
						c:set_ability(G.P_CENTERS.j_joker, true, true)
						c:set_edition(edition_key, true, true)
					end
				end
			end
			if node.nodes and type(node.nodes) == 'table' then
				for j = 1, #node.nodes do
					patch_node(node.nodes[j])
				end
			end
		end

		patch_node(ret)
		return ret
	end
end


function HNDS.excommunicado_effect_active()
	if not (SMODS and SMODS.find_card) then return false end

	local excom_cards = SMODS.find_card('j_hnds_excommunicado')
	if excom_cards and next(excom_cards) then return true end

	local jack_cards = SMODS.find_card('j_hnds_jack_in_the_box')
	if jack_cards then
		for _, jack in pairs(jack_cards) do
			local extra = jack and jack.ability and jack.ability.extra
			if extra and extra.active == true and extra.rare_key == 'j_hnds_excommunicado' then
				return true
			end
		end
	end
	return false
end

local function hnds_excommunicado_active()
	return HNDS.excommunicado_effect_active and HNDS.excommunicado_effect_active() or false
end

local function hnds_is_showdown_boss(blind_key)
	local blind = G and G.P_BLINDS and G.P_BLINDS[blind_key]
	return blind and blind.boss and blind.boss.showdown == true
end

local function hnds_excommunicado_fallback_boss(seed_key)
	if not (G and G.GAME and G.P_BLINDS) then return nil end

	local ante = G.GAME.round_resets and G.GAME.round_resets.ante or 1
	local eligible = {}
	for key, blind in pairs(G.P_BLINDS) do
		local boss = blind and blind.boss
		local min_ante = boss and tonumber(boss.min)
		local max_ante = boss and tonumber(boss.max)
		local banned = G.GAME.banned_keys and G.GAME.banned_keys[key]
		if boss
			and boss.showdown ~= true
			and not banned
			and (not min_ante or ante >= min_ante)
			and (not max_ante or ante <= max_ante)
		then
			eligible[key] = (G.GAME.bosses_used and G.GAME.bosses_used[key]) or 0
		end
	end

	local min_use
	for _, uses in pairs(eligible) do
		if type(uses) == 'number' and (min_use == nil or uses < min_use) then
			min_use = uses
		end
	end
	if min_use ~= nil then
		for key, uses in pairs(eligible) do
			if type(uses) ~= 'number' or uses ~= min_use then eligible[key] = nil end
		end
	end

	local _, picked = pseudorandom_element(eligible, pseudoseed(seed_key or 'hnds_excommunicado_boss'))
	return picked
end


function HNDS.get_excommunicado_boss(seed_key)
	if not (G and G.GAME and G.GAME.round_resets) then
		return get_new_boss()
	end

	local old_win_ante = G.GAME.win_ante
	local old_bypass = G.GAME.hnds_bypass_ante_10_force
	local ante = tonumber(G.GAME.round_resets.ante) or 1
	local win_ante = tonumber(old_win_ante) or 8

	G.GAME.hnds_bypass_ante_10_force = true
	G.GAME.win_ante = math.max(win_ante, ante + 1000)
	local ok, picked = pcall(get_new_boss)
	G.GAME.win_ante = old_win_ante
	G.GAME.hnds_bypass_ante_10_force = old_bypass

	if ok and picked and not hnds_is_showdown_boss(picked) then
		return picked
	end


	if ok and picked and hnds_is_showdown_boss(picked)
		and G.GAME.bosses_used and type(G.GAME.bosses_used[picked]) == 'number'
	then
		G.GAME.bosses_used[picked] = math.max(0, G.GAME.bosses_used[picked] - 1)
	end

	local fallback = hnds_excommunicado_fallback_boss(
		(seed_key or 'hnds_excommunicado_boss') .. '_' .. tostring(ante)
	)
	if fallback then
		if G.GAME.bosses_used then
			local uses = G.GAME.bosses_used[fallback]
			G.GAME.bosses_used[fallback] = (type(uses) == 'number' and uses or 0) + 1
		end
		return fallback
	end

	if not ok then error(picked) end
	return picked
end


local Blind_get_type_ref = Blind.get_type
function Blind:get_type(...)
	if not hnds_excommunicado_active() then
		return Blind_get_type_ref(self, ...)
	end


	if G.GAME and G.GAME.blind == self and G.GAME.blind_on_deck then
		return G.GAME.blind_on_deck
	end

	return Blind_get_type_ref(self, ...)
end


function HNDS.replace_current_blinds_with_bosses()
	if not (G.GAME and G.GAME.round_resets and G.GAME.round_resets.blind_choices) then return end
	local blind_choices = G.GAME.round_resets.blind_choices
	local blind_states = G.GAME.round_resets.blind_states or {}
	local used_bosses = {}

	if blind_choices.Boss then
		table.insert(used_bosses, blind_choices.Boss)
	end

	local function replace_if_vanilla(blind_type, seed_key)
		local choice = blind_choices[blind_type]
		local state = blind_states[blind_type]
		if not (choice and state ~= 'Defeated' and choice == 'bl_' .. blind_type:lower()) then return end

		local eligible_bosses = {}
		for k, v in pairs(G.P_BLINDS) do
			if v.boss and not v.boss.showdown then
				local is_used = false
				for _, used in ipairs(used_bosses) do
					if used == k then is_used = true break end
				end
				if not is_used then
					eligible_bosses[k] = (G.GAME.bosses_used and G.GAME.bosses_used[k]) or 0
				end
			end
		end
		local min_use = 100
		for k, v in pairs(eligible_bosses) do
			if v < min_use then min_use = v end
		end
		for k, v in pairs(eligible_bosses) do
			if v > min_use then eligible_bosses[k] = nil end
		end
		local _, new_boss = pseudorandom_element(eligible_bosses, pseudoseed(seed_key .. '_' .. G.GAME.round_resets.ante))
		if new_boss then
			blind_choices[blind_type] = new_boss
			table.insert(used_bosses, new_boss)
		end
	end

	replace_if_vanilla('Small', 'excom_small')
	replace_if_vanilla('Big', 'excom_big')
end
function HNDS.update_excom()
	if HNDS.excommunicado_effect_active and HNDS.excommunicado_effect_active() then
		HNDS.replace_current_blinds_with_bosses()
	elseif G and G.GAME and G.GAME.round_resets and G.GAME.round_resets.blind_choices then
		G.GAME.round_resets.blind_choices.Small = "bl_small"
		G.GAME.round_resets.blind_choices.Big = "bl_big"
	end
end

-------------------------------------------------------------------
-- CURSED STICKER TOOLTIP WORKAROUND
-------------------------------------------------------------------
-- SMODS doesn't support generate_ui for stickers, only loc_vars.
-- We dynamically modify the localization entry for hnds_cursed
-- based on the current card being evaluated.
-- The card reference itself is captured by the sticker's own loc_vars
-- in lib/curses.lua (_G.HNDS_CURRENT_CURSE_CARD).

_G.HNDS_CURRENT_CURSE_CARD = nil


local original_loc_vars = nil


function HNDS_setup_cursed_sticker_hook(sticker)
	if not sticker then return end
	original_loc_vars = sticker.loc_vars
	sticker.loc_vars = function(self, info_queue, card)
		_G.HNDS_CURRENT_CURSE_CARD = card
		if original_loc_vars then
			return original_loc_vars(self, info_queue, card)
		end
		return { vars = {} }
	end
end


-------------------------------------------------------------------
-- PERFECTIONIST: REPLACE RE-ENHANCING WITH PERMANENT STATS
-------------------------------------------------------------------
-- This lives in the post-content hook layer instead of the Joker file so it
-- wraps Aberrant/Obsidian after their enhancement machinery is registered.
-- It also preserves the Ortalab bottle guard used by the previous implementation.
if Card and Card.set_ability and not Card._hnds_perfectionist_reenhance then
    Card._hnds_perfectionist_reenhance = true
    local hnds_perfectionist_set_ability_ref = Card.set_ability

    local function hnds_resolve_center(center)
        if type(center) == 'string' then
            return G and G.P_CENTERS and G.P_CENTERS[center] or nil
        end
        return center
    end

    local function hnds_perfectionists()
        if not (SMODS and type(SMODS.find_card) == 'function') then return {} end
        local ok, cards = pcall(SMODS.find_card, 'j_hnds_perfectionist')
        return ok and type(cards) == 'table' and cards or {}
    end


    local function hnds_add_permanent_stat(current, amount)
        if current == nil then return amount end
        local ok, result = pcall(function() return current + amount end)
        if ok then return result end
        return (tonumber(current) or 0) + amount
    end

    function Card:set_ability(center, initial, delay_sprites, ...)
        local old_center = self and self.config and self.config.center
        local new_center = hnds_resolve_center(center)
        local internal_swap = HNDS and HNDS._aberrant_internal_center_swap
        local ortalab_rolling = G and G._ortalab_bottle_rolling

        if not initial and not internal_swap and not ortalab_rolling
            and old_center and old_center.set == 'Enhanced'
            and new_center and new_center.set == 'Enhanced'
            and old_center.key ~= new_center.key
        then
            local owners = hnds_perfectionists()
            if #owners > 0 and self.ability then
                local total_mult, total_chips = 0, 0
                for _, joker in ipairs(owners) do
                    if joker and not joker.debuff and joker.ability and joker.ability.extra then
                        total_mult = total_mult + (tonumber(joker.ability.extra.mult) or 4)
                        total_chips = total_chips + (tonumber(joker.ability.extra.chips) or 30)
                    end
                end

                if total_mult ~= 0 or total_chips ~= 0 then
                    self.ability.perma_mult = hnds_add_permanent_stat(self.ability.perma_mult, total_mult)
                    self.ability.perma_bonus = hnds_add_permanent_stat(self.ability.perma_bonus, total_chips)
                    if self.juice_up then self:juice_up(0.3, 0.25) end
                    for _, joker in ipairs(owners) do
                        if joker and not joker.debuff and type(card_eval_status_text) == 'function' then
                            card_eval_status_text(joker, 'extra', nil, nil, nil, {
                                message = localize('k_upgrade_ex'),
                                colour = G.C.FILTER,
                            })
                        end
                    end


                    return self
                end
            end
        end

        return hnds_perfectionist_set_ability_ref(self, center, initial, delay_sprites, ...)
    end
end


local get_blind_amount_ref = get_blind_amount
function get_blind_amount(ante, ...)
	local amount = get_blind_amount_ref(ante, ...)
	local count = G and G.GAME and G.GAME.modifiers and G.GAME.modifiers.hnds_base_blind_increase
	if count and count > 0 and amount ~= nil then


		local ok, scaled = pcall(function() return amount * (1.5 ^ count) end)
		if ok then amount = type(scaled) == 'number' and math.floor(scaled) or scaled end
	end
	return amount
end


if CardArea and CardArea.emplace and not HNDS._title_locked_hint_suppress_guard then
    HNDS._title_locked_hint_suppress_guard = true
    local hnds_cardarea_emplace_ref = CardArea.emplace

    local function hnds_is_locked_title_hint(area, card)
        if not (G and G.title_top and area == G.title_top and card) then return false end
        local center = card.config and card.config.center
        if not center or center.unlocked ~= false then return false end
        if center.set ~= 'Joker' and center.set ~= 'Voucher' then return false end


        local existing = area.cards and area.cards[1]
        local existing_center = existing and existing.config and existing.config.center
        local key = existing_center and existing_center.key
        return type(key) == 'string' and (key:match('^j_hnds_')
            or key:match('^c_hnds_') or key:match('^p_hnds_')) ~= nil
    end

    function CardArea:emplace(card, ...)
        if hnds_is_locked_title_hint(self, card) and self.cards and #self.cards > 0 then


            local ret = hnds_cardarea_emplace_ref(self, card, ...)
            self:remove_card(card)
            if card.remove then card:remove() end
            return ret
        end
        return hnds_cardarea_emplace_ref(self, card, ...)
    end
end


if Card and Card.align_h_popup and not HNDS._stable_hnds_tooltip_align_v3 then
    HNDS._stable_hnds_tooltip_align_v3 = true

    local function hnds_uses_custom_tooltip(card)
        if not card then return false end
        local center = card.config and card.config.center
        if center and center.mod and center.mod.id == 'HandsomeDevils' then return true end
        local key = center and tostring(center.key or '') or ''
        if key:find('hnds_', 1, true) then return true end
        if card.seal and tostring(card.seal):find('hnds_', 1, true) then return true end
        if card.edition then
            for k, v in pairs(card.edition) do
                if v and tostring(k):find('hnds_', 1, true) then return true end
            end
        end
        if card.ability then
            for k, v in pairs(card.ability) do
                if v and tostring(k):find('hnds_', 1, true) then return true end
            end
            if type(card.ability.stickers) == 'table' then
                for k, v in pairs(card.ability.stickers) do
                    if v and tostring(k):find('hnds_', 1, true) then return true end
                end
            end
        end
        if card.stickers then
            for k, v in pairs(card.stickers) do
                if v and tostring(k):find('hnds_', 1, true) then return true end
            end
        end
        return false
    end

    local hnds_align_h_popup_ref = Card.align_h_popup
    function Card:align_h_popup(...)
        local native = hnds_align_h_popup_ref(self, ...)
        if not hnds_uses_custom_tooltip(self) or type(native) ~= 'table' then
            return native
        end


        local area = self.area
        local cache = self.hnds_tooltip_alignment_cache
        if type(cache) ~= 'table' or cache.area ~= area then
            cache = {
                area = area,
                type = native.type,
                align = native.align,
                offset_x = native.offset and native.offset.x or nil,
                offset_y = native.offset and native.offset.y or nil,
                lr_clamp = native.lr_clamp,
            }
            self.hnds_tooltip_alignment_cache = cache
        end

        if cache.type ~= nil then native.type = cache.type end
        if cache.align ~= nil then native.align = cache.align end
        if native.offset then
            if cache.offset_x ~= nil then native.offset.x = cache.offset_x end
            if cache.offset_y ~= nil then native.offset.y = cache.offset_y end
        end
        if cache.lr_clamp ~= nil then native.lr_clamp = cache.lr_clamp end
        return native
    end
end
