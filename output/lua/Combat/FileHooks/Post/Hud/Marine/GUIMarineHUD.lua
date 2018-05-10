--________________________________
--
--   	NS2 Combat Mod
--	Made by JimWest and MCMLXXXIV, 2012
--
--________________________________

-- Display a COMBAT MODE instead of commander name...
local oldUpdate = GUIMarineHUD.Update
function GUIMarineHUD:Update(deltaTime)
    oldUpdate(self, deltaTime)

	self.commanderName:DestroyAnimation("COMM_TEXT_WRITE")
	self.commanderName:SetText("COMBAT MODE")
	self.commanderName:SetColor(GUIMarineHUD.kActiveCommanderColor)

end