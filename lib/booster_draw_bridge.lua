-- Cards revealed in Standard/playing-card booster packs are draws for Joker
-- progress, even though they enter G.pack_cards rather than G.hand.
-- Emit a single hand_drawn context per group of revealed cards. This keeps
-- Survey, False Idol, Energized, Be Not Afraid and compatible draw effects
-- in sync without pretending a booster card entered the player's hand.
HNDS = HNDS or {}

-- Keyed by CardArea, not by a global list: old pack sessions can be garbage
-- collected, and a second pack doesn't inherit the previous pack's counters.
local pack_sessions = setmetatable({}, { __mode = 'k' })

local function is_booster_playing_card(card)
    if not card or card.removed or card.REMOVED then return false end
    -- Playing cards have a playing_card ID; some other mods construct cards
    -- without it until after insertion, so also accept cards with a real base.
    if card.playing_card then return true end
    return card.base and card.base.suit and type(card.get_id) == 'function'
        and type(card.is_suit) == 'function'
end

local function flush_booster_draws(area, game)
    local session = pack_sessions[area]
    if not session then return true end
    session.scheduled = false
    local batch = session.pending
    session.pending = {}
    if not (G and G.GAME == game and G.pack_cards == area
        and SMODS and type(SMODS.calculate_context) == 'function') then
        return true
    end
    local drawn = {}
    for _, card in ipairs(batch) do
        if card and card.area == area and is_booster_playing_card(card) then
            drawn[#drawn + 1] = card
        end
    end
    if #drawn > 0 then
        SMODS.calculate_context({
            hand_drawn = drawn,
            hnds_booster_pack_drawn = true,
            hnds_booster_drawn_cards = drawn,
            cardarea = G.jokers,
        })
    end
    return true
end

function HNDS.note_booster_playing_card(card, area)
    if not (G and G.GAME and area and area == G.pack_cards
        and card and card.area == area and is_booster_playing_card(card)) then
        return
    end
    local session = pack_sessions[area]
    if not session then
        session = { seen = setmetatable({}, { __mode = 'k' }), pending = {}, scheduled = false }
        pack_sessions[area] = session
    end
    if session.seen[card] then return end
    session.seen[card] = true
    session.pending[#session.pending + 1] = card
    if session.scheduled then return end
    session.scheduled = true

    local game = G.GAME
    if G.E_MANAGER and Event then
        G.E_MANAGER:add_event(Event({
            trigger = 'after', delay = 0, blockable = false,
            func = function() return flush_booster_draws(area, game) end,
        }))
    else
        flush_booster_draws(area, game)
    end
end

function HNDS.install_booster_draw_bridge()
    if not (CardArea and type(CardArea.emplace) == 'function') then return false end
    if CardArea._hnds_booster_draw_bridge then return true end
    CardArea._hnds_booster_draw_bridge = true
    local emplace_ref = CardArea.emplace
    function CardArea:emplace(card, ...)
        local results = HNDS.pack(emplace_ref(self, card, ...))
        if G and self == G.pack_cards and HNDS.note_booster_playing_card then
            HNDS.note_booster_playing_card(card, self)
        end
        return ((table and table.unpack) or unpack)(results, 1, results.n)
    end
    return true
end

HNDS.install_booster_draw_bridge()
