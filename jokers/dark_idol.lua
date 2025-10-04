SMODS.Joker{
    key = "dark_idol",
    config = {
        extra = {
            mult = 0.5,
            total = 1,
        }
    },
    rarity = 2,
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult, G.GAME.current_round.dark_idol.rank,
        localize(G.GAME.current_round.dark_idol.suit, "suits_plural"), card.ability.extra.total, colours = { G.C.SUITS[G.GAME.current_round.dark_idol.suit] } } }
    end,
    atlas = "Jokers",
    pos = { x = 1, y = 2 },
    cost = 7,
    unlocked = true,
    discovered = true,
    blueprint_comat = true,
    calculate = function(self, card, context)
        local destroy = {}
        if context.individual and context.cardarea == G.play and not context.blueprint then
            if context.other_card:get_id() == G.GAME.current_round.dark_idol.id and
            context.other_card:is_suit(G.GAME.current_round.dark_idol.suit) then
                card.ability.extra.total = card.ability.extra.total + card.ability.extra.mult
                card_eval_status_text((context.blueprint_card or card), 'extra', nil, nil, nil, {message = localize{type = 'variable', key = 'a_xmult', vars = {card.ability.extra.total}}})
                context.other_card.mark_destroy = true
            end
        end
        if context.destroying_card and context.destroying_card.mark_destroy then
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
