HNDS = HNDS or {}

local magic_tag = 'tag_hnds_magic_tag'
local pack_tags = {
    tag_standard = true,
    tag_charm = true,
    tag_meteor = true,
    tag_buffoon = true,
    tag_ethereal = true,
    tag_hnds_cursed_tag = true,
}

local function opens_booster_tag(key)
    if pack_tags[key] then return true end
    local center = G and G.P_TAGS and G.P_TAGS[key]
    local config = center and center.config
    local pack_key = config and (config.pack_key or config.booster_key)
    local pack = pack_key and G.P_CENTERS and G.P_CENTERS[pack_key]
    return (config and config.hnds_opens_booster == true) or (pack and pack.set == 'Booster') or false
end

function HNDS.conjuring_active()
    local game = G and G.GAME
    if not game then return false end
    local back = game.selected_back and game.selected_back.effect
        and game.selected_back.effect.center
    return game.hnds_conjuring_magic_packs == true
        or (back and back.key == 'b_hnds_conjuring')
        or game.selected_sleeve == 'sleeve_hnds_conjuring_sleeve'
end

function HNDS.conjuring_tag_key(key)
    if HNDS.conjuring_active() and opens_booster_tag(key) then return magic_tag end
    return key
end

function HNDS.enable_conjuring_replacements()
    if not (G and G.GAME) then return end
    G.GAME.hnds_conjuring_magic_packs = true
    local blind_tags = G.GAME.round_resets and G.GAME.round_resets.blind_tags
    if blind_tags then
        for slot, key in pairs(blind_tags) do
            blind_tags[slot] = HNDS.conjuring_tag_key(key)
        end
    end
end

local function magic_center()
    local centers = G and G.P_CENTERS
    if not centers then return nil end
    local candidates = {}
    for i = 1, 6 do
        local center = centers['p_hnds_magic_' .. i]
        if center then candidates[#candidates + 1] = center end
    end
    if #candidates == 0 then return nil end
    if pseudorandom_element and pseudoseed then
        return pseudorandom_element(candidates, pseudoseed('hnds_conjuring_open_pack'))
    end
    return candidates[1]
end

function HNDS.conjuring_replace_booster(card)
    if not (HNDS.conjuring_active() and card and card.config) then return end
    local original = card.config.center
    if not (original and original.set == 'Booster' and original.kind ~= 'hnds_magic') then return end
    local replacement = magic_center()
    if not (replacement and type(card.set_ability) == 'function') then return end

    local was_free = card.cost == 0
    local sell_cost, sell_cost_label = card.sell_cost, card.sell_cost_label
    card:set_ability(replacement, nil, true)
    if was_free then
        card.cost = 0
        card.sell_cost = sell_cost
        card.sell_cost_label = sell_cost_label
    end
end

-- Tag:init covers blind rewards, copied tags, and tags granted directly by effects.
if Tag and type(Tag.init) == 'function' and not Tag._hnds_conjuring_init_wrapped then
    Tag._hnds_conjuring_init_wrapped = true
    local init_ref = Tag.init
    function Tag:init(key, for_collection, ...)
        if for_collection then
            return init_ref(self, key, for_collection, ...)
        end
        return init_ref(self, HNDS.conjuring_tag_key(key), for_collection, ...)
    end
end

if type(get_next_tag_key) == 'function' and not HNDS._conjuring_next_tag_wrapped then
    HNDS._conjuring_next_tag_wrapped = true
    local next_tag_ref = get_next_tag_key
    function get_next_tag_key(...)
        return HNDS.conjuring_tag_key(next_tag_ref(...))
    end
end

-- Change the actual pack immediately before it is used, including packs from
-- effects that request a specific key and bypass the shop's banned pool.
if G and G.FUNCS and type(G.FUNCS.use_card) == 'function'
    and not HNDS._conjuring_use_card_wrapped
then
    HNDS._conjuring_use_card_wrapped = true
    local use_card_ref = G.FUNCS.use_card
    function G.FUNCS.use_card(e, ...)
        HNDS.conjuring_replace_booster(e and e.config and e.config.ref_table)
        return use_card_ref(e, ...)
    end
end

-- Forced shop stock can bypass the usual Booster pool and its banned keys.
if type(create_shop_card_ui) == 'function' and not HNDS._conjuring_shop_ui_wrapped then
    HNDS._conjuring_shop_ui_wrapped = true
    local shop_ui_ref = create_shop_card_ui
    function create_shop_card_ui(card, card_type, area, ...)
        if G and (area == G.shop_booster or area == G.shop_jokers) then
            HNDS.conjuring_replace_booster(card)
        end
        return shop_ui_ref(card, card_type, area, ...)
    end
end

if CardArea and type(CardArea.emplace) == 'function'
    and not CardArea._hnds_conjuring_emplace_wrapped
then
    CardArea._hnds_conjuring_emplace_wrapped = true
    local emplace_ref = CardArea.emplace
    function CardArea:emplace(card, ...)
        if G and (self == G.shop_booster or self == G.shop_jokers) then
            HNDS.conjuring_replace_booster(card)
        end
        return emplace_ref(self, card, ...)
    end
end

-- Some effects call Card:open directly rather than going through use_card.
if Card and type(Card.open) == 'function' and not Card._hnds_conjuring_open_wrapped then
    Card._hnds_conjuring_open_wrapped = true
    local open_ref = Card.open
    function Card:open(...)
        HNDS.conjuring_replace_booster(self)
        return open_ref(self, ...)
    end
end
