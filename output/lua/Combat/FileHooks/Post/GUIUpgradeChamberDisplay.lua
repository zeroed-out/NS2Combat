--________________________________
--
--   	NS2 Combat Mod
--	Made by JimWest and MCMLXXXIV, 2012
--
--________________________________

-- combat_GUIUpgradeChamberDisplay.lua

-- Hide the chamber GUI
local oldInitialize = GUIUpgradeChamberDisplay.Initialize
function GUIUpgradeChamberDisplay:Initialize()

    oldInitialize(self)

    self.background:SetIsVisible(false)

end