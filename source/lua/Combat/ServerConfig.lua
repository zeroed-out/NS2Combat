-- Provide as server config for the most basic gamemode parameters
-- Todo: Add a console command to change values on the fly or to reload the config

local default = {
    ModCompMode = false,
    ModDefaultWinner = 2,
    ModPowerPointsTakeDamage = true,
    ModTimeLimit = 1500,
    ModAllowOvertime = true,
	ModARCSpawnEnabled = true,
	ModFillerBots = 0
}

local fileName = "Combat.json"

local function LoadConfig()
    local config = LoadConfigFile(fileName, default, true)

    kCombatCompMode = config.ModCompMode
    kCombatTimeLimit = config.ModTimeLimit
    kCombatAllowOvertime = config.ModAllowOvertime
    kCombatDefaultWinner = config.ModDefaultWinner
    kCombatPowerPointsTakeDamage = config.ModPowerPointsTakeDamage
	kCombatARCSpawnEnabled = config.ModARCSpawnEnabled
	kCombatFillerBots = config.ModFillerBots

end

do
    LoadConfig()
end


local function OnConnect(client)
    SendCombatSettings(client)
end
Event.Hook("ClientConnect", OnConnect)