-- Unlock all upgrade chamber
function AlienTeamInfo:OnUpdate(deltaTime)

    TeamInfo.OnUpdate(self, deltaTime)

    self.veilLevel = 3
	self.spurLevel = 3
	self.shellLevel = 3

end