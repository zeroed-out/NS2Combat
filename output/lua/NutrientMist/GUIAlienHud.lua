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
    
    self.nutrientMistStatus = GetGUIManager():CreateGraphicItem()
    self.nutrientMistStatus:SetTexture(GUIMarineHUD.kUpgradesTexture)
    self.nutrientMistStatus:SetAnchor(GUIItem.Right, GUIItem.Center)
    self.nutrientMistStatus:SetTexturePixelCoordinates(GUIUnpackCoords(GetTextureCoordinatesForIcon(kTechId.NutrientMist)))
    self.nutrientMistStatus:SetColor(useColor)
    self.background:AddChild(self.nutrientMistStatus)

    self.nutrientMistText = CreateNewTextItem(self)
    self.nutrientMistText:AddAsChildTo(self.nutrientMistStatus)

    self.Reset = oldReset
    self:Reset()

end

local originalAlienReset = GUIAlienHUD.Reset
function GUIAlienHUD:Reset()
    originalAlienReset(self)
    
  
    if not self.nutrientMistStatus or not self.nutrientMistText then
        return
    end

    self.nutrientMistStatus:SetPosition(Vector(GUIAlienHUD.kUpgradePos.x, GUIAlienHUD.kUpgradePos.y + GUIMarineHUD.kUpgradeSize.y * 2, 0) * self.scale)
    self.nutrientMistStatus:SetSize(GUIMarineHUD.kUpgradeSize * self.scale)
    self.nutrientMistStatus:SetIsVisible(false)    
    
    self.nutrientMistText:SetUniformScale(self.scale)
    self.nutrientMistText:SetScale(GetScaledVector())
    self.nutrientMistText:SetPosition(Vector( kTextOffsetX, kTextOffsetY, 0) )
    GUIMakeFontScale(self.nutrientMistText)
    self.nutrientMistText:SetIsVisible(false)   

end

local originalAlienUpdate = GUIAlienHUD.Update
function GUIAlienHUD:Update(deltaTime)
    originalAlienUpdate(self, deltaTime)
    
    if self.nutrientMistStatus and self.nutrientMistText then
        local hasNutrientMist = PlayerUI_GetHasNutrientMist()
        self.nutrientMistStatus:SetIsVisible(hasNutrientMist)
        self.nutrientMistText:SetIsVisible(hasNutrientMist)
        local nextNutrientMist = PlayerUI_GetHasNutrientMistIn()
        if nextNutrientMist == 0 then
            nextNutrientMist = "READY"
        end
        self.nutrientMistText:SetText(tostring(nextNutrientMist))
    end

end


local originalAlienUninitialize = GUIAlienHUD.Uninitialize
function GUIAlienHUD:Uninitialize()
    originalAlienUninitialize(self)
    
    self.nutrientMistStatus = nil
    self.nutrientMistText = nil
   
end


