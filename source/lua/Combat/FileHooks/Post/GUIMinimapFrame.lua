
local oldInitialize = GUIMinimapFrame.Initialize
function GUIMinimapFrame:Initialize()
    oldInitialize(self)
    self.chooseSpawnText:SetText("")
    
end