
local oldCombatMarineBuy_GUISortUps = CombatMarineBuy_GUISortUps
function CombatMarineBuy_GUISortUps(upgradeList)

	local sentryUpgrade
	for _, upgrade in ipairs(upgradeList) do
		if upgrade:GetTechId() == kTechId.DropSentry then
			sentryUpgrade = upgrade
			break
		end
	end

	local oldList = oldCombatMarineBuy_GUISortUps(upgradeList)

	if sentryUpgrade then
		for index, entry in ipairs(oldList) do
			if entry.GetTechId and entry:GetTechId() == kTechId.Jetpack then
				table.insert(oldList, index+1, sentryUpgrade)
				break
			end
		end
	end

	return oldList
	
end

local oldDescFunc = CombatMarineBuy_GetWeaponDescription
function CombatMarineBuy_GetWeaponDescription(techId)
	if techId == kTechId.DropSentry then
		return "You get one AI sentry gun. Requires Welder and Level 5."
	end
	return oldDescFunc(techId)
end
