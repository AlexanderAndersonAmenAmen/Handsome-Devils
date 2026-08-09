local function hnds_stone_mask_modifier_options(source)
    local options = {}
    local center = source and source.config and source.config.center
    if center and center.set == "Enhanced" then options[#options + 1] = "enhancement" end
    if source and source.edition and next(source.edition) then options[#options + 1] = "edition" end
    if source and source.seal then options[#options + 1] = "seal" end
    return options
end

local function hnds_stone_mask_has_modifier(card, kind)
    if not card then return false end
    if kind == "enhancement" then
        local center = card.config and card.config.center
        return center and center.set == "Enhanced" or false
    elseif kind == "edition" then
        return card.edition and next(card.edition) ~= nil or false
    elseif kind == "seal" then
        return card.seal ~= nil
    end
    return false
end

local function hnds_stone_mask_prioritized_options(target, source)
    local options = hnds_stone_mask_modifier_options(source)
    if #options == 0 then return options end

    -- Prefer modifier categories the receiving face card does not have yet.
    -- If this donor cannot supply any missing category, fall back to the full
    -- list so Stone Mask can still replace an existing modifier as before.
    local missing = {}
    for _, kind in ipairs(options) do
        if not hnds_stone_mask_has_modifier(target, kind) then
            missing[#missing + 1] = kind
        end
    end
    return #missing > 0 and missing or options
end

local function hnds_stone_mask_set_enhancement(card, center)
    if not (card and center) then return end
    local old_internal = HNDS and HNDS._aberrant_internal_center_swap
    if HNDS then HNDS._aberrant_internal_center_swap = true end
    card:set_ability(center, nil, true)
    if HNDS then HNDS._aberrant_internal_center_swap = old_internal end
end

local function hnds_stone_mask_steal(target, source, kind)
    if not (target and source and kind) then return false end

    if kind == "enhancement" then
        local center = source.config and source.config.center
        if not (center and center.set == "Enhanced") then return false end

        -- Aberrant's fused enhancements are card state, not Center config.
        -- Capture that ordered state before stripping the donor, then restore
        -- it on the receiving face card after Aberrant itself is transferred.
        local aberrant_fusions
        if center.key == "m_hnds_aberrant"
            and source.ability
            and type(source.ability.hnds_aberrant_fusions) == "table"
        then
            aberrant_fusions = {}
            for i, fusion_key in ipairs(source.ability.hnds_aberrant_fusions) do
                aberrant_fusions[i] = fusion_key
            end
        end

        hnds_stone_mask_set_enhancement(source, G.P_CENTERS.c_base)
        if source.ability then source.ability.hnds_aberrant_fusions = nil end
        hnds_stone_mask_set_enhancement(target, center)

        if aberrant_fusions then
            target.ability = target.ability or {}
            target.ability.hnds_aberrant_fusions = aberrant_fusions
            if SMODS.enh_cache and SMODS.enh_cache.write then
                SMODS.enh_cache:write(target, nil)
            end
            if target.set_sprites then target:set_sprites(target.config.center) end
            if target.should_hide_front then
                target.front_hidden = target:should_hide_front()
            end
        end
        return true
    elseif kind == "edition" then
        if not (source.edition and next(source.edition)) then return false end
        local edition = {}
        for k, v in pairs(source.edition) do edition[k] = v end
        source:set_edition(nil, true, true)
        target:set_edition(edition, true, true)
        return true
    elseif kind == "seal" then
        if not source.seal then return false end
        local seal = source.seal
        source:set_seal(nil, true)
        target:set_seal(seal, true)
        return true
    end

    return false
end

local function hnds_stone_mask_first_scored_face(context)
    for _, played in ipairs((context and context.scoring_hand) or {}) do
        if played and played.is_face and played:is_face() then return played end
    end
    return nil
end

local function hnds_stone_mask_adjacent_cards(target, context)
    local played = (context and context.full_hand) or (G.play and G.play.cards) or {}
    local index
    for i, c in ipairs(played) do
        if c == target then index = i break end
    end
    if not index then return {} end

    local adjacent = {}
    if played[index - 1] then adjacent[#adjacent + 1] = played[index - 1] end
    if played[index + 1] then adjacent[#adjacent + 1] = played[index + 1] end
    return adjacent
end

SMODS.Joker({
    key = "stone_mask",
    atlas = "Jokers",
    pos = { x = 5, y = 1 },
    rarity = 2,
    cost = 6,
    unlocked = false,
    discovered = false,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    config = { extra = { odds = 2 } },
    unlock_condition = { type = 'modify_jokers', extra = 5 },
    loc_vars = function(self, info_queue, card)
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, "hnds_stone_mask")
        return { vars = { numerator, denominator } }
    end,
    check_for_unlock = function(self, args)
        if args.type == 'modify_jokers' then
            local jokers = SMODS.find_card('j_vampire')
            for _, v in ipairs(jokers) do
                if v.ability and v.ability.extra and v.ability.extra.x_mult
                        and v.ability.extra.x_mult >= self.unlock_condition.extra then
                    return true
                end
            end
        end
    end,
    calculate = function(self, card, context)
        if not (context.before and not context.blueprint) then return end

        local target = hnds_stone_mask_first_scored_face(context)
        if not target then return end
        if not SMODS.pseudorandom_probability(card, "hnds_stone_mask", 1, card.ability.extra.odds) then return end

        local adjacent = hnds_stone_mask_adjacent_cards(target, context)
        if #adjacent == 0 then return end

        -- Each adjacent card independently picks exactly one modifier type.
        -- Types the face card does not have yet are always preferred; only if
        -- that donor cannot provide a missing type do we allow replacement of
        -- a modifier category the face card already owns.
        local picks = {}
        local target_id = tostring(target.sort_id or target.ID or "")
        for i, source in ipairs(adjacent) do
            local options = hnds_stone_mask_prioritized_options(target, source)
            if #options > 0 then
                picks[#picks + 1] = {
                    source = source,
                    kind = pseudorandom_element(options, pseudoseed("hnds_stone_mask_pick_" .. target_id .. "_" .. tostring(i))),
                }
            end
        end
        if #picks == 0 then return end

        -- If both neighbours selected the same modifier category, only one of
        -- them is robbed. The donor is chosen 50/50, as requested.
        if #picks == 2 and picks[1].kind == picks[2].kind then
            local winner = pseudorandom("hnds_stone_mask_conflict_" .. target_id) < 0.5 and 1 or 2
            picks = { picks[winner] }
        end

        local stole_any = false
        for _, pick in ipairs(picks) do
            if hnds_stone_mask_steal(target, pick.source, pick.kind) then
                stole_any = true
                if pick.source.juice_up then pick.source:juice_up(0.25, 0.2) end
            end
        end

        if stole_any then
            if target.juice_up then target:juice_up(0.45, 0.35) end
            card_eval_status_text(card, 'jokers', nil, nil, nil, {
                message = localize('k_hnds_awaken'), colour = G.C.GREY, delay = 0.4
            })
            return nil, true
        end
    end,
    attributes = { "modify_card", "enhancements", "editions", "seals", "chance" }
})
