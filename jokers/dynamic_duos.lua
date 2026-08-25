SMODS.Joker {
    key = "dynamic_duos",
    atlas = "Jokers",
    pos = { x = 7, y = 4 },
    rarity = 1,
    cost = 6,
    unlocked = false,
    discovered = false,
    unlock_condition = { type = "hnds_joker_unlock", key = "dynamic_duos" },
    locked_loc_vars = function(self)
        return HNDS.joker_locked_loc_vars("dynamic_duos")
    end,
    check_for_unlock = function(self, args)
        return HNDS.joker_unlock_condition_met("dynamic_duos", args)
    end,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    config = { extra = { repetitions = 1 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.repetitions } }
    end,
    calculate = function(self, card, context)
        if not (context.repetition and context.cardarea == G.play and context.scoring_name == "Two Pair") then return end
        local rank_a, rank_b
        local has_wild_rank = false
        for _, c in ipairs(context.scoring_hand or {}) do
            if HNDS.imposter_card_is_wild_rank(c, context) then has_wild_rank = true end
            local r = c:get_id()
            if not rank_a then rank_a = r elseif r ~= rank_a and not rank_b then rank_b = r end
        end
        if not (rank_a and rank_b) then return end

        if has_wild_rank then return { repetitions = card.ability.extra.repetitions } end
        local is_odd = function(x) return x % 2 == 1 or x == 14 end
        if is_odd(rank_a) ~= is_odd(rank_b) then return { repetitions = card.ability.extra.repetitions } end
    end,
    attributes = { "rank", "retrigger" }
}
