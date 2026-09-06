HNDS = HNDS or {}

SMODS.Shader({ key = 'billy_mask', path = 'billy_mask.fs' })
SMODS.Atlas({ key = 'billy_mask_tl', path = 'BillyMask_tl.png', px = 71, py = 95 })
SMODS.Atlas({ key = 'billy_mask_tr', path = 'BillyMask_tr.png', px = 71, py = 95 })
SMODS.Atlas({ key = 'billy_mask_bl', path = 'BillyMask_bl.png', px = 71, py = 95 })
SMODS.Atlas({ key = 'billy_mask_br', path = 'BillyMask_br.png', px = 71, py = 95 })

SMODS.Joker {
    key = 'billy',
    prefix_config = { key = { mod = false } },
    unlocked = false,
    unlock_condition = { type = '', extra = '', hidden = true },
    locked_loc_vars = function(self, info_queue, card)
        return { key = 'joker_locked_legendary', set = 'Other', vars = {} }
    end,
    discovered = false,
    blueprint_compat = false,
    rarity = 4,
    cost = 20,
    atlas = 'Jokers',
    pos = { x = 8, y = 2 },
    soul_pos = { x = 3, y = 3 },
    config = { extra = {} },
    loc_vars = function(self, info_queue, card)
        if info_queue then
            info_queue[#info_queue + 1] = { set = 'Other', key = 'hnds_puzzle_piece', vars = { 2 } }
        end
        return {}
    end,
    calculate = function(self, card, context)
        if context.modify_shop_card and context.card and not context.blueprint
            and HNDS.billy_try_roll_shop_card
        then
            HNDS.billy_try_roll_shop_card(context.card, card)
        end
    end,
    attributes = { 'joker', 'shop', 'modify_card' },
}
