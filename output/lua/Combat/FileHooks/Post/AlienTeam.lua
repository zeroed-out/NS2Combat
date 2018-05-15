--________________________________
--
--   	NS2 Combat Mod
--	Made by JimWest and MCMLXXXIV, 2012
--
--________________________________

-- combat_AlienTeam.lua

-- No cysts
function AlienTeam:SpawnInitialStructures(techPoint)

    local tower, hive = PlayingTeam.SpawnInitialStructures(self, techPoint)
    
    hive:SetFirstLogin()
    hive:SetInfestationFullyGrown()    
   
    return tower, hive
    
end


function AlienTeam:GetNumHives()

    return 6 -- Todo: Why?
    
end

function AlienTeam:GetBioMassLevel()

	return 12
	
end

function AlienTeam:GetMaxBioMassLevel()

	return 12

end

function AlienTeam:OnResetComplete()

    -- Try to destroy the local powernode, if we can find one.
    local initialTechPoint = self:GetInitialTechPoint()
    for _, powerPoint in ientitylist(Shared.GetEntitiesWithClassname("PowerPoint")) do

        if powerPoint:GetLocationName() == initialTechPoint:GetLocationName() then
            powerPoint:SetConstructionComplete()
            powerPoint:Kill(nil, nil, powerPoint:GetOrigin())
        end

    end

end