-- Implement lvl and XP
local oldProcessTauntAbilities = Player.ProcessTauntAbilities
function Player:ProcessTauntAbilities()
    oldProcessTauntAbilities(self)
    if self.combatTable then
        if self.combatTable.hasNutrientMist then
            --if self.combatTable.lastInk == 0 or Shared.GetTime() >= ( self.combatTable.lastInk + kInkTimer) then
            if GetIsPointOnInfestation(self:GetOrigin()) then
                self:TriggerMist()
              --  self.combatTable.lastInk = Shared.GetTime()
            --else
              --  local timeReady = math.ceil(self.combatTable.lastInk + kInkTimer - Shared.GetTime())
                self:SendDirectMessage("Mist away!")
            --end
            else
                Print("Not on infestation")
            end
        end
    end

    --Print("============Taunt Processed============")

end


function Player:TriggerMist()

    -- Create ShadeInk entity in world at this position with a small offset

    local mist = CreateEntity(NutrientMist.kMapName, self:GetOrigin() + Vector(0, 0.2, 0), self:GetTeamNumber())
    StartSoundEffectOnEntity("sound/NS2.fev/alien/commander/catalyze_2D", mist)

end

--Print("============Player_Server Loaded============")