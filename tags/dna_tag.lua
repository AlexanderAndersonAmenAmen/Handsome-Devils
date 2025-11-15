SMODS.Tag {
    key = "dna_tag",
    atlas = "HDtags",
    min_ante = 2,
    pos = { x = 5, y = 0 },
    discovered = true,
    apply = function(self, tag, context)
        if context.type == 'store_joker_modify' and context.card.ability.set == "Joker" then
            local lock = tag.ID
            G.CONTROLLER.locks[lock] = true
            tag:yep('+', G.C.GOLD, function()
                local copy = copy_card(context.card)
                copy.ability.couponed = true
                copy:set_cost()
                G.shop_jokers:emplace(copy)
                copy:start_materialize()
                G.CONTROLLER.locks[lock] = nil
                return true
            end)
            tag.triggered = true
            return true
        end
    end
}
