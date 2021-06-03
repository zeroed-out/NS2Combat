
--local originalAlienUpdate = GUIAlienHUD.Update
--function GUIAlienHUD:Update(deltaTime)
--    originalAlienUpdate(self, deltaTime)
--   -- self.resourceDisplay.rtCount:SetIsVisible(false)
--	self.resourceDisplay.pResDescription:SetText("Upgrade Points")
--
--	--self.teamResText:SetIsVisible(false)
--
--end

local kTextOffsetX = -120
local kTextOffsetY = 0
local useColor = kIconColors[kAlienTeamType]
GUIAlienHUD.kTextFontName = Fonts.kAgencyFB_Small

function CreateNewTextItem(self)
    local useColor = kIconColors[kAlienTeamType]
    
    local textItem = self:CreateAnimatedTextItem()
    textItem:SetFontName(GUIAlienHUD.kTextFontName)
    textItem:SetTextAlignmentX(GUIItem.Align_Max)
    textItem:SetTextAlignmentY(GUIItem.Align_Center)
    textItem:SetAnchor(GUIItem.Right, GUIItem.Center)
    textItem:SetLayer(kGUILayerPlayerHUDForeground3)
    textItem:SetColor(useColor)
    textItem:SetFontIsBold(true)
    textItem:SetIsVisible(false)
    return textItem
end


local originalAlienInitialize = GUIAlienHUD.Initialize
function GUIAlienHUD:Initialize()

	originalAlienInitialize(self)

    self.teamResText:SetIsVisible(false)
	self.lastInk = 0

    local oldReset = self.Reset
    self.Reset = function() end

    self.background = self:CreateAnimatedGraphicItem()
    self.background:SetPosition( Vector(0, 0, 0) )
    self.background:SetIsScaling(false)
    self.background:SetIsVisible(true)
    self.background:SetLayer(kGUILayerPlayerHUDBackground)
    self.background:SetColor( Color(1, 1, 1, 0) )

	self.inkStatus = GetGUIManager():CreateGraphicItem()
    self.inkStatus:SetTexture(GUIMarineHUD.kUpgradesTexture)
    self.inkStatus:SetAnchor(GUIItem.Right, GUIItem.Center)
    self.inkStatus:SetTexturePixelCoordinates(GUIUnpackCoords(GetTextureCoordinatesForIcon(kTechId.Shade)))
    self.inkStatus:SetColor(useColor)
    self.background:AddChild(self.inkStatus)

    self.inkText = CreateNewTextItem(self)
    self.inkText:AddAsChildTo(self.inkStatus)

	self.Reset = oldReset
    self:Reset()
end

local originalAlienReset = GUIAlienHUD.Reset
function GUIAlienHUD:Reset()
    originalAlienReset(self)
    
  
    if not self.inkStatus or not self.inkText then
        return
    end

    self.inkStatus:SetPosition(Vector(GUIAlienHUD.kUpgradePos.x, GUIAlienHUD.kUpgradePos.y + GUIMarineHUD.kUpgradeSize.y * 2, 0) * self.scale)
    self.inkStatus:SetSize(GUIMarineHUD.kUpgradeSize * self.scale)
    self.inkStatus:SetIsVisible(false)    
    
    self.inkText:SetUniformScale(self.scale)
    self.inkText:SetScale(GetScaledVector())
    self.inkText:SetPosition(Vector( kTextOffsetX, kTextOffsetY, 0) )
    GUIMakeFontScale(self.inkText)
    self.inkText:SetIsVisible(false)   


end

local originalAlienUpdate = GUIAlienHUD.Update
function GUIAlienHUD:Update(deltaTime)
    originalAlienUpdate(self, deltaTime)

    if self.inkStatus and self.inkText then
        local hasInk = PlayerUI_GetHasInk()
        self.inkStatus:SetIsVisible(hasInk)
        self.inkText:SetIsVisible(hasInk)
        local nextInk = PlayerUI_GetHasInkIn()
        if nextInk == 0 then
            nextInk = "READY"
        end
        self.inkText:SetText(tostring(nextInk))
    end

end


local originalAlienUninitialize = GUIAlienHUD.Uninitialize
function GUIAlienHUD:Uninitialize()
    originalAlienUninitialize(self)
    
    self.inkStatus = nil
    self.inkText = nil
    
end