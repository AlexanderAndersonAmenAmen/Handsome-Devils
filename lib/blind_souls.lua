-- Blind Soul Rewards
-- gets card creation args to pass into SMODS.add_card based on the blind. used by pennywise

--old hardcoded list (UNUSED, BUT KEPT FOR USE AS REFERENCE)
HNDS.blind_souls = {
    -- The Hook:
    bl_hook = { "j_drunkard" },
    -- The Ox:
    bl_ox = { "j_matador" },
    -- The House:
    bl_house = { "j_burnt", "j_family" },
    -- The Wall:
    bl_wall = { "j_stone", "j_marble", "j_castle", "j_ancient", "j_bloodstone" },
    -- The Wheel:
    bl_wheel = { "j_8_ball", "j_bloodstone", "j_hallucination", "j_reserved_parking", "j_space", "j_business", "j_gros_michel", "j_hnds_banana_split", "j_hnds_energized", "j_hnds_jackpot", "j_hnds_ms_fortune", "j_oops" },
    -- The Arm:
    bl_arm = { "j_juggler" },
    -- The Club:
    bl_club = { "j_gluttenous_joker", "j_blackboard", "j_onyx_agate", "j_seeing_double" },
    -- The Fish:
    bl_fish = { "j_splash", "j_lucky_cat", "j_lucky_cat", "j_lucky_cat" },
    -- The Psychic:
    bl_psychic = { "j_sixth_sense", "j_seance" },
    -- The Goad:
    bl_goad = { "j_wrathful_joker", "j_blackboard", "j_arrowhead" },
    -- The Water:
    bl_water = { "j_splash", "j_splash", "j_splash", "j_burglar" },
    -- The Window:
    bl_window = { "j_greedy_joker", "j_rough_gem" },
    -- The Manacle:
    bl_manacle = { "j_burglar", "j_burglar", "j_burglar", "j_burglar", "j_burglar", "j_burglar", "j_merry_andy", "j_stuntman" },
    -- The Eye:
    bl_eye = { "j_sixth_sense", "j_obelisk" },
    -- The Mouth:
    bl_mouth = { "j_card_sharp", "Food" },
    -- The Plant:
    bl_plant = { "j_flower_pot", "j_flower_pot", "j_flower_pot", "j_flower_pot", "j_flower_pot", "j_flower_pot", "j_faceless", "j_green_joker" },
    -- The Serpent:
    bl_serpent = { "j_hnds_head_of_medusa" },
    -- The Pillar:
    bl_pillar = { "j_obelisk" },
    -- The Needle:
    bl_needle = { "j_sixth_sense", "j_dna" },
    -- The Head:
    bl_head = { "j_lusty_joker", "j_bloodstone" },
    -- The Tooth:
    bl_tooth = { "j_hnds_coffee_break" },
    -- The Flint:
    bl_flint = { "j_campfire", "j_campfire", "j_campfire", "j_hiker" },
    -- The Mark:
    bl_mark = { "j_smiley", "j_scary_face", "j_photograph", "j_pareidolia", "j_sock_and_buskin" },

    ------------------------------
    -- Final Blinds
    ------------------------------
    -- Ambar Acorn:
    bl_final_acorn = { "j_half", "j_wee", "j_wee", "j_wee", "j_wee", "j_wee", "j_wee", "j_square" },
    -- Verdent Leaf:
    bl_final_leaf = { "j_luchador", "j_diet_cola", "j_invisible", "j_invisible", "j_invisible", "j_invisible", "j_invisible", "j_invisible" },
    -- Violet Vessel:
    bl_final_vessel = { "j_four_fingers", "j_8_ball", "j_sixth_sense", "j_fortune_teller" },
    -- Crimson Heart:
    bl_final_heart = { "j_lusty_joker", "j_bloodstone", "j_bloodstone", "j_bloodstone" },
    -- Cerulean Bell:
    bl_final_bell = { "j_sixth_sense", "j_sixth_sense", "j_dna", "j_dna", "j_dna", "j_idol", "j_idol", "j_idol" },
}

