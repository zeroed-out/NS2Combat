ModLoader.SetupFileHook( "lua/NS2Utility.lua",			"lua/NS2_GorgeTunnel/NS2Utility.lua", "replace" )
ModLoader.SetupFileHook( "lua/PlayingTeam.lua",			"lua/NS2_GorgeTunnel/PlayingTeam.lua", "replace" )
ModLoader.SetupFileHook( "lua/TeamInfo.lua", 			"lua/NS2_GorgeTunnel/TeamInfo.lua", "replace" )
ModLoader.SetupFileHook( "lua/TechTreeConstants.lua", 	"lua/NS2_GorgeTunnel/TechTreeConstants.lua", "replace" )
ModLoader.SetupFileHook( "lua/TechData.lua", 			"lua/NS2_GorgeTunnel/TechData.lua", "replace" )
ModLoader.SetupFileHook( "lua/TechTreeButtons.lua", 	"lua/NS2_GorgeTunnel/TechTreeButtons.lua", "replace" )
ModLoader.SetupFileHook( "lua/AlienTeam.lua",			"lua/NS2_GorgeTunnel/AlienTeam.lua", "post" )
ModLoader.SetupFileHook( "lua/Balance.lua",				"lua/NS2_GorgeTunnel/Balance.lua", "post" )
ModLoader.SetupFileHook( "lua/Crag.lua",				"lua/NS2_GorgeTunnel/Crag.lua", "post" )
ModLoader.SetupFileHook( "lua/Shade.lua",				"lua/NS2_GorgeTunnel/Shade.lua", "post" )
ModLoader.SetupFileHook( "lua/Shift.lua",				"lua/NS2_GorgeTunnel/Shift.lua", "post" )
ModLoader.SetupFileHook( "lua/Whip.lua", 				"lua/NS2_GorgeTunnel/Whip.lua", "post" )
ModLoader.SetupFileHook( "lua/CommanderHelp.lua",		"lua/NS2_GorgeTunnel/CommanderHelp.lua", "replace" )
ModLoader.SetupFileHook( "lua/GUIGorgeBuildMenu.lua",	"lua/NS2_GorgeTunnel/GUIGorgeBuildMenu.lua", "replace" )
ModLoader.SetupFileHook( "lua/NetworkMessages.lua", 	"lua/NS2_GorgeTunnel/NetworkMessages.lua", "post" )
ModLoader.SetupFileHook( "lua/Tunnel.lua", 				"lua/NS2_GorgeTunnel/Tunnel.lua", "replace" )
ModLoader.SetupFileHook( "lua/TunnelEntrance.lua", 		"lua/NS2_GorgeTunnel/TunnelEntrance.lua", "replace" )
ModLoader.SetupFileHook( "lua/Weapons/Alien/DropStructureAbility.lua", "lua/NS2_GorgeTunnel/Weapons/Alien/DropStructureAbility.lua", "replace" )
--ModLoader.SetupFileHook( "lua/DigestMixin.lua", 		"lua/NS2_GorgeTunnel/DigestMixin.lua", "post" )

-- Allows Gorge Tunnel in Combat
ModLoader.SetupFileHook( "lua/Combat/Globals.lua","lua/NS2_GorgeTunnel/BalanceCombat.lua", "post" )
-- Make Gorge Toys a target for arcs in combat
ModLoader.SetupFileHook( "lua/Combat/FileHooks/Post/ARC.lua","lua/NS2_GorgeTunnel/Combat/FileHooks/Post/ARC.lua", "replace" )
-- On certain "reset" event destroy gorge structures from the player
ModLoader.SetupFileHook( "lua/Combat/Player_Upgrades.lua","lua/NS2_GorgeTunnel/Combat/Player_Upgrades.lua", "post" )

