--________________________________
--
--   	NS2 Combat Mod
--	Made by JimWest and MCMLXXXIV, 2012
--
--________________________________

-- combat_CommandStructure.lua

function CommandStructure:UpdateCommanderLogin()

	self.occupied = true
	self.commanderId = Entity.invalidId

end

function CommandStructure:OnAttached(attached)

	if attached then
		attached.showObjective = true
	end

end

function CommandStructure:GetCanBeHealedOverride()
	return self:GetIsAlive() and GetHasTimelimitPassed and not GetHasTimelimitPassed()
end

function CommandStructure:GetCanBeUsed(_, useSuccessTable)
	useSuccessTable.useSuccess = false

	return false
end