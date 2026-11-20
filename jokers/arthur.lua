local pending_destruction = setmetatable({}, { __mode = 'k' })

function HNDS.card_counts_as_rank(card, rank)
    return card and type(card.get_id) == 'function' and type(rank) == 'number' and card:get_id() == rank or false
end

function HNDS.card_counts_as_face(card)
    return card and type(card.is_face) == 'function' and card:is_face() or false
end

function HNDS.arthur_suit()
    local round = G and G.GAME and G.GAME.current_round
    return round and round.hnds_arthur_suit or 'Spades'
end

function HNDS.reset_arthur_suit()
    local round = G.GAME.current_round
    local current = HNDS.arthur_suit()
    round.hnds_arthur_suit = HNDS.poll_abstract_suit('hnds_arthur', current) or current
end

local function arthur_extra(card)
    if type(card.ability.extra) ~= 'table' then card.ability.extra = {} end
    local extra = card.ability.extra
    extra.required = math.max(1, math.floor(tonumber(extra.required) or 4))
    extra.destroyed = math.max(0, math.floor(tonumber(extra.destroyed) or 0))
    return extra
end

local function award_standard_tags(amount)
    local game = G.GAME
    G.E_MANAGER:add_event(Event({
        func = function()
            if G.GAME ~= game then return true end
            for i = 1, amount do add_tag(Tag('tag_standard')) end
            play_sound('generic1')
            return true
        end,
    }))
end

SMODS.Joker {
    key = 'arthur',
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
    pos = { x = 9, y = 2 },
    soul_pos = { x = 4, y = 3 },
    config = { extra = { required = 4, destroyed = 0 } },
    loc_vars = function(self, info_queue, card)
        local extra = card and card.ability and arthur_extra(card) or self.config.extra
        local suit = HNDS.arthur_suit()
        if info_queue then info_queue[#info_queue + 1] = { key = 'tag_standard', set = 'Tag' } end
        return { vars = {
            localize(suit, 'suits_singular'), extra.required, extra.required - extra.destroyed % extra.required,
            colours = { G.C.SUITS[suit] },
        } }
    end,
    calculate = function(self, card, context)
        if context.blueprint or context.retrigger_joker or SMODS.no_resolve then return end
        local ability = card.ability
        if context.before or context.after then pending_destruction[ability] = nil end

        local target = context.destroying_card
        if target and context.cardarea == G.play and not target.debuff
            and target:is_suit(HNDS.arthur_suit())
            and not SMODS.is_eternal(target, { destroy_cards = true })
        then
            local pending = pending_destruction[ability]
            if not pending then
                pending = setmetatable({}, { __mode = 'k' })
                pending_destruction[ability] = pending
            end
            pending[target] = true
            return { remove = true }
        end

        if context.remove_playing_cards and type(context.removed) == 'table' then
            local pending = pending_destruction[ability]
            if not pending then return end
            local gained = 0
            for _, removed in ipairs(context.removed) do
                if pending[removed] then
                    pending[removed] = nil
                    if removed.destroyed or removed.shattered or removed.getting_sliced then gained = gained + 1 end
                end
            end
            if gained == 0 then return end
            local extra = arthur_extra(card)
            local total = extra.destroyed + gained
            local tags = math.floor(total / extra.required)
            extra.destroyed = total % extra.required
            if tags > 0 then
                award_standard_tags(tags)
                return { message = localize('k_hnds_plus_tag'), colour = G.C.FILTER }
            end
            return { message = extra.destroyed .. '/' .. extra.required, colour = G.C.FILTER }
        end
    end,
    joker_display_def = function(JokerDisplay)
        return {
            reminder_text = {
                { text = '(' },
                { ref_table = 'card.joker_display_values', ref_value = 'suit' },
                { text = ': ' },
                { ref_table = 'card.joker_display_values', ref_value = 'remaining' },
                { text = ')' },
            },
            calc_function = function(card)
                local extra = arthur_extra(card)
                card.joker_display_values.suit = localize(HNDS.arthur_suit(), 'suits_singular')
                card.joker_display_values.remaining = extra.required - extra.destroyed % extra.required
            end,
        }
    end,
    attributes = { 'suit', 'destroy_card', 'tag' },
}
