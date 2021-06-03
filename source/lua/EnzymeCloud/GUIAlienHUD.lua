GUIAlienHUD.kUpgradePos = GUIScale(Vector(200, 600, 0))
local kTextOffsetX = -120
local kTextOffsetY = 0
local useColor = kIconColors[kAlienTeamType]
GUIAlienHUD.kTextFontName = Fonts.kAgencyFB_Small

local originalAlienInitialize = GUIAlienHUD.Initialize
function GUIAlienHUD:Initialize()
	
    originalAlienInitialize(self)

    local oldReset = self.Reset
    self.Reset = function() end
    
    self.enzymeCloudStatus = GetGUIManager():CreateGraphicItem()
    self.enzymeCloudStatus:SetTexture(GUIMarineHUD.kUpgradesTexture)
    self.enzymeCloudStatus:SetAnchor(GUIItem.Right, GUIItem.Center)
    self.enzymeCloudStatus:SetTexturePixelCoordinates(GUIUnpackCoords(GetTextureCoordinatesForIcon(kTechId.EnzymeCloud)))
    self.enzymeCloudStatus:SetColor(useColor)
    self.background:AddChild(self.enzymeCloudStatus)

    self.enzymeCloudText = CreateNewTextItem(self)
    self.enzymeCloudText:AddAsChildTo(self.enzymeCloudStatus)

    self.Reset = oldReset
    self:Reset()

end

local originalAlienReset = GUIAlienHUD.Reset
function GUIAlienHUD:Reset()
    originalAlienReset(self)
    
  
    if not self.enzymeCloudStatus or not self.enzymeCloudText then
        return
    end
    self.enzymeCloudStatus:SetPosition(Vector(GUIAlienHUD.kUpgradePos.x, GUIAlienHUD.kUpgradePos.y + GUIMarineHUD.kUpgradeSize.y * 2, 0) * self.scale)
    self.enzymeCloudStatus:SetSize(GUIMarineHUD.kUpgradeSize * self.scale)
    self.enzymeCloudStatus:SetIsVisible(false)    
    
    self.enzymeCloudText:SetUniformScale(self.scale)
    self.enzymeCloudText:SetScale(GetScaledVector())
    self.enzymeCloudText:SetPosition(Vector( kTextOffsetX, kTextOffsetY, 0) )
    GUIMakeFontScale(self.enzymeCloudText)
    self.enzymeCloudText:SetIsVisible(false)   

end

local originalAlienUpdate = GUIAlienHUD.Update
function GUIAlienHUD:Update(deltaTime)
    originalAlienUpdate(self, deltaTime)
    if self.enzymeCloudStatus and self.enzymeCloudText then
        local hasEnzymeCloud = PlayerUI_GetHasEnzymeCloud()
        self.enzymeCloudStatus:SetIsVisible(hasEnzymeCloud)
        self.enzymeCloudText:SetIsVisible(hasEnzymeCloud)
        local nextEnzymeCloud = PlayerUI_GetNextEnzymeCloudIn()
        if nextEnzymeCloud == 0 then
            nextEnzymeCloud = "READY"
        end
        self.enzymeCloudText:SetText(tostring(nextEnzymeCloud))
    end
    
end


local originalAlienUninitialize = GUIAlienHUD.Uninitialize
function GUIAlienHUD:Uninitialize()
    originalAlienUninitialize(self)
    
    self.enzymeCloudStatus = nil
    self.enzymeCloudText = nil

   
end


