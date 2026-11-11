HNDS = HNDS or {}

function HNDS.blind_upgrade_active()
    return not not (hnds_config and hnds_config.enableBlindUpgradeButton and G and G.GAME)
end
