-- ======= Copyright (c) 2003-2016, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\IMModBlacklist.lua
--
--    Created by:   Sebastian Schuck (sebastian@naturalselection2.com)
--
--    Blocks incompatible mods from loading
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================
do
	local blacklist = {
		"NS2Plus",
		"NinS2Plus",
		"NS2+"
	}

	for _, modName in ipairs(blacklist) do
		local modEntry = ModLoader.GetModInfo(modName)
		if modEntry then
            Log("Blacklisting mod since incompatible: " .. modName)
			if modEntry.FileHooks then
				ModLoader.SetupFileHook( modEntry.FileHooks, "ModBlacklist.lua", "halt")
			end

			local client = decoda_name == "Client"
			local server = decoda_name == "Server"
			local predict = decoda_name == "Predict"
			local shared = client or server or predict

			if shared and modEntry.Shared then
				ModLoader.SetupFileHook( modEntry.Shared, "ModBlacklist.lua", "halt")
			end

			if client and modEntry.Client then
				ModLoader.SetupFileHook( modEntry.Client, "ModBlacklist.lua", "halt")
			elseif predict and modEntry.Predict then
				ModLoader.SetupFileHook( modEntry.Predict, "ModBlacklist.lua", "halt")
			elseif server and modEntry.Server then
				ModLoader.SetupFileHook( modEntry.Server, "ModBlacklist.lua", "halt")
			end
		end
	end
end



ModLoader.SetupFileHook( "lua/Weapons/Marine/ClipWeapon.lua", "lua/Combat/ClipWeapon.lua", "post" )
ModLoader.SetupFileHook( "lua/CommandStructure.lua", "lua/Combat/CommandStructure.lua", "post" )