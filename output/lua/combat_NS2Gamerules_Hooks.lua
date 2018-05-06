--________________________________
--
--   	NS2 Combat Mod     
--	Made by JimWest and MCMLXXXIV, 2012
--
--________________________________

-- combat_NS2Gamerules_Hooks.lua

local HotReload = CombatNS2Gamerules
if(not HotReload) then
    CombatNS2Gamerules = {}
	ClassHooker:Mixin("CombatNS2Gamerules")
end

function CombatNS2Gamerules:OnLoad()

    ClassHooker:SetClassCreatedIn("NS2Gamerules", "lua/NS2Gamerules.lua")
	self:PostHookClassFunction("NS2Gamerules", "OnCreate", "OnCreate_Hook")
    self:ReplaceClassFunction("NS2Gamerules", "JoinTeam", "JoinTeam_Hook")
	self:PostHookClassFunction("NS2Gamerules", "OnUpdate", "OnUpdate_Hook")
	--self:PostHookClassFunction("NS2Gamerules", "ChooseTechPoint", "ChooseTechPoint_Hook"):SetPassHandle(true)
	self:RawHookClassFunction("NS2Gamerules", "ResetGame", "ResetGame_Hook")
	self:RawHookClassFunction("NS2Gamerules", "UpdateMapCycle", "UpdateMapCycle_Hook")
	self:ReplaceClassFunction("NS2Gamerules", "CheckGameStart", "CheckGameStart_Hook")
    
    ClassHooker:SetClassCreatedIn("Gamerules", "lua/Gamerules.lua")
    self:PostHookClassFunction("Gamerules", "OnClientConnect", "OnClientConnect_Hook")
    
    self:ReplaceFunction("NS2Gamerules_GetUpgradedDamage", "NS2Gamerules_GetUpgradedDamage_Hook")
	
end

function UpdateUpgradeCountsForTeam(gameRules, teamIndex)
	
	--Seems these are occasionally invalid? idk..
	if teamIndex < 0 or teamIndex > 3 then
		--Invalid
		return
	end

	-- Get the number of players on the team who have the upgrade
	local oldCounts = gameRules.UpgradeCounts[teamIndex]
	local teamPlayers = GetEntitiesForTeam("Player", teamIndex)
	local numInTeam = #teamPlayers
	
	-- Reset the upgrade counts
	gameRules.UpgradeCounts[teamIndex] = {}
	for upgradeIndex, upgrade in ipairs(GetAllUpgrades(teamIndex)) do
		gameRules.UpgradeCounts[teamIndex][upgrade:GetId()] = 0
	end
	
	-- Recalculate the upgrade counts.
	for index, teamPlayer in ipairs(teamPlayers) do
	
		-- Skip dead players
		if (teamPlayer:GetIsAlive()) then
			
			local playerTechTree = teamPlayer:GetCombatTechTree()
			for upgradeIndex, upgrade in ipairs(playerTechTree) do
				-- Update the count for this upgrade.
				gameRules.UpgradeCounts[teamIndex][upgrade:GetId()] = gameRules.UpgradeCounts[teamIndex][upgrade:GetId()] + 1
			end
			
		end
		
	end		
	
	-- Updates for each player.
	for upgradeId, upgradeCount in pairs(gameRules.UpgradeCounts[teamIndex]) do
		-- Send any updates to all players
		if upgradeCount ~= oldCounts[upgradeId] then
			local teamPlayers = GetEntitiesForTeam("Player", teamIndex)
			for index, teamPlayer in ipairs(teamPlayers) do
				SendCombatUpgradeCountUpdate(teamPlayer, upgradeId, upgradeCount)
			end
		end
	end

end

-- Don't do this too often - it is expensive!
local function UpdateUpgradeCounts(gameRules)

	UpdateUpgradeCountsForTeam(gameRules, kTeam1Index)
	UpdateUpgradeCountsForTeam(gameRules, kTeam2Index)
	
	-- Return true to keep the loop going.
	return true

end

function CombatNS2Gamerules:OnCreate_Hook(self)

	self.UpgradeCounts = {}
	self.UpgradeCounts[kTeam1Index] = {}
	for index, upgrade in ipairs(GetAllUpgrades(kTeam1Index)) do
		self.UpgradeCounts[kTeam1Index][upgrade:GetId()] = 0
	end
	
	self.UpgradeCounts[kTeam2Index] = {}
	for index, upgrade in ipairs(GetAllUpgrades(kTeam2Index)) do
		self.UpgradeCounts[kTeam2Index][upgrade:GetId()] = 0
	end
	
	-- Recalculate these every half a second.
	self:AddTimedCallback(UpdateUpgradeCounts, kCombatUpgradeUpdateInterval)

