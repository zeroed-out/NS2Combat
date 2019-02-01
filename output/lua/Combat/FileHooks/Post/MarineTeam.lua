
local oldResetTeam = MarineTeam.ResetTeam
function MarineTeam:ResetTeam()
	local oldReturn = oldResetTeam(self)
	
	self.lastArcSpawn = Shared.GetTime()
	
	return oldReturn
end

function MarineTeam:SpawnWarmUpStructures()
end

function MarineTeam:SpawnInitialStructures(techPoint)

    self.startTechPoint = techPoint
    
    local tower, commandStation = PlayingTeam.SpawnInitialStructures(self, techPoint)

	--Check if there is already an Armory
	if #GetEntitiesForTeam("Armory", self:GetTeamNumber()) == 0 then	
		-- Don't Spawn an IP, make an armory instead!
		-- spawn initial Armory for marine team
		local techPointOrigin = techPoint:GetOrigin() + Vector(0, 2, 0)
		
		for i = 1, kSpawnArmoryMaxRetries do
			-- Increase the spawn distance on a gradual basis.
			local origin = CalculateRandomSpawn(nil, techPointOrigin, kTechId.Armory, true, kArmorySpawnMinDistance, (kArmorySpawnMaxDistance * i / kSpawnArmoryMaxRetries), nil)

			if origin then			
				local armory = CreateEntity(Armory.kMapName, origin - Vector(0, 0.1, 0), self:GetTeamNumber())
				
				SetRandomOrientation(armory)
				armory:SetConstructionComplete()
				
				break				
			end		
		end
	end
	
	self.ipsToConstruct = 0
    
    return tower, commandStation    
end


function MarineTeam:SpawnARC()
	local ARCPos
	local extents = Vector(0.2, 0.2, 0.2) -- LookupTechData(kTechId.ARC, kTechDataMaxExtents)
    for p = 1, 20 do
		ARCPos = GetRandomSpawnForCapsule(extents.y, extents.x, self.startTechPoint:GetOrigin() + Vector(0,p* 0.1 + 4,0), 2, 6)
		if ARCPos then
		
			break
			
		end
	end
	if not ARCPos then
		ARCPos = self.startTechPoint:GetOrigin() + Vector(2, 1, 2)
	end
	local newEnt = CreateEntity(ARC.kMapName, ARCPos, self:GetTeamNumber())
	SetRandomOrientation(newEnt)
	newEnt:TriggerEffects("spawnSoundEffects")
end

-- Don't Check for IPs
function MarineTeam:Update(timePassed)

    PlayingTeam.Update(self, timePassed)
	if GetGamerules():GetGameStarted() and kCombatARCSpawnEnabled then
		if self.lastArcSpawn + ScaleWithPlayerCount(kARCSpawnFrequency, #GetEntitiesForTeam("Player", GetEnemyTeamNumber(self:GetTeamNumber())), false)  < Shared.GetTime() then
			self.lastArcSpawn = Shared.GetTime()
			self:SpawnARC()
		end
	end
    
end