-- Focus
kCombatFocusAttackSpeed = 0.6
kCombatFocusDamageScalar = 1.4

-- Gestate Times
kGestateTime = {}
kGestateTime[kTechId.Skulk] = 1
kGestateTime[kTechId.Gorge] = 2
kGestateTime[kTechId.Lerk] = 2
kGestateTime[kTechId.Fade] = 3
kGestateTime[kTechId.Onos] = 6
kSkulkGestateTime = kGestateTime[kTechId.Skulk]

-- Power points
kPowerPointHealth = 1200
kPowerPointArmor = 500
kPowerPointPointValue = 0
kCombatPowerPointAutoRepairTime = 300

-- Grenade Launcher nerf
kGrenadeLauncherGrenadeDamage = 135

-- Ammo for mines
kNumMines = 1

-- number of handgrenaeds
kMaxHandGrenades = 1

-- Health values
-- Make the marine structures slightly less squishy...
kArmoryHealth = 3500
kCommandStationHealth = 6000

-- nerf range of xeno
kXenocideRange = 9

-- EMP energy drain
kEMPBlastEnergyDamage = 75

-- Timers for Scan, Resupply and Catalyst packs.
kScanTimer = 14
kResupplyTimer = 6
AmmoPack.kNumClips = 1
kCatalystTimer = 14

-- Scan Duration, maybe we need to tune it a bit
kScanDuration = 7

-- Make these less "spammy"
kEMPTimer = 30
kInkTimer = 30
-- reduce ink amount a bit
ShadeInk.kShadeInkDisorientRadius = 9
kCombatTauntCheckInterval = 4

kSprintSpeedUpgradeScalar = 3.25