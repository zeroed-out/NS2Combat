-- Sets up the combat tech data
-- Todo: Make some of it configable for server ops
Script.Load("lua/TechTreeConstants.lua")
Script.Load("lua/Combat/ExperienceLevels.lua")
Script.Load("lua/Combat/ExperienceEnums.lua")
Script.Load("lua/Combat/ExperienceFuncs.lua")

-- default start points
kCombatStartUpgradePoints = 0

-- How often to upgrade the counts for upgrades (secs)
kCombatUpgradeUpdateInterval = 1

-- How much lvl you will lose when you rejoin the same team
kCombatPenaltyLevel = 1

-- how much % from the avg xp can new player get
avgXpAmount = 0.5

-- how much % from the xp are the m8 nearby getting and the range
mateXpAmount = 0.5

-- range 35 was too big
mateXpRange = 20

-- how much % from the xp are the assisters are getting
assistXpAmount = 1.0

assistXPRange = 15
assistLOSXPRange = 40

-- how much to divide the XP between nearby players?
-- e.g. set to 1 to divide equally among nearby assisters
--      or set it to 0 to give all nearby assisters max XP
assistPlayerRatio = 0.9

baseXpForKill = 60
-- extra bonus xp given per level difference
extraXpPerLevelDiff = 20

-- XP-Values
-- Scores for various creatures and structures.
XpValues = {}
XpValues["Marine"] = 0
XpValues["Skulk"] = 0
XpValues["Gorge"] = 10
XpValues["Lerk"] = 20
XpValues["Fade"] = 40
XpValues["Onos"] = 50
XpValues["Exo"] = 50
XpValues["Exosuit"] = 50
XpValues["Jetpack"] = 25
XpValues["Hydra"] = 5
XpValues["Babbler"] = 2
XpValues["Clog"] = 1
XpValues["Cyst"] = 10
XpValues["Armory"] = 250
XpValues["CommandStation"] = 400
XpValues["PowerPoint"] = 0
XpValues["Extractor"] = 0
XpValues["Hive"] = 400
XpValues["ARC"] = 120
XpValues["Whip"] = 25
XpValues["Crag"] = 25
XpValues["Shift"] = 25
XpValues["Shade"] = 25
XpValues["Sentry"] = 25
XpValues["Tunnel"] = 25
XpValues["Egg"] = 25

local function UpgradeArmor(player, techUpgrade)
	techUpgrade:ExecuteTechUpgrade(player)
	player:UpdateArmorAmount()
end

local function GiveJetpack(player)
	local jetpackMarine = player:GiveJetpack()
	-- get jp back after respawn
	jetpackMarine.combatTable.giveClassAfterRespawn = JetpackMarine.kMapName
	jetpackMarine:GiveUpsBack()
	jetpackMarine:UpdateArmorAmount()
	return jetpackMarine
end
local function GiveExoAndStoreWeapons(kMapName, player, layout)
	local weapons = player:GetWeapons()
	for i = 1, #weapons do
		weapons[i]:SetParent(nil)
	end
	local exo = player:Replace(kMapName, player:GetTeamNumber(), false, player:GetOrigin(), layout)

	if exo then
		for i = 1, #weapons do
			exo:StoreWeapon(weapons[i])
		end
	end

	return exo
end
local function GiveExo(player)
	local exoMarine = GiveExoAndStoreWeapons(Exo.kMapName, player, { layout = "ClawMinigun" })
	-- powering up, dont let him move
	exoMarine:BlockMove()
	exoMarine:SetCameraDistance(2)
	exoMarine:SendDirectMessage("Powering up. You have to wait " .. kExoPowerUpTime .. " sec untill you can move again.")
	exoMarine.poweringUpFinishedTime = Shared.GetTime() + kExoPowerUpTime
	exoMarine:GiveUpsBack()
	exoMarine:UpdateArmorAmount()
	return exoMarine
end

