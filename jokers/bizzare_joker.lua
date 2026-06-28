function bizzare_suit()
    local ancient_suits = {}
    for _, v in ipairs({'Spades', 'Hearts', 'Clubs', 'Diamonds'}) do
        if v ~= G.GAME.hnds_bizzare_suit then
            ancient_suits[#ancient_suits + 1] = v
        end
    end
    local ancient_card = pseudorandom_element(ancient_suits, pseudoseed("this_is_so_bizzare"))
    G.GAME.hnds_bizzare_suit = ancient_card
end

SMODS.Joker({
    key = "bizzare_joker",
    unlocked = false,
    discovered = false,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = false, -- By default, all Scaling Jokers cant be perishable
    config = { extra = { chips = 0, chipsg = 5, mult = 0, multg = 1, xmult = 1, xmultg = 0.05, sell_value = 1 } },
    unlock_condition = { type = 'modify_deck' },
    loc_vars = function(self, info_queue, card)
        local cae = card.ability.extra
        local in_collection = card.area and card.area.config and card.area.config.collection
        if in_collection then
            return { key = self.key, vars = {} }
        end
        local suit = string.lower(G.GAME.hnds_bizzare_suit or "spades")
        return {
            key = self.key .. "_" .. suit,
            vars = { cae.chips, cae.chipsg, cae.mult, cae.multg, cae.xmult, cae.xmultg, cae.sell_value },
        }
    end,
    check_for_unlock = function(self, args)
		if args.type == 'modify_deck' then
			if not (G.GAME and G.GAME.blind and G.GAME.blind.in_blind) then return false end
			local cards = G.playing_cards or {}
			if #cards < 5 then return false end
			local suit = nil
			for _, v in ipairs(cards) do
				if v and v.base and v.base.suit then
					if not suit then
						suit = v.base.suit
					elseif suit ~= v.base.suit then
						return false
					end
				end
			end
			return suit ~= nil
		end
	end,
    rarity = 2,
    cost = 7,
    atlas = "Jokers",
    pos = { x = 7, y = 1 },
    demicoloncompat = true,
    calculate = function(self, card, context)
        local cae = card.ability.extra
        if context.before then
            local suit = G.GAME.hnds_bizzare_suit
            if suit == "Diamonds" then
                for _, v in pairs(G.play.cards) do
                    if v:is_suit(suit) then
                        card.ability.extra_value = (card.ability.extra_value or 0) + cae.sell_value
                    end
                end
                card:set_cost()
                return { message = localize("k_val_up"), colour = G.C.MONEY }
            end
            local spec = ({
                Spades  = { ref = "chips",  scalar = "chipsg",  colour = G.C.CHIPS },
                Clubs   = { ref = "mult",   scalar = "multg",   colour = G.C.RED },
                Hearts  = { ref = "xmult",  scalar = "xmultg",  colour = G.C.MULT },
            })[suit]
            if spec then
                for _, v in pairs(G.play.cards) do
                    if v:is_suit(suit) then
                        SMODS.scale_card(card, {
                            ref_table = cae,
                            ref_value = spec.ref,
                            scalar_value = spec.scalar,
                            message = { colour = spec.colour },
                        })
                    end
                end
            end
        end

        if context.joker_main then
            return { chips = cae.chips, mult = cae.mult, extra = { xmult = cae.xmult } }
        end
    end,
    joker_display_def = function(JokerDisplay)
        return {
            text = {
                { text = "+", colour = G.C.CHIPS },
                { ref_table = "card.joker_display_values", ref_value = "chips", colour = G.C.CHIPS },
                { text = " +", colour = G.C.MULT },
                { ref_table = "card.joker_display_values", ref_value = "mult", colour = G.C.MULT },
                { text = "  " },
                {
                    border_nodes = {
                        { text = "X" },
                        { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" }
                    }
                }
            },
            reminder_text = {
                { text = "(" },
                { ref_table = "card.joker_display_values", ref_value = "suit", ref_colour = "suit_colour" },
                { text = ")" }
            },
            calc_function = function(card)
                card.joker_display_values.chips = card.ability.extra.chips
                card.joker_display_values.mult = card.ability.extra.mult
                card.joker_display_values.x_mult = card.ability.extra.xmult
                local suit = G.GAME.hnds_bizzare_suit or "Spades"
                card.joker_display_values.suit = localize(suit, 'suits_plural')
                card.joker_display_values.suit_colour = G.C.SUITS[suit:upper()] or G.C.ORANGE
            end
        }
    end,
    attributes = { "suit", "chips", "mult", "xmult", "economy" }
})
