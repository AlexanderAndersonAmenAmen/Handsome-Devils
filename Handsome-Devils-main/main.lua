SMODS.Sound({
    key = 'madnesscolor',
    path = 'madnesscolor.ogg',
})

SMODS.Atlas {
    key = 'Jokers',      --atlas key
    path = 'Jokers.png', --atlas' path in (yourMod)/assets/1x or (yourMod)/assets/2x
    px = 71,             --width of one card
    py = 95              -- height of one card
}

SMODS.Atlas {
    key = 'Consumables',      --atlas key
    path = 'THD.png', --atlas' path in (yourMod)/assets/1x or (yourMod)/assets/2x
    px = 71,             --width of one card
    py = 95              -- height of one card
}

SMODS.Atlas {
    key = 'Extras',      --atlas key
    path = 'EHD.png', --atlas' path in (yourMod)/assets/1x or (yourMod)/assets/2x
    px = 71,             --width of one card
    py = 95              -- height of one card
}

local old_game_init = Game.init_game_object
Game.init_game_object = function(self)
    local ret = old_game_init(self)

    ret.green_seal_draws = 0

    return ret
end

local seal_files = {
    "blk_seal",
    "grn_seal"
}

for i = 1, #seal_files do
    if seal_files[i] then assert(SMODS.load_file('objects/seals/'.. seal_files[i] ..'.lua'))() end
end

local consumable_files = {
    "spectrals",
}

for i = 1, #consumable_files do
    if consumable_files[i] then assert(SMODS.load_file('objects/consumables/'.. consumable_files[i] ..'.lua'))() end
end

SMODS.Joker {
    key = 'com',               --joker key
    atlas = 'Jokers',          --atlas' key
    pos = { x = 4, y = 2 },
    rarity = 2,                --rarity: 1 = Common, 2 = Uncommon, 3 = Rare, 4 = Legendary
    --soul_pos = { x = 0, y = 0 },
    cost = 6,                  --cost
    unlocked = true,           --whether it is unlocked or not
    discovered = true,         --whether or not it starts discovered
    blueprint_compat = false,  --can it be blueprinted/brainstormed/other
    eternal_compat = false,    --can it be eternal
    perishable_compat = false, --can it be perishable
    calculate = function(card, card, context)
        if context.before and context.cardarea == G.jokers and not context.blueprint and G.GAME.current_round.hands_played == 0 then
            local suits = {
                ['Hearts'] = 0,
                ['Diamonds'] = 0,
                ['Spades'] = 0,
                ['Clubs'] = 0
            }
            for i = 1, #context.scoring_hand do
                if context.scoring_hand[i].ability.name ~= 'Wild Card' then
                    if context.scoring_hand[i]:is_suit('Hearts', true) and suits["Hearts"] == 0 then
                        suits["Hearts"] = suits["Hearts"] + 1
                    elseif context.scoring_hand[i]:is_suit('Diamonds', true) and suits["Diamonds"] == 0 then
                        suits["Diamonds"] = suits["Diamonds"] + 1
                    elseif context.scoring_hand[i]:is_suit('Spades', true) and suits["Spades"] == 0 then
                        suits["Spades"] = suits["Spades"] + 1
                    elseif context.scoring_hand[i]:is_suit('Clubs', true) and suits["Clubs"] == 0 then
                        suits["Clubs"] = suits["Clubs"] + 1
                    end
                end
            end
            for i = 1, #context.scoring_hand do
                if context.scoring_hand[i].ability.name == 'Wild Card' then
                    if context.scoring_hand[i]:is_suit('Hearts') and suits["Hearts"] == 0 then
                        suits["Hearts"] = suits["Hearts"] + 1
                    elseif context.scoring_hand[i]:is_suit('Diamonds') and suits["Diamonds"] == 0 then
                        suits["Diamonds"] = suits["Diamonds"] + 1
                    elseif context.scoring_hand[i]:is_suit('Spades') and suits["Spades"] == 0 then
                        suits["Spades"] = suits["Spades"] + 1
                    elseif context.scoring_hand[i]:is_suit('Clubs') and suits["Clubs"] == 0 then
                        suits["Clubs"] = suits["Clubs"] + 1
                    end
                end
            end
            if suits["Hearts"] > 0 and
                suits["Diamonds"] > 0 and
                suits["Spades"] > 0 and
                suits["Clubs"] > 0 then
                for i, v in ipairs(context.scoring_hand) do
                    v:set_ability(G.P_CENTERS.m_wild, nil, true)
                    play_sound('hnds_madnesscolor', 1.25, 0.05)
                end
                return
                {
                    colour = G.C.GREEN,
                    card = card,
                    message = 'Madness!',
                    sound = 'madnesscolor'
                }
            end
        end
    end,
    in_pool = function(card, wawa, wawa2)
        --whether or not this card is in the pool, return true if it is, return false if its not
        return true
    end
}

