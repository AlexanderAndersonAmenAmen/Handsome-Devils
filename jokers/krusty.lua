local function krusty_add_spending(card, amount)
    local extra = card and card.ability and card.ability.extra
    if not extra then return 0 end

    amount = math.max(0, tonumber(amount) or 0)
    local tags = tonumber(extra.tags) or 1
    local max_tags = tonumber(extra.max_tags) or 10
    local spend_req = math.max(1, tonumber(extra.spend_req) or 30)

    if amount <= 0 or tags >= max_tags then return 0 end

    extra.spent = (tonumber(extra.spent) or 0) + amount
    local upgrades = 0

    while extra.spent >= spend_req and tags < max_tags do
        extra.spent = extra.spent - spend_req
        tags = tags + 1
        upgrades = upgrades + 1
    end

    extra.tags = tags
    if tags >= max_tags then extra.spent = 0 end
    return upgrades
end

SMODS.Joker {
    key = "krusty",
    unlocked = false,
    unlock_condition = { type = "", extra = "", hidden = true },
    locked_loc_vars = function(self, info_queue, card)


        return { key = "joker_locked_legendary", set = "Other", vars = {} }
    end,
    discovered = false,
    blueprint_compat = false,
    demicoloncompat = true,
    eternal_compat = false,
    rarity = 4,
    cost = 20,
    atlas = "Jokers",
    pos = { x = 7, y = 2 },
    soul_pos = { x = 2, y = 3 },
    config = { extra = {
        tags = 1,
        max_tags = 10,
        spend_req = 30,
        spent = 0,
        tags_given = false,
    } },
    loc_vars = function(self, info_queue, card)
        local extra = card and card.ability and card.ability.extra or self.config.extra
        local tags = tonumber(extra.tags) or 1
        local max_tags = tonumber(extra.max_tags) or 10
        local spend_req = math.max(1, tonumber(extra.spend_req) or 30)
        local spent = tonumber(extra.spent) or 0
        local remaining = tags >= max_tags and 0 or math.max(0, spend_req - spent)
        local tag_phrase = localize(tags == 1
            and "k_hnds_krusty_voucher_tag"
            or "k_hnds_krusty_voucher_tags")

        return { vars = { tags, tag_phrase, max_tags, spend_req, remaining } }
    end,
    calculate = function(self, card, context)
        if not context.blueprint then
            local upgrades = 0


            if context.buying_card and not context.buying_self and context.card then
                upgrades = krusty_add_spending(card, context.card.cost)
            elseif context.reroll_shop then
                upgrades = krusty_add_spending(card, context.cost)
            end

            if upgrades > 0 then
                return { message = localize("k_upgrade_ex"), colour = G.C.MONEY }
            end
        end

        if (context.selling_self or context.forcetrigger)
            and not context.blueprint
            and not card.ability.extra.tags_given then
            card.ability.extra.tags_given = true
            local tag_count = math.min(
                tonumber(card.ability.extra.tags) or 1,
                tonumber(card.ability.extra.max_tags) or 10
            )

            G.E_MANAGER:add_event(Event({
                func = function()
                    for _ = 1, tag_count do
                        add_tag(Tag("tag_voucher"))
                    end
                    if hnds_config and hnds_config.enableCustomSounds then
                        play_sound("hnds_krusty_laugh", 1, 0.75)
                    end
                    return true
                end
            }))
            return nil, true
        end
    end,
    attributes = { "generation", "scaling" }
}
