SMODS.Joker{
    key = "dark_idol",
    config = {
        extra = {
            mult = 0.25,
            total = 1,
        }
    },
    rarity = 2,
    loc_vars = function(self, info_queue, card)
        local current_round = G and G.GAME and G.GAME.current_round
        local idol_card = current_round and current_round.dark_idol or { rank = "Ace", suit = "Spades" }
        local extra = card and card.ability and card.ability.extra or self.config.extra
        local suit_colour = G and G.C and G.C.SUITS and G.C.SUITS[idol_card.suit]
        return { vars = { extra.mult, localize(idol_card.rank, "ranks"),
        localize(idol_card.suit, "suits_plural"), extra.total, colours = { suit_colour } } }
    end,
    atlas = "Jokers",
    pos = { x = 1, y = 2 },
    cost = 6,
    unlocked = false,
    discovered = false,
    unlock_condition = { type = "hnds_joker_unlock", key = "dark_idol" },
    locked_loc_vars = function(self)
        return HNDS.joker_locked_loc_vars("dark_idol")
    end,
    check_for_unlock = function(self, args)
        return HNDS.joker_unlock_condition_met("dark_idol", args)
    end,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = false, -- By default, all Scaling Jokers cant be perishable
    calculate = function(self, card, context)
        if type(context) ~= "table" or not card or not card.ability or not card.ability.extra then return end
        local current_round = G and G.GAME and G.GAME.current_round
        local idol = current_round and current_round.dark_idol
        if not idol then return end
        local other = context.other_card
        if context.individual and G and context.cardarea == G.play and not context.blueprint
            and other and type(other.get_id) == "function" and type(other.is_suit) == "function" then
            if other:get_id() == idol.id and
            other:is_suit(idol.suit) then
                SMODS.scale_card(card, {
                    ref_table = card.ability.extra,
                    ref_value = "total",
                    scalar_value = "mult",
                    message = {
                        message_key = "a_xmult"
                    }
                })
                return nil, true
            end
        end
        local destroying = context.destroying_card
        if destroying and type(destroying.is_suit) == "function" and type(destroying.get_id) == "function"
            and destroying:is_suit(idol.suit) and destroying:get_id() == idol.id then
            return {
                remove = true
            }
        end
        if context.joker_main and card.ability.extra.total > 1 then
            return {
                xmult = card.ability.extra.total
            }
        end
    end,
    joker_display_def = function(JokerDisplay)
        return {
            text = {
                {
                    border_nodes = {
                        { text = "X" },
                        { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" }
                    }
                }
            },
            reminder_text = {
                { text = "(" },
                { ref_table = "card.joker_display_values", ref_value = "rank" },
                { text = " " },
                { ref_table = "card.joker_display_values", ref_value = "suit", colour = G.C.ORANGE },
                { text = ")" }
            },
            calc_function = function(card)
                card.joker_display_values.x_mult = card.ability.extra.total
                local idol_card = (G.GAME and G.GAME.current_round and G.GAME.current_round.dark_idol) or { rank = "Ace", suit = "Spades" }
                card.joker_display_values.rank = localize(idol_card.rank, "ranks")
                card.joker_display_values.suit = localize(idol_card.suit, "suits_plural")
            end
        }
    end,
    attributes = { "scaling", "xmult", "suit", "rank" }
}

-- Dark Idol Joker: reset the randomly chosen card for the round.
-- Registered here so lib/utils.lua does not need to know about this Joker.
HNDS.on_round_reset(function()
    G.GAME.current_round.dark_idol = { suit = 'Spades', rank = 'Ace' }
    local valid_dark_idol_cards = {}
    for _, v in ipairs(G.playing_cards) do
        if not SMODS.has_no_suit(v) and not SMODS.has_no_rank(v) then -- Abstracted enhancement check for jokers being able to give cards additional enhancements
            valid_dark_idol_cards[#valid_dark_idol_cards + 1] = v
        end
    end
    if valid_dark_idol_cards[1] then
        local dark_idol_card = pseudorandom_element(valid_dark_idol_cards,
            pseudoseed('dark_idol' .. G.GAME.round_resets.ante))
        G.GAME.current_round.dark_idol.suit = dark_idol_card.base.suit
        G.GAME.current_round.dark_idol.rank = dark_idol_card.base.value
        G.GAME.current_round.dark_idol.id = dark_idol_card.base.id
    end
end)
