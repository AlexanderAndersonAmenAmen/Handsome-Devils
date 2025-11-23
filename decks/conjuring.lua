SMODS.Back({
    name = "Conjuring Deck",
    key = "conjuring",
    order = 18,
    unlocked = true,
    discovered = true,
    pos = { x = 0, y = 2 },
    atlas = "Extras",
    apply = function(self,card)
        for _, booster in pairs(G.P_CENTER_POOLS.Booster) do
            if booster.kind ~= "hnds_magic" then
                G.GAME.banned_keys[booster.key] = true
            end
        end
    end,
    pools = { RedeemableBacks = true }
})

local magic_diha_compat = { --cryptid digital hallucinations compat
    colour = G.C.FILTER,
    loc_key = "k_plus_q",
    create = function ()
        local pool = pseudorandom_element({"Joker", "Playing Card", "Consumeables"})
        local area
        if pool == "Consumeables" then area = G.consumeables end
        SMODS.add_card({
            set = pool,
            area = area,
            edition = "e_negative",
            key_append = "diha"
        })
    end
}

SMODS.Booster {
    key = "magic_1",
    weight = 0.1,
    kind = "hnds_magic",
    cost = 10,
    atlas = "Extras",
    pos = { x = 4, y = 0 },
    config = { extra = 5, choose = 2 },
    draw_hand = true,
    group_key = "k_hnds_magic_pack",
    loc_vars = function (self, info_queue, card)
        local cfg = (card and card.ability) or self.config or {}
        return {
            vars = { cfg.extra, cfg.choose },
            key = self.key:sub(1, -3) --gets rid of the number at the end for the description key
        }
    end,
    ease_background_colour = function (self) --colours in the pack, subject to change probably
        ease_colour(G.C.DYN_UI.MAIN, G.C.DARK_EDITION)
        ease_background_colour({ new_colour = G.C.FILTER, special_colour = G.C.BLACK, contrast = 2 })
    end,
    particles = function (self)
        G.booster_pack_sparkles = Particles(1, 1, 0, 0, { --this is just arcana pack particle code, feel free to change some values
            timer = 0.015,
            scale = 0.2,
            initialize = true,
            lifespan = 1,
            speed = 1.1,
            padding = -1,
            attach = G.ROOM_ATTACH,
            colours = { G.C.BLACK, G.C.RED, G.C.SECONDARY_SET.Joker, G.C.SECONDARY_SET.Planet, G.C.SECONDARY_SET.Tarot, G.C.SECONDARY_SET.Spectral }, --im just messing around with colours tbh
            fill = true
        })
        G.booster_pack_sparkles.fade_alpha = 1
        G.booster_pack_sparkles:fade(1, 0)
    end,
    create_card = function (self, card, i)
        local pool = pseudorandom_element({"Joker", "Playing Card", "Consumeables"}, "hnds_magic_set")
        return {
            set = pool,
            area = G.pack_cards,
            skip_materialize = true,
            soulable = true,
            key_append = "hnds_magic_card",
            seal = pool == "Playing Card" and SMODS.poll_seal({ key = "magic_seal" }),
            edition = pool == "Playing Card" and SMODS.poll_edition({ key = "magic_edition" })
        }
    end,
    cry_digital_hallucinations = magic_diha_compat,
    in_pool = function (self, args)
        return G.GAME.selected_back and G.GAME.selected_back.effect.center.key == "b_hnds_conjuring" or hnds_config.enablePackSpawning
    end
}


SMODS.Booster {
    key = "magic_2",
    weight = 0.1,
    kind = "hnds_magic",
    cost = 10,
    atlas = "Extras",
    pos = { x = 5, y = 0 },
    config = { extra = 5, choose = 2 },
    draw_hand = true,
    group_key = "k_hnds_magic_pack",
    loc_vars = function (self, info_queue, card)
        local cfg = (card and card.ability) or self.config or {}
        return {
            vars = { cfg.extra, cfg.choose },
            key = self.key:sub(1, -3) --gets rid of the number at the end for the description key
        }
    end,
    ease_background_colour = function (self) --colours in the pack, subject to change probably
        ease_colour(G.C.DYN_UI.MAIN, G.C.DARK_EDITION)
        ease_background_colour({ new_colour = G.C.FILTER, special_colour = G.C.BLACK, contrast = 2 })
    end,
    particles = function (self)
        G.booster_pack_sparkles = Particles(1, 1, 0, 0, { --this is just arcana pack particle code, feel free to change some values
            timer = 0.015,
            scale = 0.2,
            initialize = true,
            lifespan = 1,
            speed = 1.1,
            padding = -1,
            attach = G.ROOM_ATTACH,
            colours = { G.C.BLACK, G.C.RED, G.C.SECONDARY_SET.Joker, G.C.SECONDARY_SET.Planet, G.C.SECONDARY_SET.Tarot, G.C.SECONDARY_SET.Spectral }, --im just messing around with colours tbh
            fill = true
        })
        G.booster_pack_sparkles.fade_alpha = 1
        G.booster_pack_sparkles:fade(1, 0)
    end,
    create_card = function (self, card, i)
        local pool = pseudorandom_element({"Joker", "Playing Card", "Consumeables"}, "hnds_magic_set")
        return {
            set = pool,
            area = G.pack_cards,
            skip_materialize = true,
            soulable = true,
            key_append = "hnds_magic_card",
            seal = pool == "Playing Card" and SMODS.poll_seal({ key = "magic_seal" }),
            edition = pool == "Playing Card" and SMODS.poll_edition({ key = "magic_edition" })
        }
    end,
    cry_digital_hallucinations = magic_diha_compat,
    in_pool = function (self, args)
        return G.GAME.selected_back and G.GAME.selected_back.effect.center.key == "b_hnds_conjuring" or hnds_config.enablePackSpawning
    end
}


