SMODS.Back {
    key = "crystal",
    atlas = "Extras",
    pos = { x = 1, y = 0 },
    unlocked = true,
    apply = function(self, back)
        G.GAME.modifiers.hnds_double_showdown = true
    end,
    calculate = function(self, back, context)
        if context.end_of_round and context.main_eval and G.GAME.round_resets.ante == math.floor(G.GAME.win_ante/2) and context.beat_boss then
            G.GAME.hnds_crystal_queued = true
        end
    end,
    pools = { RedeemableBacks = true }
}

SMODS.Booster { --putting this in the same file for convenience
    key = "spectral_ultra",
    weight = 0.01,
    kind = "Spectral",
    cost = 10,
    pos = { x = 2, y = 2 },
    atlas = "Extras",
    config = { extra = 5, choose = 2 },
    group_key = "k_spectral_pack",
    --no_collection = true,
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
            local options = {}
            for _, center in ipairs(G.P_CENTER_POOLS.Consumeables) do
                if center.hidden then options[#options + 1] = center.key end
            end
            return { key = pseudorandom_element(options, "spe"), key_append = "spe", area = G.pack_cards, skip_materialize = true }
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
        return hnds_config.enablePackSpawning
    end,
    cry_digital_hallucinations = { --cryptid digital hallucinations compat
        colour = G.C.SECONDARY_SET.Spectral,
        loc_key = "k_plus_spectral",
        create = function ()
            if pseudorandom("diha_ultraspec") < 0.2 then
                local options = {}
                for _, center in ipairs(G.P_CENTER_POOLS.Consumeables) do
                    if center.hidden then options[#options + 1] = center.key end
                end
                SMODS.add_card({
                    key = pseudorandom_element(options, "diha_spe"),
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
