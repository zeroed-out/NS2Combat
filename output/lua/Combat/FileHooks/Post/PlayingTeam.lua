--________________________________
--
--   	NS2 Combat Mod
--	Made by JimWest and MCMLXXXIV, 2012
--
--________________________________

-- combat_PlayingTeam.lua

--___________________
-- Hooks Playing Team
--___________________

function PlayingTeam:GetHasTeamLost()
    -- Don't bother with the original - we just set our own logic here.
	-- You can lose with cheats on (testing purposes)
	if(GetGamerules():GetGameStarted()) then
    
        -- Team can't respawn or last Command Station or Hive destroyed
        local numCommandStructures = self:GetNumAliveCommandStructures()
        
        if  ( numCommandStructures == 0 ) or
            ( self:GetNumPlayers() == 0 ) then
            
            return true
            
        end
            
    end

    return false

end

function PlayingTeam:SpawnInitialStructures(techPoint)
    -- Dont Spawn RTS or Cysts
        
    ASSERT(techPoint ~= nil)

    -- Spawn hive/command station at team location
    local commandStructure = techPoint:SpawnCommandStructure(self:GetTeamNumber())
    assert(commandStructure ~= nil)
    commandStructure:SetConstructionComplete()
    
    -- Use same align as tech point.
    local techPointCoords = techPoint:GetCoords()
    techPointCoords.origin = commandStructure:GetOrigin()
    commandStructure:SetCoords(techPointCoords)
    
    --if commandStructure:isa("Hive") then
      --  commandStructure:SetFirstLogin()
    --end
	
	-- Set the command station to be occupied.
	if commandStructure:isa("CommandStation") then
		commandStructure.occupied = true
		--commandStructure:UpdateCommanderLogin(true)
	end
	
	return tower, commandStructure
    
end

