
local oldCanBeWelded = CommandStation.GetCanBeWeldedOverride
function CommandStation:GetCanBeWeldedOverride(...)
	if self:GetIsAlive() and GetHasTimelimitPassed and GetHasTimelimitPassed() then
		return false
	end
	if oldCanBeWelded then
		return oldCanBeWelded(self, ...)
	end
	return true
end