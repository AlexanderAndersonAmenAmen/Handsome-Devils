


HNDS = HNDS or {}

HNDS.DEVIL_BOSSES = {}


HNDS.DEVIL_BOSS_POOL = {


    "bl_hook_the_house",
    "bl_hook_the_wall",
    "bl_hook_the_wheel",

    "bl_hook_the_club",
    "bl_hook_the_fish",

    "bl_hook_the_psychic",
    "bl_hook_the_goad",
    "bl_hook_the_window",

    "bl_hook_the_manacle",

    "bl_hook_the_eye",
    "bl_hook_the_mouth",

    "bl_hook_the_plant",
    "bl_hook_the_serpent",

    "bl_hook_the_pillar",

    "bl_hook_the_needle",

    "bl_hook_the_head",

    "bl_hook_the_mark",

    "bl_hook_the_flint",

    "bl_hook_the_water",

}


local card_debuffers = {


    bl_hook_the_plant = true,
    bl_hook_the_club = true,
    bl_hook_the_goad = true,
    bl_hook_the_window = true,
    bl_hook_the_head = true,
    bl_hook_the_mark = true,
    bl_hook_the_psychic = true,
    bl_hook_the_pillar = true,


}


local card_flippers = {
    bl_hook_the_house = true,
    bl_hook_the_wheel = true,
    bl_hook_the_fish = true,
    bl_hook_the_mark = true,
}


local forbidden = {


    {
        "bl_hook_the_plant",
        "bl_hook_the_mark"
    },


    {
        "bl_hook_the_needle",
        "bl_hook_the_wall"
    },


    {
        "bl_hook_the_needle",
        "bl_hook_the_water"
    },


    {
        "bl_hook_the_eye",
        "bl_hook_the_mouth"
    },


}


local function contains(tbl, value)

    for _,v in ipairs(tbl) do

        if v == value then
            return true
        end

    end

    return false

end


