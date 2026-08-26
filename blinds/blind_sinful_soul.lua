


HNDS = HNDS or {}

local SELL_VALUE_STEP = 1
local SIZE_PER_STEP = 0.2

local function total_joker_sell_value()
    local total = 0
    for _, joker in ipairs((G and G.jokers and G.jokers.cards) or {}) do
        total = total + math.max(0, tonumber(joker and joker.sell_cost) or 0)
    end
    return total
end

local function restore_blind_size()
    if not (G and G.GAME) then return end
    local blind = G.GAME.blind
    if blind and blind.hnds_sinful_soul_base_chips ~= nil then
        blind.chips = blind.hnds_sinful_soul_base_chips
        blind.chip_text = number_format(blind.chips)
        blind.hnds_sinful_soul_base_chips = nil
        blind.hnds_sinful_soul_sell_value = nil
        blind.hnds_sinful_soul_steps = nil
    end
    G.GAME.hnds_sinful_soul_active = nil
end

function HNDS.clear_sinful_soul()
    restore_blind_size()
end

local function apply_blind_size()
    if not (G and G.GAME and G.GAME.blind) then return end
    local blind = G.GAME.blind


    if blind.hnds_sinful_soul_base_chips ~= nil then
        blind.chips = blind.hnds_sinful_soul_base_chips
    end

    local base = blind.chips
    local sell_value = total_joker_sell_value()
    local steps = math.floor(sell_value / SELL_VALUE_STEP)
    local multiplier = 1 + SIZE_PER_STEP * steps

    blind.hnds_sinful_soul_base_chips = base
    blind.hnds_sinful_soul_sell_value = sell_value
    blind.hnds_sinful_soul_steps = steps
    blind.chips = base * multiplier
    blind.chip_text = number_format(blind.chips)
    G.GAME.hnds_sinful_soul_active = true
end

SMODS.Blind {
    key = "sinful_soul",
    boss = { showdown = true },

    mult = 2,
    atlas_table = "ANIMATION_ATLAS",
    atlas = "ante_10_atlas",
    pos = { x = 0, y = 3 },

    boss_colour = HEX("B26CBB"),
    discovered = false,
    unlocked = true,

    in_pool = function(self)
        return G and G.GAME
            and G.GAME.win_ante == 10
            and G.GAME.round_resets
            and G.GAME.round_resets.ante == 10
    end,

    set_blind = function(self)
        restore_blind_size()
        apply_blind_size()
    end,

    disable = function(self)
        restore_blind_size()
    end,

    defeat = function(self)
        restore_blind_size()
    end,
}
