
local CHUDsfunc = GUIWaitingForAutoTeamBalance.Update
function GUIWaitingForAutoTeamBalance:Update(deltaTime)
    CHUDsfunc(self, deltaTime)
    self:UpdateActual(deltaTime)
end