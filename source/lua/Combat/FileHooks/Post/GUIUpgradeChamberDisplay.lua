-- Hide the chamber GUI
local oldInitialize = GUIUpgradeChamberDisplay.Initialize
function GUIUpgradeChamberDisplay:Initialize()

    oldInitialize(self)

    self.background:SetIsVisible(false)

end