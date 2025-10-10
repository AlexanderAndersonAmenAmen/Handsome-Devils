SMODS.Back {
    key = "crystal",
    atlas = "Extras",
    pos = { x = 1, y = 0 },
    unlocked = true,
    apply = function(self, back)
        G.GAME.modifiers.hnds_double_showdown = true
    end,
    calculate = function(self, back, context)
        if context.end_of_round and context.main_eval and G.GAME.blind.boss and G.GAME.blind.config.blind.boss.showdown then
            G.GAME.hnds_booster_queue[#G.GAME.hnds_booster_queue+1] = "p_hnds_spectral_ultra"
        end
    end
}

SMODS.Booster { --putting this in the same file for convenience
    key = "spectral_ultra",
    weight = 0,
    kind = "Spectral",
    cost = 0,
    pos = { x = 0, y = 1 },
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
            return { key = pseudorandom_element(options), key_append = "spe", area = G.pack_cards, skip_materialize = true }
        else
            return {
                set = "Spectral",
                area = G.pack_cards,
                skip_materialize = true,
                soulable = true,
                key_append =
                "vremade_spe"
            }
        end
    end,
    in_pool = function(self, args)
        return false
    end
}

local get_new_boss_ref = get_new_boss
function get_new_boss()
    local win_ante = G.GAME.win_ante
    if G.GAME.modifiers.hnds_double_showdown then
        G.GAME.win_ante = math.floor(G.GAME.win_ante/2)
    end
    local boss = get_new_boss_ref()
    G.GAME.win_ante = win_ante
    return boss
end