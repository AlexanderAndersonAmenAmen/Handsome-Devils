SMODS.Back {
    key = "crystal",
    atlas = "Extras",
    pos = { x = 1, y = 0 },
    unlocked = false,
    check_for_unlock = function(self, args)
        return HNDS.unlock_condition_met("crystal", args)
    end,
    apply = function(self, back)
        G.GAME.modifiers.hnds_double_showdown = true -- legacy/save compatibility
        G.GAME.modifiers.hnds_crystal_showdown = true
        G.GAME.modifiers.hnds_crystal_ante_8_replacement = true
    end,
    calculate = function(self, back, context)
        if context.end_of_round and context.main_eval
            and HNDS.active_blind_is_real_ante_boss and HNDS.active_blind_is_real_ante_boss()
            and G.GAME.round_resets.ante == 4 then
            G.GAME.hnds_crystal_queued = true
        end
    end,
    pools = { RedeemableBacks = true }
}

-- Pick a random hidden (soul-type) Consumeable key.
local function random_hidden_consumeable(seed)
    local options = {}
    local pool = G and G.P_CENTER_POOLS and G.P_CENTER_POOLS.Consumeables or {}
    for _, center in ipairs(type(pool) == 'table' and pool or {}) do
        if center and center.hidden and center.key then options[#options + 1] = center.key end
    end
    local chosen = #options > 0 and pseudorandom_element(options, seed) or nil
    if chosen then return chosen end
    -- Challenges/modpacks may replace or empty the Consumeables pool. Prefer a
    -- registered vanilla hidden consumable, but never hand SMODS a nil key.
    if G and G.P_CENTERS then
        if G.P_CENTERS.c_soul then return 'c_soul' end
        if G.P_CENTERS.c_black_hole then return 'c_black_hole' end
    end
    return nil
end

SMODS.Booster { --putting this in the same file for convenience
    key = "spectral_ultra",
    weight = 0.01,
    kind = "Spectral",
    cost = 25,
    pos = { x = 2, y = 2 },
    atlas = "Extras",
    config = { extra = 5, choose = 2 },
    group_key = "k_spectral_pack",
    draw_hand = true,
    loc_vars = function(self, info_queue, card)
        local cfg = (card and card.ability) or self.config
        return { vars = { cfg.extra, cfg.choose } }
    end,
    ease_background_colour = function(self)
        ease_background_colour_blind(G.STATES.SPECTRAL_PACK)
    end,
    particles = function(self)
        G.booster_pack_sparkles = Particles(1, 1, 0, 0, {
            timer = 0.015,
            scale = 0.1,
            initialize = true,
            lifespan = 3,
            speed = 0.2,
            padding = -1,
            attach = G.ROOM_ATTACH,
            colours = { G.C.WHITE, lighten(G.C.GOLD, 0.2) },
            fill = true
        })
        G.booster_pack_sparkles.fade_alpha = 1
        G.booster_pack_sparkles:fade(1, 0)
    end,
    create_card = function(self, card, i)
        if i == 1 then
            local hidden_key = random_hidden_consumeable("spe")
            if hidden_key then
                return { key = hidden_key, key_append = "spe", area = G.pack_cards, skip_materialize = true }
            end
            -- Last-resort compatibility fallback when another mod removes every
            -- hidden consumable center: generate a normal Spectral instead.
            return { set = "Spectral", area = G.pack_cards, skip_materialize = true, soulable = true, key_append = "spe" }
        else
            return {
                set = "Spectral",
                area = G.pack_cards,
                skip_materialize = true,
                soulable = true,
                key_append =
                "spe"
            }
        end
    end,
    in_pool = function(self, args)
        return hnds_config.enablePackSpawning and G.GAME.round_resets.ante >= 3
    end,
    cry_digital_hallucinations = { --cryptid digital hallucinations compat
        colour = G.C.SECONDARY_SET.Spectral,
        loc_key = "k_plus_spectral",
        create = function ()
            if pseudorandom("diha_ultraspec") < 0.2 then
                local hidden_key = random_hidden_consumeable("diha_spe")
                SMODS.add_card({
                    key = hidden_key,
                    set = hidden_key and nil or "Spectral",
                    soulable = hidden_key and nil or true,
                    key_append = "diha",
                    area = G.consumeables,
                    edition = "e_negative"
                })
            else
                SMODS.add_card({
                    set = "Spectral",
                    area = G.consumeables,
                    edition = 'e_negative',
                    key_append = "diha"
                })
            end
        end
    },
}
