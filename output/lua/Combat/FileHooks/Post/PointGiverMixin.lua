
function PointGiverMixin:OnKill(attacker, doer, point, direction)

    if not Server then 
        return 
    end
    
    -- Give XP to killer.
    local pointOwner = attacker
    
    -- If the pointOwner is not a player, award it's points to it's owner.
    if pointOwner ~= nil and not HasMixin(pointOwner, "Scoring") and pointOwner.GetOwner then
        pointOwner = pointOwner:GetOwner()
    end    
	
    local XpValue = GetXpValue(self)
    
    -- Give Xp for Players - only when on opposing sides.
    -- to fix a bug, check before if the pointOwner is a Player
    if pointOwner and pointOwner:isa("Player") then
        if(pointOwner:GetTeamNumber() ~= self:GetTeamNumber()) then
			-- Only add Xp if killing a player or player structure. Structures now get partial Xp for damage.
			if not GetTrickleXp(self) then
				pointOwner:AddXp(XpValue)
				
                --pointOwner:GiveXpMatesNearby(XpValue)
				self:GiveAssistXPNearby(XpValue, pointOwner)
			end			
        end
    else
        -- if no one killed you, give assist XP to everyone nearby
        self:GiveAssistXPNearby(XpValue)
    end

end

-- Give XP to non-killer enemies around you when you die or do something stupid
function PointGiverMixin:GiveAssistXPNearby(xp, killer)

    xp = xp * assistXpAmount

    local playersInRange = GetEntitiesForTeamWithinRange("Player", GetEnemyTeamNumber(self:GetTeamNumber()), self:GetOrigin(), assistXPRange)
    
    -- Only give Xp to players who are alive!
    local alivePlayers = {}
    for _, player in ipairs(playersInRange) do
        if player:GetIsAlive() and player ~= killer then
            table.insert(alivePlayers, player)
        end
    end
    
    if #alivePlayers > 0 then
    
        local xpPerPlayer = math.ceil(xp / #alivePlayers * assistPlayerRatio + xp * (1-assistPlayerRatio))
        for _, player in ipairs(alivePlayers) do
            player:AddXp(xpPerPlayer)
        end
        
    end
    
end
