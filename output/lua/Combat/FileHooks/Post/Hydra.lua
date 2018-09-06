

-- kill hydra if owner is no longer a gorge
if Server then
	local oldOnUpdate = Hydra.OnUpdate
	function Hydra:OnUpdate(...)
		oldOnUpdate(self, ...)

		-- check if the owner is still a gorge
		if self.hydraParentId then
			local owner = Shared.GetEntity(self.hydraParentId)
			if owner then
				if not owner:isa("Gorge") then
					-- start a timer, if the player is still no gorge when the timer is 0, kill the hydras
					if not self.killTime then
						self.killTime = Shared.GetTime() + kHydraKillTime
					end
					
					if Shared.GetTime() >= self.killTime then
						self:Kill()
					end
					
				else
					self.killTime = nil
				end 
			else
				self:Kill()
			end   
		end
	end
end