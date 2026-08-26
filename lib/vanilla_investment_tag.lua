


HNDS = HNDS or {}

local pack = HNDS.pack
local unpack_values = table.unpack or unpack

local function normalize_slot(slot)
    if slot == 'Small' or slot == 'Big' or slot == 'Boss' then return slot end
end

local function tag_key(tag)
    if not tag then return nil end
    return tag.key
        or (tag.config and tag.config.key)
        or (tag.config and tag.config.center and tag.config.center.key)
end

local function is_investment_tag(tag)
    local key = tag_key(tag)
    return key == 'tag_investment'
        or key == 'investment'
        or tag.name == 'Investment Tag'
end

local function current_physical_slot()
    return normalize_slot(G and G.GAME and G.GAME.blind_on_deck)
end

local function real_boss_slot(blind)
    if not blind then return false end


    local replacement = normalize_slot(blind.hnds_platinum_replacement_slot)
    if replacement == 'Small' or replacement == 'Big' then return false end

    local slot = normalize_slot(blind.hnds_investment_physical_slot)
        or current_physical_slot()
    return slot == 'Boss'
end

local function investment_dollars(tag)
    return tonumber(tag and tag.config and tag.config.dollars) or 25
end

local function collect_investment_tags()
    local result = {}
    for _, tag in ipairs((G and G.GAME and G.GAME.tags) or {}) do
        if is_investment_tag(tag)
            and not tag.triggered
            and not tag.hnds_investment_paid
        then
            result[#result + 1] = tag
        end
    end
    return result
end

local function pay_investment_tag(tag)
    if not tag or tag.hnds_investment_paid then return false end
    tag.hnds_investment_paid = true

    local dollars = investment_dollars(tag)
    if type(tag.yep) == 'function' then
        tag:yep('+$' .. tostring(dollars), G.C.MONEY, function()
            ease_dollars(dollars)
            return true
        end)
        tag.triggered = true
    else
        tag.triggered = true
        ease_dollars(dollars)
        if type(tag.remove) == 'function' then pcall(tag.remove, tag) end
    end

    -- Counts a Tag pop on the direct Investment payout path (this payout
    -- bypasses Tag:apply_to_run, which has its own counter in hooks.lua).
    -- The shared hnds_pop_counted guard keeps the two sites mutually exclusive.
    if G and G.GAME and not tag.hnds_pop_counted then
        tag.hnds_pop_counted = true
        G.GAME.hnds_tags_popped = (G.GAME.hnds_tags_popped or 0) + 1
    end
    return true
end

function HNDS.active_blind_is_real_ante_boss()
    local blind = G and G.GAME and G.GAME.blind
    return real_boss_slot(blind)
end

function HNDS.install_investment_blind_hooks()
    if not Blind then return false end

    if type(Blind.set_blind) == 'function'
        and Blind.set_blind ~= HNDS._investment_set_blind_wrapper
    then
        local set_blind_ref = Blind.set_blind
        local set_wrapper = function(self, ...)
            local before = current_physical_slot()
            local results = pack(set_blind_ref(self, ...))
            self.hnds_investment_physical_slot =
                normalize_slot(self.hnds_platinum_replacement_slot)
                or before
                or current_physical_slot()
            return unpack_values(results, 1, results.n)
        end
        HNDS._investment_set_blind_wrapper = set_wrapper
        Blind.set_blind = set_wrapper
    end

    if type(Blind.defeat) ~= 'function' then return false end
    if Blind.defeat == HNDS._investment_defeat_wrapper then return true end

    local defeat_ref = Blind.defeat
    local wrapper = function(self, ...)


        local eligible = real_boss_slot(self)
        local tags = eligible and collect_investment_tags() or nil
        local results = pack(defeat_ref(self, ...))

        if eligible and tags then
            for _, tag in ipairs(tags) do pay_investment_tag(tag) end
        end

        return unpack_values(results, 1, results.n)
    end

    HNDS._investment_defeat_wrapper = wrapper
    Blind.defeat = wrapper
    return true
end

HNDS.install_investment_blind_hooks()

SMODS.Tag:take_ownership('investment', {
    config = { type = 'eval', dollars = 25 },
    loc_vars = function(self)
        return { vars = { 25 } }
    end,
}, true)
