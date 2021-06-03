Script.Load("lua/Combat/Player_Upgrades_Client.lua")

function PlayerUI_GetHasNutrientMist()
    local self = Client.GetLocalPlayer()

    local upgrades = self:GetPlayerUpgrades()
    for i = 1, #upgrades do
        local upgradeId = upgrades[i]

        if upgradeId == kTechId.NutrientMist then
            return true
        end
    end
    
    return false

end

function PlayerUI_GetHasNutrientMistIn()
    local player = Client.GetLocalPlayer()

    if player then
        return math.max(math.ceil((player.lastNutrientMist or 0) + kNutrientMistCooldown - Shared.GetTime()), 0)
    end

    return 0
end