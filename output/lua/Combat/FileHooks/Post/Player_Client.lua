--________________________________
--
--   	NS2 Combat Mod
--	Made by JimWest and MCMLXXXIV, 2012
--
--________________________________

-- combat_Player_ClientHook.lua

Script.Load("lua/Combat/Player_Upgrades_Client.lua")

local oldOnInitLocalClient = Player.OnInitLocalClient
function Player:OnInitLocalClient()

    -- get the ups from the server (only worked that way)
    Shared.ConsoleCommand("co_sendupgrades")

    oldOnInitLocalClient(self)
end


-- Close the menu properly when a player dies.
-- Note: This does not trigger when players are killed via the console as that calls 'Kill' directly.
local oldAddTakeDamageIndicator = Player.AddTakeDamageIndicator
function Player:AddTakeDamageIndicator(...)
    if not self:GetIsAlive() and not self.deathTriggered then    
		self:CloseMenu(true)        
    end

    oldAddTakeDamageIndicator(self, ...)
end

-- to show the correct Armor and Weapon Lvl
function PlayerUI_GetArmorLevel()
    local self = Client.GetLocalPlayer()
    local level = 0
    
    local upgrades = self:GetPlayerUpgrades()
    for i = 1, #upgrades do
        local upgradeId = upgrades[i]

        if upgradeId == kTechId.Armor3 then
            level = 3
            break
        elseif upgradeId == kTechId.Armor2 then
            level = math.max(level, 2)
        elseif upgradeId == kTechId.Armor1 then
            level = math.max(level, 1)
        end
    end

    return level
end

function PlayerUI_GetWeaponLevel()
    local self = Client.GetLocalPlayer()

    local level = 0
    local upgrades = self:GetUpgrades()
    for i = 1, #upgrades do
        local upgradeId = upgrades[i]

        if upgradeId == kTechId.Weapons3 then
            level = 3
            break
        elseif upgradeId == kTechId.Weapons2 then
            level = math.max(level, 2)
        elseif upgradeId == kTechId.Weapons1 then
            level = math.max(level, 1)
        end
    end
    
    return level
end

local oldUpdateMisc = Player.UpdateMisc
function Player:UpdateMisc(input)

    oldUpdateMisc(self, input)

    if not Shared.GetIsRunningPrediction() then

        -- Close the buy menu if it is visible when the Player moves.
        if input.move.x ~= 0 or input.move.z ~= 0 then
            self:CloseMenu(true)
        end
        
    end

end