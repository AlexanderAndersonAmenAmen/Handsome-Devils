local function play_sarmenti_sound()
    if not (hnds_config and hnds_config.enableCustomSounds) then return end


    local roll = pseudorandom("hnds_sarmenti_sfx")
    local sound_key = roll < 0.25 and "hnds_sarmenti_common_tune1"
        or roll < 0.5 and "hnds_sarmenti_common_tune2"
        or roll < 0.75 and "hnds_sarmenti_rare_tune1"
        or "hnds_sarmenti_rare_tune2"
    play_sound(sound_key, 1, 0.2109375)
end

SMODS.Joker {
    key = "sarmenti",
    unlocked = false,
    unlock_condition = { type = "", extra = "", hidden = true },
    locked_loc_vars = function(self, info_queue, card)


        return { key = "joker_locked_legendary", set = "Other", vars = {} }
    end,
    discovered = false,
    blueprint_compat = false,
    rarity = 4,
    cost = 20,
    atlas = "Jokers",
    pos = { x = 8, y = 2 },
    soul_pos = { x = 3, y = 3 },
    config = { extra = { rolls = 0 } },
    calculate = function(self, card, context)
        local four_kind = context.poker_hands
            and context.poker_hands["Four of a Kind"]

        if context.before
            and four_kind and next(four_kind)
            and not context.blueprint
            and G.jokers and G.jokers.cards then
            local sarmenti_index
            for i, joker in ipairs(G.jokers.cards) do
                if joker == card then
                    sarmenti_index = i
                    break
                end
            end

            if not sarmenti_index or sarmenti_index >= #G.jokers.cards then return end

            card.ability.extra.rolls = (tonumber(card.ability.extra.rolls) or 0) + 1
            local roll_id = card.ability.extra.rolls
            local changed = 0

            for i = sarmenti_index + 1, #G.jokers.cards do
                local target = G.jokers.cards[i]
                local edition = SMODS.poll_edition({
                    key = "hnds_sarmenti_" .. tostring(roll_id) .. "_" .. tostring(i),
                    guaranteed = true,
                })

                if edition then


                    target:set_edition(edition, true)
                    target:juice_up()
                    changed = changed + 1
                end
            end

            if changed > 0 then
                play_sarmenti_sound()
                return { message = "Randomized!", colour = G.C.DARK_EDITION }
            end
        end
    end,
    attributes = { "hand_type", "editions", "modify_card" }
}
