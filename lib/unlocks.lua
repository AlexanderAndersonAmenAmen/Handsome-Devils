


HNDS = HNDS or {}

local STAT_RARE_JOKERS = "c_hnds_rare_jokers_bought"
local STAT_BLINDS_SKIPPED = "c_hnds_blinds_skipped"
local STAT_HELD_EFFECTS = "c_hnds_held_effects_triggered"
local STAT_LUCKY_TRIGGERS = "c_hnds_lucky_effects_triggered"
local STAT_NEGATIVE_JOKERS = "c_hnds_negative_jokers_made"
local STAT_CARD_IDENTITY_CHANGES = "c_hnds_card_identity_changes"
local STAT_BOSSES_DEFEATED = "c_hnds_boss_blinds_defeated"
local STAT_ENHANCEMENT_CHANGES = "c_hnds_enhancement_changes"
local STAT_PROBABILITY_FAILURES = "c_hnds_probability_failures"
local STAT_TAGS_CREATED = "c_hnds_tags_created"
local STAT_CARDS_DESTROYED = "c_hnds_playing_cards_destroyed"
local STAT_BASIC_JOKERS_BOUGHT = "c_hnds_basic_jokers_bought"
local STAT_HEART_CARDS_SCORED = "c_hnds_heart_cards_scored"
local STAT_DIAMOND_CARDS_SCORED = "c_hnds_diamond_cards_scored"
local STAT_CLUB_CARDS_SCORED = "c_hnds_club_cards_scored"
local STAT_SPADE_CARDS_SCORED = "c_hnds_spade_cards_scored"
local STAT_HEADLESS_FACE_CARDS = "c_hnds_headless_face_cards_destroyed"
local STAT_RUN_RESTARTS = "c_hnds_run_restarts"
local STAT_WATER_SLIDE_EIGHTS = "c_hnds_water_slide_eights_discarded"

local TARGETS = {
    premiumdeck = 150,
    top_shelf = 50,
    wholesale = 40,
    hashtag_skip = 50,
    beyond = 100,
    ol_reliable = 77,

    jester_in_yellow = 10,
    demented = 100,
    imposter = 3,
    fregoli = 3,
    excommunicado = 100,
    one_punchline_man = 3,
    perfectionist = 10,
    dark_idol = 50,
    deep_pockets = 5,
    ms_fortune = 100,
    occultist = 150,
    clown_devil = 100,
    balloons = 50,
    seismic_activity = 30,
    angry_mob = 10,
    jokes_aside = 15,
    jackpot = 50,
    energized = 100,
    last_laugh = 150,

    coffee_break = 2,
    jigsaw_joker = 8,
    most_wanted = 5,
    wait_what = 4,

    dallas = 1000,
    hoxton = 1000,
    wolf = 1000,
    chains = 1000,
    spaghettified_joker = 25,
    headless_joker = 30,
    time_fcked_joker = 10,
    conquest = 50,
    war = 25,
    water_slide = 88,
}


local COLLECTION_CENTER_SETS = {
    Joker = true,
    Tarot = true,
    Planet = true,
    Spectral = true,
    Voucher = true,
    Booster = true,
    Edition = true,
}

local function current_profile()
    if not (G and G.PROFILES and G.SETTINGS and G.SETTINGS.profile) then return nil end
    return G.PROFILES[G.SETTINGS.profile]
end

local function in_run()
    if not (G and G.GAME) then return false end
    if G.STAGE and G.STAGES and G.STAGE ~= G.STAGES.RUN then return false end
    return true
end

local function run_state()
    if not in_run() then return nil end
    G.GAME.hnds_unlock_run = G.GAME.hnds_unlock_run or {}
    local state = G.GAME.hnds_unlock_run
    state.flags = state.flags or {}
    state.fregoli_buys = state.fregoli_buys or {}
    state.imposter_streak = math.max(0, tonumber(state.imposter_streak) or 0)
    state.boss_one_hand_streak = math.max(0, tonumber(state.boss_one_hand_streak) or 0)
    state.stone_scored = math.max(0, tonumber(state.stone_scored) or 0)
    state.no_joker_buy_streak = math.max(0, tonumber(state.no_joker_buy_streak) or 0)
    state.jokers_sold = math.max(0, tonumber(state.jokers_sold) or 0)
    state.consumables_created_round = math.max(0, tonumber(state.consumables_created_round) or 0)
    state.money_gained_round = math.max(0, tonumber(state.money_gained_round) or 0)
    state.round_serial = math.max(0, tonumber(state.round_serial) or 0)
    state.supersuit_flushes = state.supersuit_flushes or {Spades = false, Hearts = false, Clubs = false, Diamonds = false}
    state.coffee_break_skips = state.coffee_break_skips or {}
    state.jigsaw_hands = state.jigsaw_hands or {}
    state.jigsaw_count = math.max(0, tonumber(state.jigsaw_count) or 0)
    state.ecg_heart_round_streak = math.max(0, tonumber(state.ecg_heart_round_streak) or 0)
    state.ecg_run_heart_every_round = state.ecg_run_heart_every_round == true
    state.ecg_heart_round_current = state.ecg_heart_round_current == true
    state.ecg_last_finalized_round = tonumber(state.ecg_last_finalized_round) or 0
    state.jodiac_ante = tonumber(state.jodiac_ante) or 0
    state.jodiac_ranks = state.jodiac_ranks or {}
    state.jodiac_complete = state.jodiac_complete == true
    state.jack_in_box_showdown_ready = state.jack_in_box_showdown_ready == true
    state.jack_in_box_showdown_won = state.jack_in_box_showdown_won == true
    state.jevil_wild_flush = state.jevil_wild_flush == true
    state.spaghettified_max_level = math.max(0, tonumber(state.spaghettified_max_level) or 0)
    state.ecg_heart_hand_streak = math.max(0, tonumber(state.ecg_heart_hand_streak) or 0)
    state.famine_high_card_round_streak = math.max(0, tonumber(state.famine_high_card_round_streak) or 0)
    state.famine_round_high_card_only = state.famine_round_high_card_only == true
    state.death_unlock = state.death_unlock == true
    state.be_not_afraid_unlock = state.be_not_afraid_unlock == true
    state.joker_reverse_rare_sold = state.joker_reverse_rare_sold == true
    state.joker_reverse_common_bought = state.joker_reverse_common_bought == true
    return state
end

function HNDS.unlock_career_stat(stat_name)
    local profile = current_profile()
    local stats = profile and profile.career_stats
    return math.max(0, tonumber(stats and stats[stat_name]) or 0)
end
-- Local alias: pre-2.9 call sites in this file still use the bare name.
local unlock_career_stat = HNDS.unlock_career_stat

local function increment_career_stat(stat_name, amount)
    amount = math.max(0, tonumber(amount) or 0)
    if amount <= 0 then return end
    if type(inc_career_stat) == "function" then
        inc_career_stat(stat_name, amount)
        return
    end
    local profile = current_profile()
    if profile then
        profile.career_stats = profile.career_stats or {}
        profile.career_stats[stat_name] = math.max(0, tonumber(profile.career_stats[stat_name]) or 0) + amount
    end
end


local function is_real_playing_card(card)
    if type(card) ~= "table" or type(card.base) ~= "table" then return false end
    if card.base.suit == nil or card.base.value == nil then return false end
    local set = card.ability and card.ability.set
    return set == nil or set == "Default" or set == "Enhanced"
end

function HNDS.count_destroyed_playing_card(card)
    if not is_real_playing_card(card) or card.hnds_unlock_destroy_counted then return false end
    card.hnds_unlock_destroy_counted = true
    increment_career_stat(STAT_CARDS_DESTROYED, 1)

    if HNDS.unlock_career_stat(STAT_CARDS_DESTROYED) >= TARGETS.war then
        HNDS.joker_unlock_condition_met("war", {type = "hnds_playing_card_destroyed"})
    end

    local rank_id = card.base and (card.base.id or card.base.value)
    if rank_id == 11 or rank_id == 12 or rank_id == 13 then
        increment_career_stat(STAT_HEADLESS_FACE_CARDS, 1)
    end

    HNDS.request_unlock_check("hnds_playing_card_destroyed")
    return true
