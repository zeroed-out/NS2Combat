local oldReset_Lite = Player.Reset_Lite
function Player:Reset_Lite()
	self.combatTable.hasEnzymeCloud = false
	oldReset_Lite(self)
end