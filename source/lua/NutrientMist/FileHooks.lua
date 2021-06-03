ModLoader.SetupFileHook( "lua/CommAbilities/Alien/NutrientMist.lua", "lua/NutrientMist/NutrientMist.lua", "post" )
ModLoader.SetupFileHook( "lua/MaturityMixin.lua", "lua/NutrientMist/MaturityMixin.lua", "post" )
ModLoader.SetupFileHook( "lua/Combat/FileHooks/Post/Player_Server.lua", "lua/NutrientMist/Player_Server.lua", "post" )
ModLoader.SetupFileHook( "lua/Combat/Player_Upgrades.lua","lua/NutrientMist/Player_Upgrades.lua", "post" )
ModLoader.SetupFileHook( "lua/Combat/FileHooks/Post/GUIAlienHUD.lua","lua/NutrientMist/GUIAlienHUD.lua", "post" )
ModLoader.SetupFileHook( "lua/Combat/FileHooks/Post/Player_Client.lua", "lua/NutrientMist/Player_Client.lua", "post" )
--for network vars for local timers
ModLoader.SetupFileHook( "lua/Combat/FileHooks/Post/Alien.lua", "lua/NutrientMist/Alien.lua", "post" )