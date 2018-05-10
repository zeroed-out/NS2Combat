--________________________________
--
--   	NS2 Combat Mod
--	Made by JimWest and MCMLXXXIV, 2012
--
--________________________________

-- combat_NS2Gamerules.lua

function NS2Gamerules:GetHasTimelimitPassed()
	if self.timeSinceGameStateChanged >= kCombatTimeLimit then
		return true
	else
		return false
	end
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
	for _, upgrade in ipairs(GetAllUpgrades(teamIndex)) do
		local upgradeId = upgrade:GetId()
		local upgradeCount = gameRules.UpgradeCounts[teamIndex][upgradeId]

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

local oldOnCreate = NS2Gamerules.OnCreate
function NS2Gamerules:OnCreate()

	oldOnCreate(self)

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
local oldJoinTeam = NS2Gamerules.JoinTeam
function NS2Gamerules:JoinTeam(player, newTeamNumber, ...)

	local success, newPlayer = oldJoinTeam(self, player, newTeamNumber, ...)

	if not success then
		return success, newPlayer
	end

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
		for _, upgrade in ipairs(GetAllUpgrades(newTeamNumber)) do
			local upgradeId = upgrade:GetId()
			local upgradeCount = self.UpgradeCounts[newTeamNumber][upgradeId]

			SendCombatUpgradeCountUpdate(newPlayer, upgradeId, upgradeCount)

		end
	end

	-- Send timer updates
	SendCombatGameTimeUpdate(newPlayer)

	return success, newPlayer
end

-- If the client connects, send him the welcome Message
-- Also grant average XP.
local oldOnClientConnect = NS2Gamerules.OnClientConnect
function NS2Gamerules:OnClientConnect(client)

	oldOnClientConnect(self, client)

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

function NS2Gamerules:UpdateWarmUp()
	-- disable warmup
end

-- After a certain amount of time the aliens need to win (except if it's marines vs marines).
local oldOnUpdate = NS2Gamerules.OnUpdate
function NS2Gamerules:OnUpdate(timePassed)
	oldOnUpdate(self, timePassed)

	if self:GetGameState() == kGameState.Started then
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

local oldResetGame = NS2Gamerules.ResetGame
function NS2Gamerules:ResetGame()

	oldResetGame(self)

	local team1 = self:GetTeam(1)
	local team2 = self:GetTeam(2)
	team1.combatTeamWon = nil
	team2.combatTeamWon = nil
	self.timeSinceGameStateChanged = 0

	-- Send timer updates
	for i, player in ientitylist(Shared.GetEntitiesWithClassname("Player")) do
		SendCombatGameTimeUpdate(player)
	end
end

function NS2Gamerules_GetUpgradedDamage(attacker, doer, damage, damageType)

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

function NS2Gamerules:CheckGameStart()

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