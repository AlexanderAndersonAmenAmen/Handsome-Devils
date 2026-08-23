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
    for _, center in ipairs(G.P_CENTER_POOLS.Consumeables) do
        if center.hidden then options[#options + 1] = center.key end
    end
    return pseudorandom_element(options, seed)
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
            return { key = random_hidden_consumeable("spe"), key_append = "spe", area = G.pack_cards, skip_materialize = true }
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
                SMODS.add_card({
                    key = random_hidden_consumeable("diha_spe"),
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

-- Drain the queued Ultra Spectral Pack at the start-of-shop boundary.
-- Both the Crystal Deck and the Crystal Sleeve set hnds_crystal_queued;
-- packs spawn through the shared queued-booster helper in lib/cursed_pack.lua.
HNDS.on_context(function(context)
    if context.starting_shop and G.GAME.hnds_crystal_queued then
        HNDS.spawn_queued_booster('p_hnds_spectral_ultra')
        G.GAME.hnds_crystal_queued = nil
    end
end)
