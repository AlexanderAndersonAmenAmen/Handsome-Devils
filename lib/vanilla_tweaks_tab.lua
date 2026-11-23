-- Comparisons never construct cards, call effects, or mutate a run.
-- Checkboxes save next-launch preferences, not the active gameplay settings.
local mod = SMODS.current_mod
local entries = HNDS.vanilla_tweaks_catalog
assert(SMODS.load_file('lib/vanilla_tweak_previews.lua'))()
local categories = {
    'All changes', 'Jokers', 'Cards & hands', 'Tags', 'Vouchers',
    'Decks, stakes & blinds',
}
local state = { category = 1, index = 1 }
local area_id = 'hnds_vanilla_tweaks_comparison'
-- UIBox/Moveable "tm" means ABOVE its parent; UIElement "tm" means
-- top-aligned content. An embedded UIBox must use "tmi" (top, inside).
-- Share this config so initial render and every refresh position identically.
local function comparison_box_config(parent)
    return { offset = { x = 0, y = 0 }, align = 'tmi', parent = parent }
end
HNDS.vanilla_tweaks_catalog = entries
local refresh
local function save()
    SMODS.save_mod_config(mod)
    -- Do not remove the checkbox UI while its click callback is still running.
    G.E_MANAGER:add_event(Event({ func = function()
        refresh()
        return true
    end }))
end

