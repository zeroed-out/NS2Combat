-- Server only
if not Server then return end

local oldOnPrimaryAttack = Ability.OnPrimaryAttack
function Ability:OnPrimaryAttack(self, player)
	oldOnPrimaryAttack(self, player)
    Print("bob2 and " .. player:isa("Alien"))
	if player and player:isa("Alien") then
		player:CheckCombatData()
		player:CheckEnzyme()
	end
end