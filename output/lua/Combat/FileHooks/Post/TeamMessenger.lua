-- Intercept and block any 'No Commander' messages, Hooking caused errors so we replace it
function SendTeamMessage(team, messageType, optionalData)

    local function SendToPlayer(player)
        Server.SendNetworkMessage(player, "TeamMessage", { type = messageType, data = optionalData or 0 }, true)
    end    
    
	-- Only intercept NoCommander messages, for now.
    if not ((messageType == kTeamMessageTypes.NoCommander) or
			(messageType == kTeamMessageTypes.CannotSpawn)) then
			
		team:ForEachPlayer(SendToPlayer)
		
	end

end

if Client then
    -- enable the waiting to spawn message for marines
    do
        local kTeamMessages, owner_func, i = debug.getupvaluex(OnCommandTeamMessage, "kTeamMessages", true)
        kTeamMessages[kTeamMessageTypes.SpawningWait] = { text = { [kMarineTeamType] = "WAITING_TO_SPAWN", [kAlienTeamType] = "WAITING_TO_SPAWN" } }

        debug.setupvaluex(owner_func, i, kTeamMessages)
    end
end