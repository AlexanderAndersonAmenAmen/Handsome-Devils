SMODS.Joker {
    key = "sarmenti",
    unlocked = true,
    discovered = true,
    blueprint_compat = false,
    rarity = 4,
    cost = 20,
    atlas = "Jokers",
    pos = { x = 8, y = 2 },
    soul_pos = { x = 3, y = 3 },
    config = { extra = { mode = 0, active = true } }, -- mode 0 = editions, mode 1 = enhancements, mode 3 = seals
    loc_vars = function (self, info_queue, card)

        local mod = card.ability.extra.mode or 0

        local modeString, modeCol

        if mod == 0 then --editions
            modeString = localize("b_editions")
            modeCol = G.C.DARK_EDITION
        elseif mod == 1 then --enhancements
            modeString = localize("k_hnds_enhancements") -- turns out vanilla doesn't have a dictionary entry for "enhancements"... thunk moment
            modeCol = G.C.ORANGE
        else --seals
            modeString = localize("b_seals")
            modeCol = G.C.SEAL_EDITION
        end

        return { vars = { modeString, colours = {modeCol} } }
    end,
    calculate = function (self, card, context)
        
        if card.ability.extra.active and context.before and next(context.poker_hands["Four of a Kind"]) and not context.blueprint then

            for _, c in ipairs(context.scoring_hand) do
                if card.ability.extra.mode == 0 then
                    c:set_edition(poll_edition('sarmenti', 1, false, true))
                elseif card.ability.extra.mode == 1 then
                    c:set_ability(SMODS.poll_enhancement({key = 'sarmenti', guaranteed = true}), nil, true)
                else
                    c:set_seal(SMODS.poll_seal({key = 'sarmenti', guaranteed = true}))
                end
                G.E_MANAGER:add_event(Event{
                    func = function ()
                        c:juice_up()
                        return true
                    end
                })
            end
            return {
                message = localize('k_hnds_sarmenti_enhanced')
            }
        end

        if context.end_of_round and context.cardarea == G.jokers and not context.blueprint then
            
            card.ability.extra.mode = card.ability.extra.mode + 1
            if card.ability.extra.mode > 2 then card.ability.extra.mode = 0 end
            
            card.ability.extra.active = true

            return {
                message = localize('k_reset')
            }
        end
    end
}