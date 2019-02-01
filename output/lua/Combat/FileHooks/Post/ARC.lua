
ARC.kMoveSpeed = 1.2 -- was 2.0
ARC.kCombatMoveSpeed = 0.8 -- was 0.8
if Server then
	local oldOnUpdate = ARC.OnUpdate
	function ARC:OnUpdate(deltaTime)
		oldOnUpdate(self, deltaTime)
		if self.deployMode == ARC.kDeployMode.Undeployed then
		
			local enemyCCs = GetEntitiesForTeam("CommandStructure", GetEnemyTeamNumber(self:GetTeamNumber()))
			
			for _, enemy in ipairs (enemyCCs) do
			
				if enemy:GetIsAlive() then
				
					local distToTarget = (enemy:GetOrigin() - self:GetOrigin()):GetLengthXZ()
					
					if distToTarget < kARCRange - 2 then
						self:GiveOrder(kTechId.ARCDeploy, self:GetId(), self:GetOrigin(), nil, true, true)
						break
					elseif self:GetCurrentOrder() == nil or self:GetCurrentOrder():GetType() ~= kTechId.Move then
						self:GiveOrder(kTechId.Move, enemy:GetId(), enemy:GetOrigin(), nil, true, true)
						break
					end
					
				end
				
			end
			
		end
		
	end
end