SMODS.Seal {
    key = "green",
    badge_colour = HEX("545454"),
    atlas = "Extras",
    pos = { x = 2, y = 0 },
    discovered = true,
    config =
    { extra = {
        noc = 2
    }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.noc } }
    end,

    -- self - this seal prototype
    -- card - card this seal is applied to
    calculate = function(self, card, context)
        if (context.main_scoring or context.discard) and context.cardarea == G.play  then
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.1,
                func = function()
                    G.FUNCS.draw_from_deck_to_hand(card.ability.extra.noc)
                    return true
                end
            }))
            return {
                noc = card.ability.extra.noc,
                card = card
            }
        end
    end
}
