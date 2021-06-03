

InkMixin = CreateMixin(InkMixin)
InkMixin.type = "Ink"

function InkMixin:__initmixin()
    
    PROFILE("InkMixin:__initmixin")
    
end

InkMixin.networkVars = {
	lastInk = "time"
}

Shared.LinkClassToMap("Alien", Alien.kMapName, InkMixin.networkVars, true)

if Server then

	function InkMixin:CheckTriggerInk()
	
		if self.combatTable.hasInk then
            if self.combatTable.lastInk == 0 or Shared.GetTime() >= ( self.combatTable.lastInk + kInkTimer) then
                self:TriggerInk()
                self.combatTable.lastInk = Shared.GetTime()
            end
        end
		
	end
	
	function InkMixin:OnScan()
		self:CheckTriggerInk()
	end
	
	function InkMixin:OnSighted(isSighted)
		if isSighted and kCombatInkOnSighted then
			self:CheckTriggerInk()
		end
	end

end
