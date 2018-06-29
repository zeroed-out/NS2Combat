
if Server then

    function Exosuit:OnUpdate(deltaTime)
    
        ScriptActor.OnUpdate(self, deltaTime)
        
        -- prevent exosuits from losing their owner
        --if self.resetOwnerTime and self.resetOwnerTime < Shared.GetTime() then
        --    self:SetOwner(nil)
        --    self.resetOwnerTime = nil
        --end
        
    end
end


local originalOnKill = Exosuit.OnKill
function Exosuit:OnKill(attacker)
    -- Give XP to killer.
    local pointOwner = attacker
    
    -- If the pointOwner is not a player, award it's points to it's owner.
    if pointOwner ~= nil and not HasMixin(pointOwner, "Scoring") and pointOwner.GetOwner then
        pointOwner = pointOwner:GetOwner()
    end    
        
    -- Give Xp for Players - only when on opposing sides.
    -- to fix a bug, check before if the pointOwner is a Player
    if pointOwner and pointOwner:isa("Player") then
        if(pointOwner:GetTeamNumber() ~= self:GetTeamNumber()) then
        
            local XpValue = GetXpValue(self)
            pointOwner:AddXp(XpValue)
            pointOwner:GiveXpMatesNearby(XpValue)
        end
    end

    if originalOnKill then 
        originalOnKill(self) 
    end
end