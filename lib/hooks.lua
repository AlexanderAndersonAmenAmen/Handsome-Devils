--[[
We have a lot of hooks here, they do global stuff and helps with specifit effects from Jokers, Blinds and more

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




-------------------------------------------------------------------
-- Handsome Devils hooks
-------------------------------------------------------------------

HNDS = HNDS or {}



-------------------------------------------------------------------
-- Devil system
--
-- main.lua already loads lib/devil_bosses.lua before blinds/blind_devil.lua.
-- Do not load either file again here; double registration corrupts state and
-- makes debugging the blind much harder.
-------------------------------------------------------------------

-------------------------------------------------------------------
-- ANTE 10 SHOWDOWN BOSS POOL
-------------------------------------------------------------------

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
    -- Crystal only replaces the normal Ante 8 showdown. Platinum and higher
    -- move the run's showdown/win Ante to 10, so Ante 8 must remain an ordinary
    -- Boss Blind on those stakes.
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

-------------------------------------------------------------------
-- ANTE 10 GLOBAL BOSS SUPPORT
-------------------------------------------------------------------

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

-- Crystal Ball and Antimatter change CardArea limits directly, so hiding
-- G.GAME.used_vouchers is not enough after those CardAreas already exist.
-- Remove only their own bonus, never derive a new limit from nil/zero, and
-- remember the exact bonus to add back when Wasted Wish stops being active.
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
            -- If the CardArea is not ready yet (or already has a base-sized
            -- limit), the empty voucher proxy will make it initialize without
            -- Crystal Ball's bonus. Do not subtract again later.
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

-- Vouchers remain purchasable while Wasted Wish is active. After redemption,
-- rebuild the disabled-voucher snapshot so the newly bought Voucher is owned
-- but its effect stays suppressed until Wasted Wish ends or is rerolled away.
if Card and Card.redeem and not Card._hnds_wasted_wish_redeem then
    Card._hnds_wasted_wish_redeem = true
    local hnds_wasted_wish_redeem_ref = Card.redeem

    function Card:redeem(...)
        local refresh_after = G and G.GAME
            and G.GAME.hnds_wasted_wish_active
            and self.ability and self.ability.set == "Voucher"

        local result = hnds_wasted_wish_redeem_ref(self, ...)

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

        return result
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
            -- Save files do not preserve metatables; reinstall the proxy after
            -- loading so Voucher checks stay disabled for the rest of the Ante.
            local mt = type(G.GAME.used_vouchers) == "table"
                and getmetatable(G.GAME.used_vouchers)
            if not (mt and mt.__newindex) then
                hnds_install_wasted_wish_voucher_proxy()
            end

            -- CardAreas may be created shortly after boss selection. Apply the
            -- slot removal once they exist, without ever turning a missing or
            -- zero-valued limit into zero slots.
            hnds_wasted_wish_disable_slot_bonuses(
                G.GAME.hnds_wasted_wish_adjustments)
        end
    end
end


-------------------------------------------------------------------
-- NIGHTMARE STAKE: CURSED JOKER LEFT IN SHOP
-------------------------------------------------------------------

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

-- Called at the beginning of toggle_shop, while the shop cards still exist.
-- The actual Blind replacement is deferred until the next Blind Select screen
-- is built. At that point vanilla has finalized blind_on_deck, blind_states and
-- (after a Boss shop) the new Ante's Small/Big choices.
HNDS.handle_nightmare_cursed_shop_exit = function()
    if not (G and G.GAME and G.shop) then return false end
    if G.STATES and G.STATES.SHOP and G.STATE ~= G.STATES.SHOP then return false end
    if not hnds_nightmare_stake_active() then return false end

    -- Both the runtime wrapper and the Lovely fallback can fire for the same
    -- click. The run-level pending flag blocks that duplicate immediately,
    -- while the shop-local flag is cleared on the next event-manager tick so
    -- the following shop (including the shop before Big Blind) can queue too.
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

-- Runtime wrapper is the primary hook. The Lovely patch remains as a fallback
-- for load orders where another mod replaces toggle_shop after this file loads.
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


-------------------------------------------------------------------
-- TAG POP COUNTER (Forbidden Fruit)
-------------------------------------------------------------------

-- Count a Tag exactly once when it actually triggers. Creation, holding and
-- copying do not count by themselves; a copied Tag counts when it later pops.
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
            -- Investment is handled directly by the real physical Boss-slot
            -- defeat hook in vanilla_investment_tag.lua. Suppress vanilla's
            -- broad last_blind.boss check to avoid upgraded Small/Big payouts.
            result = false
        else
            result = tag_apply_to_run_ref(self, context, ...)
        end

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

-------------------------------------------------------------------
-- BADGE COLOR
-------------------------------------------------------------------

-- Color for Carcosa badge effect.
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
	function localize(args, misc_cat, misc_loc, silent)
		HNDS_ensure_loc_colours()
		
		-- Cursed sticker tooltip workaround: dynamically modify localization entry
		if type(args) == 'table' and args.key == 'hnds_cursed' and args.type == 'other' then
			local card = _G.HNDS_CURRENT_CURSE_CARD
			if card and card.ability then
				local offer = card.ability.hnds_curse_offer
				local price = card.ability.hnds_curse_price
				local display_mode = card.ability.hnds_curse_display_mode
				
				if offer or price then
					-- Build dynamic description
					local desc_lines = {}
					local offer_lines_count = 0
					
					if display_mode == 'offer' and offer then
						local offer_loc = G.localization.descriptions.Other[offer]
						if offer_loc and offer_loc.text then
							for _, line in ipairs(offer_loc.text) do
								table.insert(desc_lines, line)
							end
						end
					elseif display_mode == 'price' and price then
						local price_loc = G.localization.descriptions.Other[price]
						if price_loc and price_loc.text then
							for _, line in ipairs(price_loc.text) do
								table.insert(desc_lines, line)
							end
						end
					else
						local offer_loc = offer and G.localization.descriptions.Other[offer]
						if offer_loc and offer_loc.text then
							for _, line in ipairs(offer_loc.text) do
								table.insert(desc_lines, line)
								offer_lines_count = offer_lines_count + 1
							end
						end
						local price_loc = price and G.localization.descriptions.Other[price]
						if price_loc and price_loc.text then
							for _, line in ipairs(price_loc.text) do
								table.insert(desc_lines, line)
							end
						end
					end
					-- Temporarily modify the localization entry
					local loc_entry = G.localization.descriptions.Other.hnds_cursed
					local original_text = loc_entry and loc_entry.text
					local original_text_parsed = loc_entry and loc_entry.text_parsed
					if loc_entry then
						loc_entry.text = desc_lines
						-- Regenerate text_parsed for the new text
						loc_entry.text_parsed = nil
						if loc_parse_string then
							loc_entry.text_parsed = {}
							for _, line in ipairs(desc_lines) do
								table.insert(loc_entry.text_parsed, loc_parse_string(line))
							end
						end
					end
					-- Call original localize
					local result = localize_ref(args, misc_cat, misc_loc, silent)
					
					-- Insert a native UI separator line between offer and price
					if offer_lines_count > 0 and args.nodes then
						local separator_line = {
							{n=G.UIT.C, config={align = "cm", minh = 0.03, minw = 2.4, colour = G.C.UI.TEXT_INACTIVE}}
						}
						table.insert(args.nodes, offer_lines_count + 1, separator_line)
					end
					
					-- Restore original entry
					if loc_entry then
						loc_entry.text = original_text
						loc_entry.text_parsed = original_text_parsed
					end
					return result
				end
			end
		end
		return localize_ref(args, misc_cat, misc_loc, silent)
	end
end

-------------------------------------------------------------------
-- CURSED STICKER EXCLUSIVITY
-------------------------------------------------------------------

-- Cursed Sticker exclusivity functions.
-- hnds_card_has_cursed: quick check for the cursed sticker on a Joker.
-- hnds_strip_other_stickers: remove every sticker except hnds_cursed from a cursed Joker, including Rental.
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
	-- Collect before clearing fields so remove_sticker can clean visual/state data.
	local to_remove = {}
	for _, k in ipairs({ 'perishable', 'eternal', 'rental' }) do
		if card.ability[k]
			or (card.stickers and card.stickers[k])
			or (card.ability.stickers and card.ability.stickers[k])
		then
			to_remove[k] = true
		end
	end
	-- Collect all sticker keys, mostly exist bc Bunco creates stickers with card.ability
	if SMODS and SMODS.Sticker and SMODS.Sticker.obj_buffer then
		for _, k in ipairs(SMODS.Sticker.obj_buffer) do
			if k ~= 'hnds_cursed' and card.ability[k] then
				to_remove[k] = true
			end
		end
	end
	-- Also checks card.stickers table
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
	-- Remove other stickers
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
	-- Force update on the Joker
	-- Built-in sticker flags must be nil even when a mod bypassed add_sticker.
	card.ability.perishable = nil
	card.ability.eternal = nil
	card.ability.rental = nil
	if any_removed and card.set_sticker_display then
		pcall(card.set_sticker_display, card)
	end
end

-- Block add_sticker calls on cursed jokers (prevents other thing adding stickers to cursed jokers)
if Card and Card.add_sticker and not _G._hnds_wrapped_add_sticker_cursed then
	_G._hnds_wrapped_add_sticker_cursed = true
	local add_sticker_ref = Card.add_sticker
	function Card:add_sticker(key, ...)
		if key ~= 'hnds_cursed' and hnds_card_has_cursed(self) then return end
		local ret = add_sticker_ref(self, key, ...)
		if key == 'hnds_cursed' then
			hnds_strip_other_stickers(self)
		end
		return ret
	end
end

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

-- Public helper for custom consumables (for example Exchange) that implement
-- their own selection limits instead of using vanilla max_highlighted fields.
HNDS.get_contagion_bonus = hnds_contagion_bonus

local function hnds_sync_contagion_container(container, bonus, forced_base)
    if type(container) ~= 'table' then return false end

    -- Aura is a vanilla exception: it has no max_highlighted field and its
    -- one-card rule is hard-coded. While Contagion is active, temporarily give
    -- it ordinary selection fields so the hand UI can highlight extra cards.
    -- Remove those fields again when Contagion leaves play so vanilla Aura's
    -- editionless-card validation remains authoritative.
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

    -- Only card-selecting consumables are eligible. Some consumables use a
    -- field named mod_num for unrelated quantities, so changing mod_num without
    -- a max_highlighted field would leak Contagion into non-targeting effects.
    if type(container.max_highlighted) ~= 'number' then
        if previous_bonus ~= 0 and type(container.mod_num) == 'number' then
            container.mod_num = math.max(0, container.mod_num - previous_bonus)
        end
        container.hnds_contagion_bonus = nil
        return false
    end

    -- Steamodded 1620a and many vanilla-style consumables keep their targeting
    -- values in ability.consumeable. Cryptid and a number of custom Spectral
    -- cards keep the same values directly on card.ability instead. Treat both
    -- layouts identically and preserve changes made by other mods by removing
    -- only the bonus that Contagion applied on the previous update.
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
    -- Death is a special Contagion synergy: it always expands from 2 targets
    -- to exactly 3, even if several Contagions are present.
    if is_death then bonus = bonus > 0 and 1 or 0 end
    local is_aura = center_key == 'c_aura' or card.ability.name == 'Aura'

    -- Historical Steamodded spelling.
    if is_aura then
        card.ability.consumeable = card.ability.consumeable or {}
        hnds_sync_contagion_container(card.ability.consumeable, bonus, 1)
    else
        hnds_sync_contagion_container(card.ability.consumeable, bonus)
    end

    -- Compatibility with mods that use the corrected spelling.
    if card.ability.consumable ~= card.ability.consumeable then
        if is_aura then
            card.ability.consumable = card.ability.consumable or {}
            hnds_sync_contagion_container(card.ability.consumable, bonus, 1)
        else
            hnds_sync_contagion_container(card.ability.consumable, bonus)
        end
    end

    -- Cryptid Spectrals and modern SMODS custom consumables commonly place
    -- max_highlighted/mod_num directly on card.ability.
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

if Card and Card.update and not Card._hnds_wrapped_update_runtime then
    Card._hnds_wrapped_update_runtime = true
    local card_update_ref = Card.update
    function Card:update(dt, ...)
        local ret = card_update_ref(self, dt, ...)
        if hnds_card_has_cursed(self) and hnds_cursed_needs_strip(self) then
            hnds_strip_other_stickers(self)
        end
        -- Previously every Card scanned the complete Joker area every frame.
        -- Restrict synchronization to actual consumables/targeting cards.
        if hnds_card_needs_contagion_sync(self) then
            hnds_sync_contagion_selection(self)
        end
        return ret
    end
end

-- Ante-10 maintenance is global work and must run once per frame, not once for
-- every Card object. The old placement caused progressively worse frame times
-- as deck/shop/collection card counts grew.
if Game and Game.update and not Game._hnds_wrapped_update_runtime then
    Game._hnds_wrapped_update_runtime = true
    local game_update_runtime_ref = Game.update
    local hnds_runtime_game_ref = nil
    function Game:update(dt, ...)
        local ret = game_update_runtime_ref(self, dt, ...)
        hnds_update_ante_10_runtime()

        -- These are installation/migration helpers, not frame maintenance. The
        -- previous code called both every frame, which could repeatedly inspect
        -- or re-wrap runtime methods and needlessly retained wrapper chains when
        -- another mod touched the same Blind methods. Run them once per G.GAME.
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


-- Vanilla's six single-target Spectral effects still read only
-- G.hand.highlighted[1] even when Contagion raises their selection limit. Keep
-- vanilla's first-target handling intact, then apply the same effect to every
-- additional selected card. Death is deliberately absent from this list.
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

        local ret = use_consumeable_contagion_ref(self, area, copier, ...)

        if not selected or #selected <= 1 then return ret end

        local seal = hnds_contagion_seal_spectrals[center_key]
        if seal then
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.1,
                func = function()
                    for i = 2, #selected do
                        local target = selected[i]
                        if target then target:set_seal(seal, nil, true) end
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
                        if target and not target.edition then
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
                        if target and target ~= death_source then
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
                        if target then
                            for _ = 1, copies_per_card do
                                G.playing_card = (G.playing_card and G.playing_card + 1) or 1
                                local copied = copy_card(target, nil, nil, G.playing_card)
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
                    if #new_cards > 0 then playing_card_joker_effects(new_cards) end
                    return true
                end,
            }))
        end

        return ret
    end
