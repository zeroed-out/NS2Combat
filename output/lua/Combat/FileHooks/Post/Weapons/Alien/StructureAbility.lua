--________________________________
--
--   	NS2 Combat Mod
--	Made by JimWest and MCMLXXXIV, 2012
--
--________________________________

-- combat_StructureAbility.lua

function StructureAbility:IsAllowed(player)

	local dropStructureId = self:GetDropStructureId()
	if dropStructureId == kTechId.Web or dropStructureId == kTechId.BabblerEgg then
		return GetIsTechUnlocked(player, dropStructureId)
	end

    return true
	
end