end

local function visible_collection_object(object)
    return type(object) == "table"
        and object.no_collection ~= true
        and object.omit ~= true
end

local function collection_discovered_count(set_filter)
    local seen, count = {}, 0
    local function tally(key, object)
        if key and not seen[key]
            and visible_collection_object(object)
            and (not set_filter or object.set == set_filter)
            and object.discovered
        then
            seen[key] = true
            count = count + 1
        end
    end

    for key, center in pairs((G and G.P_CENTERS) or {}) do
        if COLLECTION_CENTER_SETS[center.set] then tally(key, center) end
    end
    if not set_filter then
        for key, blind in pairs((G and G.P_BLINDS) or {}) do tally(key, blind) end
        for key, tag in pairs((G and G.P_TAGS) or {}) do tally(key, tag) end
        for key, seal in pairs((G and G.P_SEALS) or {}) do tally(key, seal) end
    end

    return count
end

local function all_registered_centers_discovered(set_name)
    local total, discovered = 0, 0
    for _, center in pairs((G and G.P_CENTERS) or {}) do
        if center.set == set_name and visible_collection_object(center) then
            total = total + 1
            if center.discovered then discovered = discovered + 1 end
        end
    end
    return total > 0 and discovered >= total
end

local function current_stake_at_least(target_key)
    if not (G and G.GAME) then return false end

    if target_key == "stake_hnds_blood_stake" then
        return G.GAME.modifiers and G.GAME.modifiers.hnds_blood_stake == true
    end
    if target_key == "stake_hnds_platinum" and G.GAME.hnds_platinum_active then
        return true
    end

    local target = G.P_STAKES and G.P_STAKES[target_key]
    local current = G.GAME.stake
    if target and tonumber(target.order) and tonumber(current) then
        return tonumber(current) >= tonumber(target.order)
    end
    if type(current) == "string" and G.P_STAKES and G.P_STAKES[current] and target then
        return (tonumber(G.P_STAKES[current].order) or 0) >= (tonumber(target.order) or math.huge)
    end
    return false
end

function HNDS.unlock_progress(key)
    if key == "premiumdeck" then
        return collection_discovered_count(), TARGETS.premiumdeck
    elseif key == "top_shelf" then
        return unlock_career_stat(STAT_RARE_JOKERS), TARGETS.top_shelf
    elseif key == "wholesale" then
        return math.max(0, tonumber(G and G.GAME and G.GAME.hnds_boosters_bought_run) or 0), TARGETS.wholesale
    elseif key == "hashtag_skip" then
        return unlock_career_stat(STAT_BLINDS_SKIPPED), TARGETS.hashtag_skip
    elseif key == "beyond" then
        return unlock_career_stat(STAT_HELD_EFFECTS), TARGETS.beyond
    elseif key == "ol_reliable" then
        return unlock_career_stat(STAT_LUCKY_TRIGGERS), TARGETS.ol_reliable
    end
    return 0, 0
end

function HNDS.unlock_condition_met(key, args)
    if key == "premiumdeck" then
        return collection_discovered_count() >= TARGETS.premiumdeck
    elseif key == "crystal" then
        return args and args.type == "win" and current_stake_at_least("stake_gold")
    elseif key == "conjuring" then
        return all_registered_centers_discovered("Booster")
    elseif key == "cursed" then
        return args and args.type == "win" and current_stake_at_least("stake_hnds_platinum")
    elseif key == "circus" then
        return all_registered_centers_discovered("Joker")
    elseif key == "ol_reliable" then
        return unlock_career_stat(STAT_LUCKY_TRIGGERS) >= TARGETS.ol_reliable
    elseif key == "top_shelf" then
        return unlock_career_stat(STAT_RARE_JOKERS) >= TARGETS.top_shelf
    elseif key == "wholesale" then
        return math.max(0, tonumber(G and G.GAME and G.GAME.hnds_boosters_bought_run) or 0) >= TARGETS.wholesale
    elseif key == "hashtag_skip" then
        return unlock_career_stat(STAT_BLINDS_SKIPPED) >= TARGETS.hashtag_skip
    elseif key == "beyond" then
        return unlock_career_stat(STAT_HELD_EFFECTS) >= TARGETS.beyond
    end
    return false
end

function HNDS.request_unlock_check(kind)
    if HNDS._unlock_check_in_progress or type(check_for_unlock) ~= "function" then return end
    HNDS._unlock_check_in_progress = true
    local ok, err = pcall(check_for_unlock, { type = kind or "hnds_progress" })
    HNDS._unlock_check_in_progress = nil
    if not ok and sendWarnMessage then
        sendWarnMessage("Handsome Devils unlock check failed: " .. tostring(err), "HandsomeDevils")
    end
end

function HNDS.record_held_effects(amount, kind)
    amount = math.max(0, tonumber(amount) or 0)
    if amount <= 0 then return end
    increment_career_stat(STAT_HELD_EFFECTS, amount)
    HNDS.request_unlock_check(kind or "hnds_held_effect")
end

function HNDS.record_booster_purchase(card)
    if not (G and G.GAME) or (card and card.hnds_wholesale_purchase_counted) then return end
    G.GAME.hnds_boosters_bought_run = math.max(0, tonumber(G.GAME.hnds_boosters_bought_run) or 0) + 1
    if card then card.hnds_wholesale_purchase_counted = true end
    HNDS.request_unlock_check("hnds_booster_purchase")
end

local function card_center_key(card)
    return card and card.config and card.config.center and card.config.center.key
end

local function card_set(card)
    return card and ((card.ability and card.ability.set) or (card.config and card.config.center and card.config.center.set))
end

local function card_is_consumable(card)
    if not card then return false end
    if card.ability and card.ability.consumeable then return true end
    local set = card_set(card)
    return set == "Tarot" or set == "Planet" or set == "Spectral" or set == "Consumeable" or set == "Consumable"
end

local function card_has_enhancement(card, key)
    if not card then return false end
    if key == 'm_stone' and HNDS.card_has_stone then
        return HNDS.card_has_stone(card)
    end
    if card_center_key(card) == key then return true end


    if HNDS.aberrant_has_fusion then
        local ok, result = pcall(HNDS.aberrant_has_fusion, card, key)
        if ok and result then return true end
    end
    return false
end

local function deck_full_of_enhanced_cards()
    local cards = (G and G.playing_cards) or {}
    if #cards == 0 then return false end
    for _, card in ipairs(cards) do
        if card_set(card) ~= "Enhanced" then return false end
    end
    return true
end

local function deck_enhancement_count(key)
    local count = 0
    for _, card in ipairs((G and G.playing_cards) or {}) do
        if card_has_enhancement(card, key) then count = count + 1 end
    end
    return count
end


local function max_same_enhancement_count()
    local counts = {}
    local best = 0
    for _, card in ipairs((G and G.playing_cards) or {}) do
        local center = card and card.config and card.config.center
        local key = center and center.key
        if key and key ~= "c_base" and card_set(card) == "Enhanced" then
            counts[key] = (counts[key] or 0) + 1
            if counts[key] > best then best = counts[key] end
        end
    end
    return best
end

local function normalize_rarity(rarity)
    if type(rarity) == "table" then rarity = rarity.key or rarity.id or rarity.name end
    if type(rarity) == "number" then return rarity end
    if type(rarity) ~= "string" then return nil end
    local value = string.lower(rarity)
    if value == "common" or value == "1" then return 1 end
    if value == "uncommon" or value == "2" then return 2 end
    if value == "rare" or value == "3" then return 3 end
    if value == "legendary" or value == "4" then return 4 end
    return nil
end

local function distinct_joker_rarity_count()
    local found, count = {}, 0
    for _, card in ipairs((G and G.jokers and G.jokers.cards) or {}) do
        local rarity = normalize_rarity(card.config and card.config.center and card.config.center.rarity)
        if rarity and not found[rarity] then
            found[rarity] = true
            count = count + 1
        end
    end
    return count
