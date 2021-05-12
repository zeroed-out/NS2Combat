class 'GUIGameTimeCountDown' (GUIAnimatedScript)

GUIGameTimeCountDown.kBackgroundTexture = "ui/combat_count_down_bg.dds"

GUIGameTimeCountDown.kBackgroundWidth = GUIScale(135)
GUIGameTimeCountDown.kBackgroundHeight = GUIScale(50)
GUIGameTimeCountDown.kBackgroundOffsetX = GUIScale(0)
GUIGameTimeCountDown.kBackgroundOffsetY = GUIScale(0)

GUIGameTimeCountDown.kTimeOffset = Vector(0, GUIScale(-5), 0)
GUIGameTimeCountDown.kTimeFontName = Fonts.kAgencyFB_Small
GUIGameTimeCountDown.kTimeFontSize = 16
GUIGameTimeCountDown.kTimeBold = true

GUIGameTimeCountDown.kBgCoords = {14, 0, 112, 34}

GUIGameTimeCountDown.kBackgroundColor = Color(1, 1, 1, 0.7)
GUIGameTimeCountDown.kMarineTextColor = kMarineFontColor
GUIGameTimeCountDown.kAlienTextColor = kAlienFontColor

function GUIGameTimeCountDown:Initialize()

	GUIAnimatedScript.Initialize(self)
    
	-- Used for Global Offset
	self.background = self:CreateAnimatedGraphicItem()
    self.background:SetIsScaling(false)
    self.background:SetSize( Vector(Client.GetScreenWidth(), Client.GetScreenHeight(), 0) )
    self.background:SetPosition( Vector(0, 0, 0) ) 
    self.background:SetIsVisible(true)
    self.background:SetLayer(kGUILayerPlayerHUDBackground)
    self.background:SetColor( Color(1, 1, 1, 0) )
	
    -- Timer display background
    self.timerBackground = self:CreateAnimatedGraphicItem()
    self.timerBackground:SetSize( Vector(GUIGameTimeCountDown.kBackgroundWidth, GUIGameTimeCountDown.kBackgroundHeight, 0) )
    self.timerBackground:SetPosition(Vector(GUIGameTimeCountDown.kBackgroundOffsetX - (GUIGameTimeCountDown.kBackgroundWidth / 2), GUIGameTimeCountDown.kBackgroundOffsetY, 0))
    self.timerBackground:SetAnchor(GUIItem.Middle, GUIItem.Top) 
    self.timerBackground:SetLayer(kGUILayerPlayerHUD)
    self.timerBackground:SetTexture(GUIGameTimeCountDown.kBackgroundTexture)
    self.timerBackground:SetTexturePixelCoordinates(GUIUnpackCoords(GUIGameTimeCountDown.kBgCoords))
	self.timerBackground:SetColor( GUIGameTimeCountDown.kBackgroundColor )
	self.timerBackground:SetIsVisible(false)
	
	-- Time remaining
    self.timeRemainingText = self:CreateAnimatedTextItem()
    self.timeRemainingText:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.timeRemainingText:SetPosition(GUIGameTimeCountDown.kTimeOffset)
	self.timeRemainingText:SetLayer(kGUILayerPlayerHUDForeground1)
	self.timeRemainingText:SetTextAlignmentX(GUIItem.Align_Center)
    self.timeRemainingText:SetTextAlignmentY(GUIItem.Align_Center)
	self.timeRemainingText:SetText("")
	self.timeRemainingText:SetColor(Color(1,1,1,1))
	self.timeRemainingText:SetFontSize(GUIGameTimeCountDown.kTimeFontSize)
    self.timeRemainingText:SetFontName(GUIGameTimeCountDown.kTimeFontName)
	self.timeRemainingText:SetFontIsBold(GUIGameTimeCountDown.kTimeBold)
	self.timeRemainingText:SetIsVisible(true)
 
	self.background:AddChild(self.timerBackground)
	self.timerBackground:AddChild(self.timeRemainingText)
    self:Update(0)

