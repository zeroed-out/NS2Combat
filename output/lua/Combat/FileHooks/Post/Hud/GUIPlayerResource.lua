--________________________________
--
--   	NS2 Combat Mod
--	Made by JimWest and MCMLXXXIV, 2012
--
--________________________________

-- combat_GUIPlayerResources.lua

-- Hide the TEAM RES
local oldUpdateResource = GUIPlayerResource.UpdateResource
function GUIPlayerResource:UpdateResource(...)

    oldUpdateResource(self, ...)

	self.teamText:SetText("")

end

-- Upgrade Points instead of RESOURCES
local oldInitialize = GUIPlayerResource.Initialize
function GUIPlayerResource:Initialize(...)
    oldInitialize(self, ...)

	self.pResDescription:SetText("Upgrade Points")

end