SMODS.Booster {
    key = "magic_3",
    weight = 0.1,
    kind = "hnds_magic",
    cost = 10,
    atlas = "Extras",
    pos = { x = 4, y = 1 },
    config = { extra = 5, choose = 2 },
    draw_hand = true,
    group_key = "k_hnds_magic_pack",
    loc_vars = function (self, info_queue, card)
        local cfg = (card and card.ability) or self.config or {}
        return {
            vars = { cfg.extra, cfg.choose },
            key = self.key:sub(1, -3) --gets rid of the number at the end for the description key
        }
    end,
    ease_background_colour = function (self) --colours in the pack, subject to change probably
        ease_colour(G.C.DYN_UI.MAIN, G.C.DARK_EDITION)
        ease_background_colour({ new_colour = G.C.FILTER, special_colour = G.C.BLACK, contrast = 2 })
    end,
    particles = function (self)
        G.booster_pack_sparkles = Particles(1, 1, 0, 0, { --this is just arcana pack particle code, feel free to change some values
            timer = 0.015,
            scale = 0.2,
            initialize = true,
            lifespan = 1,
            speed = 1.1,
            padding = -1,
            attach = G.ROOM_ATTACH,
            colours = { G.C.BLACK, G.C.RED, G.C.SECONDARY_SET.Joker, G.C.SECONDARY_SET.Planet, G.C.SECONDARY_SET.Tarot, G.C.SECONDARY_SET.Spectral }, --im just messing around with colours tbh
            fill = true
        })
        G.booster_pack_sparkles.fade_alpha = 1
        G.booster_pack_sparkles:fade(1, 0)
    end,
    create_card = function (self, card, i)
        local pool = pseudorandom_element({"Joker", "Playing Card", "Consumeables"}, "hnds_magic_set")
        return {
            set = pool,
            area = G.pack_cards,
            skip_materialize = true,
            soulable = true,
            key_append = "hnds_magic_card",
            seal = pool == "Playing Card" and SMODS.poll_seal({ key = "magic_seal" }),
            edition = pool == "Playing Card" and SMODS.poll_edition({ key = "magic_edition" })
        }
    end,
    cry_digital_hallucinations = magic_diha_compat,
    in_pool = function (self, args)
        return G.GAME.selected_back and G.GAME.selected_back.effect.center.key == "b_hnds_conjuring" or hnds_config.enablePackSpawning
    end
}


SMODS.Booster {
    key = "magic_4",
    weight = 0.1,
    kind = "hnds_magic",
    cost = 10,
    atlas = "Extras",
    pos = { x = 5, y = 1 },
    config = { extra = 5, choose = 2 },
    draw_hand = true,
    group_key = "k_hnds_magic_pack",
    loc_vars = function (self, info_queue, card)
        local cfg = (card and card.ability) or self.config or {}
        return {
            vars = { cfg.extra, cfg.choose },
            key = self.key:sub(1, -3) --gets rid of the number at the end for the description key
        }
    end,
    ease_background_colour = function (self) --colours in the pack, subject to change probably
        ease_colour(G.C.DYN_UI.MAIN, G.C.DARK_EDITION)
        ease_background_colour({ new_colour = G.C.FILTER, special_colour = G.C.BLACK, contrast = 2 })
    end,
    particles = function (self)
        G.booster_pack_sparkles = Particles(1, 1, 0, 0, { --this is just arcana pack particle code, feel free to change some values
            timer = 0.015,
            scale = 0.2,
            initialize = true,
            lifespan = 1,
            speed = 1.1,
            padding = -1,
            attach = G.ROOM_ATTACH,
            colours = { G.C.BLACK, G.C.RED, G.C.SECONDARY_SET.Joker, G.C.SECONDARY_SET.Planet, G.C.SECONDARY_SET.Tarot, G.C.SECONDARY_SET.Spectral }, --im just messing around with colours tbh
            fill = true
        })
        G.booster_pack_sparkles.fade_alpha = 1
        G.booster_pack_sparkles:fade(1, 0)
    end,
    create_card = function (self, card, i)
        local pool = pseudorandom_element({"Joker", "Playing Card", "Consumeables"}, "hnds_magic_set")
        return {
            set = pool,
            area = G.pack_cards,
            skip_materialize = true,
            soulable = true,
            key_append = "hnds_magic_card",
            seal = pool == "Playing Card" and SMODS.poll_seal({ key = "magic_seal" }),
            edition = pool == "Playing Card" and SMODS.poll_edition({ key = "magic_edition" })
        }
    end,
    cry_digital_hallucinations = magic_diha_compat,
    in_pool = function (self, args)
        return G.GAME.selected_back and G.GAME.selected_back.effect.center.key == "b_hnds_conjuring" or hnds_config.enablePackSpawning
    end
}


