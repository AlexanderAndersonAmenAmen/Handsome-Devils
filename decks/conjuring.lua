SMODS.Back({
    name = "Conjuring Deck",
    key = "conjuring",
    order = 18,
    unlocked = true,
    discovered = true,
    config = { voucher = 'v_hnds_extra_filling'},
    loc_vars = function(self, info_queue, center)
       return {
            vars = { localize { type = 'name_text', key = self.config.voucher, set = 'Voucher' } }
        }
    end,
    pos = { x = 0, y = 2 },
    atlas = "Extras",
    apply = function(self, card)
    end,
    calculate = function(self, back, context)
    end
})

SMODS.Booster:take_ownership_by_kind('Arcana', {
        create_card = function(self, card, i)
            local _card
            if (G.GAME.selected_back.effect.center.key == "b_hnds_conjuring" and pseudorandom('conjured') > 0.5) then
                _card = {
                    set = pseudorandom_element({'Spectral', 'Planet', 'Joker', 'Playing Card'}, 'seed'),
                    area = G.pack_cards,
                    skip_materialize = true,
                    soulable = true,
                    key_append =
                    "ar2"
                }
            else
                _card = {
                    set = "Tarot",
                    area = G.pack_cards,
                    skip_materialize = true,
                    soulable = true,
                    key_append =
                    "ar1"
                }
            end
            return _card
        end,
    },
    true
)

SMODS.Booster:take_ownership_by_kind('Celestial', {
        create_card = function(self, card, i)
            local _card
            if (G.GAME.selected_back.effect.center.key == "b_hnds_conjuring" and pseudorandom('conjured') > 0.5) then
                _card = {
                    set = pseudorandom_element({'Spectral', 'Tarot', 'Joker', 'Playing Card'}, 'seed'),
                    area = G.pack_cards,
                    skip_materialize = true,
                    soulable = true,
                    key_append =
                    "ar2"
                }
            else
                _card = {
                    set = "Planet",
                    area = G.pack_cards,
                    skip_materialize = true,
                    soulable = true,
                    key_append =
                    "ar1"
                }
            end
            return _card
        end,
    },
    true
)

SMODS.Booster:take_ownership_by_kind('Spectral', {
        create_card = function(self, card, i)
            local _card
            if (G.GAME.selected_back.effect.center.key == "b_hnds_conjuring" and pseudorandom('conjured') > 0.5) then
                _card = {
                    set = pseudorandom_element({'Planet', 'Tarot', 'Joker', 'Playing Card'}, 'seed'),
                    area = G.pack_cards,
                    skip_materialize = true,
                    soulable = true,
                    key_append =
                    "ar2"
                }
            else
                _card = {
                    set = "Spectral",
                    area = G.pack_cards,
                    skip_materialize = true,
                    soulable = true,
                    key_append =
                    "ar1"
                }
            end
            return _card
        end,
    },
    true
)

SMODS.Booster:take_ownership_by_kind('Buffoon', {
        create_card = function(self, card, i)
            local _card
            if (G.GAME.selected_back.effect.center.key == "b_hnds_conjuring" and pseudorandom('conjured') > 0.5) then
                _card = {
                    set = pseudorandom_element({'Planet', 'Tarot', 'Spectral', 'Playing Card'}, 'seed'),
                    area = G.pack_cards,
                    skip_materialize = true,
                    soulable = true,
                    key_append =
                    "ar2"
                }
            else
                _card = {
                    set = "Joker",
                    area = G.pack_cards,
                    skip_materialize = true,
                    soulable = true,
                    key_append =
                    "ar1"
                }
            end
            return _card
        end,
    },
    true
)

SMODS.Booster:take_ownership_by_kind('Standard', {
        create_card = function(self, card, i)
            local _card
            if (G.GAME.selected_back.effect.center.key == "b_hnds_conjuring" and pseudorandom('conjured') > 0.5) then
                _card = {
                    set = pseudorandom_element({'Planet', 'Tarot', 'Spectral','Joker'}, 'seed'),
                    area = G.pack_cards,
                    skip_materialize = true,
                    soulable = true,
                    key_append =
                    "ar2"
                }
            else
                _card = {
                    set = "Playing Card",
                    area = G.pack_cards,
                    skip_materialize = true,
                    soulable = true,
                    key_append =
                    "ar1"
                }
            end
            return _card
        end,
    },
    true
)