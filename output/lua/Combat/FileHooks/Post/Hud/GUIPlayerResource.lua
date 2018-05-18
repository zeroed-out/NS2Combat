-- Hide the TEAM RES
local oldUpdate = GUIPlayerResource.Update
function GUIPlayerResource:Update(...)

    oldUpdate(self, ...)

	self.teamText:SetText("")

end

-- Upgrade Points instead of RESOURCES
local oldInitialize = GUIPlayerResource.Initialize
function GUIPlayerResource:Initialize(...)
    oldInitialize(self, ...)

	self.pResDescription:SetText("Upgrade Points")

end