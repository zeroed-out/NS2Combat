
-- Gestate Times
kGestateTime = {}
kGestateTime[kTechId.Skulk] = 1
kGestateTime[kTechId.Gorge] = 2
kGestateTime[kTechId.Lerk] = 3
kGestateTime[kTechId.Fade] = 4
kGestateTime[kTechId.Onos] = 5
kSkulkGestateTime = kGestateTime[kTechId.Skulk]

-- Power points
kPowerPointHealth = 1200
kPowerPointArmor = 500
kPowerPointPointValue = 0
kCombatPowerPointAutoRepairTime = 300

-- kill hydras if the player is not a gorge after 30 seconds
kKillHydrasWhenNotGorge = true

-- Ammo for mines
kNumMines = 2
kMaxNumMines = 2

-- number of handgrenaeds
kMaxHandGrenades = 2

-- Health values
-- Make the marine structures slightly less squishy...
kArmoryHealth = 3500
kCommandStationHealth = 6000

-- nerf range of xeno
kXenocideRange = 9

-- EMP energy drain
kEMPBlastEnergyDamage = 75

-- Timers for Scan, Resupply and Catalyst packs.
kScanTimer = 12
kResupplyTimer = 5
kImprovedResupplyExtra = 5
AmmoPack.kNumClips = 1
kCatalystTimer = 10

-- Scan Duration, maybe we need to tune it a bit
kScanDuration = 6

-- Make these less "spammy"
kEMPTimer = 30
kInkTimer = 20
kCombatInkOnSighted = false

-- reduce ink amount a bit
ShadeInk.kShadeInkDisorientRadius = 9
kCombatTauntCheckInterval = 4

kSprintSpeedUpgradeScalar = 3.5

kARCSpawnFrequency = 90

kShadeInkDuration = 5

--Focus revert

kFocusDamageBonusAtMax = 0.34
kSpitFocusAttackSlowAtMax = .165
kSpitFocusDamageBonusAtMax = 0.5

--web charge reduction

kWebMaxCharges = 2

--sentry changes
kSentryDamage = 8 --default 5
kSentryHealth = 400 --default 500
kSentryArmor = 50 --default 100
kSentryBuildTime = 5

--Digest speed Reduction
kHydraDigestDuration = 0.5
