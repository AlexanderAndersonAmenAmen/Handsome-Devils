local function arthur_suit(card)
    local extra = card and card.ability and card.ability.extra
    if type(extra) ~= "table" then return "Spades" end
    extra.suit = extra.suit or "Spades"
    return extra.suit
end

local function change_arthur_suit(card)
    local current = arthur_suit(card)
    local choices = HNDS.get_pollable_suit_keys and HNDS.get_pollable_suit_keys('hnds_arthur', current) or {}
    if #choices == 0 then
        for _, suit in ipairs({ 'Spades', 'Hearts', 'Clubs', 'Diamonds' }) do
            if suit ~= current then choices[#choices + 1] = suit end
        end
    end
    local seed = "hnds_arthur_suit_" .. tostring(card and card.sort_id or 0)
    card.ability.extra.suit = pseudorandom_element(choices, pseudoseed(seed)) or "Spades"
end

local function add_free_rerolls(amount)
    if not (G and G.GAME and G.GAME.current_round) then return end
    local current_round = G.GAME.current_round
    current_round.free_rerolls = math.max(0, (tonumber(current_round.free_rerolls) or 0) + amount)
    if calculate_reroll_cost then calculate_reroll_cost(true) end
end

SMODS.Joker {
    key = "arthur",
    unlocked = false,
    unlock_condition = { type = "", extra = "", hidden = true },
    locked_loc_vars = function(self, info_queue, card)
        return { key = "joker_locked_legendary", set = "Other", vars = {} }
    end,
    discovered = false,
    blueprint_compat = true,
    demicoloncompat = true,
    rarity = 4,
    cost = 20,
    atlas = "Jokers",
    pos = { x = 9, y = 2 },
    soul_pos = { x = 4, y = 3 },
    config = { extra = { rerolls = 1, suit = "Spades" } },

    loc_vars = function(self, info_queue, card)
        local extra = card and card.ability and card.ability.extra or self.config.extra
        local suit = (extra and extra.suit) or "Spades"
        local free_rerolls = G and G.GAME and G.GAME.current_round
            and (tonumber(G.GAME.current_round.free_rerolls) or 0)
            or 0
        local suit_colour = G and G.C and G.C.SUITS and (G.C.SUITS[suit] or G.C.SUITS[suit:upper()])
            or (G and G.C and G.C.ORANGE)
        return {
            vars = {
                free_rerolls,
                (extra and extra.rerolls) or 1,
                localize(suit, "suits_singular"),
                colours = { suit_colour },
            },
        }
    end,

    calculate = function(self, card, context)
        local extra = card.ability.extra

        if context.destroying_card
            and context.destroying_card:is_suit(arthur_suit(card))
            and not SMODS.is_eternal(context.destroying_card, card)
        then
            add_free_rerolls(tonumber(extra.rerolls) or 1)
            return {
                remove = true,
                message = localize("k_hnds_free_reroll"),
                colour = G.C.GREEN,
            }
        end

        if context.after and not context.blueprint then
            change_arthur_suit(card)
            return {
                message = localize("k_hnds_arthurs_suit"),
                colour = G.C.SUITS[arthur_suit(card)] or G.C.ORANGE,
            }
        end
    end,

    joker_display_def = function(JokerDisplay)
        return {
            reminder_text = {
                { text = "(" },
                { ref_table = "card.joker_display_values", ref_value = "suit", ref_colour = "suit_colour" },
                { text = ")" },
            },
            calc_function = function(card)
                local suit = arthur_suit(card)
                card.joker_display_values.suit = localize(suit, "suits_plural")
                card.joker_display_values.suit_colour = G.C.SUITS[suit] or G.C.ORANGE
            end,
        }
    end,

    attributes = { "destroy_card", "suit", "economy" },
}
