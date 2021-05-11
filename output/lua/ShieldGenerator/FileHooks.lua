
ModLoader.SetupFileHook( "lua/Armory.lua", "lua/ShieldGenerator/Armory.lua", "post" )
ModLoader.SetupFileHook( "lua/Balance.lua", "lua/ShieldGenerator/Balance.lua", "post" )
ModLoader.SetupFileHook( "lua/Marine.lua", "lua/ShieldGenerator/Marine.lua", "post" )
ModLoader.SetupFileHook( "lua/Marine_Server.lua", "lua/ShieldGenerator/Marine_Server.lua", "post" )
ModLoader.SetupFileHook( "lua/TechData.lua", "lua/ShieldGenerator/TechData.lua", "post" )
ModLoader.SetupFileHook( "lua/TechTreeConstants.lua", "lua/ShieldGenerator/TechTreeConstants.lua", "post" )
ModLoader.SetupFileHook( "lua/TechTreeButtons.lua", "lua/ShieldGenerator/TechTreeButtons.lua", "post" )
ModLoader.SetupFileHook( "lua/MarineBuy_Client.lua", "lua/ShieldGenerator/MarineBuy_Client.lua", "post" )
ModLoader.SetupFileHook( "lua/MarineTeam.lua", "lua/ShieldGenerator/MarineTeam.lua", "post" )
ModLoader.SetupFileHook( "lua/NS2ConsoleCommands_Server.lua", "lua/ShieldGenerator/NS2ConsoleCommands_Server.lua", "post" )
ModLoader.SetupFileHook( "lua/GUIMarineBuyMenu.lua", "lua/ShieldGenerator/GUIMarineBuyMenu.lua", "post" )
ModLoader.SetupFileHook( "lua/MarineTechMap.lua", "lua/ShieldGenerator/MarineTechMap.lua", "post" )
--ModLoader.SetupFileHook( "lua/UnitStatusMixin.lua", "lua/ShieldGenerator/UnitStatusMixin.lua", "post" )
ModLoader.SetupFileHook( "lua/Hud/Marine/GUIMarineStatus.lua", "lua/ShieldGenerator/GUIMarineStatus.lua", "post" )

ModLoader.SetupFileHook( "lua/Player_Server.lua", "lua/ShieldGenerator/Player_Server.lua", "post" )

-- add to combat!
ModLoader.SetupFileHook( "lua/Combat/ExperienceData.lua", "lua/ShieldGenerator/Combat/ExperienceData.lua", "post" )
ModLoader.SetupFileHook( "lua/Combat/ExperienceEnums.lua", "lua/ShieldGenerator/Combat/ExperienceEnums.lua", "post" )
ModLoader.SetupFileHook( "lua/Combat/MarineBuyFuncs.lua", "lua/ShieldGenerator/Combat/MarineBuyFuncs.lua", "post" )
ModLoader.SetupFileHook( "lua/Combat/Player_Upgrades.lua", "lua/ShieldGenerator/Combat/Player_Upgrades.lua", "post" )
ModLoader.SetupFileHook( "lua/Combat/FileHooks/Post/Player_Server.lua", "lua/ShieldGenerator/Combat/Player_Server.lua", "post" )