local function GiveExoDualMinigun(player)
	local exoMarine = GiveExoAndStoreWeapons(Exo.kMapName, player, { layout = "MinigunMinigun" })
	-- powering up, dont let him move
	exoMarine:BlockMove()
	exoMarine:SetCameraDistance(2)
	exoMarine:SendDirectMessage("Powering up. You have to wait " .. kExoPowerUpTime .. " sec untill you can move again.")
	exoMarine.poweringUpFinishedTime = Shared.GetTime() + kExoPowerUpTime
	exoMarine:GiveUpsBack()
	exoMarine:UpdateArmorAmount()

	return exoMarine
end

local function GiveExoRailGun(player)
	local exoMarine = GiveExoAndStoreWeapons(Exo.kMapName, player, { layout = "ClawRailgun" })
	-- powering up, dont let him move
	exoMarine:BlockMove()
	exoMarine:SetCameraDistance(2)
	exoMarine:SendDirectMessage("Powering up. You have to wait " .. kExoPowerUpTime .. " sec untill you can move again.")
	exoMarine.poweringUpFinishedTime = Shared.GetTime() + kExoPowerUpTime
	exoMarine:GiveUpsBack()
	exoMarine:UpdateArmorAmount()

	return exoMarine
end

local function GiveExoDualRailGun(player)
	local exoMarine = GiveExoAndStoreWeapons(Exo.kMapName, player, { layout = "RailgunRailgun" })
	-- powering up, dont let him move
	exoMarine:BlockMove()
	exoMarine:SetCameraDistance(2)
	exoMarine:SendDirectMessage("Powering up. You have to wait " .. kExoPowerUpTime .. " sec untill you can move again.")
	exoMarine.poweringUpFinishedTime = Shared.GetTime() + kExoPowerUpTime
	exoMarine:GiveUpsBack()
	exoMarine:UpdateArmorAmount()

	return exoMarine
end

local function TierTwo(player)
	player.combatTwoHives = true
	player.combatTable.twoHives = true
	player.twoHives = true
end

local function TierThree(player)
	player.combatThreeHives = true
	player.combatTable.threeHives = true
	player.threeHives = true
end

local function GiveCamo(player)
	player.combatTable.hasCamouflage = true
end

local function Scan(player)
	player.combatTable.hasScan = true
	player.combatTable.lastScan = 0
end

local function Resupply(player)
	player.combatTable.hasResupply = true
	player.combatTable.lastResupply = 0
end
local function ImprovedResupply(player)
	Resupply(player)
	player.combatTable.hasImprovedResupply = true
end

local function Catalyst(player)
	player.combatTable.hasCatalyst = true
	player.combatTable.lastCatalyst = 0
end

local function EMP(player)
	player.combatTable.hasEMP = true
	player.combatTable.lastEMP = 0
	player:SendDirectMessage("You got EMP-taunt, use your taunt key to activate it")
end

local function ShadeInk(player)
	player.combatTable.hasInk = true
	player.combatTable.lastInk = 0
	player:SendDirectMessage("You got Ink-taunt, use your taunt key to activate it")
end

local function GiveWelder(player, techUpgrade)
	techUpgrade:ExecuteTechUpgrade(player)
	player.combatTable.justGotWelder = true

	-- SwitchWeapon here doesn't work - move it further along...
	--player:SwitchWeapon(1)
end

local function FastReload(player)
	player.combatTable.hasFastReload = true
end
local function FastSprint(player)
	player.combatTable.hasFastSprint = true
end

-- Helper function to build upgrades for us.
local function BuildUpgrade(team, upgradeId, upgradeTextCode, upgradeDescription, upgradeTechId, upgradeFunc, requirements, levels, upgradeType, refundUpgrade, hardCap, mutuallyExclusive, needsNearComm)
	local upgrade

	if team == "Marine" then
		upgrade = CombatMarineUpgrade()
	else
		upgrade = CombatAlienUpgrade()
	end
	upgrade:Initialize(upgradeId, upgradeTextCode, upgradeDescription, upgradeTechId, upgradeFunc, requirements, levels, upgradeType, refundUpgrade, hardCap, mutuallyExclusive, needsNearComm)

	return upgrade
