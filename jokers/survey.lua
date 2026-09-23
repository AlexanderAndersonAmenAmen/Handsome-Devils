SMODS.Joker({
    key = 'survey',
    atlas = 'Jokers',
    pos = { x = 6, y = 8 },
    rarity = 1,
    cost = 4,
    unlocked = true,
    discovered = false,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    calculate = function(self, card, context)
        if context.hand_drawn and type(context.hand_drawn) == 'table' then
            local count = 0
            for _, drawn in ipairs(context.hand_drawn) do
                if drawn and type(drawn.is_face) == 'function' and drawn:is_face() then
                    count = count + 1
                end
            end
            if count > 0 then return { dollars = count } end
        end
    end,
    attributes = { 'money', 'face' },
})
