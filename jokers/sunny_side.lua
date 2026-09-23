local function hnds_sunny_side_face_card(card)
    return card and not card.debuff and type(card.is_face) == 'function' and card:is_face()
end

local function hnds_sunny_side_seal(card)
    local seal = card and card.seal
    if seal == 'hnds_green' then return 'Green' end
    return seal
end

local function hnds_sunny_side_consumable_room()
    if not (G and G.GAME and G.consumeables and G.consumeables.cards and G.consumeables.config) then return false end
    return #G.consumeables.cards + (G.GAME.consumeable_buffer or 0) < (G.consumeables.config.card_limit or 0)
end

local function hnds_sunny_side_add_tarot()
    if not hnds_sunny_side_consumable_room() then return false end
    G.GAME.consumeable_buffer = (G.GAME.consumeable_buffer or 0) + 1
    G.E_MANAGER:add_event(Event({
        func = function()
            if #G.consumeables.cards < (G.consumeables.config.card_limit or 0) then
                SMODS.add_card({ set = 'Tarot', area = G.consumeables, key_append = 'hnds_sunny_side_purple' })
            end
            G.GAME.consumeable_buffer = math.max(0, (G.GAME.consumeable_buffer or 1) - 1)
            return true
        end,
    }))
    return true
end

SMODS.Joker({
    key = "sunny_side",
    atlas = "SunnySide",
    pos = { x = 0, y = 0 },
    rarity = 2,
    cost = 7,
    unlocked = true,
    discovered = false,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    calculate = function(self, card, context)
        local other = context.other_card
        if context.repetition and context.cardarea == G.play and hnds_sunny_side_face_card(other) and hnds_sunny_side_seal(other) == 'Red' then
            return { repetitions = 1, card = card, message = localize('k_again_ex') }
        end
        if context.individual and context.cardarea == G.play and hnds_sunny_side_face_card(other) and hnds_sunny_side_seal(other) == 'Gold' then
            return { dollars = 3 }
        end
        if context.discard and hnds_sunny_side_face_card(other) and hnds_sunny_side_seal(other) == 'Purple' then
            if hnds_sunny_side_add_tarot() then return { message = localize('k_plus_tarot'), colour = G.C.SECONDARY_SET.Tarot } end
        end
        if context.before and context.full_hand and HNDS.queue_green_seal_cards then
            HNDS.queue_green_seal_cards(context.full_hand, true)
        end
        if context.pre_discard and context.full_hand and HNDS.queue_green_seal_cards then
            HNDS.queue_green_seal_cards(context.full_hand, true)
        end
    end,
    attributes = { 'seals', 'face' },
})
