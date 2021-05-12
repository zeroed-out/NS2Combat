-- Hook GetIsTechAvailable so Aliens can get Ups Like cara, cele etc.
function GetIsTechAvailable()

    return true

end


function GetHasCamouflageUpgrade(callingEntity)
    return callingEntity.combatTable and callingEntity.combatTable.hasCamouflage
end