end

-- Aura's vanilla special-case accepts exactly one editionless card before the
-- generic max_highlighted check. With Contagion, validate every selected Aura
-- target instead, preventing editioned cards from slipping through.
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

-- Clear per-card Spectral Seal progress when the seal is removed or replaced.
if Card and Card.set_seal and not Card._hnds_wrapped_spectral_progress then
    Card._hnds_wrapped_spectral_progress = true
    local set_seal_spectral_ref = Card.set_seal
    function Card:set_seal(seal, silent, ...)
        local old_seal = self.seal
        local ret = set_seal_spectral_ref(self, seal, silent, ...)
        if old_seal == 'hnds_spectralseal' and self.seal ~= 'hnds_spectralseal' and self.ability then
            self.ability.hnds_spectral_hands = nil
            self.ability.hnds_spectral_last_token = nil
        end
        return ret
    end
end

-------------------------------------------------------------------
-- CONTAGION TOOLTIP SWAP
-- By default Spectrals have fixed numbers and no plurar so we have to make
-- that ourselves to keep the linguistic clarity
-------------------------------------------------------------------

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

local function hnds_contagion_proxy_loc_vars(self, info_queue, card)
    local orig_key = self.key
    local kind = hnds_contagion_loc_targets[orig_key]
    hnds_add_contagion_spectral_info(info_queue, kind)
    local bonus = hnds_contagion_bonus()
    if orig_key == 'c_cryptid' then
        local copies = (card and card.ability and tonumber(card.ability.extra))
            or (self.config and tonumber(self.config.extra))
            or 2
        return {
            key = 'c_hnds_contagion_cryptid',
            vars = { copies, 1 + bonus },
        }
    end
    return {
        key = 'c_hnds_contagion_' .. orig_key:sub(3),
        vars = { 1 + bonus },
    }
