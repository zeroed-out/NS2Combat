local oldTriggerAlert = Player.TriggerAlert
function Player:TriggerAlert(techId, entity, force)
	oldTriggerAlert(self, techId, entity, force)
	
    if (kCombatEnzymeCloudDebug) then
        Print("TechId:" .. (LookupTechData(techId,kTechDataDisplayName) or LookupTechData(techId,kTechDataAlertText)))
    end

    if techId ~= kTechId.AlienAlertNeedDrifter or not entity or not entity.combatTable or not entity.combatTable.hasEnzymeCloud then
        return
    end
    local canEnzyme = entity.combatTable.lastEnzymeCloud <= Shared.GetTime()

	if entity:isa("Player") and entity:GetIsAlive() and canEnzyme then
		
		local newTime = Shared.GetTime() + kEnzymeCloudAbilityCooldown
		entity.combatTable.lastEnzymeCloud = newTime
		local position = entity:GetOrigin()
        local enzyme = CreateEntity(EnzymeCloud.kMapName, position , self:GetTeamNumber())
        enzyme:TriggerEffects( "drifter_shoot_enzyme", { effecthostcoords = Coords.GetTranslation(position) } )

    elseif not canEnzyme then
        local timeReady = math.abs(entity.combatTable.lastEnzymeCloud + kEnzymeCloudAbilityCooldown - Shared.GetTime())
        entity:SendDirectMessage("Enzyme ready in " .. timeReady .. " sec")
    end		
	
end
if (kCombatEnzymeCloudDebug) then
    Print("===========MyFaileLoaded==================")
end


