--________________________________
--
--   	NS2 Combat Mod
--	Made by JimWest and MCMLXXXIV, 2012
--
--________________________________

-- combat_Hive.lua

-- Hives should begin as mature.
local oldOnCreate = Hive.OnCreate
function Hive:OnCreate()
    oldOnCreate(self)

	self:SetMature()
end