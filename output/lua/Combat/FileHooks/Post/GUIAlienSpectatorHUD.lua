--________________________________
--
--   	NS2 Combat Mod
--	Made by JimWest and MCMLXXXIV, 2012
--
--________________________________

-- combat_GUIAlienSpectatorHUD.lua

local oldUpdate = GUIAlienSpectatorHUD.Update
function GUIAlienSpectatorHUD:Update()

    oldUpdate(self)

	self.eggIcon:SetIsVisible(false)

end