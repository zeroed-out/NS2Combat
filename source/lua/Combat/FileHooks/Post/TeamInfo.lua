
local networkVars =
{
    nextRespawn = "time"
}

function TeamInfo:GetNextRespawn()
    return self.nextRespawn
end

if Server then

    function TeamInfo:SetNextRespawn(time)
        self.nextRespawn = time
    end
end

Shared.LinkClassToMap("TeamInfo", TeamInfo.kMapName, networkVars)