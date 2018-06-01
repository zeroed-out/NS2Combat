
local originalAlienUpdate = GUIMarineHUD.Update
function GUIMarineHUD:Update(deltaTime)
    originalAlienUpdate(self, deltaTime)
    self.resourceDisplay.rtCount:SetIsVisible(false)
	self.resourceDisplay.pResDescription:SetText("Upgrade Points")
end