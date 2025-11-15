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
                context.card.ability.hnds_copies_to_create = (context.card.ability.hnds_copies_to_create or 0) + 1
                context.card.ability.couponed = true
                context.card:set_cost()
                G.CONTROLLER.locks[lock] = nil
                return true
            end)
            tag.triggered = true
        end
    end
}
