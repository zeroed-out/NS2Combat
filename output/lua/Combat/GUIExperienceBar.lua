--________________________________
--
--   	NS2 Combat Mod
--	Made by JimWest and MCMLXXXIV, 2012
--
--________________________________

-- GUIExperienceBar.lua

class 'GUIExperienceBar' (GUIScript)

GUIExperienceBar.kMarineBarTextureName = PrecacheAsset("ui/combat_xpbar_marine.dds")
GUIExperienceBar.kMarineBackgroundTextureName = PrecacheAsset("ui/combat_xpbarbg_marine.dds")
GUIExperienceBar.kAlienBarTextureName = PrecacheAsset("ui/combat_xpbar_alien.dds")
GUIExperienceBar.kAlienBackgroundTextureName = PrecacheAsset("ui/combat_xpbarbg_alien.dds")
GUIExperienceBar.kTextFontName = Fonts.kArial_17

GUIExperienceBar.kExperienceBackgroundWidth = 450
GUIExperienceBar.kExperienceBackgroundHeight = 30
GUIExperienceBar.kExperienceBackgroundMinimisedHeight = 30
GUIExperienceBar.kExperienceBackgroundOffset = Vector(-GUIExperienceBar.kExperienceBackgroundWidth/2, -GUIExperienceBar.kExperienceBackgroundHeight-10, 0)

GUIExperienceBar.kExperienceBorder = 0

GUIExperienceBar.kExperienceBarOffset = Vector(GUIExperienceBar.kExperienceBorder, GUIExperienceBar.kExperienceBorder, 0)
GUIExperienceBar.kExperienceBarWidth = GUIExperienceBar.kExperienceBackgroundWidth - GUIExperienceBar.kExperienceBorder*2
GUIExperienceBar.kExperienceBarHeight = GUIExperienceBar.kExperienceBackgroundHeight - GUIExperienceBar.kExperienceBorder*2
GUIExperienceBar.kExperienceBarMinimisedHeight = GUIExperienceBar.kExperienceBackgroundMinimisedHeight - GUIExperienceBar.kExperienceBorder*2

-- Texture Coords
GUIExperienceBar.kMarineBarTextureX1 = 0
GUIExperienceBar.kMarineBarTextureX2 = 512
GUIExperienceBar.kMarineBarTextureY1 = 0
GUIExperienceBar.kMarineBarTextureY2 = 32
GUIExperienceBar.kMarineBarBackgroundTextureX1 = 12
GUIExperienceBar.kMarineBarBackgroundTextureX2 = 500
GUIExperienceBar.kMarineBarBackgroundTextureY1 = 0
GUIExperienceBar.kMarineBarBackgroundTextureY2 = 31
GUIExperienceBar.kAlienBarTextureX1 = 13
GUIExperienceBar.kAlienBarTextureX2 = 498
GUIExperienceBar.kAlienBarTextureY1 = 0
GUIExperienceBar.kAlienBarTextureY2 = 31
GUIExperienceBar.kAlienBarBackgroundTextureX1 = 13
GUIExperienceBar.kAlienBarBackgroundTextureX2 = 498
GUIExperienceBar.kAlienBarBackgroundTextureY1 = 0
GUIExperienceBar.kAlienBarBackgroundTextureY2 = 31

GUIExperienceBar.kMarineBackgroundGUIColor = Color(1.0, 1.0, 1.0, 0.2)
GUIExperienceBar.kMarineGUIColor = Color(1.0, 1.0, 1.0, 0.9)
GUIExperienceBar.kAlienBackgroundGUIColor = Color(1.0, 1.0, 1.0, 0.4)
GUIExperienceBar.kAlienGUIColor = Color(1.0, 1.0, 1.0, 0.9)
GUIExperienceBar.kMarineTextColor = Color(1.0, 1.0, 1.0, 1)
GUIExperienceBar.kAlienTextColor = Color(0.9, 0.7, 0.7, 1)
GUIExperienceBar.kExperienceTextFontSize = 15
GUIExperienceBar.kExperienceTextOffset = Vector(0, -10, 0)
GUIExperienceBar.kNormalAlpha = 0.9
GUIExperienceBar.kMinimisedTextAlpha = 0.7
GUIExperienceBar.kMinimisedAlpha = 0.6

GUIExperienceBar.kBarFadeInRate = 0.2
GUIExperienceBar.kBarFadeOutDelay = 0.5
GUIExperienceBar.kBarFadeOutRate = 0.1
GUIExperienceBar.kBackgroundBarRate = 90
GUIExperienceBar.kBackgroundBarFastRate = 250
GUIExperienceBar.kTextIncreaseRate = 200

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

