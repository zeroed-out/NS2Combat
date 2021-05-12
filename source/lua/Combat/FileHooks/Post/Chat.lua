
local function OnCombatMessage(message)

    local player = Client.GetLocalPlayer()
    
    if player then
        ChatUI_AddSystemMessage(message.message)
    end
end

Client.HookNetworkMessage("CombatMessage", OnCombatMessage)