end

UpsList = {}

-- Marine Upgrades
-- Parameters:        				team,	 upgradeId, 							upgradeTextCode, 	upgradeDesc, 		upgradeTechId, 					upgradeFunc, 		requirements, 				levels, upgradeType,				refundUpgrade,	hardCapScale,	mutuallyExclusive, needsNearComm
-- Start with classes
table.insert(UpsList, BuildUpgrade("Marine", kCombatUpgrades.Jetpack,				"jp",				"Jetpack",			kTechId.Jetpack, 				GiveJetpack, 		nil, 	3, 		kCombatUpgradeTypes.Class,	false,			1/2,			{ kCombatUpgrades.Exosuit, kCombatUpgrades.RailGunExosuit, kCombatUpgrades.DualMinigunExosuit, kCombatUpgrades.Sentries}))
--table.insert(UpsList, BuildUpgrade("Marine", kCombatUpgrades.Exosuit,				"exo",			    "Exosuit",			kTechId.Exosuit, 	       		GiveExo,        	kCombatUpgrades.Armor2, 	5, 		kCombatUpgradeTypes.Class,	true,			1/7,		{kCombatUpgrades.DualMinigunExosuit, kCombatUpgrades.Jetpack, kCombatUpgrades.Sentries, kCombatUpgrades.ShieldGenerator} ))
if not kCombatCompMode then
	table.insert(UpsList, BuildUpgrade("Marine", kCombatUpgrades.DualMinigunExosuit,	"dualminigun",		"Dual Minigun Exo",	kTechId.DualMinigunExosuit, 	GiveExoDualMinigun, nil, 	7, 		kCombatUpgradeTypes.Class,  true,			1/14,		{ kCombatUpgrades.Exosuit, kCombatUpgrades.RailGunExosuit, kCombatUpgrades.Jetpack, kCombatUpgrades.Sentries, kCombatUpgrades.ShieldGenerator}, true ))
	table.insert(UpsList, BuildUpgrade("Marine", kCombatUpgrades.RailGunExosuit,	    "railgun",		    "Dual Railgun Exo",	kTechId.DualRailgunExosuit, 	GiveExoDualRailGun,      nil, 	7, 		kCombatUpgradeTypes.Class,  true,			1/14,		{ kCombatUpgrades.Exosuit, kCombatUpgrades.DualMinigunExosuit, kCombatUpgrades.Jetpack, kCombatUpgrades.Sentries, kCombatUpgrades.ShieldGenerator}, true ))
end

-- Weapons
table.insert(UpsList, BuildUpgrade("Marine", kCombatUpgrades.Welder,				"welder",			"Welder",			kTechId.Welder, 				GiveWelder, 		nil, 						1, 		kCombatUpgradeTypes.Weapon, false,			0,			nil))
table.insert(UpsList, BuildUpgrade("Marine", kCombatUpgrades.Shotgun,				"sg",				"Shotgun",			kTechId.Shotgun, 				nil, 				nil, 	2, 		kCombatUpgradeTypes.Weapon, true,			1/2,			{kCombatUpgrades.Flamethrower, kCombatUpgrades.GrenadeLauncher }))
table.insert(UpsList, BuildUpgrade("Marine", kCombatUpgrades.HeavyMachineGun,		"hmg",				"Machine Gun",		kTechId.HeavyMachineGun, 		nil, 				nil, 	2, 		kCombatUpgradeTypes.Weapon, true,			1/3,			{kCombatUpgrades.Flamethrower, kCombatUpgrades.GrenadeLauncher, kCombatUpgrades.Shotgun }, true ))

