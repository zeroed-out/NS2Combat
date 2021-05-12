-- add Scan to Pulse grenade

local oldDetonate = PulseGrenade.Detonate

function PulseGrenade:Detonate(targetHit)

    local position = self:GetOrigin()

    -- testing new scan
    CreateEntity(PulseGrenadeScan.kMapName, position, self:GetTeamNumber())

    StartSoundEffectAtOrigin(Observatory.kCommanderScanSound, position)

    oldDetonate(self,targetHit)
end