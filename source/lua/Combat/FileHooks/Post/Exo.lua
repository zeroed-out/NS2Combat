
local kExoDeployDuration = 1.4
function Exo:GetCanEject()
    return self:GetIsPlaying() and not self.ejecting and self:GetIsOnGround()
        and self.creationTime + kExoDeployDuration < Shared.GetTime()
end

function SmashNearbyEggs()
end

debug.setupvaluex(Exo.OnCreate, "SmashNearbyEggs", SmashNearbyEggs)