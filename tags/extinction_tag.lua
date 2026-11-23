
SMODS.Tag {
    key = "extinction_tag",
    atlas = "HDtags",
    pos = { x = 4, y = 0 },
    discovered = false,
    config = { type = 'immediate' },
    in_pool = function(self, args)
        return HNDS and HNDS._extinction_native_skip_choice == true
    end,
    apply = function(self, tag, context)
        if context.type == 'immediate' and not tag.triggered then
            tag.triggered = true
            tag:yep('+', G.C.GREEN, function()
                replace_jokers_keep_rarity(G.jokers.cards)
                return true
            end)
            tag.triggered = true
            return true
        end
    end,
}