function GUIExperienceBar:Initialize()

	self:CreateExperienceBar()
	self.rankIncreased = false
	self.currentExperience = 0
	self.showExperience = false
	self.experienceAlpha = GUIExperienceBar.kNormalAlpha
	self.experienceTextAlpha = GUIExperienceBar.kNormalAlpha
	self.barMoving = false
	self.playerTeam = "Ready Room"
	self.fadeOutTime = Shared.GetTime()
	self.experienceData = {}
	
end

function GUIExperienceBar:CreateExperienceBar()

    self.experienceBarBackground = GUIManager.CreateGraphicItem()
    self.experienceBarBackground:SetSize(Vector(GUIExperienceBar.kExperienceBackgroundWidth, GUIExperienceBar.kExperienceBackgroundMinimisedHeight, 0))
    self.experienceBarBackground:SetAnchor(GUIItem.Center, GUIItem.Bottom)
    self.experienceBarBackground:SetPosition(GUIExperienceBar.kExperienceBackgroundOffset)
	self.experienceBarBackground:SetLayer(kGUILayerPlayerHUDBackground)
    self.experienceBarBackground:SetIsVisible(false)
    
    self.experienceBar = GUIManager.CreateGraphicItem()
    self.experienceBar:SetSize(Vector(GUIExperienceBar.kExperienceBarWidth, GUIExperienceBar.kExperienceBarHeight, 0))
    self.experienceBar:SetAnchor(GUIItem.Left, GUIItem.Top)
    self.experienceBar:SetPosition(GUIExperienceBar.kExperienceBarOffset)
    self.experienceBar:SetIsVisible(false)
    self.experienceBarBackground:AddChild(self.experienceBar)
    
    self.experienceText = GUIManager.CreateTextItem()
    self.experienceText:SetFontSize(GUIExperienceBar.kExperienceTextFontSize)
    self.experienceText:SetFontName(GUIExperienceBar.kTextFontName)
    self.experienceText:SetFontIsBold(false)
    self.experienceText:SetAnchor(GUIItem.Center, GUIItem.Top)
    self.experienceText:SetTextAlignmentX(GUIItem.Align_Center)
    self.experienceText:SetTextAlignmentY(GUIItem.Align_Center)
    self.experienceText:SetPosition(GUIExperienceBar.kExperienceTextOffset)
    self.experienceText:SetIsVisible(false)
    self.experienceBarBackground:AddChild(self.experienceText)
	
end

