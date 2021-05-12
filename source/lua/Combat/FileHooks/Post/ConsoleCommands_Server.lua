-- combat_ConsoleCommands.lua
local function OnCommandSpendLvl(client, ...)
        
    -- support multiple types
    local args = {...}    
    local upgradeTable = {}
    local player = client:GetControllingPlayer() 
    
	if player:isa("Spectator") then
		player:spendlvlHints("spectator")
	elseif not player:GetIsAlive() then
		player:spendlvlHints("dead")
    else		
        for _, typeCode in ipairs(args) do
            local upgrade = GetUpgradeFromTextCode(typeCode)
            if not upgrade then 
                -- check for every arg if its a valid update
                local hintType = ""
                if player:isa("Marine") or player:isa("Exo") then
                    hintType = "wrong_type_marine"
                else
                    hintType = "wrong_type_alien"
                end			
                player:spendlvlHints(hintType, typeCode)
            else
            -- build new table with upgrades
                table.insert(upgradeTable, upgrade) 
            end        
        end       

        if table.maxn(upgradeTable) > 0 then   
            player:CoEnableUpgrade(upgradeTable)
        else
            player:spendlvlHints("no_type")
        end
    end
   
end

local function OnCommandAddXp(client, amount)

	local player = client:GetControllingPlayer()        
	if Shared.GetCheatsEnabled() then
		amount = tonumber(amount)
		
		if amount then            
			player:AddXp(amount)
		else
			player:AddXp(1)
		end
	end
end

local function OnCommandShowXp(client)

        local player = client:GetControllingPlayer()        
        Print(player:GetXp())

end

local function OnCommandShowLvl(client)

        local player = client:GetControllingPlayer()        
        Print(player:GetLvl())

end

local function OnCommandStatus(client)

	local player = client:GetControllingPlayer()
	player:SendDirectMessage( "You are level " .. player:GetLvl() .. " and have " .. player:GetLvlFree() .. " free Lvl to use")
	player:SendDirectMessage( "You have " .. player:GetXp() .. " XP, " .. (XpList[player:GetLvl() + 1]["XP"] - player:GetXp()).. " XP until level up!")
	
end

local function OnCommandHelp(client)

	-- Display a banner showing the available commands
	local player = client:GetControllingPlayer()
	player:SendDirectMessage("Use the 'buy' menu to buy upgrades.")
	player:SendDirectMessage("You gain XP for killing other players, ")
	player:SendDirectMessage("damaging structures and healing your structures.")
	player:SendDirectMessage("Type /timeleft in chat to get the time remaining.")

end

local function OnCommandUpgrades(client)

	-- Shows all available Upgrades
	local player = client:GetControllingPlayer()
	local upgradeList

    if player:isa("Marine") or player:isa("Exo") then
		upgradeList = GetAllUpgrades("Marine")
	else
		upgradeList = GetAllUpgrades("Alien")
	end
	
	for _, upgrade in ipairs(upgradeList) do
		local requirements = upgrade:GetRequirements()
		local requirementsText = ""
		
		if (requirements) then 
			requirementsText = GetUpgradeFromId(requirements):GetDescription()
		else
			requirementsText = "no"
		end
		
	    player:SendDirectMessage(upgrade:GetTextCode() .. " (" .. upgrade:GetDescription() .. ") needs " .. (requirementsText or "no") .. " upgrade first and " .. (upgrade:GetLevels() or 0) .. " free Lvl" )
    end

end


-- send the Ups to the requesting player
local function OnCommandSendUpgrades(client)

    local player = client:GetControllingPlayer()
    player:SendAllUpgrades()

end

-- Refund all the upgrades for this player
local function OnCommandRefundAllUpgrades(client)

    local player = client:GetControllingPlayer()
    player:RefundAllUpgrades()

end

local function SendTimeLeftChatToPlayer(player)

	local gameRules = GetGamerules()
    if not gameRules then return end

	local exactTimeLeft = kCombatTimeLimit - gameRules:GetGameStartTime()
	local timeLeft = math.ceil(exactTimeLeft)
	local timeLeftText = GetTimeText(timeLeft)

	player:SendDirectMessage(GetTimeLeftMessage(timeLeftText, player:GetTeamNumber()))

end

-- Get the time remaining in this match.
local function OnCommandTimeLeft(client)

	-- Display the remaining time left
	local player = client:GetControllingPlayer()
	SendTimeLeftChatToPlayer(player)

end

-- All commands that should be accessible via the chat need to be in this list
combatCommands = {"co_spendlvl", "co_help", "co_status", "co_upgrades", "/upgrades", "/status", "/buy", "/help", "/timeleft"}

Event.Hook("Console_co_help",                OnCommandHelp)
Event.Hook("Console_/help",                OnCommandHelp)
Event.Hook("Console_co_upgrades",                OnCommandUpgrades)
Event.Hook("Console_/upgrades",                OnCommandUpgrades)
Event.Hook("Console_co_spendlvl",                OnCommandSpendLvl)
Event.Hook("Console_/buy",						OnCommandSpendLvl)
Event.Hook("Console_co_addxp",                OnCommandAddXp)
Event.Hook("Console_co_showxp",                OnCommandShowXp)
Event.Hook("Console_co_showlvl",                OnCommandShowLvl)
Event.Hook("Console_co_status",                OnCommandStatus)
Event.Hook("Console_co_timeleft",              OnCommandTimeLeft)
Event.Hook("Console_timeleft",              OnCommandTimeLeft)
Event.Hook("Console_/timeleft",              OnCommandTimeLeft)
Event.Hook("Console_/status",                OnCommandStatus)
Event.Hook("Console_co_sendupgrades",       OnCommandSendUpgrades)
Event.Hook("Console_co_refundall", 	        OnCommandRefundAllUpgrades)