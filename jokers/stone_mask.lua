local function hnds_stone_mask_unique_count()
    local unique = {}
    for _, playing_card in ipairs(G and G.playing_cards or {}) do
        if SMODS and type(SMODS.get_enhancements) == "function" then
            local ok, enhancements = pcall(SMODS.get_enhancements, playing_card)
            if ok and type(enhancements) == "table" then
                for key, active in pairs(enhancements) do
                    if active and type(key) == "string" then
                        unique["enhancement:" .. key] = true
                    end
                end
            end
        else
            local center = playing_card.config and playing_card.config.center
            if center and center.set == "Enhanced" and center.key then
                unique["enhancement:" .. center.key] = true
            end
        end
        if playing_card.seal then
            unique["seal:" .. tostring(playing_card.seal)] = true
        end
        if type(playing_card.edition) == "table" then
            local edition = playing_card.edition.key or playing_card.edition.type
            if edition then
                unique["edition:" .. tostring(edition)] = true
            else
                for key, active in pairs(playing_card.edition) do
                    if active == true and type(key) == "string" then
                        unique["edition:" .. key] = true
                    end
                end
            end
        end
    end
    local count = 0
    for _ in pairs(unique) do count = count + 1 end
    return count
end

SMODS.Joker({
    key = "stone_mask",
    atlas = "Jokers",
    pos = { x = 5, y = 1 },
    rarity = 2,
    cost = 5,
    unlocked = false,
    discovered = false,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    config = { extra = { mult_per = 5 } },
    unlock_condition = { type = "modify_jokers", extra = 5 },
    check_for_unlock = function(self, args)
        if args.type == "modify_jokers" then
            local jokers = SMODS.find_card("j_vampire")
            for _, v in ipairs(jokers) do
                if v.ability and v.ability.extra and v.ability.extra.x_mult and v.ability.extra.x_mult >= self.unlock_condition.extra then
                    return true
                end
            end
        end
    end,
    in_pool = function(self, args)
        if HNDS.stone_joker_in_pool then return HNDS.stone_joker_in_pool(args) end
        return true
    end,
    loc_vars = function(self, info_queue, card)
        local extra = card and card.ability and card.ability.extra or self.config.extra
        local mult_per = tonumber(extra and extra.mult_per) or 5
        return { vars = { mult_per, hnds_stone_mask_unique_count() * mult_per } }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local mult_per = tonumber(card.ability.extra and card.ability.extra.mult_per) or 5
            local mult = hnds_stone_mask_unique_count() * mult_per
            if mult > 0 then return { mult = mult } end
        end
    end,
    attributes = { "mult", "scaling", "enhancement", "seals", "editions" }
})
