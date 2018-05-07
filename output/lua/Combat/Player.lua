
if Server then

    local oldOnPrimaryAttack = Player.OnPrimaryAttack
    function Player:OnPrimaryAttack()
        oldOnPrimaryAttack(self)
        if (self:isa("Marine") or self:isa("Exo")) then
            self:CheckCombatData()
            self:CheckCatalyst()
        end
    end

    local oldOnSecondaryAttack = Player.OnSecondaryAttack
    function Player:OnSecondaryAttack()
        oldOnSecondaryAttack(self)
        if (self:isa("Marine") or self:isa("Exo")) then
            self:CheckCombatData()
            self:CheckCatalyst()
        end
    end
    
end