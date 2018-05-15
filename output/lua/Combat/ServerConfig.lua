local default = {
    ModCompMode = false,
    ModDefaultWinner = 2,
    ModPowerPointsTakeDamage = true,
    ModTimeLimit = 1500,
    ModAllowOvertime = true
}

local fileName = "Combat.json"

local function LoadConfig()
    local config = LoadConfigFile(fileName, default, true)

    kCombatCompMode = config.ModCompMode
    kCombatTimeLimit = config.ModTimeLimit
    kCombatAllowOvertime = config.ModAllowOvertime
    kCombatDefaultWinner = config.ModDefaultWinner
    kCombatPowerPointsTakeDamage = config.ModPowerPointsTakeDamage

end

do
    LoadConfig()
end


local function OnConnect(client)
    SendCombatSettings(client)
end
Event.Hook("ClientConnect", OnConnect)