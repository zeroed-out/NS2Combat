Script.Load("lua/Combat/Player_Upgrades_Client.lua")


function PlayerUI_GetHasEnzymeCloud()
    local self = Client.GetLocalPlayer()

    local upgrades = self:GetPlayerUpgrades()
    for i = 1, #upgrades do
        local upgradeId = upgrades[i]

        if upgradeId == kTechId.EnzymeCloud then
            return true
        end
    end
    
    return false
end

function PlayerUI_GetNextEnzymeCloudIn()
    local player = Client.GetLocalPlayer()

    if player then
        return math.max(math.ceil((player.lastEnzymeCloud or 0) + kEnzymeCloudAbilityCooldown - Shared.GetTime()), 0)
    end

    return 0
end




