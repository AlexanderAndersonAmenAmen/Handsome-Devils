-- The hate is fading
SMODS.Tag {
    key = "extinction_tag",
    atlas = "HDtags",
    pos = { x = 4, y = 0 },
    discovered = true,
    in_pool = function(self, args)
        return false  -- Never appears in pool or as skip option, to protect player's mental health
    end,
    apply = function(self, tag, context)
        if context.type == 'new_blind_choice' then
            tag:yep('+', G.C.GREEN, function()
                replace_jokers_keep_rarity(G.jokers.cards, 0.5)
                return true
            end)
            tag.triggered = true
            return true
        end
    end,
}
