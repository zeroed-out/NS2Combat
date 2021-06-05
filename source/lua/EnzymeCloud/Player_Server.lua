



local oldTriggerAlert = Player.TriggerAlert
function Player:TriggerAlert(techId, entity, force)
	oldTriggerAlert(self, techId, entity, force)
	
    if (kCombatEnzymeCloudDebug) then
        Print("TechId:" .. (LookupTechData(techId,kTechDataDisplayName) or LookupTechData(techId,kTechDataAlertText)))
    end

    if techId ~= kTechId.AlienAlertNeedDrifter or not entity or not entity.combatTable or not entity.combatTable.hasEnzymeCloud then
        return
    end
    local canEnzyme = entity.combatTable.lastEnzymeCloud + kEnzymeCloudAbilityCooldown <= Shared.GetTime()

	if entity:isa("Player") and entity:GetIsAlive() and canEnzyme then
		
		entity.combatTable.lastEnzymeCloud = Shared.GetTime()
        entity.lastEnzymeCloud = Shared.GetTime()
		local position = entity:GetOrigin()
        local enzyme = CreateEntity(EnzymeCloud.kMapName, position , self:GetTeamNumber())
        enzyme:TriggerEffects( "drifter_shoot_enzyme", { effecthostcoords = Coords.GetTranslation(position) } )

    elseif not canEnzyme and self then
        --local timeReady = math.abs(math.ceil(entity.combatTable.lastEnzymeCloud + kEnzymeCloudAbilityCooldown - Shared.GetTime()))
        --self:SendDirectMessage("Enzyme ready in " .. timeReady .. " sec")
    end
	
end

function Player:EnzymeNow()

    local success = false
    local globalSound = CatPack.kPickupSound
    local localSound = "sound/NS2.fev/marine/common/mine_warmup"

    -- Use one sound for global, another for local player to give more of an effect!
    StartSoundEffectAtOrigin(globalSound, self:GetOrigin())
    StartSoundEffectForPlayer(localSound, self)
    self:ApplyCatPack()
    self.lastCatPack = Shared.GetTime()
    success = true
    self:SendDirectMessage("You now have catalyst for " .. kCatPackDuration .. " secs!")
    return success

end

function Player:CheckEnzyme()

    local timeNow = Shared.GetTime()

    Print("bob3")
    if self.combatTable.hasEnzymeCloud and self:isa("Alien") and self:isa("Player") then
        if not self.combatTable.lastEnzymeCloud or (timeNow >= self.combatTable.lastEnzymeCloud + kEnzymeCloudAbilityCooldown) then
            local success = true --self:EnzymeNow()
            if success then
                self.combatTable.lastEnzymeCloud = Shared.GetTime()
                self.lastEnzymeCloud = Shared.GetTime()
                local position = self:GetOrigin()
                local enzyme = CreateEntity(EnzymeCloud.kMapName, position , self:GetTeamNumber())
                enzyme:TriggerEffects( "drifter_shoot_enzyme", { effecthostcoords = Coords.GetTranslation(position) } )
                self.combatTable.lastCatalyst = timeNow
            end
        end

    end

end

if (kCombatEnzymeCloudDebug) then
    Print("===========MyFileLoaded==================")
end


