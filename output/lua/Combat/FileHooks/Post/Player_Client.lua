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
    if self.gameStarted then
    
        local techTree = self:GetUpgrades()
        if techTree then
            local armor3Node = techTree:GetTechNode(kTechId.Armor3)
            if armor3Node then return 3 end

            local armor2Node = techTree:GetTechNode(kTechId.Armor2)
            if armor2Node then return 2 end

            local armor1Node = techTree:GetTechNode(kTechId.Armor1)
            if armor1Node then return 1 end
        end
    
    end

    return 0
end

function PlayerUI_GetWeaponLevel()
    local self = Client.GetLocalPlayer()
    if self.gameStarted then

        local techTree = self:GetUpgrades()    
        if techTree then
            local techTree = self:GetUpgrades()
            if techTree then
                local weapon3Node = techTree:GetTechNode(kTechId.Weapon3)
                if weapon3Node then return 3 end

                local weapon2Node = techTree:GetTechNode(kTechId.Weapon2)
                if weapon2Node then return 2 end

                local weapon1Node = techTree:GetTechNode(kTechId.Weapon1)
                if weapon1Node then return 1 end
            end
        end
    
    end
    
    return 0
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