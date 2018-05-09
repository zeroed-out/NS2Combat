--________________________________
--
--   	NS2 Combat Mod
--	Made by JimWest and MCMLXXXIV, 2012
--
--________________________________

-- combat_Embryo.lua

local oldSetGestationData = Embryo.SetGestationData
function Embryo:SetGestationData(techIds, previousTechId, ...)

	oldSetGestationData(self, techIds, previousTechId, ...)
	-- Override the gestation times...
	self.gestationTime = kSkulkGestateTime
	
	if (self.combatTable.classEvolve) then
		local newGestateTime = kGestateTime[previousTechId]
		if newGestateTime then
			self.gestationTime = newGestateTime
		end
		
		self.combatTable.classEvolve = nil
	end
		
end
