
if Server then


	function BiomassHealthMixin:UpdateHealthAmount(bioMassLevel)

		-- Cap the health level at the max biomass level
		--local level = math.min(10, math.max(0, self:GetLvl() - 1))
		local level = 0
		
		if self.combatTwoHives then
			level = level + 4
		end
		if self.combatThreeHives then
			level = level + 5
		end
		
		local newBiomassHealth = level * self:GetHealthPerBioMass()
		
        if newBiomassHealth ~= self.biomMassHealth  then
            -- maxHealth is a integer
            local healthDelta = math.round(newBiomassHealth - self.biomassHealth)
            self:AdjustMaxHealth(self:GetMaxHealth() + healthDelta)
            self.biomassHealth = newBiomassHealth
        end

	end
end