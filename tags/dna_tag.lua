SMODS.Tag {
    key = "dna_tag",
    atlas = "HDtags",
    min_ante = 2,
    pos = { x = 5, y = 0 },
    discovered = true,
    apply = function(self, tag, context)
        if context.type == 'immediate' then
            local lock = tag.ID
            G.CONTROLLER.locks[lock] = true
            tag:yep('+', G.C.GOLD, function(card)
                if G.jokers and G.jokers.cards[1] then
                    local copied
                    for _, c in ipairs(G.jokers.cards) do
                        if c.sort_id == G.GAME.hnds_dna_tag_copy then
                            copied = c
                        end
                    end
                    if not copied then copied = card end --failsafe
                    local chosen_joker = copied
                    if context.card_added then
                        G.E_MANAGER:add_event(Event({
                            trigger = 'before',
                            delay = 0.4,
                            func = function()
                                local copied_joker = copy_card(chosen_joker, nil, nil, nil,
                                    chosen_joker.edition and chosen_joker.edition.negative)
                                copied_joker:start_materialize()
                                copied_joker:add_to_deck()
                                if copied_joker.edition and copied_joker.edition.negative then
                                    copied_joker:set_edition(nil, true)
                                end
                                G.jokers:emplace(copied_joker)
                                return true
                            end
                        }))
                    end
                end
                G.CONTROLLER.locks[lock] = nil
                return true
            end)
            tag.triggered = true
            return true
        end
    end
}
