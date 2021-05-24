--This is not loaded by anything in combat, so load it.
--Script.Load("lua/CommAbilities/CommanderAbility.lua")

--kMaturitySoftcapThreshold = 1.5
--kMaturityCappedEfficiency = 0.25
--kMaturityBuiltSpeedup = 1
--kNutrientMistMaturitySpeedup = 2
--kNutrientMistAutobuildMultiplier = 1

kNutrientMistCost = 2
kNutrientMistCooldown = 15
-- Note: If kNutrientMistDuration changes, there is a tooltip that needs to be updated.
kNutrientMistDuration = 4

-- 100% + X (increases by 66%, which is 10 second reduction over 15 seconds)
kNutrientMistPercentageIncrease = 66
kNutrientMistMaturingIncrease = 66