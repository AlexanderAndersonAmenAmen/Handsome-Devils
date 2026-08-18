SMODS.Joker {
    key = "handsome",
    atlas = "Jokers",
    pos = { x = 5, y = 0 },
    rarity = 3,
    cost = 8,
    unlocked = false,
    discovered = false,
    unlock_condition = { type = "hnds_joker_unlock", key = "handsome" },
    locked_loc_vars = function(self)
        return HNDS.joker_locked_loc_vars("handsome")
    end,
    check_for_unlock = function(self, args)
        return HNDS.joker_unlock_condition_met("handsome", args)
    end,
    blueprint_compat = true,
    perishable_compat = true,
    in_pool = function(self, args)
        -- Pool checks also run for title-screen/demo-card randomization, where
        -- no gameplay Joker area or playing-card deck exists yet. Treat that
        -- state as simply ineligible instead of indexing nil menu globals.
        local jokers = G and G.jokers and G.jokers.cards or {}
        local playing_cards = G and G.playing_cards or {}

        for _, c in ipairs(jokers) do
            if c.edition and c.edition.negative == nil and next(c.edition) then return true end
        end
        for _, c in ipairs(playing_cards) do
            if c.edition and c.edition.negative == nil and next(c.edition) then return true end
        end
        return false
    end,
    calculate = function (self, card, context)
        if type(context) ~= "table" then return end
        local other = context.other_card
        if (context.repetition or (context.retrigger_joker_check and not context.retrigger_joker))
            and other and other ~= card and other.edition then -- should this also retrigger jokers
            return { repetitions = 1 }
        end
    end,
    attributes = { "retrigger", "edition" }
}