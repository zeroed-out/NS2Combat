local upgrade = CombatMarineUpgrade()

--team, upgradeId, upgradeTextCode, upgradeDescription, upgradeTechId, upgradeFunc, techRequirements, levelRequirements, levels, upgradeType, refundUpgrade, hardCap, mutuallyExclusive, needsNearComm)
upgrade:Initialize(kCombatUpgrades.Sentries, "sentries", "Sentry", kTechId.DropSentry, nil, kCombatUpgrades.Welder, 5, 1, kCombatUpgradeTypes.Weapon, false, 1/3, { kCombatUpgrades.Exosuit, kCombatUpgrades.RailGunExosuit, kCombatUpgrades.DualMinigunExosuit, kCombatUpgrades.Jetpack})

table.insert(UpsList, upgrade)
