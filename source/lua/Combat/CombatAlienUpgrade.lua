class 'CombatAlienUpgrade' (CombatUpgrade)

function CombatAlienUpgrade:Initialize(...)

	CombatUpgrade.Initialize(self, "Alien", ...)

end

function CombatAlienUpgrade:TeamSpecificLogic(player)
	
	if not player.isRespawning then
	    -- Eliminate velocity so that we don't slide or jump as an egg
        player:SetVelocity(Vector(0, 0, 0))
		player:DropToFloor()
        local success, newPlayer = player:EvolveTo(self:GetTechId())
		
		if not success then
			player:RefundUpgrades({ kCombatUpgradeTypes.Class })
		end
		
		return successs
	end
	
	return true
end