end

-- Free the lvl when changing Teams
--
-- Returns two return codes: success and the player on the new team. This player could be a new
-- player (the default respawn type for that team) or it will be the original player if the team
-- wasn't changed (false, original player returned). Pass force = true to make player change team
-- no matter what and to respawn immediately.
--
function CombatNS2Gamerules:JoinTeam_Hook(self, player, newTeamNumber, force)

	-- The PostHook doesn't work because this function returns two values
	-- So we need to replace instead. Sorry!
	local client = Server.GetOwner(player)
	if not client then return end
	
	local success = false
	local oldPlayerWasSpectating = client and client:GetSpectatingPlayer()
	local oldTeamNumber = player:GetTeamNumber()
	
	-- Join new team
	if oldTeamNumber ~= newTeamNumber or force then        
		
		if player:isa("Commander") then
			OnCommanderLogOut(player)
		end        
		
		if not Shared.GetCheatsEnabled() and self:GetGameStarted() and newTeamNumber ~= kTeamReadyRoom then
			player.spawnBlockTime = Shared.GetTime() + kSuicideDelay
		end
	
		local team = self:GetTeam(newTeamNumber)
		local oldTeam = self:GetTeam(oldTeamNumber)
		
		-- Remove the player from the old queue if they happen to be in one
		if oldTeam then
			oldTeam:RemovePlayerFromRespawnQueue(player)
		end
		
		-- Spawn immediately if going to ready room, game hasn't started, cheats on, or game started recently
		if newTeamNumber == kTeamReadyRoom or self:GetCanSpawnImmediately() or force then
		
			success, newPlayer = team:ReplaceRespawnPlayer(player, nil, nil)
			
			local teamTechPoint = team.GetInitialTechPoint and team:GetInitialTechPoint()
			if teamTechPoint then
				newPlayer:OnInitialSpawn(teamTechPoint:GetOrigin())
			end
			
		else
		
			-- Destroy the existing player and create a spectator in their place.
			newPlayer = player:Replace(team:GetSpectatorMapName(), newTeamNumber)
			
			-- Queue up the spectator for respawn.
			team:PutPlayerInRespawnQueue(newPlayer)
			
			success = true
			
		end
		
		local clientUserId = client:GetUserId()
		--Save old pres
		if oldTeam == self.team1 or oldTeam == self.team2 then
			if not self.clientpres[clientUserId] then self.clientpres[clientUserId] = {} end
			self.clientpres[clientUserId][oldTeamNumber] = player:GetResources()
		end
		
		-- Update frozen state of player based on the game state and player team.
		if team == self.team1 or team == self.team2 then
		
			local devMode = Shared.GetDevMode()
			local inCountdown = self:GetGameState() == kGameState.Countdown
			if not devMode and inCountdown then
				newPlayer.frozen = true
			end
			
			local pres = self.clientpres[clientUserId] and self.clientpres[clientUserId][newTeamNumber]
			newPlayer:SetResources( pres or ConditionalValue(team == self.team1, kMarineInitialIndivRes, kAlienInitialIndivRes) )
		
		else
		
			-- Ready room or spectator players should never be frozen
			newPlayer.frozen = false
			
		end
		
		
		newPlayer:TriggerEffects("join_team")
		
		if success then
                
			self.sponitor:OnJoinTeam(newPlayer, team)
			
			local newPlayerClient = Server.GetOwner(newPlayer)
			if oldPlayerWasSpectating then
                local newPlayerClient = Server.GetOwner(newPlayer)
				newPlayerClient:SetSpectatingPlayer(nil)
			end
			
			if newPlayer.OnJoinTeam then
				newPlayer:OnJoinTeam()
			end    
			
			Server.SendNetworkMessage(newPlayerClient, "SetClientTeamNumber", { teamNumber = newPlayer:GetTeamNumber() }, true)
			
			if newTeamNumber == kSpectatorIndex then
				newPlayer:SetSpectatorMode(kSpectatorMode.Overhead)
			end
			
		end
		
	end
	
	-- This is the new bit for Combat
	if (success) then
        
        -- Only reset things like techTree, scan, camo etc.
		newPlayer:CheckCombatData()	
		local lastTeamNumber = newPlayer.combatTable.lastTeamNumber
		newPlayer:Reset_Lite()

		--newPlayer.combatTable.xp = player:GetXp()
		-- if the player joins the same team, subtract one level
		if lastTeamNumber == newTeamNumber then
			if newPlayer:GetLvl() >= kCombatPenaltyLevel + 1 then
			    local newXP = Experience_XpForLvl(newPlayer:GetLvl()-1)
				newPlayer.score = newXP
				newPlayer.combatTable.lvl = newPlayer:GetLvl()
				newPlayer:SendDirectMessage( "You lost " .. kCombatPenaltyLevel .. " level for rejoining the same team!")
			end
		end
		newPlayer:AddLvlFree(newPlayer:GetLvl() - 1 + kCombatStartUpgradePoints)
		
		--set spawn protect
		newPlayer:SetSpawnProtect()
		
		-- Send upgrade updates for each player.
		if newTeamNumber == kTeam1Index or newTeamNumber == kTeam2Index then
			for upgradeId, upgradeCount in pairs(self.UpgradeCounts[newTeamNumber]) do
				-- Send all upgrade counts to this player
				SendCombatUpgradeCountUpdate(newPlayer, upgradeId, upgradeCount)
			end
		end
		
		-- Send timer updates
		SendCombatGameTimeUpdate(newPlayer)
		
		return success, newPlayer
		
	end
	
	-- Return old player
	return success, player
