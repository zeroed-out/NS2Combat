function CommandStructure:GetCanBeHealedOverride()
    return self:GetIsAlive() and GetHasTimelimitPassed and not GetHasTimelimitPassed()
end
