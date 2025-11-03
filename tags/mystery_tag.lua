SMODS.Tag {
    key = "mystery_tag",
    atlas = "HDtags",
    pos = { x = 0, y = 0 },
    discovered = true,
    apply = function(self, tag, context)
        if context.type == 'immediate' then
            local lock = tag.ID
            G.CONTROLLER.locks[lock] = true
            tag:yep('+', G.C.DARK_EDITION, function()
                local tag1 = Tag(get_next_tag_key("mystery_tag"))
                local tag2 = Tag(get_next_tag_key("mystery_tag"))
                add_tag(tag1)
                add_tag(tag2)
                G.CONTROLLER.locks[lock] = nil
                return true
            end)
            tag.triggered = true
            return true
        end
    end
}
