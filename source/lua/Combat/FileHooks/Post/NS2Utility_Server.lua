
-- we modify this from vanilla to scale down to 3 players to help with seeding
function ScaleWithPlayerCount(value, numPlayers, scaleUp)

    -- 6 is supposed to be ideal
    local factor = 1
    
    if scaleUp then
        factor = math.max(3, numPlayers) / 6
    else
        factor = 6 / math.max(3, numPlayers)
    end

    return value * factor

end