end

-- Build a one-shot SMODS.Center-backed center that mirrors a vanilla Spectral
-- but routes description rendering through our contagion loc_vars.
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



-------------------------------------------------------------------
-- PLATINUM STAKE
-------------------------------------------------------------------

-- win_ante = 10 and the hnds_platinum_active flag are set directly by
-- Platinum Stake's own `modifiers()` hook (see stakes/platinum.lua) --
-- that's the officially supported place for a stake to touch game state
-- at the start of a run, so nothing needs to happen here.

-------------------------------------------------------------------
-- CARD DESTRUCTION UNLOCKS
-------------------------------------------------------------------

-- Count only cards that Steamodded has accepted into its real destruction
-- queue. start_dissolve is also used for transformations and presentation,
-- so wrapping it directly caused enhanced cards and other animations to count.
local function hnds_card_list(cards)
    if type(cards) ~= "table" then return {} end
    if cards[1] ~= nil then return cards end
    -- A single Card is also a table, but does not have an array entry.
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

        -- Newer Steamodded builds return the accepted queue. The beta used by
        -- this mod may return nil, but it still marks accepted cards
        -- getting_sliced/destroyed/shattered synchronously. Support both.
        local confirmed = type(queued) == "table" and queued or candidates
        local counted = hnds_count_confirmed_destroyed(confirmed)

        -- Some destruction helpers set their flags in the next event. Recheck
        -- once without ever counting unconfirmed input cards.
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

