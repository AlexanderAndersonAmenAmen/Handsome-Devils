local descriptions = assert(SMODS.load_file('lib/vanilla_tweak_tooltip_data.lua'))()

local function register_description(key, set, source)
    local bucket = G.localization.descriptions[set]
    if not bucket[key] then
        local text = {}
        for i, value in ipairs(source.text) do text[i] = value end
        local parsed = {}
        for i, value in ipairs(text) do parsed[i] = loc_parse_string(value) end
        bucket[key] = {
            name = source.name, text = text, text_parsed = parsed,
            name_parsed = { loc_parse_string(source.name) },
        }
    end
end

-- Use the game's collection popup renderer and its rich localization parser.
-- Preview-only localization keys keep both versions available even when the
-- tweak is disabled, without overwriting a live entity or executing effects.
function HNDS.vanilla_tweak_native_popup(sprite, entry, modded)
    local data = assert(descriptions[entry.key])
    local source = modded and data.modded or data.vanilla
    local alias = 'hnds_compare_' .. (modded and 'after_' or 'before_')
        .. entry.key:gsub('%W', '_')
    register_description(alias, data.set, source)
    local vars = {}
    for i, value in ipairs(source.vars) do vars[i] = value end
    vars.colours = { G.C.SUITS.Spades }
    if data.set == 'Planet' then
        vars[2] = localize(entry.key, 'poker_hands')
        -- Level 1 is white in the hand HUD, but needs dark text on a
        -- tooltip's white description panel, just like native Planet cards.
        vars.colours = {
            vars[1] == 1 and G.C.UI.TEXT_DARK or G.C.HAND_LEVELS[math.min(7, vars[1])],
        }
    elseif entry.key == 'j_idol' then
        vars[2], vars[3] = localize('Ace', 'ranks'), localize('Spades', 'suits_plural')
    elseif entry.key == 'j_mail' then
        vars[2] = localize('Ace', 'ranks')
    elseif not modded and entry.key:match('_joker$') and vars[2] then
        vars[2] = localize(vars[2], 'suits_singular')
    end
    local center = {
        key = alias, set = data.set, name = source.name, rarity = source.rarity,
        discovered = true, unlocked = true, config = {},
    }
    if data.set == 'Blind' then
        local real = G.P_BLINDS.bl_serpent
        center.mult, center.dollars, center.boss_colour = real.mult, real.dollars, real.boss_colour
        center.vars = vars
        return create_UIBox_blind_popup(center, true, vars)
    end

    local aut = { main = {}, info = {}, type = {}, card_type = data.set,
        -- Native Tag popups have a name, not a card-type badge. There is no
        -- k_tag dictionary entry for the generic card popup to localize.
        badges = { card_type = data.set ~= 'Back' and data.set ~= 'Stake' and data.set ~= 'Tag' } }
    aut.name = localize {
        type = 'name', set = data.set, key = alias, nodes = {},
        -- Enhanced/Default popup titles sit on white, unlike other sets.
        text_colour = data.set == 'Enhanced' and G.C.UI.TEXT_DARK or nil,
        no_shadow = data.set == 'Enhanced',
    }
    localize { type = 'descriptions', set = data.set, key = alias, nodes = aut.main, vars = vars, AUT = aut }
    -- Native subsidiary description boxes for referenced cards.
    local related = {
        j_stone = { set = 'Enhanced', key = 'm_stone', vars = { 50 } },
        j_superposition = modded and { set = 'Tarot', key = 'c_fool',
            vars = { localize('k_none') } } or nil,
        v_planet_tycoon = modded and { set = 'Edition', key = 'e_negative_consumable', vars = { 1 } } or nil,
    }
    local info = related[entry.key]
    if info and G.localization.descriptions[info.set][info.key] then
        local rows = {}
        localize { type = 'descriptions', set = info.set, key = info.key,
            nodes = rows, vars = info.vars, AUT = { info = {} } }
        rows.name = localize { type = 'name_text', set = info.set, key = info.key }
        aut.info[#aut.info + 1] = rows
    end
    sprite.config.center = center
    sprite.ability = { name = source.name, set = data.set }
    sprite.ability_UIBox_table = aut
    return G.UIDEF.card_h_popup(sprite)
end
