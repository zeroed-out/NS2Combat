-- Hide the biomass GUI
local oldUpdate = GUIBioMassDisplay.Update
function GUIBioMassDisplay:Update()

    oldUpdate(self)

    self.backgroundColor.a = 0
    self.background:SetColor(self.backgroundColor)
    self.smokeyBackground:SetColor(self.backgroundColor)

end