--________________________________
--
--   	NS2 Combat Mod
--	Made by JimWest and MCMLXXXIV, 2012
--
--________________________________

-- combat_Weapon.lua

-- Todo: Add OnAttack to Vanilla build 323
local oldOnAttack = Weapon.OnAttack
function Weapon:OnAttack(player)
	if oldOnAttack then oldOnAttack(self, player) end

	if (player:isa("Marine") or player:isa("Exo")) then
		player:CheckCombatData()
		player:CheckCatalyst()
	end
end

local oldOnPrimaryAttack = Weapon.OnPrimaryAttack
function Weapon:OnPrimaryAttack(player)
	oldOnPrimaryAttack(self, player)

	if not oldOnAttack then self:OnAttack(player) end
end

local oldOnSecondaryAttack = Weapon.OnSecondaryAttack
function Weapon:OnSecondaryAttack(player)
	oldOnSecondaryAttack(self, player)

	if not oldOnAttack then self:OnAttack(player) end
end