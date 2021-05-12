-- Only load these changes inside the Server VM
if not Server then return end

Script.Load("lua/Utility.lua")

local function setDecimalPlaces(num, idp)
    local mult = 10^(idp or 0)
    if num >= 0 then return math.floor(num * mult) / mult
    else return math.ceil(num * mult) / mult end
end


-- Give some XP to the damaging entity.
function WeldableMixin:OnWeld(doer, elapsedTime, player)

    if self:GetCanBeWelded(doer) then
    
    	--if self.GetIsBuilt and GetGamerules():GetHasTimelimitPassed() then
			-- Do nothing
        if self.OnWeldOverride then
            self:OnWeldOverride(doer, elapsedTime)
        elseif doer:isa("MAC") then
            self:AddHealth(MAC.kRepairHealthPerSecond * elapsedTime)
        elseif doer:isa("Welder") then
            local amountHealed = self:AddHealth(doer:GetRepairRate(self) * elapsedTime)
			
			local maxXp = GetXpValue(self)
			
			local healXp = 0
			if self:isa("Player") then
				healXp = setDecimalPlaces(maxXp * kPlayerHealXpRate * kHealXpRate * amountHealed / self:GetMaxHealth(), 1)
			else
				healXp = setDecimalPlaces(maxXp * kHealXpRate * amountHealed / self:GetMaxHealth(), 1)
			end
				
			-- Award XP.
            if healXp > 0 then
                local doerPlayer = doer:GetParent()
                doerPlayer:AddXp(healXp)
            end
        end
		
		if player and player.OnWeldTarget then
            player:OnWeldTarget(self)
        end
        
    end
    
end