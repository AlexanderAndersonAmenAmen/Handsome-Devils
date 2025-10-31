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
        local idol_card = G.GAME.current_round.dark_idol or { rank = "Ace", suit = "Spades" }
        return { vars = { card.ability.extra.mult, localize(idol_card.rank, "ranks"),
        localize(idol_card.suit, "suits_plural"), card.ability.extra.total, colours = { G.C.SUITS[idol_card.suit] } } }
    end,
    atlas = "Jokers",
    pos = { x = 1, y = 2 },
    cost = 6,
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    calculate = function(self, card, context)
        local destroy = {}
        if context.individual and context.cardarea == G.play and not context.blueprint then
            if context.other_card:get_id() == G.GAME.current_round.dark_idol.id and
            context.other_card:is_suit(G.GAME.current_round.dark_idol.suit) then
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
        if context.destroying_card and context.destroying_card:is_suit(G.GAME.current_round.dark_idol.suit) and context.destroying_card:get_id() == G.GAME.current_round.dark_idol.id then
            return {
                remove = true
            }
        end
        if context.joker_main and card.ability.extra.total > 1 then
            return {
                xmult = card.ability.extra.total
            }
        end
    end
}

local init_ret = Game.init_game_object
function Game:init_game_object()
	local ret = init_ret(self)
	ret.current_round.dark_idol = { suit = 'Spades', rank = 'Ace' }
	return ret
end
