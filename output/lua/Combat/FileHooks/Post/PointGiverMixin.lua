
function PointGiverMixin:OnKill(attacker, doer, point, direction)

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
			-- Only add Xp if killing a player or player structure. Structures now get partial Xp for damage.
			if not GetTrickleXp(self) then
				local XpValue = GetXpValue(self)
				pointOwner:AddXp(XpValue)
				pointOwner:GiveXpMatesNearby(XpValue)
			end			
        end
    else
    
        local playersInRange = GetEntitiesForTeamWithinRange("Player", GetEnemyTeamNumber(self:GetTeamNumber()), self:GetOrigin(), mateXpRange)
        
        local XpValue = GetXpValue(self) * mateXpAmount
        
        -- Only give Xp to players who are alive!
        for _, player in ipairs(playersInRange) do
            if self ~= player and player:GetIsAlive() then
                player:AddXp(XpValue)
            end
        end

    end

end