end

local function GetTeamType()

	local player = Client.GetLocalPlayer()
	
	if not player:isa("ReadyRoomPlayer") then	
		local teamnumber = player:GetTeamNumber()
		if teamnumber == kAlienTeamType then
			return "Aliens"
		elseif teamnumber == kMarineTeamType then
			return "Marines"
		elseif teamnumber == kNeutralTeamType then 
			return "Spectator"
		else
			return "Unknown"
		end
	else
		return "Ready Room"
	end
	
end

function GUIGameTimeCountDown:Update()

    local player = Client.GetLocalPlayer()
	
	-- Alter the display based on team, status.
	if player then
		local newTeam = false
		if (self.playerTeam ~= GetTeamType()) then
			self.playerTeam = GetTeamType()
			newTeam = true
		end
		
		if (newTeam) then
			if (self.playerTeam == "Marines") then
				self.timeRemainingText:SetColor(GUIGameTimeCountDown.kMarineTextColor)
				self.showTimer = true
			elseif (self.playerTeam == "Aliens") then
				self.timeRemainingText:SetColor(GUIGameTimeCountDown.kAlienTextColor)
				self.showTimer = true
			else
				self.timerBackground:SetIsVisible(false)
				self.showTimer = false
			end
		end
		
		local player = Client.GetLocalPlayer()
		if (self.showTimer and player:GetIsAlive()) and PlayerUI_GetHasGameStarted() then
			self.timerBackground:SetIsVisible(true)
			local TimeRemaining = PlayerUI_GetTimeRemaining()
			if TimeRemaining == "00:00:00" then		    
				self.timeRemainingText:SetText("Overtime!")
			else
				self.timeRemainingText:SetText(TimeRemaining)
			end
			
			self:RemindTime(player)
			
		else
            local gameInfo = GetGameInfoEntity()
            local state = gameInfo:GetState()
            if state == kGameState.PreGame then
				self.timeRemainingText:SetText("Game is starting")
                self.timerBackground:SetIsVisible(true)
            elseif state == kGameState.Countdown then
				self.timeRemainingText:SetText(string.format("Starting in %s", ToString(math.ceil(PlayerUI_GetRemainingCountdown()))))
                self.timerBackground:SetIsVisible(true)
            else
                self.timerBackground:SetIsVisible(false)
            end
		end
		
	end

end

local lastTimeLeftText
function GUIGameTimeCountDown:RemindTime(player)
		
    -- send timeleft chat things now here, all client sided
    if kCombatTimeLimit and PlayerUI_GetHasGameStarted() then
        local timeLeft = math.ceil(kCombatTimeLimit - PlayerUI_GetGameLengthTime())
        if timeLeft > 0 and
            ((timeLeft % kCombatTimeReminderInterval) == 0 or 
             (timeLeft == 60) or (timeLeft == 30) or
             (timeLeft == 20) or (timeLeft == 10) or
             (timeLeft <= 5)) then
            
            local timeLeftText = GetTimeText(timeLeft)
            
            if not lastTimeLeftText or timeLeftText ~= lastTimeLeftText then

				local message = GetTimeLeftMessage(timeLeftText, player:GetTeamNumber())
                ChatUI_AddSystemMessage(message)
                
                lastTimeLeftText = timeLeftText
                
            end
            
        end	
    end
    
end


function GUIGameTimeCountDown:Uninitialize()
    GUIAnimatedScript.Uninitialize(self)
    
    if self.timeRemainingText then
        GUI.DestroyItem(self.timeRemainingText)
        self.timeRemainingText = nil
    end
    
    if self.timerBackground then
        GUI.DestroyItem(self.timerBackground)
        self.timerBackground = nil
    end
    
    if self.background then
        GUI.DestroyItem(self.background)
        self.background = nil
    end

end