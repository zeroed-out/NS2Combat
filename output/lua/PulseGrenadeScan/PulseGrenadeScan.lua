-- Xanthus: edited from Scan.lua

Script.Load("lua/CommAbilities/CommanderAbility.lua")
Script.Load("lua/MapBlipMixin.lua")

class 'PulseGrenadeScan' (CommanderAbility)

PulseGrenadeScan.kMapName = "pulsegrenadescan"

PulseGrenadeScan.kPulseGrenadeScanEffect = PrecacheAsset("cinematics/pulseGrenadeScan.cinematic")
PulseGrenadeScan.kPulseGrenadeScanSound = PrecacheAsset("sound/NS2.fev/marine/commander/scan")

PulseGrenadeScan.kType = CommanderAbility.kType.Repeat
local kPulseGrenadeScanInterval = 0.2

PulseGrenadeScan.kPulseGrenadeScanDistance = kScanRadius

local networkVars = { }

function PulseGrenadeScan:OnCreate()

    CommanderAbility.OnCreate(self)

    if Server then
        StartSoundEffectOnEntity(PulseGrenadeScan.kPulseGrenadeScanSound, self)
    end

end

function PulseGrenadeScan:OnInitialized()

    CommanderAbility.OnInitialized(self)

    if Server then

        DestroyEntitiesWithinRange("PulseGrenadeScan", self:GetOrigin(), PulseGrenadeScan.kPulseGrenadeScanDistance * 0.5, EntityFilterOne(self))

        if not HasMixin(self, "MapBlip") then
            InitMixin(self, MapBlipMixin)

            -- replace mapblip with new one. Found this a little cleaner than editing multiple functions and enums. Old method in OldUnused.lua
            local mapBlip = self.mapBlipId and Shared.GetEntity(self.mapBlipId)
            if mapBlip then

                DestroyEntity(mapBlip)
                self.mapBlipId = nil

                mapName = PulseGrenadeScanMapBlip.kMapName

                local mapBlip = Server.CreateEntity(mapName)
                -- This may fail if there are too many entities.
                if mapBlip then

                    mapBlip:SetOwner(self:GetId(), kMinimapBlipType.Scan, self:GetTeamNumber())
                    self.mapBlipId = mapBlip:GetId()

                end
            end


        end

    end

end

function PulseGrenadeScan:OverrideCheckVision()
    return true
end

function PulseGrenadeScan:GetVisionRadius()
    return PulseGrenadeScan.kPulseGrenadeScanDistance
end

function PulseGrenadeScan:GetRepeatCinematic()
    return PulseGrenadeScan.kPulseGrenadeScanEffect
end

function PulseGrenadeScan:GetType()
    return PulseGrenadeScan.kType
end

function PulseGrenadeScan:GetLifeSpan()
    return kScanDuration*0.5 -- half as long as a normal scan
end

function PulseGrenadeScan:GetUpdateTime()
    return kPulseGrenadeScanInterval
end

if Server then

    function PulseGrenadeScan:PulseGrenadeScanEntity(ent)
        if HasMixin(ent, "LOS") then
            ent:SetIsSighted(true, self)
        end

        if HasMixin(ent, "Detectable") then
            ent:SetDetected(true)
        end

        -- Allow entities to respond
        if ent.OnScan then
            ent:OnScan()
        end
    end

    function PulseGrenadeScan:Perform()

        PROFILE("PulseGrenadeScan:Perform")

        local inkClouds = GetEntitiesForTeamWithinRange("ShadeInk", GetEnemyTeamNumber(self:GetTeamNumber()), self:GetOrigin(), PulseGrenadeScan.kPulseGrenadeScanDistance)

        if #inkClouds > 0 then

            for _, cloud in ipairs(inkClouds) do
                cloud:SetIsSighted(true)
            end

        else

            -- avoid scanning entities twice
            local scannedIdMap = {}
            local enemies = GetEntitiesWithMixinForTeamWithinXZRange("LOS", GetEnemyTeamNumber(self:GetTeamNumber()), self:GetOrigin(), PulseGrenadeScan.kPulseGrenadeScanDistance)
            for _, enemy in ipairs(enemies) do

                local entId = enemy:GetId()
                scannedIdMap[entId] = true

                self:PulseGrenadeScanEntity(enemy)

            end

            local detectable = GetEntitiesWithMixinForTeamWithinXZRange("Detectable", GetEnemyTeamNumber(self:GetTeamNumber()), self:GetOrigin(), PulseGrenadeScan.kPulseGrenadeScanDistance)
            for _, enemy in ipairs(detectable) do

                local entId = enemy:GetId()
                if not scannedIdMap[entId] then
                    self:PulseGrenadeScanEntity(enemy)
                end

            end

        end

    end

    function PulseGrenadeScan:OnDestroy()

        for _, entity in ipairs( GetEntitiesWithMixinForTeamWithinRange("LOS", GetEnemyTeamNumber(self:GetTeamNumber()), self:GetOrigin(), PulseGrenadeScan.kPulseGrenadeScanDistance)) do
            entity.updateLOS = true
        end

        CommanderAbility.OnDestroy(self)

    end

end

--test
function PulseGrenadeScan:GetMapBlipType()
    return kMinimapBlipType.Scan
end

Shared.LinkClassToMap("PulseGrenadeScan", PulseGrenadeScan.kMapName, networkVars)


class 'PulseGrenadeScanMapBlip' (MapBlip)
PulseGrenadeScanMapBlip.kMapName = "PulseGrenadeScanMapBlip"
if Client then

    function PulseGrenadeScanMapBlip:UpdateMinimapActivity()
        return kMinimapActivity.High
    end

    -- Update color, scale and position for animation
    local _blipPos = Vector(0,0,0) -- Avoid GC
    function PulseGrenadeScanMapBlip:UpdateMinimapItemHook(minimap, item)
        PROFILE("PulseGrenadeScanMapBlip:UpdateMinimapItemHook")

        if not item:GetIsVisible() then return end

        MapBlip.UpdateMinimapItemHook(self, minimap, item)

        local size = minimap.scanSize
        local color = Color(1,1,0,minimap.scanColor.a)

        item:SetSize(size)
        item:SetColor(color)

        -- adjust position
        local origin = self:GetOrigin()
        local xPos, yPos = minimap:PlotToMap(origin.x, origin.z)
        _blipPos.x = xPos - size.x * 0.5
        _blipPos.y = yPos - size.y * 0.5
        item:SetPosition(_blipPos)
    end

end
Shared.LinkClassToMap("PulseGrenadeScanMapBlip", PulseGrenadeScanMapBlip.kMapName, {})