-- Blind Soul Rewards
-- Maps blind keys to arrays of joker rewards. When a blind is defeated,
-- a random joker from its pool is offered as a "soul" reward.
-- Duplicate entries increase the weight of that joker in the pool.
-- String entries matching a P_CENTER_POOLS key (e.g. "Food") pick a random
-- joker from that pool instead of a specific one.

HNDS = HNDS or {}

-------------------------------
-- Vanilla Blinds
-------------------------------
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

-------------------------------
-- GrabBag Bossblinds
-------------------------------
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

-------------------------------
-- Entropy Compatibility
-------------------------------
if next(SMODS.find_mod("Entropy")) then
    for _ = 1, 4 do
        HNDS.blind_souls.bl_wheel[#HNDS.blind_souls.bl_wheel + 1] = "Dice"
    end
end