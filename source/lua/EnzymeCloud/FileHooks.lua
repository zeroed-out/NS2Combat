ModLoader.SetupFileHook( "lua/CommAbilities/Alien/EnzymeCloud.lua", "lua/EnzymeCloud/EnzymeCloud.lua", "post" )
ModLoader.SetupFileHook( "lua/EnzymeCloudMixin.lua", "lua/NutrientMist/MaturityMixin.lua", "post" )
ModLoader.SetupFileHook( "lua/Combat/FileHooks/Post/Player_Server.lua", "lua/NutrientMist/Player_Server.lua", "post" )
ModLoader.SetupFileHook( "lua/Combat/FileHooks/Post/AlienTeam.lua", "lua/EnzymeCloud/AlienTeam.lua", "post" )
