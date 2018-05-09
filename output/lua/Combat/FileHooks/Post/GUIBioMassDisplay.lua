--________________________________
--
--   	NS2 Combat Mod
--	Made by JimWest and MCMLXXXIV, 2012
--
--________________________________

-- combat_GUIBioMassDisplay.lua

-- Hide the biomass GUI
local oldUpdate = GUIBioMassDisplay.Update
function GUIBioMassDisplay:Update(deltaTime)

    oldUpdate(self)

    self.backgroundColor.a = 0
    self.background:SetColor(self.backgroundColor)
    self.smokeyBackground:SetColor(self.backgroundColor)

end