do
	local blacklist = {
		"NS2Plus",
		"NinS2Plus",
		"NS2+"
	}

	for _, modName in ipairs(blacklist) do
		local modEntry = ModLoader.GetModInfo(modName)
		if modEntry then
            Log("Blacklisting mod since incompatible: %s", modName)
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

kCombatVersion = 5.21

local function SetupFilehookFolder(folderPath, modPath, hookType)
	local files = {}
	local path = string.format("%s*.lua", folderPath)
	Shared.GetMatchingFileNames(path, true, files)

	--Log("Loading %s Filehooks: %s", hookType, files)

	for i = 1, #files do
		local filePath = files[i]
		local vanillaFilePath = string.gsub(filePath, modPath, "")
		ModLoader.SetupFileHook(vanillaFilePath, filePath, hookType)
	end

end

local function SetupFilehookFolders(modPath)
	local folders = { "Halt", "Post", "Pre", "Replace" }
	for i = 1, #folders do
		local hookType = folders[i]
		local modPath = string.format("%s/%s/", modPath, hookType)
		local folderPath = string.format("lua/%s", modPath)
		SetupFilehookFolder(folderPath, modPath, string.lower(hookType))
	end
end

SetupFilehookFolders("Combat/FileHooks")