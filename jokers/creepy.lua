HNDS = HNDS or {}

local FACELESS_STICKER = 'hnds_faceless'
local FACELESS_XMULT = 2

-- Stone is only a VISUAL exception for the Faceless sticker. A Faceless card
-- may still be Stone (or an Aberrant card containing Stone) and keeps all
-- Faceless mechanics; only the sticker sprite is hidden on those cards.
local function hnds_faceless_hide_sticker(card)
    if not card then return false end

    if HNDS.card_has_stone and HNDS.card_has_stone(card) then
        return true
    end

    local center = card.config and card.config.center
    if center and center.key == 'm_stone' then return true end

    local fusions = card.ability and card.ability.hnds_aberrant_fusions
    if type(fusions) == 'table' then
        for _, key in ipairs(fusions) do
            if key == 'm_stone' then return true end
        end
    end

    return false
end

function HNDS.is_faceless(card)
    return card and card.ability and card.ability[FACELESS_STICKER] == true
end

-- Faceless is a true rankless playing-card state, but it deliberately keeps
-- the card's original suit. Hook only rank-related helpers so poker-hand logic
-- cannot use the old J/Q/K rank while suit effects (Flushes, suit Jokers, etc.)
-- continue to see the card's real suit.
if SMODS and type(SMODS.has_no_rank) == 'function' and not HNDS._faceless_no_rank_hook then
    HNDS._faceless_no_rank_hook = true
    local has_no_rank_ref = SMODS.has_no_rank
    function SMODS.has_no_rank(card, ...)
        if HNDS.is_faceless(card) then return true end
        return has_no_rank_ref(card, ...)
    end
end

-- Belt-and-suspenders hooks for vanilla/mod code that asks the Card directly
-- instead of using Steamodded's no-rank helper. Suit methods are intentionally
-- left untouched so Faceless cards retain their original suit.
if Card and type(Card.get_id) == 'function' and not HNDS._faceless_get_id_hook then
    HNDS._faceless_get_id_hook = true
    local get_id_ref = Card.get_id
    function Card:get_id(...)
        if HNDS.is_faceless(self) then
            -- A stable, unique negative ID means two Faceless cards can never
            -- accidentally pair with one another or participate in straights.
            local identity = tonumber(self.playing_card or self.sort_id or self.ID) or 0
            return -1000000 - identity
        end
        return get_id_ref(self, ...)
    end
end

if Card and type(Card.get_chip_bonus) == 'function' and not HNDS._faceless_chip_bonus_hook then
    HNDS._faceless_chip_bonus_hook = true
    local get_chip_bonus_ref = Card.get_chip_bonus
    function Card:get_chip_bonus(...)
        if HNDS.is_faceless(self) then
            -- Rankless means no chips from the original rank, but Faceless cards
            -- still keep enhancement/temporary bonus chips and permanent chips
            -- (for example Bonus Card or Hiker), exactly like Stone's chip split.
            if self.debuff then return 0 end
            local ability = self.ability or {}
            return (ability.bonus or 0) + (ability.perma_bonus or 0)
        end
        return get_chip_bonus_ref(self, ...)
    end
end

if Card and type(Card.get_nominal) == 'function' and not HNDS._faceless_nominal_hook then
    HNDS._faceless_nominal_hook = true
    local get_nominal_ref = Card.get_nominal
    function Card:get_nominal(...)
        if HNDS.is_faceless(self) then return -1000 end
        return get_nominal_ref(self, ...)
    end
end

if Card and type(Card.is_face) == 'function' and not HNDS._faceless_is_face_hook then
    HNDS._faceless_is_face_hook = true
    local is_face_ref = Card.is_face
    function Card:is_face(...)
        if HNDS.is_faceless(self) then return false end
        return is_face_ref(self, ...)
    end
end

