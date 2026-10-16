SMODS.Joker({
    key = "miner_joker",
    atlas = "Jokers",
    pos = { x = 3, y = 0 },
    rarity = 2,
    cost = 6,
    unlocked = true,
    discovered = false,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.m_stone
    end,
    in_pool = function(self)
        for _, card in ipairs(G.playing_cards or {}) do
            if SMODS.has_enhancement(card, "m_stone") then return true end
        end
        return false
    end,
    calculate = function(self, card, context)
        local target = context.destroy_card
        if target and (context.cardarea == G.play or context.cardarea == "unscored")
            and SMODS.has_enhancement(target, "m_stone") then
            if #G.jokers.cards + (G.GAME.joker_buffer or 0) < G.jokers.config.card_limit then
                local edition = SMODS.poll_edition({
                    key = "hnds_miner_edition", guaranteed = true,
                    options = { "e_foil", "e_holo", "e_polychrome", "e_negative" },
                })
                local reservation = edition == "e_negative" and 0 or 1
                G.GAME.joker_buffer = (G.GAME.joker_buffer or 0) + reservation
                G.E_MANAGER:add_event(Event({
                    func = function()
                        local key = SMODS.poll_object({
                            type = "Joker", append = "hnds_miner", seed = "hnds_miner_joker",
                            filter = function(pool)
                                local eligible = {}
                                for _, entry in ipairs(pool) do
                                    local candidate = type(entry) == "table" and entry.key or entry
                                    local center = G.P_CENTERS[candidate]
                                    if center and candidate ~= "j_cavendish"
                                        and center.rarity ~= 4 and center.rarity ~= "Legendary" then
                                        eligible[#eligible + 1] = entry
                                    end
                                end
                                if #eligible == 0 then eligible[1] = { key = "j_joker", type = "Joker" } end
                                return eligible
                            end,
                        })
                        SMODS.add_card({ set = "Joker", key = key, area = G.jokers,
                            edition = edition, key_append = "hnds_miner" })
                        G.GAME.joker_buffer = math.max(0, (G.GAME.joker_buffer or 0) - reservation)
                        return true
                    end,
                }))
            end
            target.hnds_mined = true
            return { remove = true }
        end
    end,
    attributes = { "stone", "destroy_card", "create_joker" },
})
