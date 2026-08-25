local BOUND_STICKER = "hnds_bound"
local OBSIDIAN_KEY = "m_hnds_obsidian"

local function is_bound(card)
    return card and card.ability and card.ability[BOUND_STICKER] == true
end

HNDS.is_bound_card = is_bound

local function center_key(card)
    return card and card.config and card.config.center and card.config.center.key
end

local function has_obsidian_fusion(card)
    local fusions = card and card.ability and card.ability.hnds_aberrant_fusions
    if type(fusions) ~= "table" then return false end
    for _, key in ipairs(fusions) do
        if key == OBSIDIAN_KEY then return true end
    end
    return false
end

local function has_obsidian(card)
    return center_key(card) == OBSIDIAN_KEY or has_obsidian_fusion(card)
end

HNDS.card_has_obsidian = has_obsidian

local function obsidian_extra(card)
    if not card or not card.ability then
        return { required = 1, scored = 0, complete = false }
    end

    local extra
    if has_obsidian_fusion(card) then
        card.ability.hnds_obsidian_extra = type(card.ability.hnds_obsidian_extra) == "table"
            and card.ability.hnds_obsidian_extra or {}
        extra = card.ability.hnds_obsidian_extra
    else
        card.ability.extra = type(card.ability.extra) == "table" and card.ability.extra or {}
        extra = card.ability.extra
    end

    extra.required = 1
    extra.scored = math.max(0, tonumber(extra.scored) or 0)
    extra.complete = extra.complete == true or extra.scored >= 1 or is_bound(card)
    if extra.complete then extra.scored = 1 end
    extra.cards = nil
    return extra
end

local function make_bound(card, silent)
    if not card or is_bound(card) then return end
    if card.add_sticker then
        card:add_sticker(BOUND_STICKER, true)
    elseif card.ability then
        card.ability[BOUND_STICKER] = true
    end
    if not silent then
        card:juice_up(0.3, 0.5)
        card_eval_status_text(card, "extra", nil, nil, nil, {
            message = localize("k_hnds_ritual_complete"),
            colour = G.C.DARK_EDITION,
        })
    end
end

local function resolve_center(center)
    if type(center) == "string" then return G and G.P_CENTERS and G.P_CENTERS[center] end
    return center
end

SMODS.Enhancement({
    key = "obsidian",
    atlas = "Extras",
    pos = { x = 3, y = 0 },
    config = { extra = { required = 1, scored = 0, complete = false } },
    loc_vars = function(self, info_queue, card)
        local extra = obsidian_extra(card)
        local complete = extra.complete or is_bound(card)


        if not complete then
            info_queue[#info_queue + 1] = { key = "hnds_bound", set = "Other" }
        end
        return { key = complete and "m_hnds_obsidian_complete" or nil }
    end,
    calculate = function(self, card, context)
        local extra = obsidian_extra(card)

        if extra.complete and not is_bound(card) then make_bound(card, true) end


        local scored_now = context.main_scoring and context.cardarea == G.play
        local legacy_individual = context.individual and context.cardarea == G.play
            and context.other_card == card and not context.repetition
        if (scored_now or legacy_individual) and not card.debuff and not extra.complete then
            card.ability.hnds_obsidian_scored_last_hand = true
        end
    end,
    weight = 2.5,
})


SMODS.Sticker({
    key = "bound",
    atlas = "Stickers",
    pos = { x = 2, y = 1 },
    badge_colour = G.C.PURPLE,
    rate = 0,
    default_compat = true,
    sets = { Default = true, Enhanced = true },
    apply = function(self, card, val)
        SMODS.Sticker.apply(self, card, val)
    end,
})


if Card and Card.set_ability and not Card._hnds_obsidian_ability_wrapped then
    Card._hnds_obsidian_ability_wrapped = true
    local set_ability_obsidian_ref = Card.set_ability

    function Card:set_ability(center, initial, delay_sprites, ...)


        if initial or not self.ability then
            return set_ability_obsidian_ref(self, center, initial, delay_sprites, ...)
        end

        local new_center = resolve_center(center)
        local new_key = new_center and new_center.key
        local old_key = center_key(self)
        local was_obsidian = old_key == OBSIDIAN_KEY
        local was_bound = is_bound(self)
        local old_extra = was_obsidian and obsidian_extra(self) or nil


        if not initial and was_obsidian and was_bound and new_key == OBSIDIAN_KEY then
            old_extra.complete = true
            old_extra.scored = old_extra.required
            return self
        end


        if not initial and was_obsidian and new_key ~= OBSIDIAN_KEY and old_extra and not old_extra.complete then
            old_extra.scored = 0
            old_extra.complete = false
            if self.ability then self.ability.hnds_obsidian_scored_last_hand = nil end
        end

        local results = HNDS.pack(set_ability_obsidian_ref(self, center, initial, delay_sprites, ...))


        if was_bound and not is_bound(self) then make_bound(self, true) end

        if not initial and new_key == OBSIDIAN_KEY and was_bound then


            local extra = obsidian_extra(self)
            extra.complete = true
            extra.scored = extra.required
            if self.ability then self.ability.hnds_obsidian_scored_last_hand = nil end
        end

        return ((table and table.unpack) or unpack)(results, 1, results.n)
    end
end

HNDS.reset_obsidian_hand_marks = function()
    for _, card in ipairs((G and G.playing_cards) or {}) do
        if card and card.ability then card.ability.hnds_obsidian_scored_last_hand = nil end
    end
end

HNDS.complete_obsidian_final_hand = function()
    for _, card in ipairs((G and G.playing_cards) or {}) do
        if card and card.ability and card.ability.hnds_obsidian_scored_last_hand
            and has_obsidian(card)
        then
            local extra = obsidian_extra(card)
            if not extra.complete then
                extra.scored = math.min(extra.required, extra.scored + 1)
                if extra.scored >= extra.required then
                    extra.complete = true
                    make_bound(card, false)
                else
                    card:juice_up(0.2, 0.3)
                    card_eval_status_text(card, "extra", nil, nil, nil, {
                        message = tostring(extra.scored) .. "/" .. tostring(extra.required),
                        colour = G.C.PURPLE,
                    })
                end
            end
        end
        if card and card.ability then card.ability.hnds_obsidian_scored_last_hand = nil end
    end
end


HNDS.draw_bound_cards = function()
    if not (G and G.GAME and G.GAME.current_round and G.deck and G.hand) then return end
    if G.GAME.current_round.hnds_bound_cards_drawn then return end
    G.GAME.current_round.hnds_bound_cards_drawn = true

    local cards_to_draw = {}
    for _, target in ipairs(G.deck.cards or {}) do
        if is_bound(target) and not target.debuff and not target.ability.hnds_drawing then
            cards_to_draw[#cards_to_draw + 1] = target
            target.ability.hnds_drawing = true
        end
    end
    if #cards_to_draw == 0 then return end

    G.E_MANAGER:add_event(Event({
        trigger = "before",
        func = function()
            for _, target in ipairs(cards_to_draw) do
                if target.area == G.deck and not target.debuff then
                    draw_card(G.deck, G.hand, nil, "up", true, target)
                end
            end
            G.E_MANAGER:add_event(Event({
                trigger = "before",
                delay = 0.1,
                func = function()
                    for _, target in ipairs(cards_to_draw) do
                        if target and target.ability then target.ability.hnds_drawing = nil end
                    end
                    return true
                end,
            }))
            return true
        end,
    }))
end
