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
    -- Todo: Do we really need a console command????
    Shared.ConsoleCommand("co_sendupgrades")
	
	-- Also initialise counters
	if (kCombatTimeSinceGameStart == nil) then
		kCombatTimeSinceGameStart = 0
	end

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
    local armorLevel = 0
    local self = Client.GetLocalPlayer()
    if self.gameStarted then
    
        local techTree = self:GetUpgrades()
        --Todo: Why iterate over the techtree when we could just use a int network value ...
        if techTree then
            if table.maxn(techTree) > 0 then
                for i, upgradeTechId in ipairs(techTree) do
               
                    if upgradeTechId == kTechId.Armor3 then
                        armorLevel = 3
                    elseif upgradeTechId == kTechId.Armor2 then
                        armorLevel = 2
                    elseif upgradeTechId == kTechId.Armor1 then
                        armorLevel = 1
                    end
                    
                end   
            end
        end
    
    end

    return armorLevel
end

function PlayerUI_GetWeaponLevel()
    local weaponLevel = 0    
    local self = Client.GetLocalPlayer()
    if self.gameStarted then
    
        local techTree = self:GetUpgrades()    
        if techTree then
            if table.maxn(techTree) > 0 then
                for i, upgradeTechId in ipairs(techTree) do
               
                    if upgradeTechId == kTechId.Weapons3 then
                        weaponLevel = 3
                    elseif upgradeTechId == kTechId.Weapons2 then
                        weaponLevel = 2
                    elseif upgradeTechId == kTechId.Weapons1 then
                        weaponLevel = 1
                    end
                    
                end   
            end
        end
    
    end
    
    return weaponLevel
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
