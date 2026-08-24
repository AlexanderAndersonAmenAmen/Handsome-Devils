local function hnds_ecg_scoring_hearts(context)
    local hearts = 0
    for _, scoring_card in ipairs((context and context.scoring_hand) or {}) do
        if scoring_card and scoring_card.is_suit and scoring_card:is_suit('Hearts') then
            hearts = hearts + 1
            if hearts >= 2 then return hearts end
        end
    end
    return hearts
end

local function hnds_ecg_signed(value)
    value = tonumber(value) or 0
    if value >= 0 then return '+' .. tostring(value) end
    return tostring(value)
end

local function hnds_ecg_remove_at_zero(card)
    if not card or card.hnds_ecg_removing then return end
    card.hnds_ecg_removing = true

    -- Match self-expiring Jokers such as Popcorn: let the Mult change finish
    -- resolving, then dissolve the actual ECG card.
    if G and G.E_MANAGER and Event then
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.15,
            func = function()
                if card and card.area and card.start_dissolve then
                    if play_sound then play_sound('tarot1') end
                    card:start_dissolve()
                end
                return true
            end,
        }))
    elseif card.start_dissolve then
        card:start_dissolve()
    end
end

SMODS.Joker {
    key = 'ecg',
    atlas = 'Jokers',
    pos = { x = 2, y = 7 },
    rarity = 1,
    cost = 6,
    unlocked = false,
    discovered = false,
    unlock_condition = { type = "hnds_joker_unlock", key = "ecg" },
    locked_loc_vars = function(self)
        return HNDS.joker_locked_loc_vars("ecg")
    end,
    check_for_unlock = function(self, args)
        return HNDS.joker_unlock_condition_met("ecg", args)
    end,
    blueprint_compat = true,
    eternal_compat = false,
    perishable_compat = true,

    config = { extra = { mult = 10, gain = 2, loss = 2 } },

    loc_vars = function(self, info_queue, card)
        local extra = card and card.ability and card.ability.extra or self.config.extra
        return {
            vars = {
                tonumber(extra.gain) or 2,
                tonumber(extra.loss) or 2,
                hnds_ecg_signed(extra.mult),
            },
        }
    end,

    calculate = function(self, card, context)
        local extra = card.ability.extra

        -- Update once for the played hand. Blueprint/Brainstorm copies use the
        -- stored value but must not advance ECG's own running Mult a second time.
        if context.before and not context.blueprint then
            local delta
            if hnds_ecg_scoring_hearts(context) >= 2 then
                delta = tonumber(extra.gain) or 2
            else
                delta = -(tonumber(extra.loss) or 2)
            end
            extra.mult = (tonumber(extra.mult) or 0) + delta

            if extra.mult == 0 then
                hnds_ecg_remove_at_zero(card)
            end

            return {
                message = hnds_ecg_signed(delta) .. ' Mult',
                colour = G.C.MULT,
            }
        end

        local current = tonumber(extra.mult) or 0
        if context.joker_main and current ~= 0 then
            return { mult = current }
        end
    end,

    joker_display_def = function(JokerDisplay)
        return {
            text = {
                { ref_table = 'card.joker_display_values', ref_value = 'mult', colour = G.C.MULT },
            },
            text_config = { colour = G.C.MULT },
            calc_function = function(card)
                card.joker_display_values.mult = hnds_ecg_signed(card.ability.extra.mult)
            end,
        }
    end,

    attributes = { 'mult', 'suit' },
}
