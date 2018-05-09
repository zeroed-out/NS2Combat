--________________________________
--
--   	NS2 Combat Mod
--	Made by JimWest and MCMLXXXIV, 2012
--
--________________________________

-- combat_Team.lua

-- A cheap trick to stop waves from spawning on the Alien side.
-- This is a nasty way of doing it but it works for now!
function Team:GetNumPlayersInQueue()
    return 0
end

function Team:RemovePlayer(player)

    assert(player)
    self:RemovePlayerFromRespawnQueue(player)   
	
end
