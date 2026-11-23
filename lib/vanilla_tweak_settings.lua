-- Freeze active values at startup. UI changes affect the next launch only.
local config = SMODS.current_mod.config
config.vanillaTweaks = type(config.vanillaTweaks) == 'table' and config.vanillaTweaks or {}
HNDS.vanilla_tweaks_catalog = assert(SMODS.load_file('lib/vanilla_tweaks_catalog.lua'))()
HNDS.vanilla_tweaks_loaded = not not config.enableVanillaTweaks
local active = {}
for _, entry in ipairs(HNDS.vanilla_tweaks_catalog) do
    if entry.scope == 'setting' then
        if config.vanillaTweaks[entry.key] == nil then config.vanillaTweaks[entry.key] = true end
        active[entry.key] = HNDS.vanilla_tweaks_loaded and config.vanillaTweaks[entry.key] ~= false
    end
end
function HNDS.vanilla_tweak_enabled(key)
    return active[key] == true
end

-- Called by each locale before returning its overrides. Disabled entries must
-- fall through to the game's text instead of describing an inactive rework.
function HNDS.filter_vanilla_tweak_localization(loc)
    local sets = {
        j = 'Joker', m = 'Enhanced', c = 'Spectral', v = 'Voucher',
        tag = 'Tag', b = 'Back', stake = 'Stake', bl = 'Blind',
    }
    for key, enabled in pairs(active) do
        if not enabled then
            local set = sets[key:match('^([^_]+)_')]
            if set and loc.descriptions and loc.descriptions[set] then
                loc.descriptions[set][key] = nil
            end
        end
    end
    return loc
end