SMODS.Joker {
    key = 'occ',
    atlas = 'Jokers',
    pos = { x = 3, y = 0 },
    rarity = 3,
    cost = 8,
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    eternal_compat = false,
    perishable_compat = false,
    calculate = function(card, card, context)
        if context.joker_main and context.cardarea == G.jokers and not context.blueprint and G.GAME.current_round.hands_played == 0 then
            local suits = {
                ['Hearts'] = 0,
                ['Diamonds'] = 0,
                ['Spades'] = 0,
                ['Clubs'] = 0
            }
            for i = 1, #context.scoring_hand do
                if context.scoring_hand[i].ability.name ~= 'Wild Card' then
                    if context.scoring_hand[i]:is_suit('Hearts', true) and suits["Hearts"] == 0 then
                        suits["Hearts"] = suits["Hearts"] + 1
                    elseif context.scoring_hand[i]:is_suit('Diamonds', true) and suits["Diamonds"] == 0 then
                        suits["Diamonds"] = suits["Diamonds"] + 1
                    elseif context.scoring_hand[i]:is_suit('Spades', true) and suits["Spades"] == 0 then
                        suits["Spades"] = suits["Spades"] + 1
                    elseif context.scoring_hand[i]:is_suit('Clubs', true) and suits["Clubs"] == 0 then
                        suits["Clubs"] = suits["Clubs"] + 1
                    end
                end
            end
            for i = 1, #context.scoring_hand do
                if context.scoring_hand[i].ability.name == 'Wild Card' then
                    if context.scoring_hand[i]:is_suit('Hearts') and suits["Hearts"] == 0 then
                        suits["Hearts"] = suits["Hearts"] + 1
                    elseif context.scoring_hand[i]:is_suit('Diamonds') and suits["Diamonds"] == 0 then
                        suits["Diamonds"] = suits["Diamonds"] + 1
                    elseif context.scoring_hand[i]:is_suit('Spades') and suits["Spades"] == 0 then
                        suits["Spades"] = suits["Spades"] + 1
                    elseif context.scoring_hand[i]:is_suit('Clubs') and suits["Clubs"] == 0 then
                        suits["Clubs"] = suits["Clubs"] + 1
                    end
                end
            end
            if suits["Hearts"] > 0 and
                suits["Diamonds"] > 0 and
                suits["Spades"] > 0 and
                suits["Clubs"] > 0 then
                local tag_name = pseudorandom_element({ 'tag_meteor', 'tag_charm', 'tag_ethereal' },
                    pseudoseed('occ_pool'))
                add_tag(Tag(tag_name))
                for i, v in ipairs(context.scoring_hand) do
                    play_sound('hnds_madnesscolor', 1.25, 0.05)
                end
                return
                {
                    colour = G.C.BLUE,
                    card = card,
                    message = 'Study!',
                    sound = 'madnesscolor'
                }
            end
        end
    end
}

