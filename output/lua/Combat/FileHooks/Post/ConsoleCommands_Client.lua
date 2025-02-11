-- Console commands only for the client (so the server can send the ups to the client)

local function OnCommandSetUpgrades(upgradeId)
        
    -- insert the ids in the personal player table
    local player = Client.GetLocalPlayer()
    
    if not player.combatUpgrades then
        player.combatUpgrades = {}
    end
    
    table.insert(player.combatUpgrades, upgradeId)

 
end


local function OnCommandClearUpgrades()
        
    -- clear all tech
    local player = Client.GetLocalPlayer()
    player.combatUpgrades = {}
   
end

local function OnCommandPoints(pointsString, resString)

	local points = tonumber(pointsString)
    local res = tonumber(resString)
    ScoreDisplayUI_SetNewScore(points, res)

	-- Add the points to the score here so that we get a more accurate score amount for the experience bar.
	-- Todo: Make score/xp a network value?
	local player = Client.GetLocalPlayer()
	if player.score == nil then
		player.score = 0
	end
	player.score = player.score + points

end

Event.Hook("Console_points",						OnCommandPoints)
Event.Hook("Console_co_setupgrades",                OnCommandSetUpgrades) 
Event.Hook("Console_co_clearupgrades",              OnCommandClearUpgrades) 