-- Respawn timers.
function PlayingTeam:Update(timePassed)

	if self.timeSinceLastSpawn == nil then 
		self:ResetSpawnTimer()
	end
	
	-- Increment the spawn timer
	self.timeSinceLastSpawn = self.timeSinceLastSpawn + timePassed
	
    -- check if there are really no Spectators (should fix the spawnbug)
	local players = GetEntitiesForTeam("Spectator", self:GetTeamNumber())
	
	-- Spawn all players in the queue once every 10 seconds or so.
	if (#self.respawnQueue > 0) or (#players > 0)  then
		
		-- Are we ready to spawn? This is based on the time since the last spawn wave...
		local respawnTimer = kCombatRespawnTimer
		if GetHasTimelimitPassed() then
			respawnTimer = kCombatOvertimeRespawnTimer
		end
		local timeToSpawn = (self.timeSinceLastSpawn >= respawnTimer)
		
		if timeToSpawn then
			-- Reset the spawn timer.
			self:ResetSpawnTimer()
			
			-- Loop through the respawn queue and spawn dead players.
			-- Also handle the case where there are too many players to spawn all of them - do it on a FIFO basis.
			local lastPlayer = nil
			local thisPlayer = self:GetOldestQueuedPlayer()
			
			if thisPlayer then
                while (lastPlayer == thisPlayer) or (thisPlayer ~= nil) do
                    local success = self:SpawnPlayer(thisPlayer)
                    -- Don't crash the server when no more players can spawn...
                    if not success then break end
                    
                    lastPlayer = thisPlayer
                    thisPlayer = self:GetOldestQueuedPlayer()
                end
            else
                -- somethings wrong, spawn all Spectators
                for i, player in ipairs(players) do
                    local success = self:SpawnPlayer(player)
                    -- Don't crash the server when no more players can spawn...
                    if not success then break end
                end
            end
			
			-- If there are any players left, send them a message about why they didn't spawn.
			if (#self.respawnQueue > 0) then
				for i, player in ipairs(self.respawnQueue) do
				    -- sanity check if there are ids instead of objects
				    if (IsNumber(player)) then
				        player = Shared.GetEntity(player)
				    end
				    if (player) then
					    player:SendDirectMessage("Could not find a valid spawn location for you... You will spawn in the next wave instead!")
                    end					    
				end
			elseif (#players > 0) then
                for i, player in ipairs(players) do
					player:SendDirectMessage("Could not find a valid spawn location for you... You will spawn in the next wave instead!")
				end
            end
            
		else
			-- Send any 'waiting to respawn' messages (normally these only go to AlienSpectators)
			for _, player in ipairs(self:GetPlayers()) do
				if not player.waitingToSpawnMessageSent then
					if player:GetIsAlive() == false then
						SendPlayersMessage({ player }, kTeamMessageTypes.SpawningWait)
						player.waitingToSpawnMessageSent = true

						-- TODO: Update the GUI so that marines can get the 'ready to spawn in ... ' message too.
						-- After that is done, remove the AlienSpectator check here.
						if (player:isa("AlienSpectator")) then
							player.timeWaveSpawnEnd = nextSpawnTime
						end
					end
				end
			end
		end
	
	end
    
end

function PlayingTeam:ResetSpawnTimer()

	-- Reset the spawn timer
	self.timeSinceLastSpawn = 0
	if not GetHasTimelimitPassed() then
		self.nextSpawnTime = Shared.GetTime() + kCombatRespawnTimer
	else
		self.nextSpawnTime = Shared.GetTime() + kCombatOvertimeRespawnTimer
	end
			
end

function PlayingTeam:SpawnPlayer(player)

    local success = false
	local newPlayer

	player.isRespawning = true
	SendPlayersMessage({ player }, kTeamMessageTypes.Spawning)

    if Server then
        
        if player.SetSpectatorMode then
            player:SetSpectatorMode(kSpectatorMode.Following)
        end
  
    end

    if player.combatTable and player.combatTable.giveClassAfterRespawn then
        success, newPlayer  = player:GetTeam():ReplaceRespawnPlayer(player, nil, nil, player.combatTable.giveClassAfterRespawn)
    else
		-- Spawn normally
        success, newPlayer = player:GetTeam():ReplaceRespawnPlayer(player, nil, nil)
    end
	
	if success then
		-- Give any upgrades back
        newPlayer:GiveUpsBack()    
	
        -- Make a nice effect when you spawn.
		-- Aliens hatch due the CoEvolve function
        if newPlayer:isa("Marine") or newPlayer:isa("Exo") then
            newPlayer:TriggerEffects("infantry_portal_spawn")
        end
		newPlayer:TriggerEffects("spawnSoundEffects")
		newPlayer:GetTeam():RemovePlayerFromRespawnQueue(newPlayer)
		
		-- Remove the third-person mode (bug introduced in 216).
		newPlayer:SetCameraDistance(0)
		
		--give him spawn Protect (dont set the time here, just that spawn protect is active)
		newPlayer:SetSpawnProtect()
		
		-- always switch to first weapon
		newPlayer:SwitchWeapon(1)
		
		-- Send timer updates
		SendCombatGameTimeUpdate(newPlayer)
    end

    return success

end

-- Another copy job I'm afraid...
-- The default spawn code just isn't strong enough for us. Give it a dose of coffee.
-- Call with origin and angles, or pass nil to have them determined from team location and spawn points.
function PlayingTeam:RespawnPlayer(player, origin, angles)

    local success = false
    local initialTechPoint = Shared.GetEntity(self.initialTechPointId)
    
    if origin ~= nil and angles ~= nil then
        success = Team.RespawnPlayer(self, player, origin, angles)
    elseif initialTechPoint ~= nil then
    
        -- Compute random spawn location
        local capsuleHeight, capsuleRadius = player:GetTraceCapsule()
		local spawnOrigin = nil
		
		-- Try it 10 times here
		for index = 1, 10 do
			spawnOrigin = GetRandomSpawnForCapsule(capsuleHeight, capsuleRadius, initialTechPoint:GetOrigin(), kSpawnMinDistance, 25, EntityFilterAll())
			if spawnOrigin ~= nil then
				break
			end
		end
		
        if spawnOrigin ~= nil then
        
            -- Orient player towards tech point
            local lookAtPoint = initialTechPoint:GetOrigin() + Vector(0, 5, 0)
            local toTechPoint = GetNormalizedVector(lookAtPoint - spawnOrigin)
            success = Team.RespawnPlayer(self, player, spawnOrigin, Angles(GetPitchFromVector(toTechPoint), GetYawFromVector(toTechPoint), 0))
            
        else
        
			player:SendDirectMessage("No room to spawn. You should spawn in the next wave instead!")
            Print("PlayingTeam:RespawnPlayer: Couldn't compute random spawn for player. Will retry at next wave...\n")
			-- Escape the player's name here... names like Sandwich% cause a crash to appear here!
			local escapedPlayerName = string.gsub(player:GetName(), "%%", "")
			Print("PlayingTeam:RespawnPlayer: Name: " .. escapedPlayerName .. " Class: " .. player:GetClassName())
            
        end
        
    else
        Print("PlayingTeam:RespawnPlayer(): No initial tech point.")
    end
    
    return success

end
