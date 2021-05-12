function GetAreEnemies(entityOne, entityTwo)
    return entityOne and entityTwo and HasMixin(entityOne, "Team") and HasMixin(entityTwo, "Team") and (
            (entityOne:GetTeamNumber() == kMarineTeamType and entityTwo:GetTeamNumber() == kAlienTeamType) or
            (entityOne:GetTeamNumber() == kAlienTeamType and entityTwo:GetTeamNumber() == kMarineTeamType)
            or entityOne:GetTeamNumber() == kNeutralTeamType or entityTwo:GetTeamNumber() == kNeutralTeamType)
end

function GetAreFriends(entityOne, entityTwo)
    return entityOne and entityTwo and HasMixin(entityOne, "Team") and HasMixin(entityTwo, "Team") and
            (entityOne:GetTeamNumber() == entityTwo:GetTeamNumber() or
				entityOne:GetTeamNumber() == kNeutralTeamType or
				entityTwo:GetTeamNumber() == kNeutralTeamType
			)
end

--
-- Returns the spawn point on success, nil on failure.
--
local function ValidateSpawnPoint(spawnPoint, capsuleHeight, capsuleRadius, filter, origin)

    local center = Vector(0, capsuleHeight * 0.5 + capsuleRadius, 0)
    local spawnPointCenter = spawnPoint + center
    
    -- Make sure capsule isn't interpenetrating something.
    local spawnPointBlocked = Shared.CollideCapsule(spawnPointCenter, capsuleRadius, capsuleHeight, CollisionRep.Default, PhysicsMask.AllButPCs, nil)
    if not spawnPointBlocked then

        -- Trace capsule to ground, making sure we're not on something like a player or structure
        local trace = Shared.TraceCapsule(spawnPointCenter, spawnPoint - Vector(0, 10, 0), capsuleRadius, capsuleHeight, CollisionRep.Move, PhysicsMask.AllButPCs)            
        if trace.fraction < 1 and (trace.entity == nil or not trace.entity:isa("ScriptActor")) then
        
            VectorCopy(trace.endPoint, spawnPoint)
            
            local endPoint = trace.endPoint + Vector(0, capsuleHeight / 2, 0)
            -- Trace in both directions to make sure no walls are being ignored.
            trace = Shared.TraceRay(endPoint, origin, CollisionRep.Move, PhysicsMask.AllButPCs, filter)
            local traceOriginToEnd = Shared.TraceRay(origin, endPoint, CollisionRep.Move, PhysicsMask.AllButPCs, filter)
            
            if trace.fraction == 1 and traceOriginToEnd.fraction == 1 then
                return spawnPoint - Vector(0, capsuleHeight / 2, 0)
            end
            
        end
        
    end
    
    return nil
    
end

-- Find place for player to spawn, within range of origin. Makes sure that a line can be traced between the two points
-- without hitting anything, to make sure you don't spawn on the other side of a wall. Returns nil if it can't find a
-- spawn point after a few tries.
function GetRandomSpawnForCapsule(capsuleHeight, capsuleRadius, origin, minRange, maxRange, filter, validationFunc)

    ASSERT(capsuleHeight > 0)
    ASSERT(capsuleRadius > 0)
    ASSERT(origin ~= nil)
    ASSERT(type(minRange) == "number")
    ASSERT(type(maxRange) == "number")
    ASSERT(maxRange > minRange)
    ASSERT(minRange > 0)
    ASSERT(maxRange > 0)
    
    for i = 0, kSpawnMaxRetries do
    
        local spawnPoint
        local points = GetRandomPointsWithinRadius(origin, minRange, maxRange, kSpawnMaxVertical, 1, 1, nil, validationFunc)
        if #points == 1 then
            spawnPoint = points[1]
        elseif Server then
            --Print("GetRandomPointsWithinRadius() failed inside of GetRandomSpawnForCapsule()")
        end
        
        if spawnPoint then
        
            -- The spawn point returned by GetRandomPointsWithinRadius() may be too close to the ground.
            -- Move it up a bit so there is some "wiggle" room. ValidateSpawnPoint() traces down anyway.
            spawnPoint = spawnPoint + Vector(0, 0.6, 0)
            local validSpawnPoint = ValidateSpawnPoint(spawnPoint, capsuleHeight, capsuleRadius, filter, origin)
            if validSpawnPoint then
                return validSpawnPoint
            end
            
        end
        
    end
    
    return nil
    
end

-- to get tier2 and tier3 working again
local function UnlockAbility(forAlien, techId)

	--Shared.Message("techId: " .. techId)
    local mapName = LookupTechData(techId, kTechDataMapName)
	--Shared.Message("mapName: " .. tostring(mapName))
    if mapName and forAlien:GetIsAlive() then
    
        local activeWeapon = forAlien:GetActiveWeapon()

        local tierWeapon = forAlien:GetWeapon(mapName)
        if not tierWeapon then
        
            forAlien:GiveItem(mapName)
            
            if activeWeapon then
                forAlien:SetActiveWeapon(activeWeapon:GetMapName())
            end
            
        end
    
    end

end

local function LockAbility(forAlien, techId)

    local mapName = LookupTechData(techId, kTechDataMapName)    
    if mapName and forAlien:GetIsAlive() then
    
        local tierWeapon = forAlien:GetWeapon(mapName)
        local activeWeapon = forAlien:GetActiveWeapon()
        local activeWeaponMapName

        if activeWeapon ~= nil then
            activeWeaponMapName = activeWeapon:GetMapName()
        end
        
        if tierWeapon then
            forAlien:RemoveWeapon(tierWeapon)
        end
        
        if activeWeaponMapName == mapName then
            forAlien:SwitchWeapon(1)
        end
        
    end    
    
end

function UpdateAbilityAvailability(forAlien, tierOneTechId, tierTwoTechId, tierThreeTechId)

    forAlien:CheckCombatData()
    local time = Shared.GetTime()
    if forAlien.timeOfLastNumHivesUpdate == nil or (time > forAlien.timeOfLastNumHivesUpdate + 0.5) then

        local team = forAlien:GetTeam()
        if team and team.GetTechTree then

            -- B257: ShadowStep and Charge are now "one hive" abilities, so make them available with Tier Two upgrade
            forAlien.oneHive = forAlien.combatTwoHives
            if GetIsTechUnlocked(forAlien, tierOneTechId) then
                UnlockAbility(forAlien, tierOneTechId)
            else
                LockAbility(forAlien, tierOneTechId)
            end

            forAlien.twoHives = forAlien.combatTwoHives
            if GetIsTechUnlocked(forAlien, tierTwoTechId) then
                UnlockAbility(forAlien, tierTwoTechId)
            else
                LockAbility(forAlien, tierTwoTechId)
            end

            forAlien.threeHives = forAlien.combatThreeHives
            if GetIsTechUnlocked(forAlien, tierThreeTechId) then
                UnlockAbility(forAlien, tierThreeTechId)
            else
                LockAbility(forAlien, tierThreeTechId)
            end

        end

        forAlien.timeOfLastNumHivesUpdate = time
        
    end

end

-- Allow Marines to use buymenu everywhere
function GetIsCloseToMenuStructure()
    return true
end