if not kCombatCompMode then

	table.insert(UpsList, BuildUpgrade("Marine", kCombatUpgrades.Mines,					"mines",			"Mines",			kTechId.LayMines, 				nil, 				kCombatUpgrades.Welder, 						1, 		kCombatUpgradeTypes.Weapon, false,			0,			nil))
	table.insert(UpsList, BuildUpgrade("Marine", kCombatUpgrades.Flamethrower,			"flame",			"Flamethrower",		kTechId.Flamethrower, 			nil, 				nil, 	2, 		kCombatUpgradeTypes.Weapon, true,			1/5,			{ kCombatUpgrades.GrenadeLauncher, kCombatUpgrades.HeavyMachineGun, kCombatUpgrades.Shotgun }, true ))
	table.insert(UpsList, BuildUpgrade("Marine", kCombatUpgrades.GrenadeLauncher,		"gl",				"Grenade Launcher",	kTechId.GrenadeLauncher, 		nil, 				nil, 	2, 		kCombatUpgradeTypes.Weapon, true,			1/4,		{kCombatUpgrades.Flamethrower, kCombatUpgrades.HeavyMachineGun, kCombatUpgrades.Shotgun }, true ))

	table.insert(UpsList, BuildUpgrade("Marine", kCombatUpgrades.ClusterGrenade,		"clustergrenade",	"ClusterGrenade",	kTechId.ClusterGrenade, 		nil, 		kCombatUpgrades.Welder, 	1, 		kCombatUpgradeTypes.Weapon,   false,			0,			{ kCombatUpgrades.GasGrenade, kCombatUpgrades.PulseGrenade}))
	table.insert(UpsList, BuildUpgrade("Marine", kCombatUpgrades.PulseGrenade,			"pulsegrenade",		"PulseGrenade",		kTechId.PulseGrenade, 			nil, 		kCombatUpgrades.Welder, 	1, 		kCombatUpgradeTypes.Weapon,   false,			0,			{ kCombatUpgrades.ClusterGrenade, kCombatUpgrades.GasGrenade}))

end

table.insert(UpsList, BuildUpgrade("Marine", kCombatUpgrades.GasGrenade,			"gasgrenade",		"GasGrenade",		kTechId.GasGrenade, 			nil, 		kCombatUpgrades.Welder, 	1, 		kCombatUpgradeTypes.Weapon,   false,			0,			{ kCombatUpgrades.ClusterGrenade, kCombatUpgrades.PulseGrenade}))

-- Tech
table.insert(UpsList, BuildUpgrade("Marine", kCombatUpgrades.Weapons1,				"dmg1",				"Damage 1",			kTechId.Weapons1, 				nil, 				nil, 						1, 		kCombatUpgradeTypes.Tech,   false,			0,			nil))
table.insert(UpsList, BuildUpgrade("Marine", kCombatUpgrades.Weapons2,				"dmg2",				"Damage 2",			kTechId.Weapons2, 				nil, 				kCombatUpgrades.Weapons1,	1, 		kCombatUpgradeTypes.Tech,   false,			0,			nil))
table.insert(UpsList, BuildUpgrade("Marine", kCombatUpgrades.Weapons3,				"dmg3",				"Damage 3",			kTechId.Weapons3, 				nil, 				kCombatUpgrades.Weapons2, 	1, 		kCombatUpgradeTypes.Tech,   false,			0,			nil))
table.insert(UpsList, BuildUpgrade("Marine", kCombatUpgrades.Armor1,				"arm1",				"Armor 1",			kTechId.Armor1, 				UpgradeArmor, 		nil, 						1, 		kCombatUpgradeTypes.Tech,   false,			0,			nil))
table.insert(UpsList, BuildUpgrade("Marine", kCombatUpgrades.Armor2,				"arm2",				"Armor 2",			kTechId.Armor2, 				UpgradeArmor, 		kCombatUpgrades.Armor1,		1, 		kCombatUpgradeTypes.Tech,   false,			0,			nil))
table.insert(UpsList, BuildUpgrade("Marine", kCombatUpgrades.Armor3,				"arm3",				"Armor 3",			kTechId.Armor3, 				UpgradeArmor, 		kCombatUpgrades.Armor2, 	1, 		kCombatUpgradeTypes.Tech,   false,			0,			nil))

