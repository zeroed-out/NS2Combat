--________________________________
--
--   	NS2 Combat Mod
--	Made by JimWest and MCMLXXXIV, 2012
--
--________________________________

if not Server then return end

-- combat_SoundEffect.lua
local kTauntSounds =
{
    "sound/NS2.fev/alien/voiceovers/chuckle",
    "sound/NS2.fev/alien/skulk/taunt",
    "sound/NS2.fev/alien/gorge/taunt",
    "sound/NS2.fev/alien/lerk/taunt",
    "sound/NS2.fev/alien/fade/taunt",
    "sound/NS2.fev/alien/onos/taunt",
    "sound/NS2.fev/alien/common/swarm",
	"sound/NS2.fev/marine/voiceovers/taunt",
	"sound/NS2.fev/marine/voiceovers/taunt_female",
	"sound/NS2.fev/marine/voiceovers/taunt_exclusive",
	"sound/NS2.fev/marine/voiceovers/taunt_exclusive_female",
}

-- Hooks for Ink and EMP are in here.
-- Todo: Really should hook into client's key input as sound system is not reliable
local oldStartSoundEffectOnEntity = StartSoundEffectOnEntity
function StartSoundEffectOnEntity(soundEffectName, onEntity)

	oldStartSoundEffectOnEntity(soundEffectName, onEntity)

	if onEntity and onEntity:isa("Player") then
		onEntity:CheckCombatData()
		
		-- Check whether the sound is a taunt sound
		for index, tauntSoundName in ipairs(kTauntSounds) do
			if (soundEffectName == tauntSoundName) then
				
				-- Now check whether the player has taunted recently and fire taunt abilities.
				if (Shared.GetTime() - onEntity.combatTable.lastTauntTime > kCombatTauntCheckInterval) then
					onEntity:ProcessTauntAbilities()
					onEntity.combatTable.lastTauntTime = Shared.GetTime()
				end
				
				break
			end
		end
	end

end