end

local function rare_joker_count()
    local count = 0
    for _, card in ipairs((G and G.jokers and G.jokers.cards) or {}) do
        if normalize_rarity(card.config and card.config.center and card.config.center.rarity) == 3 then
            count = count + 1
        end
    end
    return count
end

local function edition_key(card)
    local edition = card and card.edition
    if type(edition) ~= "table" then return nil end
    if edition.key then return edition.key end
    for key, value in pairs(edition) do
        if value == true then
            if string.sub(key, 1, 2) == "e_" then return key end
            return "e_" .. key
        end
    end
    return nil
end

local function distinct_joker_edition_count()
    local found, count = {}, 0
    for _, card in ipairs((G and G.jokers and G.jokers.cards) or {}) do
        local key = edition_key(card)
        if key and not found[key] then
            found[key] = true
            count = count + 1
        end
    end
    return count
end
local function have_three_copies_of_same_joker()
    local counts = {}
    for _, card in ipairs((G and G.jokers and G.jokers.cards) or {}) do
        local key = card_center_key(card)
        if key then
            counts[key] = (counts[key] or 0) + 1
            if counts[key] >= 3 then return true end
        end
    end
    return false
end

local function have_both_bananas()
    local gros, cavendish = false, false
    for _, card in ipairs((G and G.jokers and G.jokers.cards) or {}) do
        local key = card_center_key(card)
        if key == "j_gros_michel" then gros = true end
        if key == "j_cavendish" then cavendish = true end
    end
    return gros and cavendish
end

local function odd_rank(rank)
    rank = tonumber(rank)
    return rank and (rank == 14 or rank % 2 == 1) or false
end