local function invalid_combo(result, candidate)


    local test = {}

    for _,v in ipairs(result) do
        test[#test+1] = v
    end


    test[#test+1] = candidate


    local debuffs = 0


    for _,v in ipairs(test) do

        if card_debuffers[v] then

            debuffs = debuffs + 1

        end

    end


    if debuffs > 1 then

        return true

    end


    local flippers = 0

    for _,v in ipairs(test) do
        if card_flippers[v] then
            flippers = flippers + 1
        end
    end

    if flippers > 1 then
        return true
    end


    for _,pair in ipairs(forbidden) do


        if contains(test,pair[1])
        and contains(test,pair[2])
        then

            return true

        end


    end


    return false

end


HNDS.devil_combo_invalid = invalid_combo
HNDS.DEVIL_CARD_DEBUFFERS = card_debuffers
HNDS.DEVIL_CARD_FLIPPERS = card_flippers


HNDS.DEVIL_BOSSES.bl_hook_the_hook = {
    loc_name = "The Hook",

    calculate = function(self, blind, context)
        if not context.press_play then return end
        G.E_MANAGER:add_event(Event({ func = function()
            local available = {}
            for _, card in ipairs((G.hand and G.hand.cards) or {}) do
                available[#available + 1] = card
            end
            local selected = false
            for _ = 1, math.min(2, #available) do
                local card, index = pseudorandom_element(available, pseudoseed("hnds_platinum_hook"))
                if not card then break end
                G.hand:add_to_highlighted(card, true)
                table.remove(available, index)
                selected = true
                play_sound("card1", 1)
            end
            if selected then G.FUNCS.discard_cards_from_highlighted(nil, true) end
            return true
        end }))
        blind.triggered = true
        delay(0.7)
    end,
}


HNDS.DEVIL_BOSSES.bl_hook_the_ox = {
    loc_name = "The Ox",

    calculate = function(self, blind, context)
        if context.debuff_hand
            and context.scoring_name == G.GAME.current_round.most_played_poker_hand
        then
            blind.triggered = true
            if not context.check then
                ease_dollars(-G.GAME.dollars, true)
                blind:wiggle()
            end
        end
    end,
}


HNDS.DEVIL_BOSSES.bl_hook_the_arm = {
    loc_name = "The Arm",

    calculate = function(self, blind, context)
        local hand = context.debuff_hand and context.scoring_name
        if hand and G.GAME.hands[hand] and G.GAME.hands[hand].level > 1 then
            blind.triggered = true
            if not context.check then
                level_up_hand(blind.children.animatedSprite, hand, nil, -1)
                blind:wiggle()
            end
        end
    end,
}


HNDS.DEVIL_BOSSES.bl_hook_the_house = {


    loc_name = "The House",


    set_blind = function(self)

        self.active = true

    end,


    calculate = function(self, blind, context)


        if context.blind_disabled or context.blind_defeated then


            for _,card in ipairs(G.hand.cards) do

                if card.facing == "back" then

                    card:flip()

                end

            end


            for _,card in ipairs(G.playing_cards) do

                card.ability.wheel_flipped = nil
            end


        end


        if context.stay_flipped
        and context.to_area == G.hand
        and G.GAME.current_round.hands_played == 0
        and G.GAME.current_round.discards_used == 0
        then


            return {

                stay_flipped = true

            }


        end


    end


}


HNDS.DEVIL_BOSSES.bl_hook_the_wall = {


    loc_name = "The Wall",


    calculate = function(self, blind, context)


        if context.blind_disabled then


            G.GAME.blind.chips =
                G.GAME.blind.chips / 2


            G.GAME.blind.chip_text =
                number_format(
                    G.GAME.blind.chips
                )


        end


    end


}


HNDS.DEVIL_BOSSES.bl_hook_the_wheel = {


    loc_name = "The Wheel",


    calculate = function(self, blind, context)


        if context.stay_flipped
        and context.to_area == G.hand
        and SMODS.pseudorandom_probability(
            blind,
            "devil_wheel",
            1,
            7
        )
        then


            return {

                stay_flipped = true

            }


        end


    end


}


HNDS.DEVIL_BOSSES.bl_hook_the_club = {


    loc_name = "The Club",


    debuff = {

        suit = "Clubs"

    }


}


HNDS.DEVIL_BOSSES.bl_hook_the_fish = {

    loc_name = "The Fish",

    set_blind = function(self)
        self.prepped = false
        self.cards_to_flip = 0
    end,

    calculate = function(self, blind, context)

        if context.press_play then
            self.prepped = true
            self.cards_to_flip = 0
        end


        if context.drawing_cards and self.prepped then
            self.cards_to_flip = context.amount or 0
            self.prepped = false
        end

        if context.stay_flipped
            and context.to_area == G.hand
            and (self.cards_to_flip or 0) > 0
        then
            self.cards_to_flip = self.cards_to_flip - 1
            return { stay_flipped = true }
        end

        if context.blind_disabled or context.blind_defeated then
            self.prepped = false
            self.cards_to_flip = 0
        end
    end,
}


HNDS.DEVIL_BOSSES.bl_hook_the_psychic = {


    loc_name = "The Psychic",


    debuff = {

        h_size_ge = 5

    }


}


HNDS.DEVIL_BOSSES.bl_hook_the_goad = {


    loc_name = "The Goad",


    debuff = {


        suit = "Spades"


    }


}


HNDS.DEVIL_BOSSES.bl_hook_the_window = {


    loc_name = "The Window",


    debuff = {
        suit = "Diamonds"
    },

    calculate = function(self, blind, context)
        if context.debuff_card
        and context.debuff_card:is_suit("Diamonds")
        then
            return {
                debuff = true
            }
        end
    end


}


HNDS.DEVIL_BOSSES.bl_hook_the_manacle = {


    loc_name = "The Manacle",


    set_blind = function(self)


        if not self.handsize_penalty_applied then
            G.hand:change_size(-1)
            self.handsize_penalty_applied = true
        end
    end,

    calculate = function(self, blind, context)
        if (context.blind_disabled or context.blind_defeated)
            and self.handsize_penalty_applied
        then
            G.hand:change_size(1)
            self.handsize_penalty_applied = false
        end
    end


}


HNDS.DEVIL_BOSSES.bl_hook_the_eye = {


    loc_name = "The Eye",


    set_blind = function(self)


        self.hands = {}


        for _,hand in ipairs(G.handlist) do

            self.hands[hand] = false

        end


    end,


    calculate = function(self, blind, context)


        if context.debuff_hand then


            if self.hands[context.scoring_name] then


                return {


                    debuff = true


                }


            end


            if not context.check then


                self.hands[context.scoring_name] = true


            end


        end


    end


}


HNDS.DEVIL_BOSSES.bl_hook_the_mouth = {


    loc_name = "The Mouth",


    set_blind = function(self)

        self.only_hand = nil

    end,


    calculate = function(self, blind, context)


        if context.debuff_hand then


            if self.only_hand
            and self.only_hand ~= context.scoring_name
            then


                return {


                    debuff = true


                }


            end


            if not context.check then


                self.only_hand =
                    context.scoring_name


            end


        end


    end


}


HNDS.DEVIL_BOSSES.bl_hook_the_plant = {


    loc_name = "The Plant",


    set_blind = function(self)


        self.active = true


    end,


    calculate = function(self, blind, context)


        if context.debuff_card
        and context.debuff_card:is_face(true)
        then


            return {


                debuff = true


            }


        end


    end


}


HNDS.DEVIL_BOSSES.bl_hook_the_serpent = {


    loc_name = "The Serpent",


    calculate = function(self, blind, context)


        if context.drawing_cards
        and (
            G.GAME.current_round.hands_played ~= 0
            or
            G.GAME.current_round.discards_used ~= 0
        )
        then


            return {


                cards_to_draw = 3


            }


        end


    end


}


HNDS.DEVIL_BOSSES.bl_hook_the_pillar = {


    loc_name = "The Pillar",


    calculate = function(self, blind, context)


        if context.debuff_card
        and context.debuff_card.area ~= G.jokers
        and context.debuff_card.ability.played_this_ante
        then


            return {


                debuff = true


            }


        end


    end


}


HNDS.DEVIL_BOSSES.bl_hook_the_needle = {

    loc_name = "The Needle",

    calculate = function(self, blind, context)


        if context.setting_blind then
            local hands_left = G.GAME.current_round.hands_left
                or G.GAME.round_resets.hands
                or 1

            self.hands_sub = math.max(0, hands_left - 1)
            self.hands_restored = false

            if self.hands_sub > 0 then
                ease_hands_played(-self.hands_sub)
            end
        end

        if (context.blind_disabled or context.blind_defeated)
            and not self.hands_restored
        then
            if (self.hands_sub or 0) > 0 then
                ease_hands_played(self.hands_sub)
            end
            self.hands_restored = true
        end
    end,
}


HNDS.DEVIL_BOSSES.bl_hook_the_head = {


    loc_name = "The Head",


    debuff = {


        suit = "Hearts"


    }


}


HNDS.DEVIL_BOSSES.bl_hook_the_mark = {


    loc_name = "The Mark",


    calculate = function(self, blind, context)


        if context.stay_flipped
        and context.to_area == G.hand
        and context.other_card
        and context.other_card:is_face(true)
        then


            return {


                stay_flipped = true


            }


        end


    end


}


HNDS.DEVIL_BOSSES.bl_hook_the_flint = {


    loc_name = "The Flint",


    calculate = function(self, blind, context)


        if context.modify_hand then


            blind.triggered = true


            mult =
                mod_mult(
                    math.max(
                        math.floor(
                            mult * 0.5 + 0.5
                        ),
                        1
                    )
                )


            hand_chips =
                mod_chips(
                    math.max(
                        math.floor(
                            hand_chips * 0.5 + 0.5
                        ),
                        0
                    )
                )


            update_hand_text(

                {
                    sound = 'chips2',
                    modded = true
                },

                {
                    chips = hand_chips,
                    mult = mult
                }

            )


        end


    end


}


HNDS.DEVIL_BOSSES.bl_hook_the_water = {


    loc_name = "The Water",


    set_blind = function(self)


        self.discards_sub =
            G.GAME.current_round.discards_left


        ease_discard(
            -self.discards_sub
        )


    end,


    calculate = function(self, blind, context)


        if context.blind_disabled or context.blind_defeated then


            ease_discard(
                self.discards_sub
            )


        end


    end


}


HNDS.DEVIL_BOSSES.bl_hook_the_tooth = {
    loc_name = "The Tooth",

    calculate = function(self, blind, context)
        if context.press_play then
            local count = G.hand and G.hand.highlighted and #G.hand.highlighted or 0
            if count > 0 then
                blind.triggered = true
                ease_dollars(-count)
            end
        end
    end,
}


function HNDS.clear_devil_state()


    G.GAME.hnds_devil_bosses = nil


end


HNDS.roll_devil_bosses = function(seed_suffix, ante_override)
    local pool = {}


    for _, key in ipairs(HNDS.DEVIL_BOSS_POOL or {}) do
        if HNDS.DEVIL_BOSSES[key] then
            pool[#pool + 1] = key
        end
    end

    local result = {}
    local ante = ante_override
        or (G.GAME and G.GAME.round_resets and G.GAME.round_resets.ante)
        or 0
    local suffix = seed_suffix and ("_" .. tostring(seed_suffix)) or ""

    while #result < 3 and #pool > 0 do
        local eligible = {}

        for _, candidate in ipairs(pool) do
            if not invalid_combo(result, candidate) then
                eligible[#eligible + 1] = candidate
            end
        end

        if #eligible == 0 then
            break
        end

        local pick = pseudorandom(
            "hnds_devil_boss_" .. tostring(ante) .. suffix .. "_" .. tostring(#result + 1),
            1,
            #eligible
        )
        local chosen = eligible[pick]
        result[#result + 1] = chosen

        for i, key in ipairs(pool) do
            if key == chosen then
                table.remove(pool, i)
                break
            end
        end
    end

    return result
end


