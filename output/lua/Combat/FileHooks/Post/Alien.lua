
Script.Load("lua/Combat/InkMixin.lua")

local oldOnCreate = Alien.OnCreate
function Alien:OnCreate()
	oldOnCreate(self)
    InitMixin(self, InkMixin)
	
end

function Alien:UpdateArmorAmount(carapaceLevel)

    local level = GetHasCarapaceUpgrade(self) and carapaceLevel or 0
    local newMaxArmor = (level / 3) * (self:GetArmorFullyUpgradedAmount() - self:GetBaseArmor()) + self:GetBaseArmor()

    if newMaxArmor ~= self.maxArmor then

        local armorPercent = self.maxArmor > 0 and self.armor/self.maxArmor or 0
        self.maxArmor = newMaxArmor
        self:SetArmor(self.maxArmor * armorPercent)
    
    end

	-- Always set the hives back to false, so that later on we can enable tier 2/3 even after embryo.
	if self:GetTeamNumber() ~= kTeamReadyRoom then
		if self.combatTwoHives then
			self.twoHives = true
		else
			self.twoHives = false
		end
		
		if self.combatThreeHives then
			self.threeHives = true
		else
			self.threeHives = false
		end
	end

end


-- no hook, replace it
function GetHasCamouflageUpgrade(callingEntity)
    if Server then
        return callingEntity.combatTable and callingEntity.combatTable.hasCamouflage 
    elseif Client then
        local upgrade = GetUpgradeFromId(GetUpgradeFromId(upgradeId))
        return callingEntity:GotItemAlready(upgrade)
    end
end


if Server then

	local oldGetCanTakeDamageOverride = Alien.GetCanTakeDamageOverride
    function Alien:GetCanTakeDamageOverride()

        return not self.gotSpawnProtect and  oldGetCanTakeDamageOverride(self)
    end

	local oldCopyPlayerDataFrom = Alien.CopyPlayerDataFrom
	function Alien:CopyPlayerDataFrom(player)

		oldCopyPlayerDataFrom(self, player)
		
		self.combatTwoHives = player.combatTwoHives
		self.combatThreeHives = player.combatThreeHives
		
		if player.combatTable then
			self:CheckCombatData()
			if player.combatTable.twoHives then
				self.combatTwoHives = true
				self.combatTable.twoHives = true
			end

			if player.combatTable.threeHives then
				self.combatThreeHives = true
				self.combatTable.threeHives = true
			end
			self:UpdateHealthAmount(0)
		end
    
	end

end