local function is_even_odd_two_pair(cards)
    local counts, ranks = {}, {}
    for _, card in ipairs(cards or {}) do
        local rank = card.get_id and card:get_id() or nil
        if rank then counts[rank] = (counts[rank] or 0) + 1 end
    end
    for rank, count in pairs(counts) do
        if count >= 2 then ranks[#ranks + 1] = rank end
    end
    if #ranks < 2 then return false end
    for i = 1, #ranks - 1 do
        for j = i + 1, #ranks do
            if odd_rank(ranks[i]) ~= odd_rank(ranks[j]) then return true end
        end
    end
    return false
end

local function current_flush_suit(cards)
    if not cards or #cards < 5 then return nil end
    local candidate = nil
    for _, card in ipairs(cards) do
        if not card_has_enhancement(card, "m_wild") and card.base and card.base.suit then
            candidate = card.base.suit
            break
        end
    end
    candidate = candidate or (cards[1] and cards[1].base and cards[1].base.suit)
    if not candidate then return nil end
    for _, card in ipairs(cards) do
        if not (card.is_suit and card:is_suit(candidate)) then return nil end
    end
    return candidate
end

local function deck_size()
    return #((G and G.playing_cards) or {})
end

local function current_ante()
    return math.max(0, tonumber(G and G.GAME and G.GAME.round_resets and G.GAME.round_resets.ante) or 0)
end

local function normalize_blind_slot(value)
    if type(value) == "table" then
        value = value.blind_on_deck or value.type or value.name or value.key
    end
    if type(value) ~= "string" then return nil end
    local lower = string.lower(value)
    if string.find(lower, "small", 1, true) then return "Small" end
    if string.find(lower, "big", 1, true) then return "Big" end
    if string.find(lower, "boss", 1, true) then return "Boss" end
    return nil
end

local function record_coffee_break_skip(ante, slot)
    local state = run_state()
    ante = math.max(0, tonumber(ante) or current_ante())
    slot = normalize_blind_slot(slot)
    if not state or ante ~= 8 or (slot ~= "Small" and slot ~= "Big") then return false end
    local key = tostring(ante) .. ":" .. slot
    if state.coffee_break_skips[key] then return false end
    state.coffee_break_skips[key] = true
    HNDS.request_unlock_check("hnds_ante8_skip")
    return true
end

local function coffee_break_complete(state)
    return state and state.coffee_break_skips["8:Small"] and state.coffee_break_skips["8:Big"] or false
end

local function reset_ante_tracking(state, ante)
    if state.jigsaw_ante ~= ante then
        state.jigsaw_ante = ante
        state.jigsaw_hands = {}
        state.jigsaw_count = 0
    end
    if state.supersuit_ante ~= ante then
        state.supersuit_ante = ante
        state.supersuit_flushes = {Spades = false, Hearts = false, Clubs = false, Diamonds = false}
    end
end

local function four_distinct_flush_suits(state)
    local count = 0
    for _, suit in ipairs({"Spades", "Hearts", "Clubs", "Diamonds"}) do
        if state and state.supersuit_flushes[suit] then count = count + 1 end
    end
    return count >= 4
end

function HNDS.mark_jevil_unlock()
    local state = run_state()
    if not state or state.jevil_wild_flush then return false end

    state.jevil_wild_flush = true

    local center = G and G.P_CENTERS and G.P_CENTERS.j_hnds_jevil
    if center then
        if type(unlock_card) == "function" then
            unlock_card(center)
        else
            center.unlocked = true
        end
    end

    HNDS.request_unlock_check("hnds_jevil_wild_flush")
    return true
end

function HNDS.joker_unlock_progress(key)
    local state = run_state()

    if key == "jigsaw_joker" then return state and state.jigsaw_count or 0, TARGETS[key]
    elseif key == "wait_what" then return unlock_career_stat(STAT_BASIC_JOKERS_BOUGHT), TARGETS[key]
    elseif key == "jester_in_yellow" then return unlock_career_stat(STAT_NEGATIVE_JOKERS), TARGETS[key]
    elseif key == "demented" then return unlock_career_stat(STAT_CARD_IDENTITY_CHANGES), TARGETS[key]
    elseif key == "imposter" then return state and state.imposter_streak or 0, TARGETS[key]
    elseif key == "fregoli" then
        local best = 0
        for _, count in pairs(state and state.fregoli_buys or {}) do
            best = math.max(best, tonumber(count) or 0)
        end
        return best, TARGETS[key]
    elseif key == "excommunicado" or key == "conquest" then
        return HNDS.unlock_career_stat(STAT_BOSSES_DEFEATED), TARGETS[key]
    elseif key == "most_wanted" then
        return rare_joker_count(), TARGETS[key]
    elseif key == "energized" or key == "last_laugh" then
        return HNDS.unlock_career_stat(STAT_CARDS_DESTROYED), TARGETS[key]
    elseif key == "war" then
        return HNDS.unlock_career_stat(STAT_CARDS_DESTROYED), TARGETS[key]
    elseif key == "water_slide" then
        return HNDS.unlock_career_stat(STAT_WATER_SLIDE_EIGHTS), TARGETS[key]
    elseif key == "one_punchline_man" then return state and state.boss_one_hand_streak or 0, TARGETS[key]
    elseif key == "perfectionist" then return unlock_career_stat(STAT_ENHANCEMENT_CHANGES), TARGETS[key]
    elseif key == "dark_idol" then return unlock_career_stat(STAT_CARDS_DESTROYED), TARGETS[key]
    elseif key == "deep_pockets" then return state and state.consumables_created_round or 0, TARGETS[key]
    elseif key == "ms_fortune" then return unlock_career_stat(STAT_PROBABILITY_FAILURES), TARGETS[key]
    elseif key == "occultist" or key == "clown_devil" or key == "balloons" then
        return unlock_career_stat(STAT_TAGS_CREATED), TARGETS[key]
    elseif key == "seismic_activity" then return state and state.stone_scored or 0, TARGETS[key]
    elseif key == "angry_mob" then return state and state.no_joker_buy_streak or 0, TARGETS[key]
    elseif key == "jokes_aside" then return state and state.jokers_sold or 0, TARGETS[key]
    elseif key == "jackpot" then return state and state.money_gained_round or 0, TARGETS[key]
    elseif key == "dallas" then return HNDS.unlock_career_stat(STAT_HEART_CARDS_SCORED), TARGETS[key]
    elseif key == "hoxton" then return HNDS.unlock_career_stat(STAT_DIAMOND_CARDS_SCORED), TARGETS[key]
    elseif key == "wolf" then return HNDS.unlock_career_stat(STAT_CLUB_CARDS_SCORED), TARGETS[key]
    elseif key == "chains" then return HNDS.unlock_career_stat(STAT_SPADE_CARDS_SCORED), TARGETS[key]
    elseif key == "headless_joker" then return HNDS.unlock_career_stat(STAT_HEADLESS_FACE_CARDS), TARGETS[key]
    elseif key == "time_fcked_joker" then return HNDS.unlock_career_stat(STAT_RUN_RESTARTS), TARGETS[key]
    elseif key == "ecg" then return state and state.ecg_heart_hand_streak or 0, 10
    elseif key == "plague" then return max_same_enhancement_count(), 10
    elseif key == "famine" then return state and state.famine_high_card_round_streak or 0, 3
    elseif key == "jodiac" then
        local count = 0
        for _ in pairs(state and state.jodiac_ranks or {}) do count = count + 1 end
        return count, 13
    elseif key == "jack_in_the_box" then return state and state.jack_in_box_showdown_ready and 1 or 0, 1
    elseif key == "jevil" then return state and state.jevil_wild_flush and 1 or 0, 1
    elseif key == "spaghettified_joker" then return state and state.spaghettified_max_level or 0, TARGETS.spaghettified_joker
    end

    return 0, TARGETS[key] or 0
end

function HNDS.joker_locked_loc_vars(key)
    local current, target = HNDS.joker_unlock_progress(key)
    return { vars = { tonumber(current) or 0, tonumber(target) or 0 } }
end

function HNDS.joker_unlock_condition_met(key, args)
    local state = run_state()

    local function finish_unlock(center_key, condition)
        if not condition then return false end
        local center = G and G.P_CENTERS and G.P_CENTERS[center_key]
        if center then
            if type(unlock_card) == "function" then
                unlock_card(center)
            else
                center.unlocked = true
            end
        end
        return true
    end

    if key == "coffee_break" then return coffee_break_complete(state)
    elseif key == "jigsaw_joker" then return state and state.jigsaw_count >= TARGETS[key] or false
    elseif key == "most_wanted" then return rare_joker_count() >= TARGETS[key]
    elseif key == "wait_what" then return unlock_career_stat(STAT_BASIC_JOKERS_BOUGHT) >= TARGETS[key]
    elseif key == "dark_humor" then return state and state.has_selected_blind and deck_size() > 0 and deck_size() <= 25 or false
    elseif key == "public_nuisance" then return state and state.flags.public_nuisance or false
    elseif key == "pot_of_greed" then return state and state.flags.pot_of_greed or false
    elseif key == "jester_in_yellow" then return unlock_career_stat(STAT_NEGATIVE_JOKERS) >= TARGETS[key]
    elseif key == "demented" then return unlock_career_stat(STAT_CARD_IDENTITY_CHANGES) >= TARGETS[key]
    elseif key == "imposter" then return state and state.imposter_streak >= TARGETS[key] or false
    elseif key == "contagion" then return deck_full_of_enhanced_cards()
    elseif key == "fregoli" then
        for _, count in pairs(state and state.fregoli_buys or {}) do
            if count >= TARGETS[key] then return true end
        end
        return false
    elseif key == "excommunicado" then return unlock_career_stat(STAT_BOSSES_DEFEATED) >= TARGETS[key]
    elseif key == "meme" then return state and state.flags.meme or false
    elseif key == "one_punchline_man" then return state and state.boss_one_hand_streak >= TARGETS[key] or false
    elseif key == "digital_circus" then return distinct_joker_rarity_count() >= 4
    elseif key == "handsome" then return distinct_joker_edition_count() >= 4
    elseif key == "perfectionist" then return unlock_career_stat(STAT_ENHANCEMENT_CHANGES) >= TARGETS[key]
    elseif key == "dark_idol" then return unlock_career_stat(STAT_CARDS_DESTROYED) >= TARGETS[key]
    elseif key == "color_of_madness" then return deck_enhancement_count("m_wild") >= 10
    elseif key == "deep_pockets" then return state and state.consumables_created_round >= TARGETS[key] or false
    elseif key == "head_of_medusa" then return deck_enhancement_count("m_stone") >= 10
    elseif key == "ms_fortune" then return unlock_career_stat(STAT_PROBABILITY_FAILURES) >= TARGETS[key]
    elseif key == "occultist" or key == "clown_devil" or key == "balloons" then
        return unlock_career_stat(STAT_TAGS_CREATED) >= TARGETS[key]
    elseif key == "creepy" then return have_three_copies_of_same_joker()
    elseif key == "seismic_activity" then return state and state.stone_scored >= TARGETS[key] or false
    elseif key == "angry_mob" then return state and state.no_joker_buy_streak >= TARGETS[key] or false
    elseif key == "supersuit" then return state and state.flags.supersuit or false
    elseif key == "jokes_aside" then return state and state.jokers_sold >= TARGETS[key] or false
    elseif key == "jackpot" then return state and state.money_gained_round >= TARGETS[key] or false
    elseif key == "dallas" then return HNDS.unlock_career_stat(STAT_HEART_CARDS_SCORED) >= TARGETS[key]
    elseif key == "hoxton" then return HNDS.unlock_career_stat(STAT_DIAMOND_CARDS_SCORED) >= TARGETS[key]
    elseif key == "wolf" then return HNDS.unlock_career_stat(STAT_CLUB_CARDS_SCORED) >= TARGETS[key]
    elseif key == "chains" then return HNDS.unlock_career_stat(STAT_SPADE_CARDS_SCORED) >= TARGETS[key]
    elseif key == "conquest" then
        return finish_unlock("j_hnds_conquest", HNDS.unlock_career_stat(STAT_BOSSES_DEFEATED) >= TARGETS[key])
    elseif key == "war" then
        return finish_unlock("j_hnds_war", HNDS.unlock_career_stat(STAT_CARDS_DESTROYED) >= TARGETS[key])
    elseif key == "water_slide" then
        return finish_unlock("j_hnds_water_slide", HNDS.unlock_career_stat(STAT_WATER_SLIDE_EIGHTS) >= TARGETS[key])
    elseif key == "ecg" then
        return finish_unlock("j_hnds_ecg", state and state.ecg_heart_hand_streak >= 10)
    elseif key == "plague" then
        return finish_unlock("j_hnds_plague", max_same_enhancement_count() >= 10)
    elseif key == "famine" then
        return finish_unlock("j_hnds_famine", state and state.famine_high_card_round_streak >= 3 or false)
    elseif key == "death" then
        return finish_unlock("j_hnds_death", state and state.death_unlock or false)
    elseif key == "be_not_afraid" then
        return finish_unlock("j_hnds_be_not_afraid", state and state.be_not_afraid_unlock or false)
    elseif key == "joker_reverse" then
        return finish_unlock("j_hnds_joker_reverse", state and state.joker_reverse_rare_sold and state.joker_reverse_common_bought or false)
    elseif key == "spaghettified_joker" then
        if state and state.spaghettified_max_level >= TARGETS[key] then return true end
        for _, hand in pairs((G and G.GAME and G.GAME.hands) or {}) do
            if tonumber(hand.level) and hand.level >= TARGETS[key] then return true end
        end
        return false
    elseif key == "jodiac" then return state and state.jodiac_complete or false
    elseif key == "jack_in_the_box" then return args and args.type == "win" and state and state.jack_in_box_showdown_ready == true or false
    elseif key == "jevil" then return state and state.jevil_wild_flush or false
    elseif key == "headless_joker" then return HNDS.unlock_career_stat(STAT_HEADLESS_FACE_CARDS) >= TARGETS[key]
    elseif key == "time_fcked_joker" then return HNDS.unlock_career_stat(STAT_RUN_RESTARTS) >= TARGETS[key]
    elseif key == "banana_split" then return have_both_bananas()
    elseif key == "dynamic_duos" then return state and state.flags.dynamic_duos or false
    elseif key == "energized" or key == "last_laugh" then return unlock_career_stat(STAT_CARDS_DESTROYED) >= TARGETS[key]
    end

    return false
end

local function record_consumable_created(card)
    local state = run_state()
    if not state or state.round_serial <= 0 or not card_is_consumable(card) or card.hnds_unlock_consumable_counted then return end
    card.hnds_unlock_consumable_counted = true
    state.consumables_created_round = state.consumables_created_round + 1
    HNDS.request_unlock_check("hnds_consumable_created")
end

local function reset_round_tracking(state)
    state.round_serial = state.round_serial + 1
    state.consumables_created_round = 0
    state.money_gained_round = 0
    state.round_end_serial = nil
    state.boss_counted_serial = nil


    state.famine_round_high_card_only = true
end

local function schedule_imposter_round_check(state)
    local serial = state.round_serial
    if state.round_end_serial == serial then return end
    state.round_end_serial = serial
    local function finalize()
        local live = run_state()
        if not live or live.round_serial ~= serial then return true end
        local has_joker, has_untriggered = false, false
        for _, joker in ipairs((G and G.jokers and G.jokers.cards) or {}) do
            has_joker = true
            if joker.hnds_unlock_trigger_round ~= serial then has_untriggered = true end
        end
        if has_joker and has_untriggered then
            live.imposter_streak = live.imposter_streak + 1
        else
            live.imposter_streak = 0
        end
        HNDS.request_unlock_check("hnds_imposter_round")
        return true
    end
    if G and G.E_MANAGER and Event then
        G.E_MANAGER:add_event(Event({ trigger = "after", delay = 0, func = finalize }))
    else
        finalize()
    end
end

function HNDS.track_unlock_context(context)
    if not (context and G and G.GAME) then return end
    local state = run_state()
    if not state then return end
    local changed = false


    if context.before and not context.blueprint and not context.retrigger_joker then
        local scoring = context.scoring_hand

        if type(scoring) == "table" then
            local heart = false
            for _, card in ipairs(scoring) do
                if card and card.is_suit and card:is_suit("Hearts") then
                    heart = true
                    break
                end
            end

            if heart then
                state.ecg_heart_hand_streak = state.ecg_heart_hand_streak + 1
            else
                state.ecg_heart_hand_streak = 0
            end

            changed = true

            if state.ecg_heart_hand_streak >= 10 then
                HNDS.joker_unlock_condition_met("ecg", { type = "hnds_ecg_10_hands" })
            end
        end


        if not state.be_not_afraid_unlock
            and context.scoring_name == "Three of a Kind"
            and type(scoring) == "table"
        then
            local enhanced_aces = 0
            for _, scored_card in ipairs(scoring) do
                local rank = scored_card and scored_card.get_id and scored_card:get_id()
                    or (scored_card and scored_card.base and scored_card.base.id)
                if rank == 14 and card_set(scored_card) == "Enhanced" then
                    enhanced_aces = enhanced_aces + 1
                end
            end

            if enhanced_aces >= 3 then
                state.be_not_afraid_unlock = true
                changed = true
                HNDS.joker_unlock_condition_met("be_not_afraid", { type = "hnds_be_not_afraid" })
            end
        end

    end


    if context.before and not context.blueprint and not context.retrigger_joker
        and state.round_serial > 0 and context.scoring_name
        and context.scoring_name ~= "High Card"
    then
        if state.famine_round_high_card_only then
            state.famine_round_high_card_only = false
            changed = true
        end
    end


    if context.discard and context.other_card and not context.repetition then
        local discarded = context.other_card
        local rank = discarded.get_id and discarded:get_id()
            or (discarded.base and discarded.base.id)

        if rank == 8 then
            increment_career_stat(STAT_WATER_SLIDE_EIGHTS, 1)
            changed = true
        end
    end

    if context.individual and context.cardarea == G.play
        and context.other_card and not context.repetition and not context.repetition_only
        and not context.blueprint
    then
        local card = context.other_card
        local suit = card.base and card.base.suit
        if suit == "Hearts" then
            increment_career_stat(STAT_HEART_CARDS_SCORED, 1)
            state.ecg_heart_round_current = true
            changed = true
        elseif suit == "Diamonds" then
            increment_career_stat(STAT_DIAMOND_CARDS_SCORED, 1)
            changed = true
        elseif suit == "Clubs" then
            increment_career_stat(STAT_CLUB_CARDS_SCORED, 1)
            changed = true
        elseif suit == "Spades" then
            increment_career_stat(STAT_SPADE_CARDS_SCORED, 1)
            changed = true
        end


        local ante = current_ante()
        if state.jodiac_ante ~= ante then
            state.jodiac_ante = ante
            state.jodiac_ranks = {}
            state.jodiac_complete = false
        end
        local rank = card.get_id and card:get_id() or (card.base and card.base.id)
        if rank and rank >= 2 and rank <= 14 then
            state.jodiac_ranks[rank] = true
            local rank_count = 0
            for _ in pairs(state.jodiac_ranks) do rank_count = rank_count + 1 end
            if rank_count >= 13 then
                state.jodiac_complete = true
            end
            changed = true
        end

    end

    if context.before and not context.blueprint then
        local max_level = state.spaghettified_max_level
        for _, hand in pairs((G and G.GAME and G.GAME.hands) or {}) do
            local level = tonumber(hand.level) or 1
            if level > max_level then
                state.spaghettified_max_level = level
                max_level = level
                changed = true
            end
        end
    end

    if context.setting_blind and not context.blueprint then


        if state.has_selected_blind then
            if state.joker_bought_round then state.no_joker_buy_streak = 0
            else state.no_joker_buy_streak = state.no_joker_buy_streak + 1 end
        else
            state.has_selected_blind = true
        end
        state.joker_bought_round = false
        state.joker_reverse_rare_sold = false
        state.joker_reverse_common_bought = false
        reset_round_tracking(state)
        reset_ante_tracking(state, current_ante())
        changed = true
    end

    if context.buying_card and context.card then
        local card = context.card
        local center = card.config and card.config.center
        local set = card_set(card)

        if set == "Joker" then
            state.joker_bought_round = true
            if center and tonumber(center.rarity) == 3 and not card.hnds_unlock_purchase_counted then
                increment_career_stat(STAT_RARE_JOKERS, 1)
                card.hnds_unlock_purchase_counted = true
            end
            if center and center.key and not card.hnds_fregoli_purchase_counted then
                state.fregoli_buys[center.key] = (state.fregoli_buys[center.key] or 0) + 1
                card.hnds_fregoli_purchase_counted = true
            end
            if center and center.key == "j_joker" and not card.hnds_wait_what_purchase_counted then
                increment_career_stat(STAT_BASIC_JOKERS_BOUGHT, 1)
                card.hnds_wait_what_purchase_counted = true
            end


            local rarity = center and normalize_rarity(center.rarity)
            if rarity == 1 then
                state.joker_reverse_common_bought = true
            end
            if state.joker_reverse_rare_sold and state.joker_reverse_common_bought then
                HNDS.joker_unlock_condition_met("joker_reverse", { type = "hnds_joker_reverse" })
            end

            changed = true
        end
    end

    if context.selling_card and context.card and card_set(context.card) == "Joker"
        and not context.card.hnds_unlock_sale_counted
    then
        context.card.hnds_unlock_sale_counted = true
        state.jokers_sold = state.jokers_sold + 1

        local sold_center = context.card.config and context.card.config.center
        local sold_rarity = sold_center and normalize_rarity(sold_center.rarity)
        if sold_rarity == 3 then
            state.joker_reverse_rare_sold = true
        end
        if state.joker_reverse_rare_sold and state.joker_reverse_common_bought then
            HNDS.joker_unlock_condition_met("joker_reverse", { type = "hnds_joker_reverse" })
        end

        changed = true
    end

    if context.skip_blind then


        increment_career_stat(STAT_BLINDS_SKIPPED, 1)
        changed = true
    end

    if context.setting_ability and context.old and context.new and context.old ~= context.new
        and context.old ~= "c_base" and context.new ~= "c_base" and not context.unchanged
    then
        increment_career_stat(STAT_ENHANCEMENT_CHANGES, 1)
        changed = true
    end


    if context.remove_playing_cards and type(context.removed) == "table" then
        for _, removed_card in ipairs(context.removed) do
            if HNDS.count_destroyed_playing_card(removed_card) then changed = true end
        end
    end

    if context.before and not context.blueprint and not context.retrigger_joker then
        local cards = context.full_hand or context.scoring_hand or {}
        if #cards == 5 then
            local all_debuffed = true
            for _, card in ipairs(cards) do if not card.debuff then all_debuffed = false break end end
            if all_debuffed then state.flags.meme = true changed = true end
        end

        if context.scoring_name == "Two Pair" and is_even_odd_two_pair(context.scoring_hand or cards) then
            state.flags.dynamic_duos = true
            changed = true
        end


        local played_hand = context.scoring_hand
        if not state.jevil_wild_flush and type(played_hand) == "table" and #played_hand == 5 then
            local common_suit = nil
            local valid = true

            for _, played_card in ipairs(played_hand) do
                local printed_suit = played_card.base and played_card.base.suit
                if not printed_suit or not card_has_enhancement(played_card, "m_wild") then
                    valid = false
                    break
                end

                if common_suit == nil then
                    common_suit = printed_suit
                elseif common_suit ~= printed_suit then
                    valid = false
                    break
                end
            end

            if valid and common_suit then
                HNDS.mark_jevil_unlock()
                changed = true
            end
        end

        local ante = current_ante()
        reset_ante_tracking(state, ante)

        if context.scoring_name and not state.jigsaw_hands[context.scoring_name] then
            state.jigsaw_hands[context.scoring_name] = true
            state.jigsaw_count = state.jigsaw_count + 1
            changed = true
        end

        if context.scoring_name == "Flush" then
            local suit = current_flush_suit(context.scoring_hand or cards)
            if suit and state.supersuit_flushes[suit] ~= nil and not state.supersuit_flushes[suit] then
                state.supersuit_flushes[suit] = true
                if four_distinct_flush_suits(state) then state.flags.supersuit = true end
                changed = true
            end
        end
    end

    if context.individual and context.cardarea == G.play and context.other_card
        and not context.repetition and card_has_enhancement(context.other_card, "m_stone")
    then
        state.stone_scored = state.stone_scored + 1
        changed = true
    end

    if context.card_added and context.card then
        if context.card.hnds_unlock_created_consumable then record_consumable_created(context.card) end
        changed = true
    end

    if context.hand_drawn
        and state.round_serial > 0
        and G.deck and G.deck.cards and #G.deck.cards == 0
    then


        if not state.flags.pot_of_greed then
            state.flags.pot_of_greed = true
            changed = true
        end
    end

    if context.end_of_round and context.main_eval and not context.individual and not context.repetition then
        local blind = G and G.GAME and G.GAME.blind
        local round_won = context.game_over ~= true
            and blind
            and G.GAME.chips ~= nil
            and blind.chips ~= nil
            and G.GAME.chips >= blind.chips

        if round_won then
            local hands_played = math.max(0, tonumber(G.GAME.current_round and G.GAME.current_round.hands_played) or 0)
            if state.famine_round_high_card_only and hands_played > 0 then
                state.famine_high_card_round_streak = state.famine_high_card_round_streak + 1
                if state.famine_high_card_round_streak >= 3 then
                    HNDS.joker_unlock_condition_met("famine", { type = "hnds_famine_high_card_rounds" })
                end
            else
                state.famine_high_card_round_streak = 0
            end


            local held = (G and G.hand and G.hand.cards) or {}
            local death_valid = #held > 0
            local rank, suit = nil, nil
            if death_valid then
                for _, card in ipairs(held) do
                    local card_rank = card and card.base and (card.base.value or card.base.id)
                    local card_suit = card and card.base and card.base.suit
                    if not card_rank or not card_suit then
                        death_valid = false
                        break
                    end
                    if rank == nil then
                        rank, suit = card_rank, card_suit
                    elseif rank ~= card_rank or suit ~= card_suit then
                        death_valid = false
                        break
                    end
                end
            end
            if death_valid then
                state.death_unlock = true
                HNDS.joker_unlock_condition_met("death", { type = "hnds_death" })
            end
        else
            state.famine_high_card_round_streak = 0
        end


        local active_blind = G.GAME.blind
        local upgraded_slot = active_blind and active_blind.hnds_platinum_replacement_slot


        local is_boss = not upgraded_slot
            and ((context.beat_boss == true) or (active_blind and active_blind.boss == true))
        local round_serial = state.round_serial
        if is_boss and state.boss_counted_serial ~= round_serial then
            state.boss_counted_serial = round_serial
            increment_career_stat(STAT_BOSSES_DEFEATED, 1)
            if HNDS.unlock_career_stat(STAT_BOSSES_DEFEATED) >= TARGETS.conquest then
                HNDS.joker_unlock_condition_met("conquest", {type = "hnds_boss_defeated"})
            end
            if G.GAME.current_round and G.GAME.current_round.hands_played == 1 then
                state.boss_one_hand_streak = state.boss_one_hand_streak + 1
            else
                state.boss_one_hand_streak = 0
            end
            if G.GAME.current_round and (tonumber(G.GAME.current_round.hands_left) or 0) <= 0 then
                state.flags.public_nuisance = true
            end
        end
        schedule_imposter_round_check(state)
        changed = true
        HNDS.request_unlock_check("hnds_boss_defeated")
    end


    if context.setting_blind and not context.blueprint then
        local blind = G and G.GAME and G.GAME.blind
        local center = blind and blind.config and blind.config.blind
        local is_showdown = false
        if center and type(center.boss) == "table" then
            is_showdown = center.boss.showdown == true
        end
        if is_showdown then
            local rares = 0
            for _, joker in ipairs((G and G.jokers and G.jokers.cards) or {}) do
                local rarity = joker.config and joker.config.center and joker.config.center.rarity
                if normalize_rarity(rarity) == 3 then rares = rares + 1 end
            end
            if rares >= 5 then
                state.jack_in_box_showdown_ready = true
                changed = true
            end
        end
    end

    if changed then HNDS.request_unlock_check("hnds_joker_progress") end
end

local function meaningful_effect_count(ret)
    if type(ret) ~= "table" then return 0 end
    local count = 0
    for key, value in pairs(ret) do
        if key ~= "retriggers" and value ~= nil and value ~= false then
            if key == "playing_card" and type(value) == "table" then
                for _, nested in pairs(value) do
                    if nested ~= nil and nested ~= false and nested ~= 0
                        and (type(nested) ~= "table" or next(nested) ~= nil)
                    then
                        count = count + 1
                    end
                end
            elseif type(value) ~= "table" or next(value) ~= nil then
                count = count + 1
            end
        end
    end
    return count
end

local function is_lucky_card(card)
    if not card then return false end
    local center = card.config and card.config.center
    if center and center.key == "m_lucky" then return true end
    if HNDS.aberrant_has_fusion then
        local ok, result = pcall(HNDS.aberrant_has_fusion, card, "m_lucky")
        if ok and result then return true end
    end
    return false
end

local function lucky_success_count(ret)
    if type(ret) ~= "table" then return 0 end
    local effects = type(ret.playing_card) == "table" and ret.playing_card or ret
    local count = 0
    if tonumber(effects.mult) and tonumber(effects.mult) ~= 0 then count = count + 1 end
    if tonumber(effects.p_dollars) and tonumber(effects.p_dollars) ~= 0 then count = count + 1 end
    return count
end

if CardArea and type(CardArea.draw_card_from) == "function" and not CardArea._hnds_unlock_draw_from_wrapped then
    CardArea._hnds_unlock_draw_from_wrapped = true
    local draw_card_from_unlock_ref = CardArea.draw_card_from
    function CardArea:draw_card_from(area, stay_flipped, discarded_only, ...)
        local moved = draw_card_from_unlock_ref(self, area, stay_flipped, discarded_only, ...)
        if moved and in_run()
            and G.GAME.facing_blind
            and area == G.deck and self == G.hand
            and G.deck and G.deck.cards and #G.deck.cards == 0
        then
            local state = run_state()
            if state and state.round_serial > 0 and not state.flags.pot_of_greed then
                state.flags.pot_of_greed = true
                local function check_later()
                    HNDS.request_unlock_check("hnds_full_deck_drawn")
                    return true
                end


                if G.E_MANAGER and Event then
                    G.E_MANAGER:add_event(Event({
                        trigger = "after",
                        delay = 0,
                        blockable = false,
                        func = check_later,
                    }))
                else
                    check_later()
                end
            end
        end
        return moved
    end
end

if type(eval_card) == "function" and not HNDS._unlock_eval_card_wrapped then
    HNDS._unlock_eval_card_wrapped = true
    local eval_card_unlock_ref = eval_card
    function eval_card(card, context, ...)
        local ret, post = eval_card_unlock_ref(card, context, ...)
        if G and context and context.cardarea == G.hand then
            local triggered = meaningful_effect_count(ret)
            if triggered > 0 then HNDS.record_held_effects(triggered, "hnds_held_effect") end
        end
        if G and context and context.cardarea == G.play and context.main_scoring and is_lucky_card(card) then
            local triggered = lucky_success_count(ret)
            if triggered > 0 then
                increment_career_stat(STAT_LUCKY_TRIGGERS, triggered)
                HNDS.request_unlock_check("hnds_lucky_effect")
            end
        end
        return ret, post
    end
end

if G and G.FUNCS and type(G.FUNCS.skip_blind) == "function" and not HNDS._unlock_skip_blind_wrapped then
    HNDS._unlock_skip_blind_wrapped = true
    local skip_blind_unlock_ref = G.FUNCS.skip_blind
    function G.FUNCS.skip_blind(e, ...)
        local ante = current_ante()
        local slot = normalize_blind_slot(G and G.GAME and G.GAME.blind_on_deck)
            or normalize_blind_slot(e and e.config and e.config.id)
        record_coffee_break_skip(ante, slot)
        return skip_blind_unlock_ref(e, ...)
    end
end

if G and G.FUNCS and type(G.FUNCS.use_card) == "function" and not HNDS._unlock_use_card_wrapped then
    HNDS._unlock_use_card_wrapped = true
    local use_card_unlock_ref = G.FUNCS.use_card
    function G.FUNCS.use_card(e, mute, nosave, ...)
        local card = e and e.config and e.config.ref_table
        local set = card and card.ability and card.ability.set
        local paid_shop_booster = set == "Booster"
            and not nosave
            and G.STATE == G.STATES.SHOP
            and not card.from_tag
            and not card.hnds_wholesale_purchase_counted
        if paid_shop_booster then HNDS.record_booster_purchase(card) end
        return use_card_unlock_ref(e, mute, nosave, ...)
    end
end

if Card and type(Card.calculate_joker) == "function" and not Card._hnds_unlock_trigger_wrapped then
    Card._hnds_unlock_trigger_wrapped = true
    local calculate_joker_unlock_ref = Card.calculate_joker
    local function hnds_unlock_effect_triggered(value)
        return value ~= nil and value ~= false
            and (type(value) ~= "table" or next(value) ~= nil)
    end
    function Card:calculate_joker(...)
        local results = HNDS.pack(calculate_joker_unlock_ref(self, ...))
        local triggered = false
        for i = 1, results.n do
            if hnds_unlock_effect_triggered(results[i]) then
                triggered = true
                break
            end
        end
        if triggered and card_set(self) == "Joker" then
            local state = run_state()
            if state then self.hnds_unlock_trigger_round = state.round_serial end
        end
        return ((table and table.unpack) or unpack)(results, 1, results.n)
    end
end

if Card and type(Card.set_edition) == "function" and not Card._hnds_unlock_edition_wrapped then
    Card._hnds_unlock_edition_wrapped = true
    local set_edition_unlock_ref = Card.set_edition
    function Card:set_edition(edition, immediate, silent, ...)
        local was_negative = self.edition and (self.edition.negative or self.edition.key == "e_negative")
        local results = HNDS.pack(set_edition_unlock_ref(self, edition, immediate, silent, ...))
        local is_negative = self.edition and (self.edition.negative or self.edition.key == "e_negative")
        if in_run() and card_set(self) == "Joker" and not was_negative and is_negative then
            increment_career_stat(STAT_NEGATIVE_JOKERS, 1)
            HNDS.request_unlock_check("hnds_negative_joker")
        else
            HNDS.request_unlock_check("hnds_edition_state")
        end
        return ((table and table.unpack) or unpack)(results, 1, results.n)
    end
end

if Card and type(Card.set_base) == "function" and not Card._hnds_unlock_base_wrapped then
    Card._hnds_unlock_base_wrapped = true
    local set_base_unlock_ref = Card.set_base
    function Card:set_base(card, initial, ...)
        local old_suit = self.base and self.base.suit
        local old_rank = self.base and (self.base.value or self.base.id)
        local results = HNDS.pack(set_base_unlock_ref(self, card, initial, ...))
        if in_run() and not initial and old_suit and old_rank and self.base then
            local changes = 0
            local new_rank = self.base.value or self.base.id
            if old_suit ~= self.base.suit then changes = changes + 1 end
            if old_rank ~= new_rank then changes = changes + 1 end
            if changes > 0 then
                increment_career_stat(STAT_CARD_IDENTITY_CHANGES, changes)
                HNDS.request_unlock_check("hnds_card_identity")
            end
        end
        return ((table and table.unpack) or unpack)(results, 1, results.n)
    end
end

if Card and type(Card.set_ability) == "function" and not Card._hnds_unlock_ability_wrapped then
    Card._hnds_unlock_ability_wrapped = true
    local set_ability_unlock_ref = Card.set_ability
    function Card:set_ability(...)
        local results = HNDS.pack(set_ability_unlock_ref(self, ...))
        HNDS.request_unlock_check("hnds_enhancement_state")
        return ((table and table.unpack) or unpack)(results, 1, results.n)
    end
end

if type(add_tag) == "function" and not HNDS._unlock_add_tag_wrapped then
    HNDS._unlock_add_tag_wrapped = true
    local add_tag_unlock_ref = add_tag
    function add_tag(tag, ...)
        local results = HNDS.pack(add_tag_unlock_ref(tag, ...))
        if in_run() and (type(tag) ~= "table" or not tag.hnds_unlock_tag_counted) then
            if type(tag) == "table" then tag.hnds_unlock_tag_counted = true end
            increment_career_stat(STAT_TAGS_CREATED, 1)
            HNDS.request_unlock_check("hnds_tag_created")
        end
        return ((table and table.unpack) or unpack)(results, 1, results.n)
    end
end

if SMODS and type(SMODS.pseudorandom_probability) == "function" and not SMODS._hnds_unlock_probability_wrapped then
    SMODS._hnds_unlock_probability_wrapped = true
    local probability_unlock_ref = SMODS.pseudorandom_probability
    function SMODS.pseudorandom_probability(...)
        local results = HNDS.pack(probability_unlock_ref(...))
        local result = results[1]
        if in_run() and result == false then
            increment_career_stat(STAT_PROBABILITY_FAILURES, 1)
            HNDS.request_unlock_check("hnds_probability_failed")
        end
        return ((table and table.unpack) or unpack)(results, 1, results.n)
    end
end

if type(ease_dollars) == "function" and not HNDS._unlock_ease_dollars_wrapped then
    HNDS._unlock_ease_dollars_wrapped = true
    local ease_dollars_unlock_ref = ease_dollars
    function ease_dollars(mod, instant, ...)
        local state = run_state()
        local amount = tonumber(mod) or 0
        if state and state.round_serial > 0 and amount > 0 then
            state.money_gained_round = state.money_gained_round + amount
            HNDS.request_unlock_check("hnds_money_gained")
        end
        return ease_dollars_unlock_ref(mod, instant, ...)
    end
end

if SMODS and type(SMODS.add_card) == "function" and not SMODS._hnds_unlock_add_card_wrapped then
    SMODS._hnds_unlock_add_card_wrapped = true
    local add_card_unlock_ref = SMODS.add_card
    function SMODS.add_card(args, ...)
        local results = HNDS.pack(add_card_unlock_ref(args, ...))
        local card = results[1]
        if card_is_consumable(card) then record_consumable_created(card) end
        HNDS.request_unlock_check("hnds_card_added")
        return ((table and table.unpack) or unpack)(results, 1, results.n)
    end
end

if type(create_card) == "function" and not HNDS._unlock_create_card_wrapped then
    HNDS._unlock_create_card_wrapped = true
    local create_card_unlock_ref = create_card
    function create_card(_type, area, ...)
        local results = HNDS.pack(create_card_unlock_ref(_type, area, ...))
        local card = results[1]
        if card and G and G.consumeables and area == G.consumeables and card_is_consumable(card) then
            card.hnds_unlock_created_consumable = true
        end
        return ((table and table.unpack) or unpack)(results, 1, results.n)
    end
end

if Card and type(Card.add_to_deck) == "function" and not Card._hnds_unlock_add_to_deck_wrapped then
    Card._hnds_unlock_add_to_deck_wrapped = true
    local add_to_deck_unlock_ref = Card.add_to_deck
    function Card:add_to_deck(...)
        local results = HNDS.pack(add_to_deck_unlock_ref(self, ...))
        if self.hnds_unlock_created_consumable then record_consumable_created(self) end
        HNDS.request_unlock_check("hnds_card_added")
        return ((table and table.unpack) or unpack)(results, 1, results.n)
    end
end

if type(discover_card) == "function" and not HNDS._unlock_discover_card_wrapped then
    HNDS._unlock_discover_card_wrapped = true
    local discover_card_unlock_ref = discover_card
    function discover_card(...)
        local pack = HNDS.pack
        local unpack_values = table.unpack or unpack
        local result = pack(discover_card_unlock_ref(...))
        HNDS.request_unlock_check("hnds_discovery")
        return unpack_values(result, 1, result.n)
    end
end


if Game and type(Game.start_run) == "function" and not HNDS._restart_unlock_wrapped then
    HNDS._restart_unlock_wrapped = true
    local start_run_unlock_ref = Game.start_run
    function Game:start_run(args, ...)
        local was_running = G and G.STAGE and G.STAGES and G.STAGE == G.STAGES.RUN
        local is_new_run = type(args) == "table" and args.savetext == nil
        if was_running and is_new_run then
            increment_career_stat(STAT_RUN_RESTARTS, 1)
            HNDS.request_unlock_check("hnds_run_restart")
        end
        return start_run_unlock_ref(self, args, ...)
    end
end

if not HNDS._hnds_wrapped_level_up_unlock and type(level_up_hand) == "function" then
    HNDS._hnds_wrapped_level_up_unlock = true
    local level_up_hand_ref = level_up_hand
    function level_up_hand(card, hand, instant, ...)
        local results = HNDS.pack(level_up_hand_ref(card, hand, instant, ...))
        HNDS.request_unlock_check("hnds_hand_level")
        return ((table and table.unpack) or unpack)(results, 1, results.n)
    end
end

local LOCK_SCHEMA = 7
local DESTROY_STAT_SCHEMA = 1
local CONDITION_LOCK_KEYS = {
    "b_hnds_premiumdeck", "b_hnds_crystal", "b_hnds_conjuring",
    "b_hnds_cursed", "b_hnds_circus", "b_hnds_ol_reliable",
    "v_hnds_top_shelf", "v_hnds_wholesale", "v_hnds_hashtag_skip", "v_hnds_beyond",
}
local JOKER_CONDITION_LOCK_KEYS = {
    "j_hnds_jester_in_yellow", "j_hnds_demented", "j_hnds_imposter", "j_hnds_contagion",
    "j_hnds_fregoli", "j_hnds_excommunicado", "j_hnds_meme", "j_hnds_one_punchline_man",
    "j_hnds_digital_circus", "j_hnds_handsome", "j_hnds_perfectionist", "j_hnds_dark_idol",
    "j_hnds_color_of_madness", "j_hnds_deep_pockets", "j_hnds_head_of_medusa", "j_hnds_ms_fortune",
    "j_hnds_occultist", "j_hnds_clown_devil", "j_hnds_balloons", "j_hnds_creepy",
    "j_hnds_seismic_activity", "j_hnds_angry_mob", "j_hnds_supersuit", "j_hnds_jokes_aside",
    "j_hnds_jackpot", "j_hnds_banana_split", "j_hnds_dynamic_duos", "j_hnds_energized",
    "j_hnds_last_laugh", "j_hnds_coffee_break", "j_hnds_jigsaw_joker",
    "j_hnds_dallas", "j_hnds_hoxton", "j_hnds_wolf", "j_hnds_chains",
    "j_hnds_ecg", "j_hnds_spaghettified_joker", "j_hnds_jodiac",
    "j_hnds_jack_in_the_box", "j_hnds_jevil", "j_hnds_headless_joker",
    "j_hnds_time_fcked_joker",
    "j_hnds_most_wanted", "j_hnds_wait_what", "j_hnds_dark_humor",
    "j_hnds_public_nuisance", "j_hnds_pot_of_greed", "j_hnds_ancestor",
    "j_hnds_conquest", "j_hnds_war", "j_hnds_water_slide", "j_hnds_ecg",
    "j_hnds_plague", "j_hnds_famine", "j_hnds_death", "j_hnds_be_not_afraid",
    "j_hnds_joker_reverse",
}
local LEGENDARY_LOCK_KEYS = {
    "j_hnds_pennywise", "j_hnds_art", "j_hnds_krusty", "j_hnds_sarmenti", "j_hnds_arthur",
}

function HNDS.apply_unlock_state_migration()
    local profile = current_profile()
    if not profile then return end

    local lock_schema_current = tonumber(profile.hnds_unlock_schema) == LOCK_SCHEMA
    local destroy_schema_current = tonumber(profile.hnds_destroy_stat_schema) == DESTROY_STAT_SCHEMA
    if lock_schema_current and destroy_schema_current then return end

    if not (G and G.P_CENTERS
        and G.P_CENTERS.b_hnds_premiumdeck
        and G.P_CENTERS.v_hnds_top_shelf
        and G.P_CENTERS.j_hnds_arthur
        and G.P_CENTERS.j_hnds_jester_in_yellow)
    then
        return
    end

    if not lock_schema_current then
        for _, key in ipairs(CONDITION_LOCK_KEYS) do
            local center = G.P_CENTERS[key]
            if center then center.unlocked = false end
        end
        for _, key in ipairs(JOKER_CONDITION_LOCK_KEYS) do
            local center = G.P_CENTERS[key]
            if center then center.unlocked = false end
        end
        for _, key in ipairs(LEGENDARY_LOCK_KEYS) do
            local center = G.P_CENTERS[key]
            if center and not center.discovered then center.unlocked = false end
        end
        profile.hnds_unlock_schema = LOCK_SCHEMA
    end

    if not destroy_schema_current then


        profile.career_stats = profile.career_stats or {}
        profile.career_stats[STAT_CARDS_DESTROYED] = 0
        profile.hnds_destroy_stat_schema = DESTROY_STAT_SCHEMA
    end

    if G and type(G.save_progress) == "function" then G:save_progress() end
    HNDS.request_unlock_check("hnds_unlock_migration")
end

if type(set_discover_tallies) == "function" and not HNDS._unlock_tallies_wrapped then
    HNDS._unlock_tallies_wrapped = true
    local set_discover_tallies_unlock_ref = set_discover_tallies
    function set_discover_tallies(...)
        local result = HNDS.pack(set_discover_tallies_unlock_ref(...))
        HNDS.apply_unlock_state_migration()
        HNDS.request_unlock_check("hnds_discovery_refresh")
        return ((table and table.unpack) or unpack)(result, 1, result.n)
    end
end
