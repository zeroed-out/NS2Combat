-- Server only
if not Server then return end

-- Todo: Add OnAttack to Vanilla build 323
local oldOnAttack = Weapon.OnAttack
function Weapon:OnAttack(player)
	if oldOnAttack then oldOnAttack(self, player) end

	if (player:isa("Marine") or player:isa("Exo")) then
		player:CheckCombatData()
		player:CheckCatalyst()
	end
end

local oldOnPrimaryAttackEnd = Weapon.OnPrimaryAttackEnd
function Weapon:OnPrimaryAttackEnd(player)
	oldOnPrimaryAttackEnd(self, player)

	if player and (player:isa("Marine") or player:isa("Exo")) then
		player:CheckCombatData()
		player:CheckCatalyst()
	end
end