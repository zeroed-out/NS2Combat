-- Upgrade Points instead of RESOURCES
local oldInitialize = GUIPlayerResource.Initialize
function GUIPlayerResource:Initialize(...)
    oldInitialize(self, ...)

	self.pResDescription:SetText("Upgrade Points")

end