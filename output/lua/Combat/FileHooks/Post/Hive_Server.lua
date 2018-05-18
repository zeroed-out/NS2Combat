-- Hives should begin as mature.
local oldOnCreate = Hive.OnCreate
function Hive:OnCreate()
    oldOnCreate(self)

	self:SetMature()
end