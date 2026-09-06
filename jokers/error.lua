SMODS.Atlas {
    key = 'ERROR_BG',
    path = 'ERROR2.png',
    px = 71,
    py = 95,
    frames = 26,
    fps = 24,
    atlas_table = 'ANIMATION_ATLAS',
}

SMODS.Atlas {
    key = 'ERROR_FG',
    path = 'ERROR.png',
    px = 71,
    py = 95,
    frames = 26,
    fps = 24,
    atlas_table = 'ANIMATION_ATLAS',
}

local function hnds_joker_mld_is_joker(target)
    local center = target and target.config and target.config.center
    return target and center and center.set == 'Joker'
end

local function hnds_joker_mld_valid_target(owner, target)
    return owner and owner ~= target and hnds_joker_mld_is_joker(target)
        and G and G.jokers and target.area == G.jokers
end

local function hnds_joker_mld_copy(owner, target)
    if not hnds_joker_mld_valid_target(owner, target)
        or owner.REMOVED or owner.removed or owner.area ~= G.jokers
        or (type(copy_card) ~= 'function'
            and not (SMODS and type(SMODS.copy_card) == 'function'))
    then
        return false
    end

    owner.hnds_joker_mld_internal_readd = true
    if owner.remove_from_deck and type(owner.remove_from_deck) == 'function' then
        owner:remove_from_deck()
    end
    if SMODS and type(SMODS.copy_card) == 'function' then
        SMODS.copy_card(target, { new_card = owner, no_add = true })
    else
        copy_card(target, owner)
    end
    if owner.add_to_deck and type(owner.add_to_deck) == 'function' then
        owner:add_to_deck()
    end
    owner.hnds_joker_mld_internal_readd = nil
    if owner.juice_up then owner:juice_up(0.6, 0.4) end
    return true
end

HNDS = HNDS or {}

function HNDS.joker_mld_obtained(target)
    if not (G and G.jokers and G.jokers.cards)
        or not hnds_joker_mld_is_joker(target)
        or target.hnds_joker_mld_internal_readd
        or target.hnds_joker_mld_obtain_pending
    then
        return false
    end

    target.hnds_joker_mld_obtain_pending = true
    local function process_obtained_joker()
        target.hnds_joker_mld_obtain_pending = nil
        if target.area ~= G.jokers or target.REMOVED or target.removed then
            return true
        end

        local owners = {}
        for _, joker in ipairs(G.jokers.cards) do
            local center = joker and joker.config and joker.config.center
            if joker ~= target and center and center.key == 'j_hnds_error'
                and not joker.debuff and not joker.REMOVED and not joker.removed
                and not (joker.ability and joker.ability.hnds_joker_mld_pending)
            then
                owners[#owners + 1] = joker
            end
        end

        for _, owner in ipairs(owners) do
            local odds = tonumber(owner.ability and owner.ability.extra
                and owner.ability.extra.odds) or 3
            if SMODS.pseudorandom_probability(
                owner, 'hnds_joker_mld', 1, odds, 'hnds_joker_mld'
            ) then
                owner.ability.hnds_joker_mld_pending = true
                local copied = hnds_joker_mld_copy(owner, target)
                if owner.ability then owner.ability.hnds_joker_mld_pending = nil end
                if copied and type(card_eval_status_text) == 'function' then
                    card_eval_status_text(owner, 'extra', nil, nil, nil, {
                        message = localize('k_copied_ex'),
                        colour = G.C.CHIPS,
                    })
                end
            end
        end
        return true
    end

    if G.E_MANAGER and Event then
        G.E_MANAGER:add_event(Event {
            trigger = 'after', delay = 0, blockable = false,
            func = process_obtained_joker,
        })
    else
        process_obtained_joker()
    end
    return true
end

SMODS.Joker {
    key = 'error',
    atlas = 'ERROR_BG',
    pos = { x = 0, y = 0 },
    soul_atlas = 'ERROR_FG',
    soul_pos = {
        x = 0,
        y = 0,
        draw = function(card, scale_mod, rotate_mod)
            if card.children and card.children.floating_sprite then
                card.children.floating_sprite:draw_shader(
                    'dissolve', nil, nil, nil, card.children.center, scale_mod, rotate_mod
                )
            end
        end,
    },
    rarity = 1,
    cost = 6,
    unlocked = true,
    discovered = false,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    config = { extra = { odds = 3 } },
    loc_vars = function(self, info_queue, card)
        local extra = card and card.ability and card.ability.extra or self.config.extra
        local numerator, denominator = 1, tonumber(extra.odds) or 3
        if SMODS and type(SMODS.get_probability_vars) == 'function' then
            numerator, denominator = SMODS.get_probability_vars(
                card or self, 1, denominator, 'hnds_joker_mld'
            )
        end
        return { vars = { numerator, denominator } }
    end,
    calculate = function(self, card, context)
        if context.card_added and context.card and not context.blueprint then
            HNDS.joker_mld_obtained(context.card)
        end
    end,
    attributes = { 'joker', 'chance', 'copy' },
}
