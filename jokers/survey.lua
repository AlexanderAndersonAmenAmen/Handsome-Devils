SMODS.Joker({
    key = 'survey',
    atlas = 'Jokers',
    pos = { x = 8, y = 4 },
    rarity = 1,
    cost = 4,
    unlocked = true,
    discovered = false,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    calculate = function(self, card, context)
        local drawn_cards = HNDS.progress_drawn_cards(context)
        if drawn_cards then
            local count = 0
            for _, drawn in ipairs(drawn_cards) do
                if drawn and type(drawn.is_face) == 'function' and drawn:is_face() then
                    count = count + 1
                end
            end
            if count > 0 then return { dollars = count } end
        end
    end,
    attributes = { 'money', 'face' },
})