local function filtered_entries()
    local result = {}
    for _, entry in ipairs(entries) do
        if state.category == 1 or entry.category == categories[state.category] then
            result[#result + 1] = entry
        end
    end
    return result
end

local function text_row(text, colour, scale)
    return {
        n = G.UIT.R, config = { align = 'cm', padding = 0, minh = 0.29 },
        nodes = {{
            n = G.UIT.T,
            config = { text = text, colour = colour or G.C.UI.TEXT_LIGHT, scale = scale or 0.31 },
        }},
    }
end

local function wrap(text, width)
    local lines, line = {}, ''
    for word in text:gmatch('%S+') do
        local candidate = line == '' and word or line .. ' ' .. word
        local font = G.LANG and G.LANG.font
        local fits = #candidate <= width
        if font and font.FONT and G.TILESIZE then
            fits = font.FONT:getWidth(candidate) * font.squish * 0.29 * font.FONTSCALE / G.TILESIZE <= 3.95
        end
        if #line > 0 and not fits then
            lines[#lines + 1], line = line, word
        else
            line = line == '' and word or line .. ' ' .. word
        end
    end
    if line ~= '' then lines[#lines + 1] = line end
    return lines
end

local function comparison_column(title, text, colour, entry, modded, body_height)
    local body = {}
    for _, line in ipairs(wrap(text, 29)) do
        body[#body + 1] = text_row(line, nil, 0.29)
    end
    return {
        n = G.UIT.C,
        config = { align = 'tm', padding = 0.12, minw = 4.2, r = 0.1, colour = G.C.BLACK },
        nodes = {
            text_row(title, colour, 0.4),
            { n = G.UIT.R, config = { align = 'tm', minh = body_height }, nodes = {
                { n = G.UIT.C, config = { align = 'tm', padding = 0 }, nodes = body },
            }},
            HNDS.vanilla_tweak_preview(entry, modded, wrap),
        },
    }
end

function HNDS.vanilla_tweaks_comparison()
    local pool = filtered_entries()
    state.index = math.max(1, math.min(state.index, #pool))
    local entry = pool[state.index]
    -- Reserve the longest description across every category, not just this
    -- entry. Titles, sprites, toggles and selectors keep the same coordinates.
    local max_lines = 1
    for _, item in ipairs(entries) do
        max_lines = math.max(max_lines, #wrap(item.vanilla, 29), #wrap(item.modded, 29))
    end
    local body_height = max_lines * 0.29
    local choices = {}
    for i, item in ipairs(pool) do
        choices[i] = item.name .. ' (' .. i .. '/' .. #pool .. ')'
    end
    local active = HNDS.vanilla_tweak_enabled(entry.key)
    local requested = hnds_config.enableVanillaTweaks and hnds_config.vanillaTweaks[entry.key] ~= false
    local status = active and 'Active this session' or 'Vanilla this session'
    if requested ~= active then status = status .. ' - restart pending' end
    if not hnds_config.enableVanillaTweaks then status = status .. ' - master switch OFF' end
    return {
        n = G.UIT.ROOT,
        config = { align = 'cm', colour = G.C.CLEAR, padding = 0.03 },
        nodes = {
            create_option_cycle({
                options = choices, current_option = state.index, w = 7.4,
                h = 0.5, text_scale = 0.34, no_pips = true, cycle_shoulders = true,
                opt_callback = 'hnds_vanilla_tweaks_entry', colour = G.C.MONEY,
                focus_args = { snap_to = true, nav = 'wide' },
            }),
            text_row(entry.category, G.C.JOKER_GREY, 0.28),
            { n = G.UIT.R, config = { align = 'cm', padding = 0.08 }, nodes = {
                comparison_column('Vanilla', entry.vanilla, G.C.CHIPS, entry, false, body_height),
                comparison_column('Handsome Devils', entry.modded, G.C.MULT, entry, true, body_height),
            }},
            create_toggle({
                label = 'Enable this tweak (restart required)', label_scale = 0.29,
                ref_table = hnds_config.vanillaTweaks, ref_value = entry.key,
                callback = save, w = 5.5, scale = 0.7,
            }),
            text_row(status, G.C.UI.TEXT_LIGHT, 0.25),
        },
    }
end

refresh = function()
    -- A queued/controller event can arrive after the mod menu has closed.
    if not (G.OVERLAY_MENU and G.OVERLAY_MENU:get_UIE_by_ID(area_id)) then return end
    local area = G.OVERLAY_MENU:get_UIE_by_ID(area_id)
    local definition = HNDS.vanilla_tweaks_comparison()
    area.config.object:remove()
    -- DynamicUIManager adds a 0.5 vertical offset. This panel must sit directly
    -- below the category selector, including after changing pages.
    area.config.object = UIBox {
        definition = definition,
        config = comparison_box_config(area),
    }
    G.OVERLAY_MENU:recalculate()
end

G.FUNCS.hnds_vanilla_tweaks_enable_all = function()
    hnds_config.enableVanillaTweaks = true
    for _, entry in ipairs(entries) do
        if entry.scope == 'setting' then hnds_config.vanillaTweaks[entry.key] = true end
    end
    save()
end
G.FUNCS.hnds_vanilla_tweaks_disable_all = function()
    for _, entry in ipairs(entries) do
        if entry.scope == 'setting' then hnds_config.vanillaTweaks[entry.key] = false end
    end
    save()
end

G.FUNCS.hnds_vanilla_tweaks_category = function(e)
    local index = e and e.cycle_config and tonumber(e.cycle_config.current_option)
    if not index or index % 1 ~= 0 or not categories[index] then return end
    state.category, state.index = index, 1
    refresh()
end

G.FUNCS.hnds_vanilla_tweaks_entry = function(e)
    local index = e and e.cycle_config and tonumber(e.cycle_config.current_option)
    if not index or index % 1 ~= 0 or not filtered_entries()[index] then return end
    state.index = index
    refresh()
end

function HNDS.vanilla_tweaks_tab()
    return {
        n = G.UIT.ROOT,
        config = { align = 'tm', padding = 0.06, colour = G.C.BLACK, r = 0.1, minw = 9 },
        nodes = {
            text_row('Vanilla Tweaks - side-by-side comparison', G.C.UI.TEXT_LIGHT, 0.42),
            text_row('Restart Balatro, then start a new run after changing tweaks.', G.C.JOKER_GREY, 0.25),
            { n = G.UIT.R, config = { align = 'cm', padding = 0.06 }, nodes = {
                UIBox_button({ label = { 'Enable all' }, button = 'hnds_vanilla_tweaks_enable_all',
                    col = true, minw = 2.7, minh = 0.35, scale = 0.3, colour = G.C.CHIPS }),
                UIBox_button({ label = { 'Disable all' }, button = 'hnds_vanilla_tweaks_disable_all',
                    col = true, minw = 2.7, minh = 0.35, scale = 0.3, colour = G.C.RED }),
            }},
            create_option_cycle({
                options = categories, current_option = state.category,
                w = 6.5, h = 0.5, text_scale = 0.34, no_pips = true,
                opt_callback = 'hnds_vanilla_tweaks_category', colour = G.C.MONEY,
            }),
            { n = G.UIT.R, config = { align = 'cm', padding = 0 }, nodes = {{
                n = G.UIT.O, config = {
                    id = area_id,
                    object = UIBox {
                        definition = HNDS.vanilla_tweaks_comparison(),
                        config = comparison_box_config(),
                    },
                },
            }}},
        },
    }
end

-- Preserve tabs supplied by other parts of this mod.
local previous_tabs = mod.extra_tabs
mod.extra_tabs = function(...)
    local result, previous = {}, previous_tabs and previous_tabs(...) or {}
    if previous.tab_definition_function then previous = { previous } end
    for _, tab in ipairs(previous) do result[#result + 1] = tab end
    result[#result + 1] = {
        label = 'Vanilla Tweaks',
        tab_definition_function = HNDS.vanilla_tweaks_tab,
    }
    return result
end
