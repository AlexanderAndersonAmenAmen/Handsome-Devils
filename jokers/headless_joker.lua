local function hnds_headless_owner_id(card)
    local extra = card and card.ability and card.ability.extra
    if not extra then return nil end
    if not extra.owner_id and G and G.GAME then
        G.GAME.hnds_headless_owner_seq = (tonumber(G.GAME.hnds_headless_owner_seq) or 0) + 1
        extra.owner_id = 'headless_' .. tostring(G.GAME.hnds_headless_owner_seq)
    end
    return extra.owner_id
end

local function hnds_headless_gain_head(card)
    local extra = card and card.ability and card.ability.extra
    if not extra or extra.head_added then return end
    local owner = hnds_headless_owner_id(card)
    if not owner then return end

    -- "When you get this Joker": add_to_deck is the common acquisition path
    -- for shop buys, packs, creation effects and Joker replacements. The saved
    -- head_added flag prevents save/load or repeated add_to_deck calls from
    -- producing duplicate heads.
    extra.head_added = true
    if not (G and G.E_MANAGER and Event) then return end
    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0,
        func = function()
            local added
            if HNDS and HNDS.add_jack_of_lanterns then
                added = HNDS.add_jack_of_lanterns(card, owner)
            end
            if added and card_eval_status_text and card and not card.removed then
                card_eval_status_text(card, 'extra', nil, nil, nil, {
                    message = localize('k_hnds_head_added'),
                    colour = (G.C and (G.C.ORANGE or G.C.ATTENTION)) or {1, 0.5, 0, 1},
                })
            end
            return true
        end,
    }))
end

SMODS.Joker {
    key = 'headless_joker',
    atlas = 'Jokers',
    pos = { x = 9, y = 6 },
    rarity = 2,
    cost = 6,
    unlocked = false,
    discovered = false,
    unlock_condition = { type = "hnds_joker_unlock", key = "headless_joker" },
    locked_loc_vars = function(self)
        return HNDS.joker_locked_loc_vars("headless_joker")
    end,
    check_for_unlock = function(self, args)
        return HNDS.joker_unlock_condition_met("headless_joker", args)
    end,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,

    config = { extra = { owner_id = nil, head_added = false } },

    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = { set = 'Other', key = 'hnds_jack_of_lanterns_headless' }
        return { vars = {} }
    end,

    add_to_deck = function(self, card, from_debuff)
        if from_debuff then return end
        hnds_headless_gain_head(card)
    end,

    remove_from_deck = function(self, card, from_debuff)
        if from_debuff then return end
        local owner = card and card.ability and card.ability.extra and card.ability.extra.owner_id
        if owner and HNDS and HNDS.remove_jack_of_lanterns then
            HNDS.remove_jack_of_lanterns(owner)
        end
    end,

    attributes = { 'modify_card', 'rank', 'suit', 'chips' },
}