SMODS.Booster {
    key = "magic_5",
    weight = 0.1,
    kind = "hnds_magic",
    cost = 10,
    atlas = "Extras",
    pos = { x = 4, y = 2 },
    config = { extra = 5, choose = 2 },
    draw_hand = true,
    group_key = "k_hnds_magic_pack",
    loc_vars = function (self, info_queue, card)
        local cfg = (card and card.ability) or self.config or {}
        return {
            vars = { cfg.extra, cfg.choose },
            key = self.key:sub(1, -3) --gets rid of the number at the end for the description key
        }
    end,
    ease_background_colour = function (self) --colours in the pack, subject to change probably
        ease_colour(G.C.DYN_UI.MAIN, G.C.DARK_EDITION)
        ease_background_colour({ new_colour = G.C.FILTER, special_colour = G.C.BLACK, contrast = 2 })
    end,
    particles = function (self)
        G.booster_pack_sparkles = Particles(1, 1, 0, 0, { --this is just arcana pack particle code, feel free to change some values
            timer = 0.015,
            scale = 0.2,
            initialize = true,
            lifespan = 1,
            speed = 1.1,
            padding = -1,
            attach = G.ROOM_ATTACH,
            colours = { G.C.BLACK, G.C.RED, G.C.SECONDARY_SET.Joker, G.C.SECONDARY_SET.Planet, G.C.SECONDARY_SET.Tarot, G.C.SECONDARY_SET.Spectral }, --im just messing around with colours tbh
            fill = true
        })
        G.booster_pack_sparkles.fade_alpha = 1
        G.booster_pack_sparkles:fade(1, 0)
    end,
    create_card = function (self, card, i)
        local pool = pseudorandom_element({"Joker", "Playing Card", "Consumeables"}, "hnds_magic_set")
        return {
            set = pool,
            area = G.pack_cards,
            skip_materialize = true,
            soulable = true,
            key_append = "hnds_magic_card",
            seal = pool == "Playing Card" and SMODS.poll_seal({ key = "magic_seal" }),
            edition = pool == "Playing Card" and SMODS.poll_edition({ key = "magic_edition" })
        }
    end,
    cry_digital_hallucinations = magic_diha_compat,
    in_pool = function (self, args)
        return G.GAME.selected_back and G.GAME.selected_back.effect.center.key == "b_hnds_conjuring" or hnds_config.enablePackSpawning
    end
}


SMODS.Booster {
    key = "magic_6",
    weight = 0.1,
    kind = "hnds_magic",
    cost = 10,
    atlas = "Extras",
    pos = { x = 5, y = 2 },
    config = { extra = 5, choose = 2 },
    draw_hand = true,
    group_key = "k_hnds_magic_pack",
    loc_vars = function (self, info_queue, card)
        local cfg = (card and card.ability) or self.config or {}
        return {
            vars = { cfg.extra, cfg.choose },
            key = self.key:sub(1, -3) --gets rid of the number at the end for the description key
        }
    end,
    ease_background_colour = function (self) --colours in the pack, subject to change probably
        ease_colour(G.C.DYN_UI.MAIN, G.C.DARK_EDITION)
        ease_background_colour({ new_colour = G.C.FILTER, special_colour = G.C.BLACK, contrast = 2 })
    end,
    particles = function (self)
        G.booster_pack_sparkles = Particles(1, 1, 0, 0, { --this is just arcana pack particle code, feel free to change some values
            timer = 0.015,
            scale = 0.2,
            initialize = true,
            lifespan = 1,
            speed = 1.1,
            padding = -1,
            attach = G.ROOM_ATTACH,
            colours = { G.C.BLACK, G.C.RED, G.C.SECONDARY_SET.Joker, G.C.SECONDARY_SET.Planet, G.C.SECONDARY_SET.Tarot, G.C.SECONDARY_SET.Spectral }, --im just messing around with colours tbh
            fill = true
        })
        G.booster_pack_sparkles.fade_alpha = 1
        G.booster_pack_sparkles:fade(1, 0)
    end,
    create_card = function (self, card, i)
        local pool = pseudorandom_element({"Joker", "Playing Card", "Consumeables"}, "hnds_magic_set")
        return {
            set = pool,
            area = G.pack_cards,
            skip_materialize = true,
            soulable = true,
            key_append = "hnds_magic_card",
            seal = pool == "Playing Card" and SMODS.poll_seal({ key = "magic_seal" }),
            edition = pool == "Playing Card" and SMODS.poll_edition({ key = "magic_edition" })
        }
    end,
    cry_digital_hallucinations = magic_diha_compat,
    in_pool = function (self, args)
        return G.GAME.selected_back and G.GAME.selected_back.effect.center.key == "b_hnds_conjuring" or hnds_config.enablePackSpawning
    end
}