end

-- If the client connects, send him the welcome Message
-- Also grant average XP.
function CombatNS2Gamerules:OnClientConnect_Hook(self, client)

    local player = client:GetControllingPlayer()

	-- Tell the player that Combat Mode is active.
    SendCombatModeActive(client, kCombatModActive, kCombatCompMode, kCombatAllowOvertime)
	
	player:CheckCombatData()
    
    for i, message in ipairs(combatWelcomeMessage) do
        player:SendDirectMessage(message)  
    end
	
	-- Give the player the average XP of all players on the server.
    if GetGamerules():GetGameStarted() then
		player.combatTable.setAvgXp = true
		local avgXp = Experience_GetAvgXp(player)
		-- Send the avg as a message to the player (%d doesn't work with SendDirectMessage)
		if avgXp > 0 then
		    player:SendDirectMessage("You joined the game late... you will get some free Xp when you join a team!")
        end
	end    

end

-- After a certain amount of time the aliens need to win (except if it's marines vs marines).
function CombatNS2Gamerules:OnUpdate_Hook(self, timePassed)
    
    
    if self.justCreated then
    
        if not self.gameStarted then
            self:ResetGame()
        end
        
        self.justCreated = false
        
    end
    
    if self:GetMapLoaded() then
    
        self:CheckGameStart()
        self:CheckGameEnd()

        --self:UpdateWarmUp()
        
        self:UpdatePregame(timePassed)
        self:UpdateToReadyRoom()
        self:UpdateMapCycle()
        self:ServerAgeCheck()
        self:UpdateAutoTeamBalance(timePassed)
        
        self.timeSinceGameStateChanged = self.timeSinceGameStateChanged + timePassed
        
        self.worldTeam:Update(timePassed)
        self.team1:Update(timePassed)
        self.team2:Update(timePassed)
        self.spectatorTeam:Update(timePassed)
        
        self:UpdatePings()
        self:UpdateHealth()
        self:UpdateTechPoints()

        self:CheckForNoCommander(self.team1, "MarineCommander")
        self:CheckForNoCommander(self.team2, "AlienCommander")
        self:KillEnemiesNearCommandStructureInPreGame(timePassed)
        
        self:UpdatePlayerSkill()
        self:UpdateNumPlayersForScoreboard()
        
        
	local team1 = self:GetTeam(1)
	local team2 = self:GetTeam(2)
	
	-- Check that it's Marines vs Aliens...
	if self:GetGameState() == kGameState.Started then
		if team1:isa("MarineTeam") and team2:isa("AlienTeam") then
			-- send timeleft to all players, but only every few min
			local exactTimeLeft = (kCombatTimeLimit - self.timeSinceGameStateChanged)
			local timeTaken = math.ceil(self.timeSinceGameStateChanged)
			local timeLeft = math.ceil(exactTimeLeft)
				
			if self:GetHasTimelimitPassed() and kCombatAllowOvertime == false then
				self:GetTeam(kCombatDefaultWinner).combatTeamWon = true
			else
				-- send timeleft to all players, but only every few min
                if 	kCombatTimeLeftPlayed ~= timeLeft then
               
					if timeLeft == -1 and kCombatAllowOvertime then
						-- Send the last stand sound to every player
						for i, player in ientitylist(Shared.GetEntitiesWithClassname("Player")) do
							Server.PlayPrivateSound(player, CombatEffects.kLastStandAnnounce, player, 1.0, Vector(0, 0, 0))
							player:SendDirectMessage("OVERTIME!!")
							player:SendDirectMessage("Structures cannot be repaired!")
							player:SendDirectMessage("Spawn times have been increased!")
						end
						kCombatTimeLeftPlayed = timeLeft
					end
				end
			end
			
			-- Periodic events...
			if timeTaken ~= kCombatTimePlayed then
				-- Balance the teams once every 5 minutes or so...
				if timeTaken % kCombatRebalanceInterval == 0 then
					local avgXp = Experience_GetAvgXp()
					for i, player in ientitylist(Shared.GetEntitiesWithClassname("Player")) do      
						-- Ignore players that are not on a team.
						if player:GetIsPlaying() then
							player:BalanceXp(avgXp)
						end
					end
				end
				
				kCombatTimePlayed = timeTaken
			end
		end
	else
		-- reset kCombatTimePlayed
	    if kCombatTimePlayed ~= 0 then
	        kCombatTimePlayed = 0
	    end
	
	    -- reset kCombatTimeLeftPlayed
	    if kCombatTimeLeftPlayed ~= 0 then
	        kCombatTimeLeftPlayed = 0
	    end
	end
        
end


end

-- let ns2 find a techPoint for team1 and search the nearest techPoint for team2
-- DISABLED FOR NOW
local team1TechPoint = nil
function CombatNS2Gamerules:ChooseTechPoint_Hook(handle, self, techPoints, teamNumber)

    --GetLocationName() to get the name
    spawnTeam1Location, spawnTeam2Location = CombatGetSpawns()
    local allTechPoints = EntityListToTable(Shared.GetEntitiesWithClassname("TechPoint"))
        
    if not ( spawnTeam1Location and  spawnTeam2Location ) then
    
        for i, techPoint in ipairs(allTechPoints) do
            -- find the techPoint that fits to our team and LocationName
            if techPoint:GetLocationName() == ConditionalValue(teamNumber == kTeam1Index, spawnTeam1Location, spawnTeam2Location) then
                spawnTechPoint = techPoint
                break
            end                
        end
        
        CombatInitProps()
        -- when no techPoint could be found, take the original techPoints
        
    else
	
		-- Use some custom spawn picker code when the map gets too large.
		if #allTechPoints >= 5 then
        
			-- no spawn pairs, so search 2 near spawns 
			if teamNumber == kTeam1Index then        
				-- if its team1, just search any random techPoint  
				local randomNumber = math.random(1, table.maxn(allTechPoints))
				spawnTechPoint = allTechPoints[randomNumber]
				team1TechPoint = spawnTechPoint
				
			else
			
				local closestRange = nil
				
				for i, currentTechPoint in ipairs(allTechPoints) do
					-- skip if we found team1techpoint
					if currentTechPoint ~= team1TechPoint then
						range = GetPathDistance(team1TechPoint:GetOrigin(), currentTechPoint:GetOrigin())
						if not closestRange then
							closestRange = range
							spawnTechPoint = currentTechPoint                    
						else
							if range < closestRange then
								closestRange = range
								spawnTechPoint = currentTechPoint
							end
						end
					end
				end 
	  
			end
		end
        
    end
        
    if spawnTechPoint then
        handle:SetReturn(spawnTechPoint)
    end
    
end


function CombatNS2Gamerules:ResetGame_Hook(self)

	-- Reset teams and timers
	local team1 = self:GetTeam(1)
	local team2 = self:GetTeam(2)
	team1.combatTeamWon = nil
	team2.combatTeamWon = nil
	self.timeSinceGameStateChanged = 0

    -- reset SpawnCombo to set them again
    combatSpawnCombo = nil
    combatSpawnComboIndex  = nil
	
	-- Send timer updates
	for i, player in ientitylist(Shared.GetEntitiesWithClassname("Player")) do
		SendCombatGameTimeUpdate(player)
	end

    
    self:SetGameState(kGameState.NotStarted)

    TournamentModeOnReset()

    -- Destroy any map entities that are still around
    DestroyLiveMapEntities()
    
    -- Reset all players, delete other not map entities that were created during 
    -- the game (hives, command structures, initial resource towers, etc)
    -- We need to convert the EntityList to a table since we are destroying entities
    -- within the EntityList here.
    for index, entity in ientitylist(Shared.GetEntitiesWithClassname("Entity")) do
    
        -- Don't reset/delete NS2Gamerules or TeamInfo.
        -- NOTE!!!
        -- MapBlips are destroyed by their owner which has the MapBlipMixin.
        -- There is a problem with how this reset code works currently. A map entity such as a Hive creates
        -- it's MapBlip when it is first created. Before the entity:isa("MapBlip") condition was added, all MapBlips
        -- would be destroyed on map reset including those owned by map entities. The map entity Hive would still reference
        -- it's original MapBlip and this would cause problems as that MapBlip was long destroyed. The right solution
        -- is to destroy ALL entities when a game ends and then recreate the map entities fresh from the map data
        -- at the start of the next game, including the NS2Gamerules. This is how a map transition would have to work anyway.
        -- Do not destroy any entity that has a parent. The entity will be destroyed when the parent is destroyed or
        -- when the owner manually destroyes the entity.
        local shieldTypes = { "GameInfo", "MapBlip", "NS2Gamerules", "PlayerInfoEntity" }
        local allowDestruction = true
        for i = 1, #shieldTypes do
            allowDestruction = allowDestruction and not entity:isa(shieldTypes[i])
end

        if allowDestruction and entity:GetParent() == nil then

            local isMapEntity = entity:GetIsMapEntity()
            local mapName = entity:GetMapName()

            -- Reset all map entities and all player's that have a valid Client (not ragdolled players for example).
            local resetEntity = entity:isa("TeamInfo") or entity:GetIsMapEntity() or (entity:isa("Player") and entity:GetClient() ~= nil)
            if resetEntity then
	
                if entity.Reset then
                    entity:Reset()
	end

            else
                DestroyEntity(entity)
end

        end       

    end

    -- Clear out obstacles from the navmesh before we start repopualating the scene
    RemoveAllObstacles()
    
    -- Build list of tech points
    local techPoints = EntityListToTable(Shared.GetEntitiesWithClassname("TechPoint"))
    if #techPoints < 2 then
        Print("Warning -- Found only %d %s entities.", table.maxn(techPoints), TechPoint.kMapName)
    end
    local team1TechPoint, team2TechPoint
        
    if Server.teamSpawnOverride and #Server.teamSpawnOverride > 0 then
            
        for t = 1, #techPoints do
                
            local techPointName = string.lower(techPoints[t]:GetLocationName())
            local selectedSpawn = Server.teamSpawnOverride[1]
            if techPointName == selectedSpawn.marineSpawn then
                team1TechPoint = techPoints[t]
            elseif techPointName == selectedSpawn.alienSpawn then
                team2TechPoint = techPoints[t]
            end
            
        end
                
        if not team1TechPoint or not team2TechPoint then
            Shared.Message("Invalid spawns, defaulting to normal spawns")
            if Server.spawnSelectionOverrides then
            
                local selectedSpawn = self.techPointRandomizer:random(1, #Server.spawnSelectionOverrides)
                selectedSpawn = Server.spawnSelectionOverrides[selectedSpawn]
                
                for t = 1, #techPoints do
            
                    local techPointName = string.lower(techPoints[t]:GetLocationName())
                    if techPointName == selectedSpawn.marineSpawn then
                        team1TechPoint = techPoints[t]
                    elseif techPointName == selectedSpawn.alienSpawn then
                        team2TechPoint = techPoints[t]
        end
        
    end
        
            else

                -- Reset teams (keep players on them)
                team1TechPoint = self:ChooseTechPoint(techPoints, kTeam1Index)
                team2TechPoint = self:ChooseTechPoint(techPoints, kTeam2Index)

end

        end

    elseif Server.spawnSelectionOverrides then
			
        local selectedSpawn = self.techPointRandomizer:random(1, #Server.spawnSelectionOverrides)
        selectedSpawn = Server.spawnSelectionOverrides[selectedSpawn]

        for t = 1, #techPoints do

            local techPointName = string.lower(techPoints[t]:GetLocationName())
            if techPointName == selectedSpawn.marineSpawn then
                team1TechPoint = techPoints[t]
            elseif techPointName == selectedSpawn.alienSpawn then
                team2TechPoint = techPoints[t]
            end

        end
			
    else
				
        -- Reset teams (keep players on them)
        team1TechPoint = self:ChooseTechPoint(techPoints, kTeam1Index)
        team2TechPoint = self:ChooseTechPoint(techPoints, kTeam2Index)

				end
				
    self.team1:ResetPreservePlayers(team1TechPoint)
    self.team2:ResetPreservePlayers(team2TechPoint)
				
    -- Save data for end game stats later.
    self.startingLocationNameTeam1 = team1TechPoint:GetLocationName()
    self.startingLocationNameTeam2 = team2TechPoint:GetLocationName()
    self.startingLocationsPathDistance = GetPathDistance(team1TechPoint:GetOrigin(), team2TechPoint:GetOrigin())
    self.initialHiveTechId = nil
					
    self.worldTeam:ResetPreservePlayers(nil)
    self.spectatorTeam:ResetPreservePlayers(nil)    
						
    -- Create team specific entities
    local commandStructure1 = self.team1:ResetTeam()
    local commandStructure2 = self.team2:ResetTeam()
					
    -- Create living map entities fresh
    CreateLiveMapEntities()
				
    self.forceGameStart = false
    self.preventGameEnd = nil
    -- Reset banned players for new game
    self.bannedPlayers = {}
			
    -- Send scoreboard and tech node update, ignoring other scoreboard updates (clearscores resets everything)
    for index, player in ientitylist(Shared.GetEntitiesWithClassname("Player")) do
        Server.SendCommand(player, "onresetgame")
        player.sendTechTreeBase = true
		end
		
    self.team1:OnResetComplete()
    self.team2:OnResetComplete()
	end
	
function CombatNS2Gamerules:UpdateMapCycle_Hook(self)
	
	if self.timeToCycleMap ~= nil and Shared.GetTime() >= self.timeToCycleMap then

		local playerCount = Shared.GetEntitiesWithClassname("Player"):GetSize()
		ModSwitcher_Save(nil, nil, playerCount, nil, nil, nil, nil, nil, false)
		
	end
			
end
			
function CombatNS2Gamerules:NS2Gamerules_GetUpgradedDamage_Hook(attacker, doer, damage, damageType)
				
    local damageScalar = 1
				
    if attacker ~= nil then
				
        -- Damage upgrades only affect weapons, not ARCs, Sentries, MACs, Mines, etc.
        if doer:isa("Weapon") or doer:isa("Grenade") or doer:isa("Minigun") or doer:isa("Railgun") then
				
            if(GetHasTech(attacker, kTechId.Weapons3, true)) then
				
                damageScalar = kWeapons3DamageScalar
			
            elseif(GetHasTech(attacker, kTechId.Weapons2, true)) then
				
                damageScalar = kWeapons2DamageScalar
				
            elseif(GetHasTech(attacker, kTechId.Weapons1, true)) then
				
                damageScalar = kWeapons1DamageScalar
				
			end

		end
        
	end
        
    return damage * damageScalar

end

local function StartCountdown(self)

    self:ResetGame()
    
    self:SetGameState(kGameState.Countdown)
    self.countdownTime = kCountDownLength
    
    self.lastCountdownPlayed = nil
    
end
function CombatNS2Gamerules:CheckGameStart_Hook(self)

    if self:GetGameState() <= kGameState.PreGame then
        
        -- Start pre-game when both teams have players or when once side does if cheats are enabled
        local team1Players = self.team1:GetNumPlayers()
        local team2Players = self.team2:GetNumPlayers()
            
        if (team1Players > 0 and team2Players > 0) or (Shared.GetCheatsEnabled() and (team1Players > 0 or team2Players > 0)) then
            
            if self:GetGameState() < kGameState.PreGame then
                StartCountdown(self)
            end
                
        else
            if self:GetGameState() == kGameState.PreGame then
            self:SetGameState(kGameState.NotStarted)
        end
        end
            
    end

end

if (not HotReload) then
	CombatNS2Gamerules:OnLoad()
end