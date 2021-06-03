ModLoader.SetupFileHook( "lua/CommAbilities/Alien/EnzymeCloud.lua", "lua/EnzymeCloud/EnzymeCloud.lua", "post" )
ModLoader.SetupFileHook( "lua/Combat/FileHooks/Post/Player_Server.lua", "lua/EnzymeCloud/Player_Server.lua", "post" )
ModLoader.SetupFileHook( "lua/Combat/Player_Upgrades.lua","lua/EnzymeCloud/Player_Upgrades.lua", "post" )
ModLoader.SetupFileHook( "lua/Combat/FileHooks/Post/GUIAlienHUD.lua","lua/EnzymeCloud/GUIAlienHUD.lua", "post" )
ModLoader.SetupFileHook( "lua/Combat/FileHooks/Post/Player_Client.lua", "lua/EnzymeCloud/Player_Client.lua", "post" )
--for network vars for local timers
ModLoader.SetupFileHook( "lua/Combat/FileHooks/Post/Alien.lua", "lua/EnzymeCloud/Alien.lua", "post" )
ModLoader.SetupFileHook( "lua/Weapons/Alien/Ability.lua", "lua/EnzymeCloud/Ability.lua", "post" )