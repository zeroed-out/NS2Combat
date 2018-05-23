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



-- Don't Check for IPS
function MarineTeam:Update(timePassed)

    PlayingTeam.Update(self, timePassed)
    
end