-- combat_PowerPoint.lua
local kSocketedModelName = PrecacheAsset("models/system/editor/power_node.model")
local kSocketedAnimationGraph = PrecacheAsset("models/system/editor/power_node.animation_graph")
local kAuxPowerBackupSound = PrecacheAsset("sound/NS2.fev/marine/power_node/backup")

function PowerPoint:GetCanTakeDamageOverride()
    return kCombatPowerPointsTakeDamage
end

if not Server then return end

function PowerPoint:PowerUp()

	self:SetModel(kSocketedModelName, kSocketedAnimationGraph)
	self:SetInternalPowerState(PowerPoint.kPowerState.socketed)
	self:SetConstructionComplete()
	self:SetLightMode(kLightMode.Normal)
	self:StopSound(kAuxPowerBackupSound)
	self:TriggerEffects("fixed_power_up")
	self:SetPoweringState(true)
	
end

local oldOnInitialized = PowerPoint.OnInitialized
function PowerPoint:OnInitialized()
	oldOnInitialized(self)

	self:PowerUp()
end

local oldReset = PowerPoint.Reset
function PowerPoint:Reset()
	oldReset(self)

	self:PowerUp()
end

function PowerPoint:AutoRepair()
	self.health = kPowerPointHealth
	self.armor = kPowerPointArmor
	
	self.maxHealth = kPowerPointHealth
	self.maxArmor = kPowerPointArmor
	
	self.alive = true
	
	self:PowerUp()
	return false
end

local oldOnKill = PowerPoint.OnKill
function PowerPoint:OnKill(attacker, doer, point, direction)
	oldOnKill(self, attacker, doer, point, direction)

	if attacker and attacker:isa("Player") then
		self:AddTimedCallback(self.AutoRepair, kCombatPowerPointAutoRepairTime)
	end
end