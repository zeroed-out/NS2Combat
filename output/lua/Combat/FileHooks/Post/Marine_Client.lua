function MarineUI_GetHasArmsLab()

    local player = Client.GetLocalPlayer()
    
    if player then
        return true
    end
    
    return false
    
end