
function ObstacleMixin:_GetPathingInfo()

    local position = self:GetOrigin() + Vector(0, -2, 0)
    local radius = LookupTechData(self:GetTechId(), kTechDataObstacleRadius, 1.0)
    local height = 5.0

    return position, radius, height

end