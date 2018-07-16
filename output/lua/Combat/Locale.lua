-- Override the vanilla localization system with our own (using lua files instead of txt)
do
	local gamestringsFiles = {}

	kCombatLocaleMessages = {}
	Shared.GetMatchingFileNames("gamestrings/combat_*.lua", false, gamestringsFiles)
    

	for i = 1, #gamestringsFiles do
	local file = gamestringsFiles[i]
        if Server then
            Server.AddRestrictedFileHashes(file)
        end
		Script.Load(file)
	end

end

local defaultLang = "enUS"

-- Replace the normal Locale.ResolveString with our own version!
if Locale then
	local NS2ResolveFunction = Locale.ResolveString

	function Combat_ResolveString(input)
		if not input then return "" end

		local lang = Locale.GetLocale()
		local resolvedString
		if kCombatLocaleMessages[lang] and kCombatLocaleMessages[lang][input] then
			resolvedString = kCombatLocaleMessages[lang][input]
		elseif kCombatLocaleMessages[defaultLang] and kCombatLocaleMessages[defaultLang][input] then
			resolvedString = kCombatLocaleMessages[defaultLang][input]
		else
			resolvedString = NS2ResolveFunction(input)
		end

		return resolvedString

	end

	Locale.ResolveString = Combat_ResolveString
end