SMODS.Joker {
    key = 'bsplit',
    atlas = 'Jokers',
    pos = { x = 0, y = 2 },
    rarity = 2,
    cost = 10,
    unlocked = true,
    discovered = true,
    blueprint_compat = false,
    eternal_compat = false,
    perishable_compat = false,
    config =
    { extra = {
        Xmult = 1.5
    }
    },
    loc_vars = function(card, info_queue, center)
        return { vars = { center.ability.extra.Xmult, G.GAME.probabilities.normal } }
    end,
    calculate = function(card, card, context)
        if context.joker_main then
            return {
                card = card,
                Xmult_mod = card.ability.extra.Xmult,
                message = 'X' .. card.ability.extra.Xmult,
                color = G.C.MULT
            }
        end

        if context.end_of_round and context.main_eval and not context.blueprint then
            if pseudorandom('banan') < G.GAME.probabilities.normal / 6 then
                if #G.jokers.cards < G.jokers.config.card_limit then
                    local _card = copy_card(card, nil, nil, nil, card.edition and card.edition.negative)
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            _card:add_to_deck()
                            G.jokers:emplace(_card)
                            return true
                        end
                    }))
                    return
                    {
                        colour = G.C.ORNAGE,
                        card = card,
                        message = 'Split!',
                    }
                else
                    return {
                        message = localize("k_no_room_ex")
                    }
                end
            end
        end
    end
}

local set_cost_ref = Card.set_cost
function Card.set_cost(self)
    if self.config.center.key == "j_hnds_coffee" or self.config.center.key == "j_hnds_digital_circus" then
        self.sell_cost = 0
        return
    end

    set_cost_ref(self)
end

SMODS.Joker {
    key = 'coffee',
    atlas = 'Jokers',
    pos = { x = 3, y = 2 },
    rarity = 1,
    cost = 5,
    unlocked = true,
    discovered = true,
    blueprint_compat = false,
    eternal_compat = false,
    perishable_compat = true,
    config =
    { extra = {
        money = 50,
        coffee_rounds = 0,
        target = 3
    }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.target, card.ability.extra.coffee_rounds, card.ability.extra.money } }
    end,
    calculate = function(self, card, context)
        if context.before then
            for _, played_card in pairs(context.full_hand) do
                card.ability.extra.money = card.ability.extra.money - 1
                SMODS.calculate_effect({
                    message = '-$1',
                    colour = G.C.RED,
                    message_card = card,
                }, played_card)
            end
        end
        if context.end_of_round and context.main_eval then
            card.ability.extra.coffee_rounds = card.ability.extra.coffee_rounds + 1
            if card.ability.extra.coffee_rounds == card.ability.extra.target then
                card.ability.extra.active = true
                local eval = function() return card.ability.extra.active end
                juice_card_until(card, eval, true)
            end
            return {
                message = card.ability.extra.active and localize('k_active_ex') or
                card.ability.extra.coffee_rounds .. '/' .. card.ability.extra.target,
                colour = G.C.FILTER
            }
        end
        if context.selling_self and card.ability.extra.active then
            return {
                dollars = card.ability.extra.money
            }
        end
    end,
    add_to_deck = function(self, card, from_debuff)
        card:set_cost()
    end
}

--Head of Medusa
SMODS.Joker {
    key = "head_of_medusa",
    config = {
        extra = {
            x_mult = 1,
            scaling = 0.2,
        }
    },
    rarity = 2,
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.x_mult, card.ability.extra.scaling } }
    end,
    atlas = "Jokers",
    pos = { x = 6, y = 0 },
    cost = 6,
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = false,
    calculate = function(self, card, context)
        if not card.debuff then
            if context.cardarea == G.jokers and context.before and not (context.individual or context.repetition) and not context.blueprint then
                local faces = {}
                for k, v in ipairs(context.scoring_hand) do
                    if v:is_face() then
                        faces[#faces + 1] = v
                        card.ability.extra.x_mult = card.ability.extra.x_mult + card.ability.extra.scaling
                        v:set_ability(G.P_CENTERS.m_stone, nil, true)
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                v:juice_up()
                                return true
                            end
                        }))
                    end
                end
                if #faces > 0 then
                    return {
                        message = localize('k_hnds_petrified'),
                        colour = G.C.GREY,
                        card = card
                    }
                end
            end

            --Scoring
            if context.joker_main and context.cardarea == G.jokers then
                return {
                    Xmult_mod = card.ability.extra.x_mult,
                    message = localize { type = 'variable', key = 'a_xmult', vars = { card.ability.extra.x_mult } },
                }
            end
        end
    end
}