function GUIExperienceBar:Update(deltaTime)

	-- Alter the display based on team, status.
	local newTeam = false
	if (self.playerTeam ~= GetTeamType()) then
		self.playerTeam = GetTeamType()
		newTeam = true
	end
	
	-- We have switched teams.
	if (newTeam) then
		if (self.playerTeam == "Marines") then
			self.experienceBarBackground:SetIsVisible(true)
			self.experienceBar:SetIsVisible(true)
			self.experienceText:SetIsVisible(true)
			self.experienceData.barPixelCoordsX1 = GUIExperienceBar.kMarineBarTextureX1
			self.experienceData.barPixelCoordsX2 = GUIExperienceBar.kMarineBarTextureX2
			self.experienceData.barPixelCoordsY1 = GUIExperienceBar.kMarineBarTextureY1
			self.experienceData.barPixelCoordsY2 = GUIExperienceBar.kMarineBarTextureY2
			self.experienceBarBackground:SetTexture(GUIExperienceBar.kMarineBackgroundTextureName)
			self.experienceBarBackground:SetTexturePixelCoordinates(GUIExperienceBar.kMarineBarBackgroundTextureX1, GUIExperienceBar.kMarineBarBackgroundTextureY1, GUIExperienceBar.kMarineBarBackgroundTextureX2, GUIExperienceBar.kMarineBarBackgroundTextureY2)
			self.experienceBarBackground:SetColor(GUIExperienceBar.kMarineBackgroundGUIColor)
			self.experienceBar:SetTexture(GUIExperienceBar.kMarineBarTextureName)
		    self.experienceBar:SetTexturePixelCoordinates(GUIExperienceBar.kMarineBarTextureX1, GUIExperienceBar.kMarineBarTextureY1, GUIExperienceBar.kMarineBarTextureX2, GUIExperienceBar.kMarineBarTextureY2)
			self.experienceBar:SetColor(GUIExperienceBar.kMarineGUIColor)
			self.experienceText:SetColor(GUIExperienceBar.kMarineTextColor)
			self.experienceAlpha = 1.0
			self.showExperience = true
		elseif (self.playerTeam == "Aliens") then
			self.experienceBarBackground:SetIsVisible(true)
			self.experienceBar:SetIsVisible(true)
			self.experienceText:SetIsVisible(true)
			self.experienceData.barPixelCoordsX1 = GUIExperienceBar.kAlienBarTextureX1
			self.experienceData.barPixelCoordsX2 = GUIExperienceBar.kAlienBarTextureX2
			self.experienceData.barPixelCoordsY1 = GUIExperienceBar.kAlienBarTextureY1
			self.experienceData.barPixelCoordsY2 = GUIExperienceBar.kAlienBarTextureY2
			self.experienceBarBackground:SetTexture(GUIExperienceBar.kAlienBackgroundTextureName)
			self.experienceBarBackground:SetTexturePixelCoordinates(GUIExperienceBar.kAlienBarBackgroundTextureX1, GUIExperienceBar.kAlienBarBackgroundTextureY1, GUIExperienceBar.kAlienBarBackgroundTextureX2, GUIExperienceBar.kAlienBarBackgroundTextureY2)
			self.experienceBarBackground:SetColor(GUIExperienceBar.kAlienBackgroundGUIColor)
			self.experienceBar:SetTexture(GUIExperienceBar.kAlienBarTextureName)
			self.experienceBar:SetTexturePixelCoordinates(GUIExperienceBar.kAlienBarTextureX1, GUIExperienceBar.kAlienBarTextureY1, GUIExperienceBar.kAlienBarTextureX2, GUIExperienceBar.kAlienBarTextureY2)
			self.experienceBar:SetColor(GUIExperienceBar.kAlienGUIColor)
			self.experienceText:SetColor(GUIExperienceBar.kAlienTextColor)
			self.experienceAlpha = 1.0
			self.showExperience = true
		else
			self.experienceBarBackground:SetIsVisible(false)
			self.experienceBar:SetIsVisible(false)
			self.experienceText:SetIsVisible(false)
			self.showExperience = false
		end
	end
		
	-- Recalculate, tween and fade
	if (self.showExperience) then
		self:CalculateExperienceData()
		self:UpdateExperienceBar(deltaTime)
		self:UpdateFading(deltaTime)
		self:UpdateText(deltaTime)
		self:UpdateVisible(deltaTime)
	end
	
end

function GUIExperienceBar:CalculateExperienceData()

	local player = Client.GetLocalPlayer()
	self.experienceData.isVisible = player:GetIsAlive()
	self.experienceData.targetExperience = player:GetScore()
	self.experienceData.experienceToNextLevel = player:XPUntilNextLevel()
	self.experienceData.nextLevelExperience = player:GetNextLevelXP()
	self.experienceData.thisLevel = Experience_GetLvl(player:GetScore())
	self.experienceData.thisLevelName = Experience_GetLvlName(Experience_GetLvl(player:GetScore()), player:GetTeamNumber())
	self.experienceData.experiencePercent = player:GetLevelProgression()
	self.experienceData.experienceLastTick = self.experienceData.targetExperience

end

