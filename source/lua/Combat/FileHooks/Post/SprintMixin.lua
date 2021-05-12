
function SprintMixin:GetSprintingScalar()
    return self.sprintingScalar * (self:GotFastSprint() and kSprintSpeedUpgradeScalar or 1)
end