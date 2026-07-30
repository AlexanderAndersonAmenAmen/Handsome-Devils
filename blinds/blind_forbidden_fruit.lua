-------------------------------------------------------------------
-- FORBIDDEN FRUIT
-- Ante 10 Showdown Boss Blind
-- Randomly debuffs 6 playing cards per Tag popped this run.
-------------------------------------------------------------------

HNDS = HNDS or {}

local MARK = "hnds_forbidden_fruit_debuff"
local CARDS_PER_TAG = 6

local function tags_popped_this_run()
    return math.max(0, math.floor((G and G.GAME and G.GAME.hnds_tags_popped) or 0))
end

local function recalc(card)
    if card and SMODS and SMODS.recalc_debuff then
        SMODS.recalc_debuff(card)
    end
end

local function clear_marks()
    if not (G and G.playing_cards) then return end
    for _, card in ipairs(G.playing_cards) do
        if card and card.ability and card.ability[MARK] then
            card.ability[MARK] = nil
            recalc(card)
        end
    end
end

local function apply_random_debuffs()
    clear_marks()
    if not (G and G.playing_cards) then return end

    local amount = math.min(#G.playing_cards, CARDS_PER_TAG * tags_popped_this_run())
    if amount <= 0 then return end

    local pool = {}
    for _, card in ipairs(G.playing_cards) do
        pool[#pool + 1] = card
    end

    local ante = G.GAME and G.GAME.round_resets and G.GAME.round_resets.ante or 0
    for i = 1, amount do
        local chosen, index = pseudorandom_element(
            pool,
            pseudoseed("hnds_forbidden_fruit_" .. tostring(ante) .. "_" .. tostring(i))
        )
        chosen = chosen or pool[1]
        if not chosen then break end
        chosen.ability = chosen.ability or {}
        chosen.ability[MARK] = true
        recalc(chosen)
        table.remove(pool, index or 1)
    end
end

SMODS.Blind {
    key = "forbidden_fruit",
    boss = { showdown = true },

    mult = 2,
    atlas_table = "ANIMATION_ATLAS",
    atlas = "ante_10_atlas",
    pos = { x = 0, y = 1 },

    boss_colour = HEX("55C565"),
    discovered = false,
    unlocked = true,

    in_pool = function(self)
        return G and G.GAME
            and G.GAME.win_ante == 10
            and G.GAME.round_resets
            and G.GAME.round_resets.ante == 10
    end,

    set_blind = function(self)
        apply_random_debuffs()
    end,

    calculate = function(self, blind, context)
        local card = context and context.debuff_card
        if card and card.ability and card.ability[MARK] then
            return { debuff = true }
        end
    end,

    disable = function(self)
        clear_marks()
    end,

    defeat = function(self)
        clear_marks()
    end,
}
