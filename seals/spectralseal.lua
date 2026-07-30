SMODS.Seal {
    key = "spectralseal",
    pos = { x = 2, y = 1 },
    atlas = "Extras",
    badge_colour = G.C.SECONDARY_SET.Spectral,
    config = { extra = { hands = 4 } },
    unlocked = true,

    loc_vars = function(self, info_queue, card)
        local tracked = card and card.ability and card.ability.hnds_spectral_hands
        local ordered_keys = {}
        local added = {}

        if type(tracked) == "table" then
            -- Show vanilla and modded hands in the same order used by Balatro's
            -- hand list, then append any unlisted custom hands alphabetically.
            for _, hand_key in ipairs((G and G.handlist) or {}) do
                if tracked[hand_key] then
                    ordered_keys[#ordered_keys + 1] = hand_key
                    added[hand_key] = true
                end
            end

            local remaining_keys = {}
            for hand_key in pairs(tracked) do
                if not added[hand_key] then
                    remaining_keys[#remaining_keys + 1] = hand_key
                end
            end
            table.sort(remaining_keys)
            for _, hand_key in ipairs(remaining_keys) do
                ordered_keys[#ordered_keys + 1] = hand_key
            end
        end

        local progress = #ordered_keys
        local remaining = math.max(0, self.config.extra.hands - progress)

        if info_queue and card then
            if progress == 0 then
                info_queue[#info_queue + 1] = {
                    set = "Other",
                    key = "hnds_spectralseal_progress_empty",
                    vars = {
                        "none",
                        progress, self.config.extra.hands,
                    },
                }
            else
                -- Use a different localization entry for each progress count so
                -- the tooltip only creates rows for poker hands that actually
                -- exist. Fixed placeholder rows render as visible blank space in
                -- Balatro's tooltip layout, so they must not be supplied at all.
                local shown = math.min(progress, self.config.extra.hands)
                local vars = {}
                for i = 1, shown do
                    vars[#vars + 1] = localize(ordered_keys[i], "poker_hands")
                end
                vars[#vars + 1] = shown
                vars[#vars + 1] = self.config.extra.hands

                info_queue[#info_queue + 1] = {
                    set = "Other",
                    key = "hnds_spectralseal_progress_" .. tostring(shown),
                    vars = vars,
                }
            end
        end

        return { vars = { self.config.extra.hands, remaining } }
    end,

    calculate = function(self, card, context)
        if not (context.main_scoring
            and context.cardarea == G.play
            and context.scoring_name
            and not context.repetition_only
            and not card.debuff)
        then
            return
        end

        card.ability.hnds_spectral_hands = card.ability.hnds_spectral_hands or {}

        -- The token prevents a retrigger or repeated calculation pass for the same
        -- played hand from being interpreted as another newly-scored hand.
        local round = G.GAME and G.GAME.current_round
        local hand_token = table.concat({
            tostring(round and round.round or 0),
            tostring(round and round.hands_played or 0),
            tostring(context.scoring_name),
        }, ":")

        local unique_hands = 0
        for _ in pairs(card.ability.hnds_spectral_hands) do
            unique_hands = unique_hands + 1
        end

        if card.ability.hnds_spectral_last_token ~= hand_token then
            card.ability.hnds_spectral_last_token = hand_token
            -- Once the four-hand set is complete, keep it stable while waiting
            -- for a consumable slot instead of accumulating extra tooltip rows.
            if unique_hands < self.config.extra.hands
                and not card.ability.hnds_spectral_hands[context.scoring_name]
            then
                card.ability.hnds_spectral_hands[context.scoring_name] = true
                unique_hands = unique_hands + 1
            end
        end

        if unique_hands < self.config.extra.hands then return end
        if not (G.consumeables and G.consumeables.cards and G.consumeables.config and G.GAME) then return end

        local buffer = G.GAME.consumeable_buffer or 0
        if #G.consumeables.cards + buffer >= G.consumeables.config.card_limit then
            -- Keep the completed set. It will create the card the next time this
            -- sealed card scores while a consumable slot is available.
            return
        end

        G.GAME.consumeable_buffer = buffer + 1
        card.ability.hnds_spectral_hands = {}

        G.E_MANAGER:add_event(Event({
            func = function()
                SMODS.add_card({
                    set = "Spectral",
                    area = G.consumeables,
                    key_append = "hnds_spectralseal",
                })
                G.GAME.consumeable_buffer = math.max(0, (G.GAME.consumeable_buffer or 1) - 1)
                return true
            end,
        }))

        return {
            message = localize("k_plus_spectral"),
            colour = G.C.SECONDARY_SET.Spectral,
        }
    end,
}
