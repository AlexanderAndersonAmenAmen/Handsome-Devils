HNDS = {}

--[[---------------------------
Config tab
--]]---------------------------
HD = SMODS.current_mod
hnds_config = SMODS.current_mod.config

SMODS.current_mod.config_tab = function()
	return {n = G.UIT.ROOT, config = {
		align = "tm",
		padding = 0.2,
		minw = 8,
		minh = 2,
		colour = G.C.BLACK,
		r = 0.1,
		hover = true,
		shadow = true,
		emboss = 0.05
	}, nodes = {
		{n = G.UIT.R, config = {padding = 0, align = "cm", minh = 0.1}, nodes = {
			{n = G.UIT.C, config = { align = "c", padding = 0, minh = 0.1}, nodes = {
                {n = G.UIT.R, config = {padding = 0, align = "cm", minh = 0}, nodes = {
                    { n = G.UIT.T, config = { text = "Enable Stone Ocean hand", scale = 0.45, colour = G.C.UI.TEXT_LIGHT }},
                }},
                {n = G.UIT.R, config = {padding = 0, align = "cm", minh = 0}, nodes = {
                    { n = G.UIT.T, config = { text = "Requires restart", scale = 0.35, colour = G.C.JOKER_GREY }},
                }}
            }},
			{n = G.UIT.C, config = { align = "cl", padding = 0.05 }, nodes = {
                create_toggle{ col = true, label = "", scale = 1, w = 0, shadow = true, ref_table = hnds_config, ref_value = "enableStoneOcean" },
            }},
		}},
        
	}}
end


--[[---------------------------
Script names
--]]---------------------------

local joker_files = {
    --You can rearrange the joker order in the collection by changing the order here
    "coffee_break",
    "pot_of_greed",
    "balloons",
    "banana_split",
    "head_of_medusa",
    "jackpot",
    "jokestone",
    "color_of_madness",
    "deep_pockets",
    "seismic_activity",
    "occultist",
    "stone_mask",
    "meme",
    "digital_circus",
    "jokes_aside"
}

local seal_files = {
    "black_seal",
    "green_seal"
}

local consumable_files = {
    "spectrals",
    "planets"
}

local pokerhands_files = {
    --"stone_ocean"
}
if hnds_config.enableStoneOcean then table.insert(pokerhands_files, "stone_ocean") end

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
    old_ret = old_game_init(self)

    old_ret.green_seal_draws = 0
    old_ret.ante_stones_scored = 0

    return old_ret
end

local set_cost_ref = Card.set_cost
function Card.set_cost(self)
    set_cost_ref(self)

    if self.config.center.key == "j_hnds_coffee_break" or self.config.center.key == "j_hnds_digital_circus" then
        self.sell_cost = 0
    end
    if self.config.center.key == "j_hnds_banana_split" then
        self.sell_cost = 10
    end
end

--[[---------------------------
Utility functions
--]]---------------------------

---Gets the number of unique suits in a provided scoring hand - code from Paperback, try it if you haven't!
function HNDS.get_unique_suits(scoring_hand, bypass_debuff, flush_calc)
  -- Set each suit's count to 0
  local suits = {}

  for k, _ in pairs(SMODS.Suits) do
    suits[k] = 0
  end

  -- First we cover all the non Wild Cards in the hand
  for _, card in ipairs(scoring_hand) do
    if not SMODS.has_any_suit(card) then
      for suit, count in pairs(suits) do
        if card:is_suit(suit, bypass_debuff, flush_calc) and count == 0 then
          suits[suit] = count + 1
          break
        end
      end
    end
  end

  -- Then we cover Wild Cards, filling the missing suits
  for _, card in ipairs(scoring_hand) do
    if SMODS.has_any_suit(card) then
      for suit, count in pairs(suits) do
        if card:is_suit(suit, bypass_debuff, flush_calc) and count == 0 then
          suits[suit] = count + 1
          break
        end
      end
    end
  end

  -- Count the amount of suits that were found
  local num_suits = 0

  for _, v in pairs(suits) do
    if v > 0 then num_suits = num_suits + 1 end
  end

  return num_suits
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

for i = 1, #pokerhands_files do
    if pokerhands_files[i] then assert(SMODS.load_file('poker_hands/'.. pokerhands_files[i] ..'.lua'))() end
end
