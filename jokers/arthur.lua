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
    extra.cards_per_joke = 4
    extra.cards_drawn = math.max(0, math.floor(tonumber(extra.cards_drawn) or 0))
    extra.jokes = math.max(0, math.floor(tonumber(extra.jokes) or 0))
    return extra
end

function HNDS.joker_retrigger_limit(context)
    local effect = context.other_ret and context.other_ret.jokers
    return effect and effect.hnds_retrigger_limit
end

function HNDS.spend_limited_joker_retrigger(source)
    if HNDS.retrigger_charge_managed then return end
    -- Steamodded passes the Joker that requested this particular repetition.
    local center = type(source) == 'table' and source.config and source.config.center
    if center and center.hnds_spend_limited_retrigger then
        center:hnds_spend_limited_retrigger(source)
    end
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
    eternal_compat = true,
    perishable_compat = true,
    config = { extra = { cards_per_joke = 4, cards_drawn = 0, jokes = 0 } },
    hnds_spend_limited_retrigger = function(self, card)
        local extra = arthur_extra(card)
        extra.jokes = math.max(0, extra.jokes - 1)
    end,
    loc_vars = function(self, info_queue, card)
        local extra = card and card.ability and arthur_extra(card) or self.config.extra
        local suit = HNDS.arthur_suit()
        return { vars = {
            localize(suit, 'suits_singular'), extra.cards_per_joke,
            extra.cards_per_joke - extra.cards_drawn % extra.cards_per_joke, extra.jokes,
            colours = { G.C.SUITS[suit] },
        } }
    end,
    calculate = function(self, card, context)
        if context.blueprint or context.retrigger_joker or SMODS.no_resolve or card.debuff then return end
        local extra = arthur_extra(card)
        if type(context.hand_drawn) == 'table' then
            local count = 0
            for _, drawn in ipairs(context.hand_drawn) do
                if drawn and not drawn.debuff and drawn.is_suit and drawn:is_suit(HNDS.arthur_suit()) then
                    count = count + 1
                end
            end
            local total = extra.cards_drawn + count
            local gained = math.floor(total / extra.cards_per_joke)
            extra.cards_drawn = total % extra.cards_per_joke
            extra.jokes = extra.jokes + gained
            if gained > 0 then
                return { message = localize({ type = 'variable', key = 'a_hnds_jokes', vars = { gained } }), colour = G.C.FILTER }
            end
        end

        if context.retrigger_joker_check and extra.jokes > 0
            and card.area == G.jokers and context.other_card and not context.other_card.debuff
            and type(context.other_ret) == 'table'
            and (next(context.other_ret) or type(context.other_context) == 'table')
        then
            local target_context = context.other_context or {}
            if target_context.check or target_context.retrigger_joker or target_context.retrigger_joker_check
                or target_context.modify_scoring_hand then return end
            if SMODS.can_context_retrigger and not SMODS.can_context_retrigger(target_context) then return end
            -- Steamodded also asks after a genuine "return nil, true"
            -- activation. Its other_ret can be empty, but it is still a trigger.
            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i] == card and HNDS.retrigger_neighbor(card, -1) == context.other_card then
                    local limit = HNDS.joker_retrigger_limit(context)
                    local jokes = limit and math.min(extra.jokes, limit) or extra.jokes
                    if jokes <= 0 then return end
                    -- A limited target spends each joke only when its effect succeeds.
                    return HNDS.request_safe_retriggers(card, card, context, jokes, 'joke')
                end
            end
        end
    end,
    joker_display_def = function(JokerDisplay)
        return {
            reminder_text = {
                { text = '(' },
                { ref_table = 'card.joker_display_values', ref_value = 'suit' },
                { text = ': ' },
                { ref_table = 'card.joker_display_values', ref_value = 'remaining' },
                { text = '; ' },
                { ref_table = 'card.joker_display_values', ref_value = 'jokes' },
                { text = ')' },
            },
            calc_function = function(card)
                local extra = arthur_extra(card)
                card.joker_display_values.suit = localize(HNDS.arthur_suit(), 'suits_singular')
                card.joker_display_values.remaining = extra.cards_per_joke - extra.cards_drawn % extra.cards_per_joke
                card.joker_display_values.jokes = extra.jokes
            end,
        }
    end,
    attributes = { 'suit', 'retrigger', 'scaling' },
}
