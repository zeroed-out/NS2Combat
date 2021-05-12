
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
    
    -- Give Xp for Players - only when on opposing sides.
    -- to fix a bug, check before if the pointOwner is a Player
    if pointOwner and pointOwner:isa("Player") then
        if(pointOwner:GetTeamNumber() ~= self:GetTeamNumber()) then
			-- Only add Xp if killing a player or player structure. Structures now get partial Xp for damage.
			if not GetTrickleXp(self) then
				self:GiveXpForKill(self, pointOwner)
			end			
        end
    else
        -- if no one killed you, give assist XP to everyone nearby
        self:GiveXpForKill(self)
    end

end

-- Give XP to non-killer enemies around you when you die or do something stupid
function PointGiverMixin:GiveXpForKill(dying, killer)
	
	local baseXp = GetXpValue(dying)
	
    local playersInRange = GetEntitiesForTeamWithinRange("Player", GetEnemyTeamNumber(self:GetTeamNumber()), self:GetOrigin(), assistLOSXPRange)
    
    local alivePlayers = {}
	
	-- always include the killer even if they are dead!
	if killer then
        table.insert(alivePlayers, killer)
	end
	
    for _, player in ipairs(playersInRange) do
        if player:GetIsAlive() and killer ~= player then
		
			-- check if we're in the minimum assist XP range, if not, do a LOS check
			if (self:GetOrigin() - player:GetOrigin()):GetLength() < assistXPRange or GetCanSeeEntity(player, self) then
				table.insert(alivePlayers, player)
			end
			
        end
    end
    
    baseXp = baseXp * assistXpAmount
	
    if #alivePlayers > 0 then
    
        local xpPerPlayer = math.ceil(baseXp / #alivePlayers * assistPlayerRatio + baseXp * (1-assistPlayerRatio))
        for _, player in ipairs(alivePlayers) do
			local bonusXp = GetXpLevelDiff(dying, player)
            player:AddXp(xpPerPlayer + bonusXp)
        end
        
    end
    
end