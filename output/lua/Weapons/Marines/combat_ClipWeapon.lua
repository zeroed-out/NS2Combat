//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_ClipWeapon.lua

// for fast reload

local HotReload = CombatClipWeapon
if(not HotReload) then
  CombatClipWeapon = {}
  ClassHooker:Mixin("CombatClipWeapon")
end

local idleTime = 0
local animFrequency = 10 --Amount of time between idle animations
    
function CombatClipWeapon:OnLoad()

    --self:ReplaceClassFunction("ClipWeapon", "GetCatalystSpeedBase", "GetCatalystSpeedBase_Hook")
	
end

if (not HotReload) then
	CombatClipWeapon:OnLoad()
end