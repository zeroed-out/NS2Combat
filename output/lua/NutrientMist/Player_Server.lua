-- Implement lvl and XP
local oldProcessTauntAbilities = Player.ProcessTauntAbilities
function Player:ProcessTauntAbilities()
    oldProcessTauntAbilities(self)
    if self.combatTable then
        if self.combatTable.hasNutrientMist then
            if self.combatTable.lastInk == 0 or Shared.GetTime() >= ( self.combatTable.lastNutrientMist + kNutrientMistCooldown) then
                if GetIsPointOnInfestation(self:GetOrigin()) then
                    self:TriggerMist()
                    self.combatTable.lastNutrientMist = Shared.GetTime()
                else
                    self:SendDirectMessage("Cannot Nutrient Mist. Not on infestation")
                end
            else
                local timeReady = math.ceil(self.combatTable.lastNutrientMist + kNutrientMistCooldown - Shared.GetTime())
                self:SendDirectMessage("Mist ready in " .. timeReady .. " sec")
            end
                
        end
    end

end


function Player:TriggerMist()

    -- Create Mist entity in world at this position with a small offset

    local mist = CreateEntity(NutrientMist.kMapName, self:GetOrigin() + Vector(0, 0.2, 0), self:GetTeamNumber())
    StartSoundEffectOnEntity("sound/NS2.fev/alien/commander/catalyze_2D", mist)

end