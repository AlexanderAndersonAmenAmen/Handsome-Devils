SMODS.Tag {
    key = "dna_tag",
    atlas = "HDtags",
    min_ante = 2,
    pos = { x = 5, y = 0 },
    discovered = true,
    apply = function(self, tag, context)
        if context.type == 'store_joker_modify' and context.card.ability.set == "Joker" then
            local copy = copy_card(context.card)
            create_shop_card_ui(copy, "Joker", G.shop_jokers)
            copy.states.visible = false
            tag:yep('+', G.C.GOLD, function()
                copy:start_materialize()
                copy.ability.couponed = true
                copy:set_cost()
                return true
            end)
            tag.triggered = true
            return copy
        end
    end
}