--Deep Pockets
SMODS.Joker {
    key = "deep_pockets",
    config = {
        extra = {
            slots = 2,
            consumeable_mult = 8,
        }
    },
    rarity = 2,
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.slots, card.ability.extra.consumeable_mult } }
    end,
    atlas = "Jokers",
    pos = { x = 1, y = 0 },
    cost = 7,
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = false,
    calculate = function(self, card, context)
        if not card.debuff then
            if context.other_consumeable then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        context.other_consumeable:juice_up(0.5, 0.5)
                        return true
                    end
                }))
                return {
                    message = localize { type = 'variable', key = 'a_mult', vars = { card.ability.extra.consumeable_mult } },
                    mult_mod = card.ability.extra.consumeable_mult
                }
            end
        end
    end,
    add_to_deck = function(self, card, from_debuff)
        G.consumeables.config.card_limit = G.consumeables.config.card_limit + card.ability.extra.slots
    end,
    remove_from_deck = function(self, card, from_debuff)
        G.consumeables.config.card_limit = G.consumeables.config.card_limit - card.ability.extra.slots
    end,
}

--Digital Circus
SMODS.Joker {
    key = "digital_circus",
    config = {
        extra = {
            max_rounds = 3,
            current_rounds = 0,
            current_rarity = 1,
            rarity_strings = { "Common", "Uncommon", "Rare", "Legendary" }
        }
    },
    rarity = 3,
    loc_vars = function(self, info_queue, card)
        local rarity_color = { "blue", "green", "red", "legendary,E:1" }
        return {
            vars = {
                card.ability.extra.rarity_strings[card.ability.extra.current_rarity],
                card.ability.extra.current_rounds,
                card.ability.extra.max_rounds,
                colours = {
                    G.C.RARITY[card.ability.extra.current_rarity]
                }
            }
        }
    end,
    atlas = "Jokers",
    pos = { x = 2, y = 0 },
    cost = 8,
    unlocked = true,
    discovered = true,
    blueprint_compat = false,
    eternal_compat = false,
    perishable_compat = true,
    calculate = function(self, card, context)
        if not card.debuff then
            if context.selling_self and not context.blueprint then
                if #G.jokers.cards <= G.jokers.config.card_limit then
                    local rarity_vals = { 0, 0.8, 1 }
                    SMODS.add_card({
                        set = 'Joker',
                        area = G.jokers,
                        legendary = (card.ability.extra.current_rarity == 4) or nil,
                        rarity = (card.ability.extra.current_rarity ~= 4) and
                        rarity_vals[card.ability.extra.current_rarity] or nil
                    })
                else
                    card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil,
                        { message = localize('k_no_room_ex') })
                end
            end

            if context.end_of_round and context.cardarea == G.jokers then
                if card.ability.extra.current_rarity ~= 4 then
                    card.ability.extra.current_rounds = card.ability.extra.current_rounds + 1
                    if card.ability.extra.current_rounds >= card.ability.extra.max_rounds then
                        card.ability.extra.current_rarity = card.ability.extra.current_rarity + 1
                        if card.ability.extra.current_rarity ~= 4 then
                            card.ability.extra.current_rounds = 0
                        end
                    end
                    if card.ability.extra.current_rounds ~= 0 and card.ability.extra.current_rounds ~= card.ability.extra.max_rounds then
                        return {
                            message = card.ability.extra.current_rounds .. '/' .. card.ability.extra.max_rounds,
                            colour = G.C.FILTER
                        }
                    else
                        return {
                            message = card.ability.extra.rarity_strings[card.ability.extra.current_rarity] .. "!",
                            colour = G.C.RARITY[card.ability.extra.current_rarity]
                        }
                    end
                end
            end
        end
    end,
    add_to_deck = function(self, card, from_debuff)
        card:set_cost()
    end
}