-------------------------------------------------------------------
-- BLACK SEAL & VOUCHER CARD DESTRUCTION / SCORING
-------------------------------------------------------------------

HNDS.should_hand_destroy = function(card)
	if not (card and type(card.get_seal) == 'function' and G and G.GAME) then return false end
	local vouchers = G.GAME.used_vouchers or {}
	local hand_cards = G.hand and G.hand.cards or {}
	return card:get_seal() == "hnds_black"
		or (vouchers.v_hnds_soaked and card == hand_cards[1])
		or (vouchers.v_hnds_beyond and card == hand_cards[#hand_cards])
end

local destroy_cards_ref = SMODS.calculate_destroying_cards
-- Handle destruction of cards with black seal or voucher effects
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

-- Black Seal scoring: Force scoring of destroyed cards as if they were played
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

-------------------------------------------------------------------
-- CARD COST MODIFICATIONS (Coffee Break, Art, Premium Deck, Curses)
-------------------------------------------------------------------

-- Card cost modifications: Coffee Break, Art, Premium Deck, and curse multiplier.
local set_cost_ref = Card.set_cost
function Card.set_cost(self, ...)
	local ret = set_cost_ref(self, ...)
	local key = self.config and self.config.center and self.config.center.key
	local set = self.config and self.config.center and self.config.center.set

	-- Per-joker sell cost overrides
	if key == "j_hnds_coffee_break" then self.sell_cost = 0 end
	if key == "j_hnds_art" then self.sell_cost = -5 end

	-- Premium Deck: joker cost scales with ante
	if set == "Joker"
		and G.GAME and G.GAME.selected_back
		and G.GAME.selected_back.effect and G.GAME.selected_back.effect.center
		and G.GAME.selected_back.effect.center.key == "b_hnds_premiumdeck"
		and G.GAME.round_resets and G.GAME.round_resets.ante then
		self.cost = math.floor(self.cost + G.GAME.round_resets.ante)
	end

	-- Curse price multiplier (affects jokers, boosters, and consumables; NOT vouchers)
	if G and G.GAME and G.GAME.hnds_price_multiplier and G.GAME.hnds_price_multiplier > 1 then
		if set == "Joker" or set == "Booster" or set == "Consumable" then
			self.cost = math.max(0, math.floor(self.cost * G.GAME.hnds_price_multiplier))
		end
	end
	return ret
end

-------------------------------------------------------------------
-- JOKER CREATION (Blood Stake curses)
-------------------------------------------------------------------

-- Blood Stake curse generation is handled by the Cursed Sticker's central
-- should_apply callback in lib/curses.lua. These wrappers remain only as an
-- exclusivity safety net after other generation code applies its stickers.
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
        -- Preserve every foreign return value after the Card. Some compatibility
        -- layers attach metadata here even though base Steamodded returns only a Card.
		return unpack_values(packed, 2, packed.n)
	end
end

-------------------------------------------------------------------
-- CREATE_CARD WRAPPER (Devil's Round)
-------------------------------------------------------------------

-- Apply Devil's Round curses to centrally generated cards.
if not _G._hnds_wrapped_create_card then
	_G._hnds_wrapped_create_card = true
	local create_card_ref = create_card
	function create_card(_type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append, ...)
		-- Sticker.should_apply only receives the destination area. Preserve the
		-- creation append/source while the underlying generator performs its
		-- central sticker roll so Cursed can reject non-pack generation effects.
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


		-- Feature: Devil's Round challenge - curse jokers on creation
		if HNDS and HNDS.try_devils_round_curse then
			HNDS.try_devils_round_curse(card)
		end

		-- Cursed Sticker is exclusive even if a later generation hook applied
		-- another sticker after the central curse roll.
		hnds_finalize_generated_curse(card)
		return unpack_values(packed, 2, packed.n)
	end
end

-------------------------------------------------------------------
-- ADD_TO_DECK WRAPPER (DNA Tag + Devil's Round)
-------------------------------------------------------------------

-- Consolidated hook: DNA tag copies + Devil's Round curse application.
-- Each feature is a separate concern; both run independently.
if not Card._hnds_wrapped_add_to_deck then
	Card._hnds_wrapped_add_to_deck = true
	local add_to_deck_ref = Card.add_to_deck
	function Card:add_to_deck(from_debuff, ...)
		local ret = add_to_deck_ref(self, from_debuff, ...)

		if not from_debuff then
			-- Feature: DNA Tag - create copies when hnds_copies_to_create is set.
			-- Reserve the purchased Joker's own slot when it has not been emplaced
			-- yet, then verify capacity again when the queued copy is created.
			-- This prevents DNA from ever overflowing the Joker limit (for example
			-- creating a sixth Joker in a 5-slot area).
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
								then
									local copy = copy_card(c)
									copy.ability.hnds_copies_to_create = nil
									copy:add_to_deck()
									G.jokers:emplace(copy)
								end
								return true
							end
						})
					end
				end
				self.ability.hnds_copies_to_create = nil
			end

			-- Feature: Devil's Round challenge - curse jokers on add to deck
			if HNDS and HNDS.try_devils_round_curse then
				HNDS.try_devils_round_curse(self)
			end

			if hnds_card_has_cursed(self) then hnds_strip_other_stickers(self) end


			-- Play sound when cursed jokers are added (general, not just Devil's Round)
			if self.ability and (self.ability.hnds_curse_offer or self.ability.hnds_curse_price) then
				play_sound("hnds_curse_used", 1, 0.75)
			end
		end

		return ret
	end
end

-------------------------------------------------------------------
-- CIRCUS DECK
-------------------------------------------------------------------

-- Circus Deck: extend find_joker to include the offscreen joker in results.
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



-------------------------------------------------------------------
-- CRYSTAL DECK
-------------------------------------------------------------------

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
        -- Vanilla chooses a Showdown Blind whenever the current Ante equals
        -- win_ante. Temporarily mirror that condition, then restore the true
        -- winning Ante even if another boss-selection hook errors.
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

-------------------------------------------------------------------
-- GAMBLING OPPORTUNITY VINTAGE EDITION PATCH
-------------------------------------------------------------------

-- Patch edition-only cards in the Restrictions tab to show them on a base Joker
-- card instead of a blank card.
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

-------------------------------------------------------------------
-- IMPOSTOR MULTI RANK CODE
-------------------------------------------------------------------

-- When the Impostor is owned by the player, face cards
-- (J/Q/K, ids 11-13) are treated like any rank for any scoring purpose.
-- This works by temporarily faking the rank for each Jokers so
-- `card:get_id()` and `calculate_joker` always works for face cards
-- Is bit heavy on performance
if Card and Card.calculate_joker and not Card._hnds_wrapped_calculate_joker_imposter then
	Card._hnds_wrapped_calculate_joker_imposter = true
	local calculate_joker_ref = Card.calculate_joker
	local hnds_unpack = (table and table.unpack) or unpack
	local hnds_impostor_available = false
	local hnds_cached_round = -1
	local hnds_cached_joker_count = -1
	local hnds_cached_hand_tick = -1

	local spoof_cache = {}
	local spoof_hints = {}

	local function hnds_clear_spoof_cache() spoof_cache = {} end
	local function hnds_clear_spoof_hints() spoof_hints = {} end

	-- Check whether the Impostor system should be active this evaluation.
	-- Caches the result and invalidates when the joker lineup or hand state changes.
	local function hnds_impostor_is_active()
		if not (G and G.STAGE == G.STAGES.RUN) then
			if hnds_impostor_available then
				hnds_impostor_available = false
				hnds_cached_round = -1
				hnds_cached_joker_count = -1
				hnds_cached_hand_tick = -1
				hnds_clear_spoof_cache()
				hnds_clear_spoof_hints()
			end
			return false
		end
		local cr = G.GAME and G.GAME.current_round
		local current_round = cr and cr.round or 0
		local joker_count = G.jokers and G.jokers.cards and #G.jokers.cards or 0
		local hand_tick = (cr and cr.hands_played or 0) * 1024 + (cr and cr.discards_used or 0)

		if hand_tick ~= hnds_cached_hand_tick then
			hnds_cached_hand_tick = hand_tick
			hnds_clear_spoof_cache()
		end
		if current_round ~= hnds_cached_round then
			hnds_cached_round = current_round
			hnds_clear_spoof_hints()
		end

		if joker_count ~= hnds_cached_joker_count then
			hnds_cached_joker_count = joker_count
			hnds_impostor_available = false
			hnds_clear_spoof_cache()
			hnds_clear_spoof_hints()

			if G.jokers and G.jokers.cards then
				for i = 1, #G.jokers.cards do
					local jc = G.jokers.cards[i]
					if jc and jc.config and jc.config.center
						and jc.config.center.key == 'j_hnds_imposter' then
						hnds_impostor_available = true
						break
					end
				end
			end
			hnds_impostor_available = hnds_impostor_available and HNDS and HNDS.imposter_rank_match
		end
		return hnds_impostor_available
	end

	-- Build a compact string signature for a context + target combination.
	-- Used as cache key to avoid redundant spoof attempts.
	local function hnds_context_signature(context, target)
		local sig = ''
		if context.individual then sig = sig .. 'i' end
		if context.repetition then sig = sig .. 'r' end
		if context.other_joker then sig = sig .. 'o' end
		if context.before then sig = sig .. 'b' end
		if context.after then sig = sig .. 'a' end
		if context.cardarea then sig = sig .. 'c' end
		if context.joker_main then sig = sig .. 'm' end
		if context.joker_act then sig = sig .. 'x' end
		if context.joker_post then sig = sig .. 'p' end
		if context.scoring_hand then sig = sig .. 's' end
		if context.discard then sig = sig .. 'd' end
		if context.destroying_card then sig = sig .. 'D' end
		if context.setting_blind then sig = sig .. 'B' end
		if context.other_joker and context.other_joker.config and context.other_joker.config.center then
			sig = sig .. '|oj:' .. (context.other_joker.config.center.key or '')
		end
		if context.blind and context.blind.config and context.blind.config.blind then
			sig = sig .. '|blind:' .. (context.blind.config.blind.key or '')
		end
		if target then
			local target_key = target.ID or target.sort_id or (target.base and target.base.id) or tostring(target)
			sig = sig .. '|t:' .. tostring(target_key)
		end
		return sig
	end

	function Card:calculate_joker(context, ...)
		-- Skip spoofing in collection view or outside a run. Do not pack varargs
		-- here: this function is called extremely often while playing/discarding.
		if (self.area and self.area.config and self.area.config.collection)
			or not (G and G.STAGE == G.STAGES.RUN) then
			hnds_impostor_is_active()
			return calculate_joker_ref(self, context, ...)
		end

		-- Only spoof for active jokers during relevant contexts
		if not (self.ability and self.ability.set == 'Joker' and self.added_to_deck) then
			return calculate_joker_ref(self, context, ...)
		end
		if type(context) ~= 'table' then
			return calculate_joker_ref(self, context, ...)
		end
		if not (context.individual or context.repetition or context.other_joker or context.before
				or context.after or context.cardarea or context.joker_main or context.joker_act
				or context.joker_post or context.destroying_card or context.setting_blind) then
			return calculate_joker_ref(self, context, ...)
		end

		-- Run the original calculation first
		local eff, post = calculate_joker_ref(self, context, ...)

		if not hnds_impostor_is_active() then return eff, post end

		-- Don't spoof the impostor jokers themselves, or Cloud 9 (special case)
		local joker_key = self.config and self.config.center and self.config.center.key
		if joker_key == 'j_hnds_imposter' or joker_key == 'j_cloud_9' then
			return eff, post
		end

		-- Only spoof for playing cards (not consumables/vouchers)
		local target = context.other_card or context.card or context.cardarea or nil
		if not target or not target.get_id or not target.ability then return eff, post end
		if target.ability.set == 'Tarot' or target.ability.set == 'Planet'
			or target.ability.set == 'Spectral' or target.ability.set == 'Voucher'
			or target.ability.consumeable then
			return eff, post
		end
		if target.ability.set ~= 'Default' and target.ability.set ~= 'Enhanced' then return eff, post end
		if SMODS and SMODS.has_no_rank and SMODS.has_no_rank(target) then return eff, post end

		-- Only spoof face cards (J=11, Q=12, K=13)
		local target_id = target:get_id()
		if not target_id or target_id < 11 or target_id > 13 then return eff, post end

		-- If the original calc already produced a result, use it
		if eff or post then
			if type(eff) == 'table' and next(eff) then return eff, post end
			if type(post) == 'table' and #post > 0 then return eff, post end
		end
		if not joker_key then return eff, post end

		-- Try spoofing: temporarily replace target:get_id() with each rank 2-14
		local cache_key = self.ID or self.sort_id or joker_key or 'unknown'
		local sig = hnds_context_signature(context, target)
		local round_index = G.GAME and G.GAME.current_round and G.GAME.current_round.round or 0
		local hint_key = joker_key .. '|r:' .. tostring(round_index) .. '|' .. hnds_context_signature(context, nil)
		spoof_cache[cache_key] = spoof_cache[cache_key] or {}
		local cached_spoof = spoof_cache[cache_key][sig]
		local hint_spoof = spoof_hints[hint_key]
		local original_get_id = target.get_id
		-- Only the actual brute-force spoof path needs to replay varargs. Packing
		-- here avoids one temporary table for every ordinary Joker evaluation.
		local hnds_args = { ... }

		local function hnds_try_spoof(spoof_id)
			target.get_id = function() return spoof_id end
			local ok, e, p = pcall(calculate_joker_ref, self, context, hnds_unpack(hnds_args))
			target.get_id = original_get_id
			if not ok then error(e) end
			local has_e = e and (type(e) ~= 'table' or next(e))
			local has_p = p and (type(p) ~= 'table' or #p > 0)
			if has_e or has_p then return e, p, true end
			return e, p, false
		end

		-- Check cached spoof result first
		if type(cached_spoof) == 'number' then
			local e, p, ok = hnds_try_spoof(cached_spoof)
			if ok then return e, p end
		elseif cached_spoof == false then
			return eff, post
		end

		-- Check hint from same joker in a previous hand this round
		if type(hint_spoof) == 'number' then
			local e, p, ok = hnds_try_spoof(hint_spoof)
			if ok then
				spoof_cache[cache_key][sig] = hint_spoof
				return e, p
			end
			spoof_cache[cache_key][sig] = false
			return eff, post
		end

		-- Brute-force: try all ranks 2-14 (Ace)
		for spoof_id = 2, 14 do
			local e, p, ok = hnds_try_spoof(spoof_id)
			if ok then
				spoof_cache[cache_key][sig] = spoof_id
				spoof_hints[hint_key] = spoof_id
				return e, p
			end
		end

		spoof_cache[cache_key][sig] = false
		return eff, post
	end
end

-------------------------------------------------------------------
-- EXCOMMUNICADO: Boss Blind Replacement
-------------------------------------------------------------------

-- Helper: Check if Excommunicado effect should be active. The effect can come
-- from the real Rare Joker OR from an active Jack-in-the-Box borrowing it.
-- Keep this as the single authority because Lovely patches cannot see Jack's
-- borrowed center through SMODS.find_card('j_hnds_excommunicado').
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

-- Ensure Blind:get_type() returns Small/Big for replaced blinds
local Blind_get_type_ref = Blind.get_type
function Blind:get_type(...)
	if not hnds_excommunicado_active() then
		return Blind_get_type_ref(self, ...)
	end

	-- For the active blind, use blind_on_deck which always knows the slot
	if G.GAME and G.GAME.blind == self and G.GAME.blind_on_deck then
		return G.GAME.blind_on_deck
	end

	return Blind_get_type_ref(self, ...)
end

-- Replace current vanilla Small/Big blinds with random bosses
-- Called from excommunicado.lua add_to_deck to handle mid-round acquisition
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

-- Store reference to current card during loc_vars evaluation
_G.HNDS_CURRENT_CURSE_CARD = nil

-- Hook into the sticker's loc_vars to capture the card reference
local original_loc_vars = nil

-- We'll set this up after the sticker is defined in curses.lua
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
-- CURSE: BASE BLIND INCREASE (price_ante_scaling)
-------------------------------------------------------------------

local get_blind_amount_ref = get_blind_amount
function get_blind_amount(ante, ...)
	local amount = get_blind_amount_ref(ante, ...)
	local count = G and G.GAME and G.GAME.modifiers and G.GAME.modifiers.hnds_base_blind_increase
	if count and count > 0 and amount ~= nil then
		-- Big-number mods often return an arithmetic object rather than a Lua
		-- number. Multiply through its metamethod, but only math.floor native
		-- numbers; math.floor(big-number-object) is a common modpack crash.
		local ok, scaled = pcall(function() return amount * (1.5 ^ count) end)
		if ok then amount = type(scaled) == 'number' and math.floor(scaled) or scaled end
	end
	return amount
end


-------------------------------------------------------------------
-- MAIN-MENU LOCKED HINT SUPPRESSION
-------------------------------------------------------------------
-- Balatro can queue a delayed locked Joker/Voucher hint when the title card is
-- clicked repeatedly. With a custom Steamodded menu card already occupying
-- G.title_top, that delayed card must never be allowed to replace or stack under
-- the Handsome Devils title card.
--
-- Let CardArea:emplace perform its normal bookkeeping, then immediately remove
-- only that incoming locked hint in the same call. No frame can render between
-- those operations, so the visible title card remains untouched while the
-- temporary Card is still cleaned up correctly.
if CardArea and CardArea.emplace and not HNDS._title_locked_hint_suppress_guard then
    HNDS._title_locked_hint_suppress_guard = true
    local hnds_cardarea_emplace_ref = CardArea.emplace

    local function hnds_is_locked_title_hint(area, card)
        if not (G and G.title_top and area == G.title_top and card) then return false end
        local center = card.config and card.config.center
        if not center or center.unlocked ~= false then return false end
        if center.set ~= 'Joker' and center.set ~= 'Voucher' then return false end

        -- G.title_top is shared with every menu-card mod. Only suppress the
        -- vanilla locked hint while a Handsome Devils menu card owns the slot;
        -- never delete another mod's intentionally locked title card.
        local existing = area.cards and area.cards[1]
        local existing_center = existing and existing.config and existing.config.center
        local key = existing_center and existing_center.key
        return type(key) == 'string' and (key:match('^j_hnds_')
            or key:match('^c_hnds_') or key:match('^p_hnds_')) ~= nil
    end

    function CardArea:emplace(card, ...)
        if hnds_is_locked_title_hint(self, card) and self.cards and #self.cards > 0 then
            -- Complete the native emplacement/removal lifecycle synchronously so
            -- the transient Card does not leave sprites/nodes registered, but do
            -- not disturb the card that was already in G.title_top.
            local ret = hnds_cardarea_emplace_ref(self, card, ...)
            self:remove_card(card)
            if card.remove then card:remove() end
            return ret
        end
        return hnds_cardarea_emplace_ref(self, card, ...)
    end
end

-------------------------------------------------------------------
-- HANDSOME DEVILS TOOLTIP POSITION STABILITY
-------------------------------------------------------------------
-- Card:hover asks Card:align_h_popup() where the popup should live.  Locking
-- Node.hover (the previous workaround) happens one layer too late and can itself
-- make a popup get torn down/recreated with a different side.  Cache the native
-- alignment result instead.  We preserve Balatro/SMODS's own alignment table and
-- only reuse the side/offset while the card stays in the same CardArea.
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

        -- A different area (shop -> jokers, hand -> play, collection page, etc.)
        -- is a legitimate reason to choose a new side.  Hover tilt, juice,
        -- controller focus jitter and brief hover reacquisition are not.
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