-- Add motion detector, scanner, resup, catpacks as available...
table.insert(UpsList, BuildUpgrade("Marine", kCombatUpgrades.Resupply,				"resup",			"Resupply",			kTechId.MedPack , 	       		Resupply,    		nil, 	                    1, 		kCombatUpgradeTypes.Tech,   false,			0,			nil))
if not kCombatCompMode then
	table.insert(UpsList, BuildUpgrade("Marine", kCombatUpgrades.ImprovedResupply,	"impresup",			"Improved Resupply",kTechId.AmmoPack , 	    ImprovedResupply,    		kCombatUpgrades.Resupply, 	1, 		kCombatUpgradeTypes.Tech,   false,			0,			nil))
	table.insert(UpsList, BuildUpgrade("Marine", kCombatUpgrades.Scanner,				"scan",				"Scanner",			kTechId.Scan, 			   		Scan, 	      		kCombatUpgrades.Mines,                     	1, 		kCombatUpgradeTypes.Tech,   false,			0,			nil))
	table.insert(UpsList, BuildUpgrade("Marine", kCombatUpgrades.Catalyst,				"cat",				"Catalyst",			kTechId.CatPack , 	       		Catalyst,  			kCombatUpgrades.ImprovedResupply, 	                    1, 		kCombatUpgradeTypes.Tech,   false,			0,			nil))
	table.insert(UpsList, BuildUpgrade("Marine", kCombatUpgrades.EMP,   				"emp",			    "EMP-Taunt",		kTechId.MACEMP , 	       		EMP,        		nil, 	                   99, 		kCombatUpgradeTypes.Tech,   false,			0,			nil))
	table.insert(UpsList, BuildUpgrade("Marine", kCombatUpgrades.FastReload,   		    "fastreload",		"Fast Reload",		kTechId.AdvancedWeaponry, 		FastReload,   	    kCombatUpgrades.Weapons2, 	                    2, 		kCombatUpgradeTypes.Tech,   false,			0,			{ kCombatUpgrades.Exosuit, kCombatUpgrades.RailGunExosuit, kCombatUpgrades.DualMinigunExosuit}))
	table.insert(UpsList, BuildUpgrade("Marine", kCombatUpgrades.FastSprint,   		    "fastsprint",		"Improved Sprint",		kTechId.PhaseTech, 		FastSprint,   	    nil, 	                    1, 		kCombatUpgradeTypes.Tech,   false,			0,			nil))
end

-- Alien Upgrades
local kLerkHardCapScale = 1/2.5
local kFadeHardCapScale = 1/4
local kGorgeHardCapScale = 1/3
local kOnosHardCapScale = 1/7

-- Parameters:        				team,	 upgradeId, 							upgradeTextCode, 	upgradeDesc, 		upgradeTechId, 					upgradeFunc, 		requirements, 				levels, upgradeType,                refundUpgrade,	hardCapScale,			mutuallyExclusive, needsNearComm
table.insert(UpsList, BuildUpgrade("Alien", kCombatUpgrades.Gorge,					"gorge",			"Gorge",			kTechId.Gorge, 					nil, 				nil, 						1, 		kCombatUpgradeTypes.Class,  true,			kGorgeHardCapScale,		nil))
table.insert(UpsList, BuildUpgrade("Alien", kCombatUpgrades.Lerk,					"lerk",				"Lerk",				kTechId.Lerk, 					nil, 				nil,              	kLerkCost, 		kCombatUpgradeTypes.Class,  true,			kLerkHardCapScale,		nil))
table.insert(UpsList, BuildUpgrade("Alien", kCombatUpgrades.Fade,					"fade",				"Fade",				kTechId.Fade, 					nil, 				nil,              	kFadeCost, 		kCombatUpgradeTypes.Class,  true,			kFadeHardCapScale,		nil))
table.insert(UpsList, BuildUpgrade("Alien", kCombatUpgrades.Onos,					"onos",				"Onos",				kTechId.Onos, 					nil, 				nil,              	kOnosCost, 		kCombatUpgradeTypes.Class,  true,			kOnosHardCapScale,	    nil, true))

