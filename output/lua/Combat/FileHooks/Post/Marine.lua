--________________________________
--
--   	NS2 Combat Mod
--	Made by JimWest and MCMLXXXIV, 2012
--
--________________________________

-- combat_Marine.lua

--___________________
-- Hooks Marine
--___________________

-- Dont' drop Weapons after getting killed, but destroy them!
local oldOnKill = Marine.OnKill
function Marine:OnKill(...)

    self:DestroyWeapons()

    oldOnKill(self, ...)
end

-- Weapons can't be dropped anymore
function Marine:Drop()

	-- just do nothing

end

-- Return the new marine so that we can update the player that is referenced.
function Marine:GiveJetpack()

    local activeWeapon = self:GetActiveWeapon()
    local activeWeaponMapName
    local health = self:GetHealth()
    
    if activeWeapon ~= nil then
        activeWeaponMapName = activeWeapon:GetMapName()
    end
    
    local jetpackMarine = self:Replace(JetpackMarine.kMapName, self:GetTeamNumber(), true, Vector(self:GetOrigin()))
    
    jetpackMarine:SetActiveWeapon(activeWeaponMapName)
    jetpackMarine:SetHealth(health)
    
	return jetpackMarine
	
end

local oldOnTakeDamage = Marine.OnTakeDamage
function Marine:OnTakeDamage(...)

    oldOnTakeDamage(self, ...)

	-- Activate the Catalyst Pack.
	self:CheckCombatData()
	self:CheckCatalyst()

end

