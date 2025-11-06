SMODS.Tag {
    key = "dna_tag",
    atlas = "HDtags",
    min_ante = 2,
    pos = { x = 5, y = 0 },
    discovered = true,
    apply = function(self, tag, context)
        if context.type == 'hnds_joker_bought' then
            local lock = tag.ID
            G.CONTROLLER.locks[lock] = true
            tag:yep('+', G.C.GOLD, function(card)
                if context.card then
                    local copy = copy_card(context.card)
                    copy.ability.from_hnds_dna = true
                    copy:add_to_deck()
                    G.jokers:emplace(copy)
                end
                G.CONTROLLER.locks[lock] = nil
                return true
            end)
            tag.triggered = true
            return true
        end
    end
}
