local networkVars = {
    lastNutrientMist = "time"

}

Shared.LinkClassToMap("Alien", Alien.kMapName, networkVars, true)

local oldOnCreate = Alien.OnCreate
function Alien:OnCreate()
	oldOnCreate(self)
    self.lastNutrientMist = 0
    
end
