
Script.Load("lua/UnitStatusMixin.lua")
Script.Load("lua/ObstacleMixin.lua")
Script.Load("lua/TeamMixin.lua")
Script.Load("lua/LOSMixin.lua")
Script.Load("lua/LiveMixin.lua")


local networkVars =
{
}

AddMixinNetworkVars(ObstacleMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)
AddMixinNetworkVars(LOSMixin, networkVars)
AddMixinNetworkVars(LiveMixin, networkVars)

local oldOnCreate = Door.OnCreate
function Door:OnCreate()
	oldOnCreate(self)
	
    InitMixin(self, TeamMixin)
    InitMixin(self, ObstacleMixin)
    InitMixin(self, LOSMixin)
    InitMixin(self, LiveMixin)
	
end

local oldOnInit = Door.OnInitialized
function Door:OnInitialized()
	oldOnInit(self)
	
	if Server then
		self:SetTeamNumber(kNeutralTeamType)
		self:SetState(Door.kState.Close)
		self:RemoveFromMesh()
		self:OnObstacleChanged()
	end
	
	if Client then
		InitMixin(self, UnitStatusMixin)
	end
	--Log(self:GetTeamNumber())
end

local oldReset = Door.Reset
function Door:Reset()

	oldReset(self)
	self:RemoveFromMesh()
	self:OnObstacleChanged()
	
end

local oldUpdateAutoOpen = debug.getupvaluex(Door.OnCreate, "UpdateAutoOpen")
local function UpdateAutoOpen(self, timePassed)
	
	if self.welded and kCombatAllowOvertime  then
	
		if not GetHasTimelimitPassed() then
		
			if not self:GetIsWeldedShut() then
			
				self:SetState(Door.kState.Welded)
				self:AddToMesh()
				
			end
			return true
			
		else
		
			if self:GetIsWeldedShut() then
			
				self:SetState(Door.kState.Open)
				self:OnObstacleChanged()
				
			end
			
		end

	end
	
	self:RemoveFromMesh()
	
	return oldUpdateAutoOpen(self, timePassed)
end

debug.replaceupvalue( Door.OnCreate, "UpdateAutoOpen", UpdateAutoOpen, true)


function Door:GetShowUnitStatusForOverride(forEntity)
    return true
end

function Door:GetShowHealthFor(player)
    return true
end

function Door:OverrideCheckVision()
    return false
end

function Door:GetIsAlive()
	return true
end

function Door:GetCanDie()
	return false
end

function Door:GetIsSighted()
	return true
end

function Door:GetCanTakeDamageOverride()
    return false
end
function Door:GetCanBeHealedOverride()
    return false
end   

function Door:GetEngagementPoint()
    return self:GetOrigin() + Vector(0, 0.8, 0)
end

function Door:GetName(forEntity)
	return "Door"
end

Shared.LinkClassToMap("Door", Door.kMapName, networkVars)