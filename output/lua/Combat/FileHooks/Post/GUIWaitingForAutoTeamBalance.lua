
local oldInit = GUIWaitingForAutoTeamBalance.Initialize
function GUIWaitingForAutoTeamBalance:Initialize()
    oldInit(self)
    kSpawnInOffset = GUIScale(Vector(0, 165, 0))
    self.waitingText:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.waitingText:SetPosition(kSpawnInOffset)
    
end



local oldUpdate = GUIWaitingForAutoTeamBalance.Update
function GUIWaitingForAutoTeamBalance:Update(deltaTime)

    oldUpdate(self, deltaTime)

    
    local teamInfo = GetTeamInfoEntity( PlayerUI_GetTeamNumber() )
    if teamInfo and (PlayerUI_GetIsDead() or not Client.GetIsControllingPlayer())then
        local timeToSpawn = math.max(0, math.ceil(teamInfo:GetNextRespawn() - Shared.GetTime()))
        if timeToSpawn > 0 then
            self.waitingText:SetText(string.format(Locale.ResolveString("NEXT_SPAWN_IN"), ToString(timeToSpawn)))
        else
            self.waitingText:SetText("")
        end
        self.waitingText:SetIsVisible(true)
    else
        self.waitingText:SetIsVisible(false)
    end
end