-- A Faceless playing card should describe the Faceless state in its main
-- description box instead of showing the normal rank-chip line plus a separate
-- sticker tooltip. Faceless text must come before enhancement text. Vanilla
-- Glass is special-cased after the UI is generated: its native X2 line is
-- removed and replaced with a single combined X4 line, followed by "no rank".
-- This avoids relying on Glass' localization variables, which are resolved on a
-- path that ignores temporary card/config XMult mutations.
if Card and type(Card.generate_UIBox_ability_table) == 'function' and not HNDS._faceless_ui_chip_hook then
    HNDS._faceless_ui_chip_hook = true
    local generate_ability_ui_ref = Card.generate_UIBox_ability_table

    local function hnds_has_enhancement(card, key)
        if not card then return false end
        local center = card.config and card.config.center
        if center and center.key == key then return true end

        local fusions = card.ability and card.ability.hnds_aberrant_fusions
        if type(fusions) == 'table' then
            for _, fusion_key in ipairs(fusions) do
                if fusion_key == key then return true end
            end
        end
        return false
    end

    local function hnds_localize_faceless_nodes(xmult, show_no_rank)
        local nodes = {}
        localize {
            type = 'descriptions',
            set = 'Other',
            key = show_no_rank and 'hnds_faceless_card' or 'hnds_faceless_xmult_only',
            nodes = nodes,
            vars = { xmult },
        }
        return nodes
    end

    local function hnds_prepend_nodes(dst, src)
        if not dst or not src then return end
        for i = #src, 1, -1 do
            table.insert(dst, 1, src[i])
        end
    end

    function Card:generate_UIBox_ability_table(...)
        if not HNDS.is_faceless(self) or not self.base then
            return generate_ability_ui_ref(self, ...)
        end

        local old_nominal = self.base.nominal
        local old_faceless = self.ability and self.ability[FACELESS_STICKER]
        local is_glass = hnds_has_enhancement(self, 'm_glass')
        local has_stone = hnds_has_enhancement(self, 'm_stone')

        -- Suppress only the native rank-chip line. Keep ability.bonus and
        -- perma_bonus intact so legitimate extra chips still appear in the UI.
        self.base.nominal = 0
        if self.ability then
            -- Prevent the sticker itself from adding its auxiliary tooltip/badge
            -- while the Faceless card's own ability UI is being generated.
            self.ability[FACELESS_STICKER] = nil
        end

        local ok, result = pcall(generate_ability_ui_ref, self, ...)

        self.base.nominal = old_nominal
        if self.ability then
            self.ability[FACELESS_STICKER] = old_faceless
        end

        if not ok then error(result) end

        if result and result.main and not result.hnds_faceless_main_added then
            result.hnds_faceless_main_added = true

            if is_glass then
                -- With nominal rank chips suppressed, vanilla Glass' first main
                -- description row is its own "X2 Mult" row. Remove that exact
                -- row, then prepend one combined Faceless + Glass X4 row and
                -- "no rank". The rest of Glass' text stays in its original order.
                if #result.main > 0 then
                    table.remove(result.main, 1)
                end
                hnds_prepend_nodes(
                    result.main,
                    hnds_localize_faceless_nodes(FACELESS_XMULT * 2, not has_stone)
                )
            else
                -- Enhancements without the native Glass XMult line get the
                -- normal Faceless block at the very top of the description.
                hnds_prepend_nodes(
                    result.main,
                    hnds_localize_faceless_nodes(FACELESS_XMULT, not has_stone)
                )
            end
        end
        return result
    end
end


SMODS.Sticker {
    key = 'faceless',
    atlas = 'Stickers',
    pos = { x = 4, y = 4 },
    badge_colour = (G.C and G.C.BLACK) or G.C.PURPLE,
    rate = 0,
    no_collection = true,
    default_compat = true,
    sets = { Default = true, Enhanced = true },
    always_scores = true,

    -- Deliberately omit the normal Sticker voucher shader (the shine). On Stone
    -- cards (including Aberrant + Stone), hide ONLY the sticker art; Faceless
    -- remains applied and fully functional mechanically.
    draw = function(self, card, layer)
        if hnds_faceless_hide_sticker(card) then return end
        if HNDS.draw_flat_sticker then
            HNDS.draw_flat_sticker(self, card, layer)
        end
    end,

    apply = function(self, card, val)
        SMODS.Sticker.apply(self, card, val)
        card.ability = card.ability or {}
        card.ability[FACELESS_STICKER] = val and true or nil
    end,

    calculate = function(self, card, context)
        if not card.debuff and context and context.main_scoring and context.cardarea == G.play then
            return { xmult = FACELESS_XMULT }
        end
    end,
}

SMODS.Joker({
    key = "creepy",
    atlas = "Jokers",
    pos = { x = 7, y = 3 },
    rarity = 2,
    cost = 5,
    unlocked = false,
    discovered = false,
    unlock_condition = { type = "hnds_joker_unlock", key = "creepy" },
    locked_loc_vars = function(self)
        return HNDS.joker_locked_loc_vars("creepy")
    end,
    check_for_unlock = function(self, args)
        return HNDS.joker_unlock_condition_met("creepy", args)
    end,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    config = { extra = { odds = 4 } },
    loc_vars = function(self, info_queue, card)
        if info_queue then
            info_queue[#info_queue + 1] = { set = 'Other', key = 'hnds_faceless' }
        end
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, "hnds_creepy")
        return { vars = { numerator, denominator, FACELESS_XMULT } }
    end,
    calculate = function(self, card, context)
        local target = context and context.other_card
        if not (context and context.individual and context.cardarea == G.play and target)
            or target.debuff or HNDS.is_faceless(target)
            or not (target.is_face and target:is_face())
        then
            return
        end

        if SMODS.pseudorandom_probability(card, "hnds_creepy", 1, card.ability.extra.odds, "hnds_creepy") then
            if target.add_sticker then
                -- Bypass the sticker's rate roll so a successful Creepy roll always applies.
                target:add_sticker(FACELESS_STICKER, true)
            else
                target.ability = target.ability or {}
                target.ability[FACELESS_STICKER] = true
            end

            -- The card's sticker calculation for this scoring pass may already
            -- have happened, so grant the new Faceless X2 immediately too.
            return { xmult = FACELESS_XMULT }
        end
    end,
    joker_display_def = function(JokerDisplay)
        return {
            text = {},
            extra = {
                {
                    { text = "(" },
                    { ref_table = "card.joker_display_values", ref_value = "odds" },
                    { text = ")" },
                },
            },
            calc_function = function(card)
                card.joker_display_values.odds = localize {
                    type = 'variable', key = 'jdis_odds',
                    vars = { (G.GAME and G.GAME.probabilities.normal or 1), card.ability.extra.odds },
                }
            end,
        }
    end,
    attributes = { "chance", "modify_card" },
})
