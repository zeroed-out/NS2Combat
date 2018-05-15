--________________________________
--
--   	NS2 Combat Mod
--	Made by JimWest and MCMLXXXIV, 2012
--
--________________________________

-- combat_Player.lua

-- Load the Upgrade functions too...
Script.Load("lua/Combat/Player_Upgrades.lua")

-- Open buy menu for exos and marines. Alien class overwrites this method so we are fine.
function Player:Buy()

    -- Don't allow display in the ready room, or as phantom
    if self:GetIsLocalPlayer() and not HelpScreen_GetHelpScreen():GetIsBeingDisplayed() then

        -- The Embryo cannot use the buy menu in any case.
        if self:GetTeamNumber() ~= 0 and not self:isa("Embryo") then

            if not self.buyMenu then

                self.buyMenu = GetGUIManager():CreateGUIScript("GUIMarineBuyMenu")

            else
                self:CloseMenu()
            end

        end

    end
end

-- check for FastReload
function Player:GotFastReload()
    
    local fastReload = false
    
    if Server then
		self:CheckCombatData()
        if self.combatTable.hasFastReload then
            fastReload = true
        end
    elseif Client then
        local techTree = self:GetUpgrades()
        
        if #techTree > 0 then
            for i, upgradeTechId in ipairs(techTree) do
                if upgradeTechId == kTechId.AdvancedWeaponry then
                    fastReload = true
                    break
                end
            end
        end
        
    end
    
    return fastReload

end

-- check focus upgrade and weapon
function Player:GotFocus()

    local gotFocus = false
    
    if Server then
		self:CheckCombatData()
        if self.combatTable.hasFocus then
            -- check the weapon
            if self:IsAttackingPrimry() then
                gotFocus = true
            end       
        end  
        
    elseif Client then
        local techTree = self:GetUpgrades()
        
        if #techTree > 0 then
            for i, upgradeTechId in ipairs(techTree) do
                if upgradeTechId == kTechId.NutrientMist then
                    if self:IsAttackingPrimry() then
                        gotFocus = true
                    end
                    break
                end
            end
        end
        
    end
    
    return gotFocus
end

function Player:IsAttackingPrimry()
    local activeWeapon = self:GetActiveWeapon()
    if activeWeapon then
        -- only give focus when primary attacking, every weapon has itsn own attribute so its a bit dirty, but it works
        -- there is a primaryAttacking on every weapon, but only on bite its getting true
        if (activeWeapon.primaryAttacking == true or activeWeapon.firingPrimary == true or activeWeapon.attacking == true or activeWeapon.attackButtonPressed == true) then
            local hudSlot = activeWeapon.GetHUDSlot()                
            if hudSlot == 1 then
                return true
            end 
        end              
    end
    return false
end

local oldGetCanTakeDamageOverride = Player.GetCanTakeDamageOverride
function Player:GetCanTakeDamageOverride()
    local canTakeDamage = oldGetCanTakeDamageOverride(self)

    return canTakeDamage and not self.gotSpawnProtect

end