local oldUpdate = GUIAlienSpectatorHUD.Update
function GUIAlienSpectatorHUD:Update()

    oldUpdate(self)

	self.eggIcon:SetIsVisible(false)

end