-- Tech
table.insert(UpsList, BuildUpgrade("Alien", kCombatUpgrades.Carapace,				"cara",				"Carapace",			kTechId.Carapace, 				nil, 				nil, 						1, 		kCombatUpgradeTypes.Tech,   false,			0,			nil))
table.insert(UpsList, BuildUpgrade("Alien", kCombatUpgrades.Regeneration,			"regen",			"Regeneration",		kTechId.Regeneration, 			nil, 				nil, 						1, 		kCombatUpgradeTypes.Tech,   false,			0,			nil))
table.insert(UpsList, BuildUpgrade("Alien", kCombatUpgrades.Vampirism,				"vampirism",        "Vampirism",	    kTechId.Vampirism, 				nil,				nil, 						1, 		kCombatUpgradeTypes.Tech,   false,			0,			nil))
if not kCombatCompMode then
	table.insert(UpsList, BuildUpgrade("Alien", kCombatUpgrades.Camouflage,				"camouflage",        "Camouflage",	    kTechId.Camouflage, 			GiveCamo,				nil, 						1, 		kCombatUpgradeTypes.Tech,   false,			0,			nil))
	table.insert(UpsList, BuildUpgrade("Alien", kCombatUpgrades.Aura,					"aura",				"Aura",				kTechId.Aura, 					nil, 				kCombatUpgrades.TierTwo, 						1, 		kCombatUpgradeTypes.Tech,   false,			0,			nil))
	table.insert(UpsList, BuildUpgrade("Alien", kCombatUpgrades.ShadeInk,				"ink",		        "Ink-Taunt",		kTechId.ShadeInk, 		   	 	ShadeInk,			nil, 						1, 		kCombatUpgradeTypes.Tech,   false,			0,			nil))
	table.insert(UpsList, BuildUpgrade("Alien", kCombatUpgrades.Focus,				    "focus",			"Focus",			kTechId.Focus, 			        nil, 			    kCombatUpgrades.TierTwo,	                    1, 		kCombatUpgradeTypes.Tech,   false,			0,			nil))
end
table.insert(UpsList, BuildUpgrade("Alien", kCombatUpgrades.Celerity,				"cele",				"Celerity",			kTechId.Celerity, 				nil, 				nil, 						1, 		kCombatUpgradeTypes.Tech,   false,			0,			nil))
table.insert(UpsList, BuildUpgrade("Alien", kCombatUpgrades.Adrenaline,				"adrenaline",		"Adrenaline",		kTechId.Adrenaline, 			nil, 				nil, 						1, 		kCombatUpgradeTypes.Tech,   false,			0,			nil))
table.insert(UpsList, BuildUpgrade("Alien", kCombatUpgrades.Crush,				    "crush",		    "Crush",		    kTechId.Crush, 			        nil, 				nil, 						1, 		kCombatUpgradeTypes.Tech,   false,			0,			nil))



table.insert(UpsList, BuildUpgrade("Alien", kCombatUpgrades.TierTwo,				"tier2",			"Tier 2 abilities",			kTechId.BioMassTwo, 			TierTwo, 			nil, 						2, 		kCombatUpgradeTypes.Tech,   false,			0,			nil))
table.insert(UpsList, BuildUpgrade("Alien", kCombatUpgrades.TierThree,				"tier3",			"Tier 3 abilities",			kTechId.BioMassThree, 			TierThree, 			kCombatUpgrades.TierTwo,	2, 		kCombatUpgradeTypes.Tech,   false,			0,			nil))