--[[
if next(SMODS.find_mod("GrabBag")) then
    local gb_souls = {
        bl_hook    = "j_gb_hook",
        bl_ox      = "j_gb_ox",
        bl_house   = "j_gb_house",
        bl_wall    = "j_gb_wall",
        bl_wheel   = "j_gb_wheel",
        bl_arm     = "j_gb_arm",
        bl_club    = "j_gb_club",
        bl_fish    = "j_gb_fish",
        bl_psychic = "j_gb_psychic",
        bl_goad    = "j_gb_goad",
        bl_water   = "j_gb_water",
        bl_window  = "j_gb_window",
        bl_manacle = "j_gb_manacle",
        bl_eye     = "j_gb_eye",
        bl_mouth   = "j_gb_mouth",
        bl_plant   = "j_gb_plant",
        bl_serpent = "j_gb_serpent",
        bl_pillar  = "j_gb_pillar",
        bl_needle  = "j_gb_needle",
        bl_head    = "j_gb_head",
        bl_tooth   = "j_gb_tooth",
        bl_flint   = "j_gb_flint",
        bl_mark    = "j_gb_mark",
    }
    for blind_key, joker_key in pairs(gb_souls) do
        if HNDS.blind_souls[blind_key] then
            HNDS.blind_souls[blind_key][#HNDS.blind_souls[blind_key] + 1] = joker_key
        end
    end
end

if next(SMODS.find_mod("Entropy")) then
    for _ = 1, 4 do
        HNDS.blind_souls.bl_wheel[#HNDS.blind_souls.bl_wheel + 1] = "Dice"
    end
end
]]
-- Get a random soul joker for defeating a blind (supports custom soul definitions).
-- `blind` should be an instance of `Blind`
-- for modded, get_hnds_soul(self, seed) can be added to support this. seed should in some way be used for the internal rng
HNDS.get_blind_soul = function (blind, seed)
	local blind_obj = blind.config.blind
    local k = blind_obj.key
    if type(blind_obj.get_hnds_soul) == "function" then
        return blind_obj:get_hnds_soul(seed)
    -- GIANT FUCKING ELSEIF CHAIN
    elseif k == "bl_hook" then return { key = "j_drunkard", }
    elseif k == "bl_ox" then return { key = "j_matador" }
    elseif k == "bl_house" then return { key = pseudorandom_element({ "j_burnt", "j_family" }, seed) }
    elseif k == "bl_wall" then return { key = pseudorandom_element({ "j_stone", "j_marble", "j_castle", "j_ancient", "j_bloodstone" }, seed) }
    elseif k == "bl_wheel" then
        return {
            attributes = {"chance", "mod_chance"},
            union = true,
        }
    elseif k == "bl_arm" then return { key = "j_juggler" }
    elseif k == "bl_club" then
        return { --maybe suit ones to old?
            attributes = {"clubs"}
        }
    elseif k == "bl_fish" then
        if pseudorandom(seed) < 0.75 then
            return{key="j_lucky_cat"}
        else
            return{ key = "j_splash"}
        end
    elseif k == "bl_psychic" then return { key = pseudorandom_element({ "j_sixth_sense", "j_seance" }, seed) }
    elseif k == "bl_goad" then
        return {
            attributes = {"spades"}
        }
    elseif k == "bl_water" then
        if pseudorandom(seed)<0.75 then
            return { key = "j_splash" }
        else
            return { key = "j_burglar" }
        end
    elseif k == "bl_window" then
        return {
            attributes = {"diamonds"}
        }
    elseif k == "bl_manacle" then
        if pseudorandom(seed)<0.75 then
            return { key = "j_burglar" }
        else
            return { key = pseudorandom_element({ "j_merry_andy", "j_stuntman"}, seed.."_2" )}
        end
    elseif k == "bl_eye" then return { key = pseudorandom_element({"j_sixth_sense","j_obelisk"},seed)}
    elseif k == "bl_mouth" then
        if pseudorandom(seed)<0.5 then
            return { key = "j_card_sharp" }
        else
            return { attributes = {"food"} }
        end
    elseif k == "bl_plant" then
        if pseudorandom(seed)<0.75 then
            return { key = "j_flower_pot" }
        else
            return { key = pseudorandom_element({"j_green_joker","j_faceless"}, seed.."_2")}
        end
    elseif k == "bl_serpent" then return { key = "j_hnds_head_of_medusa" }
    elseif k == "bl_pillar" then return { key = "j_obelisk" }
    elseif k == "bl_needle" then return { key = pseudorandom_element({"j_sixth_sense","j_dna"}, seed)}
    elseif k == "bl_head" then
        return {
            attributes = {"diamonds"}
        }
    elseif k == "bl_tooth" then return { key = "j_hnds_coffee_break" }
    elseif k == "bl_flint" then
        if pseudorandom(seed)<0.75 then
            return { key = "j_campfire" }
        else
            return { key = "j_hiker" }
        end
    elseif k == "bl_mark" then
        return {
            attributes = { "face" }
        }
    elseif k == "bl_final_acorn" then
        if pseudorandom(seed)<0.75 then
            return { key = "j_wee" }
        else
            return { key = pseudorandom_element({"j_half", "j_square"}, seed.."_2")}
        end
    elseif k == "bl_final_leaf" then
        if pseudorandom(seed)<0.75 then
            return { key = "j_invisible" }
        else
            return {
                attributes = {"on_sell"},
                filter = function (pool)
                    pool["j_invisible"] = nil --praying that this works
                    return pool
                end
            }
        end
    elseif k == "bl_final_leaf" then return { key = pseudorandom_element({ "j_four_fingers", "j_8_ball", "j_sixth_sense", "j_fortune_teller" }, seed)}
    elseif k == "bl_final_heart" then
        if pseudorandom(seed)<0.75 then
            return { key = "j_bloodstone" }
        else
            return { key = "j_lusty_joker" }
        end
    elseif k == "bl_final_bell" then
        if pseudorandom(seed) < 0.75 then
            return { key = pseudorandom_element({ "j_dna", "j_idol"}, seed.."_2")}
        else
            return { key = "j_sixth_sense" }
        end
    end
	return nil
end