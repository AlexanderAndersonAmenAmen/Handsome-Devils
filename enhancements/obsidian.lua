local function obsidian_extra(card)
    card.ability.extra = type(card.ability.extra) == "table" and card.ability.extra or {}
    local extra = card.ability.extra
    -- Save migration from the former draw-extra-cards implementation.
    extra.required = math.max(1, tonumber(extra.required) or tonumber(extra.cards) or 2)
    extra.scored = math.max(0, tonumber(extra.scored) or 0)
    extra.complete = extra.complete == true or extra.scored >= extra.required
    extra.cards = nil
    return extra
end

SMODS.Enhancement({
    key = "obsidian",
    atlas = "Extras",
    pos = { x = 3, y = 0 },
    config = { extra = { required = 2, scored = 0, complete = false } },
    loc_vars = function(self, info_queue, card)
        local extra = obsidian_extra(card)
        return {
            key = extra.complete and "m_hnds_obsidian_complete" or nil,
            vars = { extra.required, math.min(extra.required, extra.scored) },
        }
    end,
    calculate = function(self, card, context)
        -- Enhancements receive `main_scoring` for their own scoring card in
        -- this Steamodded build. The previous implementation waited for an
        -- `individual/other_card` context that never reached the Enhancement,
        -- so no Obsidian card was ever marked and progress remained at 0/2.
        -- Keep the individual branch as compatibility for versions that emit
        -- it, while main_scoring is the authoritative path here.
        local scored_now = context.main_scoring and context.cardarea == G.play
        local legacy_individual = context.individual and context.cardarea == G.play
            and context.other_card == card and not context.repetition
        if (scored_now or legacy_individual) and not card.debuff then
            card.ability.hnds_obsidian_scored_last_hand = true
        end
    end,
    weight = 2.5,
})

HNDS.reset_obsidian_hand_marks = function()
    for _, card in ipairs((G and G.playing_cards) or {}) do
        if card and card.ability then card.ability.hnds_obsidian_scored_last_hand = nil end
    end
end

HNDS.complete_obsidian_final_hand = function()
    for _, card in ipairs((G and G.playing_cards) or {}) do
        if card and card.ability and card.ability.hnds_obsidian_scored_last_hand
            and SMODS.has_enhancement(card, "m_hnds_obsidian")
        then
            local extra = obsidian_extra(card)
            if not extra.complete then
                extra.scored = math.min(extra.required, extra.scored + 1)
                if extra.scored >= extra.required then
                    extra.complete = true
                    card:set_edition("e_negative", true)
                    card:juice_up(0.3, 0.5)
                    card_eval_status_text(card, "extra", nil, nil, nil, {
                        message = localize("k_hnds_ritual_complete"),
                        colour = G.C.DARK_EDITION,
                    })
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
