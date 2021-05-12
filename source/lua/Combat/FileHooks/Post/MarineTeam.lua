
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

function MarineTeam:GetARCSpawnPoint()

	-- if there's a robo or arc factory
	local robos = GetEntitiesForTeam("RoboticsFactory", self:GetTeamNumber())
	if #robos > 0 then	
		
		for _, robo in ipairs(robos) do
			return robo:GetOrigin()
		end
		
	end
	
	return self.startTechPoint:GetOrigin()
end

function MarineTeam:PathExistsToEnemyCommand(origin)

	local teamNumber = GetEnemyTeamNumber(self:GetTeamNumber())
	local hives = GetEntitiesForTeam("CommandStructure", teamNumber)
	
	for _, hive in ipairs(hives) do
	
		local points = PointArray()
		local isReachable = Pathing.GetPathPoints(origin, hive:GetOrigin(), points)   
		if isReachable then
			return true
		end
		
	end
	
	return false
end

function MarineTeam:SpawnARC()
	local ARCPos
	local extents = Vector(0.2, 0.2, 0.2) -- LookupTechData(kTechId.ARC, kTechDataMaxExtents)
    for p = 1, 20 do
		ARCPos = GetRandomSpawnForCapsule(extents.y, extents.x, self:GetARCSpawnPoint() + Vector(0,p* 0.1 + 4,0), 2, 6)
		if ARCPos then
		
			break
			
		end
	end
	if not ARCPos then
		ARCPos = self:GetARCSpawnPoint() + Vector(2, 1, 2)
	end
	
	-- if path doesn't exist, quit
	if not self:PathExistsToEnemyCommand(ARCPos) then
		return
	end
	
	local newEnt = CreateEntity(ARC.kMapName, ARCPos, self:GetTeamNumber())
	SetRandomOrientation(newEnt)
	newEnt:TriggerEffects("spawnSoundEffects")
	GetGamerules():SpawnedARC()
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


local oldTriggerAlert = MarineTeam.TriggerAlert
function MarineTeam:TriggerAlert(techId, entity, force)
	oldTriggerAlert(self, techId, entity, force)
	
	if (techId == kTechId.MarineAlertNeedMedpack or techId == kTechId.MarineAlertNeedAmmo) and 
		entity and entity:isa("Player") and
		entity:GetIsAlive() and entity.combatTable and entity.combatTable.hasImprovedResupply and
		(entity.combatTable.lastResupply <= Shared.GetTime()) then
		
		local newTime = Shared.GetTime() + kImprovedResupplyExtra
		entity.combatTable.lastResupply = newTime
		entity.lastResupply = newTime
		
		local position = entity:GetOrigin()
		local mapName
		if techId == kTechId.MarineAlertNeedMedpack then
			mapName = MedPack.kMapName
		else -- ammopack instead
			mapName = AmmoPack.kMapName
		end
		
        local droppack = CreateEntity(mapName, position, self:GetTeamNumber())
        droppack:TriggerEffects( "medpack_commander_drop", { effecthostcoords = Coords.GetTranslation(position) } )
		
	end
	
end