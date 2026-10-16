HNDS = HNDS or {}

function HNDS.blind_upgrade_active()
    if not (hnds_config and hnds_config.enableBlindUpgradeButton and G and G.GAME) then
        return false
    end

    local modifiers = G.GAME.modifiers or {}
    if modifiers.hnds_blue_stake_upgrades or modifiers.hnds_nightmare_stake then
        return true
    end

    local blue = G.P_STAKES and G.P_STAKES.stake_blue
    local current = G.GAME.stake
    if type(current) == 'string' and G.P_STAKES and G.P_STAKES[current] then
        current = G.P_STAKES[current].order
    end
    return blue and tonumber(blue.order) ~= nil and tonumber(current) ~= nil
        and tonumber(current) >= tonumber(blue.order) or false
end

if hnds_config and hnds_config.enableBlindUpgradeButton then
    SMODS.Stake:take_ownership('blue', {
        modifiers = function()
            G.GAME.modifiers = G.GAME.modifiers or {}
            G.GAME.modifiers.hnds_blue_stake_upgrades = true
        end,
    }, true)
end