function GUIExperienceBar:UpdateExperienceBar(deltaTime)

    local expBarPercentage = self.experienceData.experiencePercent
	local calculatedBarWidth = GUIExperienceBar.kExperienceBarWidth * expBarPercentage
	local currentBarWidth = self.experienceBar:GetSize().x
	local targetBarWidth = calculatedBarWidth
	
	-- Method to allow proper tweening visualisation when you go up a rank.
	-- Currently detecting this by examining old vs new size.
	if (math.ceil(calculatedBarWidth) < math.floor(currentBarWidth)) then
		self.rankIncreased = true
	end
	
	if (self.rankIncreased) then
		targetBarWidth = GUIExperienceBar.kExperienceBarWidth
		-- Once we reach the end, reset the bar back to the beginning.
		if (currentBarWidth >= targetBarWidth) then
			self.rankIncreased = false
			currentBarWidth = 0
			targetBarWidth = calculatedBarWidth
		end
	end
	
	if (self.experienceData.targetExperience >= maxXp) then
		currentBarWidth = GUIExperienceBar.kExperienceBarWidth
		targetBarWidth = GUIExperienceBar.kExperienceBarWidth
		calculatedBarWidth = GUIExperienceBar.kExperienceBarWidth
		self.rankIncreased = false
	end

	local increaseRate = GUIExperienceBar.kBackgroundBarRate
	if currentBarWidth <= targetBarWidth - 50 then
		increaseRate = GUIExperienceBar.kBackgroundBarFastRate
	end
	self.experienceBar:SetSize(Vector(Slerp(currentBarWidth, targetBarWidth, deltaTime*increaseRate), self.experienceBar:GetSize().y, 0))
	local texCoordX2 = self.experienceData.barPixelCoordsX1 + (Slerp(currentBarWidth, targetBarWidth, deltaTime*increaseRate) / GUIExperienceBar.kExperienceBarWidth * (self.experienceData.barPixelCoordsX2 - self.experienceData.barPixelCoordsX1))
	self.experienceBar:SetTexturePixelCoordinates(self.experienceData.barPixelCoordsX1, self.experienceData.barPixelCoordsY1, texCoordX2, self.experienceData.barPixelCoordsY2)
	
	-- Detect and register if the bar is moving
	if (math.abs(currentBarWidth - calculatedBarWidth) > 0.01) then
		self.barMoving = true
	else
		-- Delay the fade out by a while
		if (self.barMoving) then
			self.fadeOutTime = Shared.GetTime() + GUIExperienceBar.kBarFadeOutDelay
		end
		self.barMoving = false
	end
	
end

function GUIExperienceBar:UpdateFading(deltaTime)

	local currentBarColor = self.experienceBar:GetColor()
	local currentTextColor = self.experienceText:GetColor()
	local targetAlpha = GUIExperienceBar.kNormalAlpha
	local targetTextAlpha = GUIExperienceBar.kNormalAlpha
		
	if (self.barMoving or Shared.GetTime() < self.fadeOutTime) then
		targetAlpha = GUIExperienceBar.kMinimisedAlpha
		targetTextAlpha = GUIExperienceBar.kMinimisedTextAlpha
	end
	
	self.experienceAlpha = Slerp(self.experienceAlpha, targetAlpha, deltaTime*GUIExperienceBar.kBarFadeOutRate)
	self.experienceTextAlpha = Slerp(self.experienceTextAlpha, targetTextAlpha, deltaTime*GUIExperienceBar.kBarFadeOutRate)
	
	self.experienceBar:SetColor(Color(currentBarColor.r, currentBarColor.g, currentBarColor.b, self.experienceAlpha))
	self.experienceText:SetColor(Color(currentTextColor.r, currentTextColor.g, currentTextColor.b, self.experienceTextAlpha))
	
end

function GUIExperienceBar:UpdateText(deltaTime)
	local updateRate = GUIExperienceBar.kTextIncreaseRate
	-- Handle the case when the experience jumps up by a huge amount
	if self.experienceData.targetExperience > self.currentExperience and
	   self.experienceData.targetExperience - self.currentExperience > GUIExperienceBar.kTextIncreaseRate*2 then
	   updateRate = GUIExperienceBar.kTextIncreaseRate * 10
	end
	   
	-- Tween the experience text too!
	self.currentExperience = Slerp(self.currentExperience, self.experienceData.targetExperience, deltaTime*updateRate)
	
	-- Handle the case when the round changes and we are set back to 0 experience.
	if self.currentExperience > self.experienceData.targetExperience then
		self.currentExperience = 0
	end
	
	if (self.experienceData.targetExperience >= maxXp) then
		self.experienceText:SetText("Level " .. self.experienceData.thisLevel .. " / " .. maxLvl .. ": " .. tostring(math.ceil(self.currentExperience)) .. " (" .. self.experienceData.thisLevelName .. ")")
	else
		self.experienceText:SetText("Level " .. self.experienceData.thisLevel .. " / " .. maxLvl .. ": " .. tostring(math.ceil(self.currentExperience)) .. " / " .. self.experienceData.nextLevelExperience .. " (" .. self.experienceData.thisLevelName .. ")")
	end
end

function GUIExperienceBar:UpdateVisible(deltaTime)

	-- Hide the experience bar if the player is dead.
	self.experienceBarBackground:SetIsVisible(self.experienceData.isVisible)
	
end

function GUIExperienceBar:Uninitialize()

	if self.experienceBar then
        GUI.DestroyItem(self.experienceBarBackground)
        self.experienceBar = nil
        self.experienceBarText = nil
        self.experienceBarBackground = nil
    end
    
end