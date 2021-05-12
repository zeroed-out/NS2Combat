function StructureAbility:IsAllowed(player)

	local dropStructureId = self:GetDropStructureId()
	if dropStructureId == kTechId.Web or dropStructureId == kTechId.BabblerEgg then
		return GetIsTechUnlocked(player, dropStructureId)
	end

    return true
	
end