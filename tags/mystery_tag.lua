SMODS.Tag {
    key = "mystery_tag",
    atlas = "HDtags",
    pos = { x = 0, y = 0 },
    discovered = false,
    apply = function(self, tag, context)
        if context.type == 'immediate' then
            local lock = tag.ID
            G.CONTROLLER.locks[lock] = true
            tag:yep('+', G.C.DARK_EDITION, function()
                for _ = 1, 2 do
                    local new_tag = HNDS.poll_allowed_tag("mystery_tag")
                    if new_tag then add_tag(new_tag) end
                end
                G.CONTROLLER.locks[lock] = nil
                return true
            end)
            tag.triggered = true
            return true
        end
    end
}
