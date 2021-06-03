local networkVars = {
    lastEnzymeCloud = "time"
}

Shared.LinkClassToMap("Alien", Alien.kMapName, networkVars, true)

local oldOnCreate = Alien.OnCreate
function Alien:OnCreate()
	oldOnCreate(self)
	self.lastEnzymeCloud = 0
    
end
