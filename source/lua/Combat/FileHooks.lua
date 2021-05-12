
kCombatVersion = 6.1

-- Setup Filehooks based on the folder structure inside the FileHooks folder
-- Warning: Paths are case sensitive at Linux
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

local hookedFolder = "Combat/FileHooks"
if Server then
	Server.AddRestrictedFileHashes(hookedFolder .. "/*")
end
SetupFilehookFolders(hookedFolder)

-- fix for ns2_co_core that includes the old water mod that breaks the server
-- TODO: Only block the water mod when loading broken water mods
ModLoader.SetupFileHook("lua/water_Client.lua", "", "halt")
ModLoader.SetupFileHook("lua/water_Server.lua", "", "halt")
ModLoader.SetupFileHook("lua/water_Predict.lua", "", "halt")
ModLoader.SetupFileHook("lua/water_Shared.lua", "", "halt")