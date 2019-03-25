-- combat_PowerPoint.lua
local kSocketedModelName = PrecacheAsset("models/system/editor/power_node.model")
local kSocketedAnimationGraph = PrecacheAsset("models/system/editor/power_node.animation_graph")
local kUnsocketedSocketModelName = PrecacheAsset("models/system/editor/power_node_socket.model")
local kAuxPowerBackupSound = PrecacheAsset("sound/NS2.fev/marine/power_node/backup")

function PowerPoint:GetCanTakeDamageOverride()
    return kCombatPowerPointsTakeDamage
end

if not Server then return end

function PowerPoint:PowerUp()

	self:SetModel(kUnsocketedSocketModelName)
	self:SetInternalPowerState(PowerPoint.kPowerState.unsocketed)
	--self:SetConstructionComplete()
	self:SetLightMode(kLightMode.Normal)
	self:StopSound(kAuxPowerBackupSound)
	self:SetPoweringState(false)
	self.constructionComplete = false
	
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

function PowerPoint:GetShowUnitStatusForOverride(forEntity)
    return false
end

function PowerPoint:GetCanConstructOverride()
	return false
end

function PowerPoint:GetCanTakeDamageOverride()
	return false
end