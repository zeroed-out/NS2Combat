-- custom NetworkMessages for the combat mod (for telling client if the mode is active or not)
Script.Load("lua/Combat/ExperienceEnums.lua")

local kCombatUpgradeCountUpdateMessage =
{
    upgradeId = "enum kCombatUpgrades",
	upgradeCount = "integer"
}
Shared.RegisterNetworkMessage("CombatUpgradeCountUpdate", kCombatUpgradeCountUpdateMessage)

local kCombatSetUpgradeMessage =
{
	upgradeId = "enum kCombatUpgrades"
}
Shared.RegisterNetworkMessage("CombatSetUpgrade", kCombatSetUpgradeMessage)

local kCombatSetLvlUpMessage =
{
    level = "integer"
}
Shared.RegisterNetworkMessage("CombatLvlUp", kCombatSetLvlUpMessage)

local kCombatSettings =
{
	compMode = "boolean",
	defaultWinner = "integer (0 to 2)",
	powerPointTakeDamage = "boolean",
	timelimit = "integer",
    allowOverTime = "boolean"
}
Shared.RegisterNetworkMessage("CombatSettings", kCombatSettings)

if Server then
	
	function BuildCombatUpgradeCountMessage(messageUpgradeId, messageUpgradeCount)
	
		return { upgradeId = messageUpgradeId,
				 upgradeCount = messageUpgradeCount }
	
	end
	
	function SendCombatUpgradeCountUpdate(player, upgradeId, upgradeCount)
		
        if player then
			local message = BuildCombatUpgradeCountMessage(upgradeId, upgradeCount)
            Server.SendNetworkMessage(player, "CombatUpgradeCountUpdate", message, true)
        end
     
    end
	
	function BuildCombatSetUpgradeMessage(messageUpgradeId)
	
		return { upgradeId = messageUpgradeId, }
	
	end
	
	function SendCombatSetUpgrade(player, upgradeId)
		
        if player then
			local message = BuildCombatSetUpgradeMessage(upgradeId)
            Server.SendNetworkMessage(player, "CombatSetUpgrade", message, true)
        end
     
    end
    
    function SendCombatLvlUp(player)
		
        if player then
			local message = {level = player.resources}
            Server.SendNetworkMessage(player, "CombatLvlUp", message, true)
        end
     
    end

    function SendCombatSettings(client)
        local settings = {
            compMode = kCombatCompMode,
            defaultWinner = kCombatDefaultWinner,
            powerPointTakeDamage = kCombatPowerPointsTakeDamage,
            timelimit = kCombatTimeLimit,
            allowOverTime = kCombatAllowOvertime
        }

        Server.SendNetworkMessage(client, "CombatSettings", settings, true)
    end
    
elseif Client then
	
	-- Upgrade the counts for this upgrade Id.
	local function GetUpgradeCountUpdate(messageTable)

		if (kCombatUpgradeCounts == nil) then 
			kCombatUpgradeCounts = {}
		end
		kCombatUpgradeCounts[messageTable.upgradeId] = messageTable.upgradeCount
        
    end
    
    Client.HookNetworkMessage("CombatUpgradeCountUpdate", GetUpgradeCountUpdate)
	
	local function GetCombatSetUpgrade(messageTable)

		-- insert the ids in the personal player table
		local player = Client.GetLocalPlayer()
		
		if not player.combatUpgrades then
			player.combatUpgrades = {}
		end
		
		table.insert(player.combatUpgrades, messageTable.upgradeId)
        
    end
    Client.HookNetworkMessage("CombatSetUpgrade", GetCombatSetUpgrade)
    
    local function GetCombatLvlUp(messageTable)
		local player = Client.GetLocalPlayer()
        player:LevelUpMessage(messageTable.level)
    end
    Client.HookNetworkMessage("CombatLvlUp", GetCombatLvlUp)

    local function ReceiveCombatSettings(settings)
        kCombatCompMode = settings.compMode
        kCombatTimeLimit = settings.timeLimit
        kCombatAllowOvertime = settings.allowOvertime
        kCombatDefaultWinner = settings.defaultWinner
        kCombatPowerPointsTakeDamage = settings.powerPointsTakeDamage
    end
    Client.HookNetworkMessage("CombatSettings", ReceiveCombatSettings)
    
end
