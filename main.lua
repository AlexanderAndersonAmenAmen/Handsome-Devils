--[[---------------------------
Script names
--]]---------------------------

local joker_files = {
    --You can rearrange the joker order in the collection by changing the order here
    "banana_split",
    "coffee_break",
    "color_of_madness",
    "deep_pockets",
    "digital_circus",
    "head_of_medusa",
    "jackpot",
    "occultist",
    "pot_of_greed"
}

local seal_files = {
    "black_seal",
    "green_seal"
}

local consumable_files = {
    "spectrals",
}


--[[---------------------------
Atlases and other resources
--]]---------------------------

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


--[[---------------------------
Function hooks
--]]---------------------------

local old_game_init = Game.init_game_object
Game.init_game_object = function(self)
    local ret = old_game_init(self)

    ret.green_seal_draws = 0

    return ret
end

local set_cost_ref = Card.set_cost
function Card.set_cost(self)
    set_cost_ref(self)

    if self.config.center.key == "j_hnds_coffee_break" or self.config.center.key == "j_hnds_digital_circus" then
        self.sell_cost = 0
    end
end


--[[---------------------------
Load files
--]]---------------------------

for i = 1, #joker_files do
    if joker_files[i] then assert(SMODS.load_file('jokers/'.. joker_files[i] ..'.lua'))() end
end

for i = 1, #seal_files do
    if seal_files[i] then assert(SMODS.load_file('seals/'.. seal_files[i] ..'.lua'))() end
end

for i = 1, #consumable_files do
    if consumable_files[i] then assert(SMODS.load_file('consumables/'.. consumable_files[i] ..'.lua'))() end
end

