-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\GUIGorgeBuildMenu.lua
--
-- Created by: Andreas Urwalek (a_urwa@sbox.tugraz.at)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUIAnimatedScript.lua")

local kMouseOverSound = "sound/NS2.fev/alien/common/alien_menu/hover"
local kSelectSound = "sound/NS2.fev/alien/common/alien_menu/evolve"
local kCloseSound = "sound/NS2.fev/alien/common/alien_menu/sell_upgrade"
local kFontName = Fonts.kAgencyFB_Small
Client.PrecacheLocalSound(kMouseOverSound)
Client.PrecacheLocalSound(kSelectSound)
Client.PrecacheLocalSound(kCloseSound)

function GorgeBuild_OnClose()
    StartSoundEffect(kCloseSound)
end

function GorgeBuild_OnSelect()
    StartSoundEffect(kSelectSound)
end

function GorgeBuild_OnMouseOver()
    StartSoundEffect(kMouseOverSound)
end

function GorgeBuild_Close()

    local player = Client.GetLocalPlayer()
    local dropStructureAbility = player:GetWeapon(DropStructureAbility.kMapName)

    if dropStructureAbility then
        dropStructureAbility:DestroyBuildMenu()
    end

end

function GorgeBuild_SendSelect(index)

    local player = Client.GetLocalPlayer()

    if player then
    
        local dropStructureAbility = player:GetWeapon(DropStructureAbility.kMapName)
        if dropStructureAbility then
            dropStructureAbility:SetActiveStructure(index)
        end
        
    end
    
end

function GorgeBuild_GetIsAbilityAvailable(index)

    return DropStructureAbility.kSupportedStructures[index] and DropStructureAbility.kSupportedStructures[index]:IsAllowed(Client.GetLocalPlayer())

end

function GorgeBuild_AllowConsumeDrop(techId)
    return LookupTechData(techId, kTechDataAllowConsumeDrop, false)
end

function GorgeBuild_GetCanAffordAbility(techId)

    local player = Client.GetLocalPlayer()
    local abilityCost = LookupTechData(techId, kTechDataCostKey, 0)
    local exceededLimit = not GorgeBuild_AllowConsumeDrop(techId) and GorgeBuild_GetNumStructureBuilt(techId) >= GorgeBuild_GetMaxNumStructure(techId)

    return player:GetResources() >= abilityCost and not exceededLimit

end

function GorgeBuild_GetStructureCost(techId)
    return LookupTechData(techId, kTechDataCostKey, 0)
end

function GorgeBuild_GetNumStructureBuilt(techId)

    local player = Client.GetLocalPlayer()
    local ability = player:GetActiveWeapon()
    
    if ability and ability:isa("DropStructureAbility") then
        return ability:GetNumStructuresBuilt(techId)
    end
    
    return -1

end

function GorgeBuild_GetMaxNumStructure(techId)

    return LookupTechData(techId, kTechDataMaxAmount, -1)

end

class 'GUIGorgeBuildMenu' (GUIAnimatedScript)

GUIGorgeBuildMenu.kBaseYResolution = 1200

GUIGorgeBuildMenu.kButtonWidth = 180
GUIGorgeBuildMenu.kButtonHeight = 180

GUIGorgeBuildMenu.kBackgroundYOffset = GUIGorgeBuildMenu.kButtonHeight * 0.5

GUIGorgeBuildMenu.kButtonTexture = "materials/deployables/gorge_build_menu.dds"
GUIGorgeBuildMenu.kBuyMenuTexture = "ui/alien_buymenu.dds"
GUIGorgeBuildMenu.kSmokeSmallTextureCoordinates = { { 916, 4, 1020, 108 }, { 916, 15, 1020, 219 }, { 916, 227, 1020, 332 }, { 916, 332, 1020, 436 } }

GUIGorgeBuildMenu.kPixelSize = 128

GUIGorgeBuildMenu.kAvailableColor = kAlienTeamColorFloat
GUIGorgeBuildMenu.kTooExpensiveColor = Color(1, 0, 0, 1)
GUIGorgeBuildMenu.kUnavailableColor = Color(0.4, 0.4, 0.4, 0.7)

-- selection circle animation:
GUIGorgeBuildMenu.kPulseInAnimationDuration = 0.6
GUIGorgeBuildMenu.kPulseOutAnimationDuration = 0.3
GUIGorgeBuildMenu.kLowColor = Color(1, 0.4, 0.4, 0.5)
GUIGorgeBuildMenu.kHighColor = Color(1, 1, 1, 1)

GUIGorgeBuildMenu.kPersonalResourceIcon = { Width = 0, Height = 0, X = 0, Y = 0, Coords = { X1 = 144, Y1 = 363, X2 = 192, Y2 = 411} }
GUIGorgeBuildMenu.kPersonalResourceIcon.Width = 32
GUIGorgeBuildMenu.kPersonalResourceIcon.Height = 32
GUIGorgeBuildMenu.kResourceTexture = "ui/alien_commander_textures.dds"
GUIGorgeBuildMenu.kIconTextXOffset = 5

GUIGorgeBuildMenu.kBackgroundNoiseTexture = "ui/alien_commander_bg_smoke.dds"
GUIGorgeBuildMenu.kSmokeyBackgroundSize = Vector(220, 400, 0)

local kDefaultStructureCountPos = Vector(-48, -24, 0)
local kCenteredStructureCountPos = Vector(0, -24, 0)

--selection circle animation callbacks
function PulseOutAnimation(script, item)
    item:SetColor(GUIGorgeBuildMenu.kHighColor, GUIGorgeBuildMenu.kPulseInAnimationDuration, "PULSE", AnimateLinear, PulseInAnimation)
end

function PulseInAnimation(script, item)
    item:SetColor(GUIGorgeBuildMenu.kLowColor, GUIGorgeBuildMenu.kPulseOutAnimationDuration, "PULSE", AnimateLinear, PulseOutAnimation)
end

local rowTable
local function GetRowForTechId(techId)

    if not rowTable then
    
        rowTable = {}
        rowTable[kTechId.Hydra] = 1
        rowTable[kTechId.BabblerEgg] = 2
        rowTable[kTechId.Clog] = 3
        rowTable[kTechId.GorgeTunnel] = 4
        rowTable[kTechId.Web] = 5
        
        rowTable[kTechId.GorgeWhip] = 6
        rowTable[kTechId.GorgeCrag] = 7
        rowTable[kTechId.GorgeShade] = 8
        rowTable[kTechId.GorgeShift] = 9
    end
    return rowTable[techId]

end

function GUIGorgeBuildMenu:Initialize()

    GUIAnimatedScript.Initialize(self)
    
    self.kSmokeyBackgroundSize = GUIScale(Vector(220, 400, 0))
    
    self.scale = Client.GetScreenHeight() / GUIGorgeBuildMenu.kBaseYResolution
    self.background = self:CreateAnimatedGraphicItem()
    self.background:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.background:SetColor(Color(0,0,0,0))
    
    self.buttons = {}
    
    self:Reset()

end

function GUIGorgeBuildMenu:Uninitialize()
    
    GUIAnimatedScript.Uninitialize(self)

end

function GUIGorgeBuildMenu:GetIsVisible()
    return self.background:GetIsVisible()
end

function GUIGorgeBuildMenu:SetIsVisible(isVisible)
    self.background:SetIsVisible(isVisible == true)
end

function GUIGorgeBuildMenu:_HandleMouseOver(onItem)
    
    if onItem ~= self.lastActiveItem then
        GorgeBuild_OnMouseOver()
        self.lastActiveItem = onItem
    end
    
end

local function UpdateButton(button, index)

    local col = 1
    local color = GUIGorgeBuildMenu.kAvailableColor

    if not GorgeBuild_GetCanAffordAbility(button.techId) then
        col = 2
        color = GUIGorgeBuildMenu.kTooExpensiveColor
    end
    
    if not GorgeBuild_GetIsAbilityAvailable(index) then
        col = 3
        color = GUIGorgeBuildMenu.kUnavailableColor
    end
    
    local row = GetRowForTechId(button.techId)
   
    button.smokeyBackground:SetIsVisible(Client.GetHudDetail() ~= kHUDMode.Minimal)
    button.graphicItem:SetTexturePixelCoordinates(GUIGetSprite(col, row, GUIGorgeBuildMenu.kPixelSize, GUIGorgeBuildMenu.kPixelSize))
    button.description:SetColor(color)
    button.costIcon:SetColor(color)
    button.costText:SetColor(color)

    local numLeft = GorgeBuild_GetNumStructureBuilt(button.techId)
    if numLeft == -1 then
        button.structuresLeft:SetIsVisible(false)
    else
        button.structuresLeft:SetIsVisible(true)
        local amountString = ToString(numLeft)
        local maxNum = GorgeBuild_GetMaxNumStructure(button.techId)
        
        if maxNum > 0 then
            amountString = amountString .. "/" .. ToString(maxNum)
        end
        
        if numLeft >= maxNum then
            color = GUIGorgeBuildMenu.kTooExpensiveColor
        end
        
        button.structuresLeft:SetColor(color)
        button.structuresLeft:SetText(amountString)
        
    end    
    
    local cost = GorgeBuild_GetStructureCost(button.techId)
    if cost == 0 then        
    
        button.costIcon:SetIsVisible(false)
        button.structuresLeft:SetPosition(kCenteredStructureCountPos)
        
    else
    
        button.costIcon:SetIsVisible(true)
        button.costText:SetText(ToString(cost))
        button.structuresLeft:SetPosition(kDefaultStructureCountPos)
        
        
    end
    
end

function GUIGorgeBuildMenu:Update(deltaTime)
                  
    PROFILE("GUIGorgeBuildMenu:Update")
    
    GUIAnimatedScript.Update(self, deltaTime)
    
    for index, button in ipairs(self.buttons) do
        
        UpdateButton(button, index)
       
    end

end

local GorgeBuildKeys = {
    [1] = "Weapon1",
    [2] = "Weapon2",
    [3] = "Weapon3",
    [4] = "Weapon4",
    [5] = "Weapon5",
    [6] = "Reload", --r
    [7] = "Drop", --g
    [8] = "Use", --e
    [9] = "ToggleFlashlight", --f
    
}
function GUIGorgeBuildMenu:Reset()
    
    self.background:SetUniformScale(self.scale)

    for index, structureAbility in ipairs(DropStructureAbility.kSupportedStructures) do
    
        -- TODO: pass keybind from options instead of index
        table.insert( self.buttons, self:CreateButton(structureAbility.GetDropStructureId(), self.scale, self.background, GorgeBuildKeys[index], index - 1) )
    
    end
    
    local backgroundXOffset = (#self.buttons * GUIGorgeBuildMenu.kButtonWidth) * -.5
    self.background:SetPosition(Vector(backgroundXOffset, GUIGorgeBuildMenu.kBackgroundYOffset, 0))
    
end

function GUIGorgeBuildMenu:OnResolutionChanged(oldX, oldY, newX, newY)

    self:Uninitialize()
    self:Initialize()

end

function GUIGorgeBuildMenu:CreateButton(techId, scale, frame, keybind, position)

    local button =
    {
        frame = self:CreateAnimatedGraphicItem(),
        background = self:CreateAnimatedGraphicItem(),
        graphicItem = self:CreateAnimatedGraphicItem(),
        description = self:CreateAnimatedTextItem(),
        keyIcon = GUICreateButtonIcon(keybind, true),
        keybind = keybind,
        techId = techId,
        structuresLeft = self:CreateAnimatedTextItem(),
        costIcon = self:CreateAnimatedGraphicItem(),
        costText = self:CreateAnimatedTextItem(),
    }
    
    local minimal = Client.GetHudDetail() == kHUDMode.Minimal
    local backgroundSize = ConditionalValue(minimal, Vector(0,0,0), self.kSmokeyBackgroundSize)
    local backgroundTexCoords = ConditionalValue(minimal, {{0, 0, 0, 0}, {0, 0, 0, 0}, {0, 0, 0, 0}, {0, 0, 0, 0}}, self.kSmokeSmallTextureCoordinates)

    local smokeyBackground = GetGUIManager():CreateGraphicItem()
    smokeyBackground:SetAnchor(GUIItem.Middle, GUIItem.Center)
    smokeyBackground:SetSize(self.kSmokeyBackgroundSize)
    smokeyBackground:SetPosition(self.kSmokeyBackgroundSize * -.5)
    smokeyBackground:SetShader("shaders/GUISmokeHUD.surface_shader")
    smokeyBackground:SetTexture("ui/alien_logout_smkmask.dds")
    smokeyBackground:SetAdditionalTexture("noise", self.kBackgroundNoiseTexture)
    smokeyBackground:SetFloatParameter("correctionX", 0.6)
    smokeyBackground:SetFloatParameter("correctionY", 1)
    smokeyBackground:SetIsVisible(not minimal)
    
    button.frame:SetUniformScale(scale)
    button.frame:SetSize(Vector(GUIGorgeBuildMenu.kButtonWidth, GUIGorgeBuildMenu.kButtonHeight, 0))
    button.frame:SetColor(Color(1,1,1,0))
    button.frame:SetPosition(Vector(position * GUIGorgeBuildMenu.kButtonWidth, 0, 0))
    frame:AddChild(button.frame)
    
    button.background:SetUniformScale(scale)
    button.graphicItem:SetUniformScale(scale)    
    button.frame:AddChild(button.background)
    
    button.description:SetUniformScale(scale) 
    
    button.background:SetSize(Vector(GUIGorgeBuildMenu.kButtonWidth, GUIGorgeBuildMenu.kButtonHeight * 1.5, 0))
    button.background:SetColor(Color(0,0,0,0))
    
    button.graphicItem:SetSize(Vector(GUIGorgeBuildMenu.kButtonWidth, GUIGorgeBuildMenu.kButtonHeight, 0))
    button.graphicItem:SetTexture(GUIGorgeBuildMenu.kButtonTexture)
    button.graphicItem:SetShader("shaders/GUIWavyNoMask.surface_shader")
     
    --button.description:SetText(LookupTechData(techId, kTechDataDisplayName, "") .. " (".. keybind ..")")
    button.description:SetText(Locale.ResolveString(LookupTechData(techId, kTechDataDisplayName, "")))
    button.description:SetAnchor(GUIItem.Middle, GUIItem.Top)
    button.description:SetTextAlignmentX(GUIItem.Align_Center)
    button.description:SetTextAlignmentY(GUIItem.Align_Center)
    button.description:SetScale(GetScaledVector())
    button.description:SetFontName(kFontName)
    GUIMakeFontScale(button.description)
    button.description:SetPosition(Vector(0, 0, 0))
    button.description:SetFontIsBold(true)
    
    button.keyIcon:SetAnchor(GUIItem.Middle, GUIItem.Bottom)
    button.keyIcon:SetFontName(kFontName)
    GUIMakeFontScale(button.keyIcon)
    local pos = Vector(-button.keyIcon:GetSize().x/2, 0.5*button.keyIcon:GetSize().y, 0)
    button.keyIcon:SetPosition(pos)
    
    button.structuresLeft:SetAnchor(GUIItem.Middle, GUIItem.Bottom)
    button.structuresLeft:SetTextAlignmentX(GUIItem.Align_Center)
    button.structuresLeft:SetTextAlignmentY(GUIItem.Align_Center)
    button.structuresLeft:SetScale(GetScaledVector())
    button.structuresLeft:SetFontName(kFontName)
    GUIMakeFontScale(button.structuresLeft)
    button.structuresLeft:SetPosition(kDefaultStructureCountPos)
    button.structuresLeft:SetFontIsBold(true)
    button.structuresLeft:SetColor(GUIGorgeBuildMenu.kAvailableColor)
    
    -- Personal display.
    button.costIcon:SetSize(Vector(GUIGorgeBuildMenu.kPersonalResourceIcon.Width, GUIGorgeBuildMenu.kPersonalResourceIcon.Height, 0))
    button.costIcon:SetAnchor(GUIItem.Middle, GUIItem.Bottom)
    button.costIcon:SetTexture(GUIGorgeBuildMenu.kResourceTexture)
    button.costIcon:SetPosition(Vector(0, -GUIGorgeBuildMenu.kPersonalResourceIcon.Height * .5 - 24, 0))
    button.costIcon:SetUniformScale(scale)
    GUISetTextureCoordinatesTable(button.costIcon, GUIGorgeBuildMenu.kPersonalResourceIcon.Coords)

    button.costText:SetUniformScale(scale)
    button.costText:SetAnchor(GUIItem.Right, GUIItem.Center)
    button.costText:SetTextAlignmentX(GUIItem.Align_Min)
    button.costText:SetTextAlignmentY(GUIItem.Align_Center)
    button.costText:SetPosition(Vector(GUIGorgeBuildMenu.kIconTextXOffset, 0, 0))
    button.costText:SetColor(Color(1, 1, 1, 1))
    button.costText:SetFontIsBold(true)    
    button.costText:SetScale(GetScaledVector())
    button.costText:SetFontName(kFontName)
    GUIMakeFontScale(button.costText)
    button.costText:SetColor(GUIGorgeBuildMenu.kAvailableColor)
    button.costIcon:AddChild(button.costText)
    
    button.smokeyBackground = smokeyBackground
    button.background:AddChild(smokeyBackground)
    button.background:AddChild(button.graphicItem)    
    button.graphicItem:AddChild(button.description)
    button.graphicItem:AddChild(button.structuresLeft)
    button.graphicItem:AddChild(button.keyIcon)   
    button.graphicItem:AddChild(button.costIcon)

    return button

end

function GUIGorgeBuildMenu:OverrideInput(input)

    -- Assume the user wants to switch the top-level weapons
    if HasMoveCommand( input.commands, Move.SelectNextWeapon )
    or HasMoveCommand( input.commands, Move.SelectPrevWeapon ) then

        GorgeBuild_OnClose()
        GorgeBuild_Close()
        return input

    end

    local weaponSwitchCommands = { Move.Weapon1, Move.Weapon2, Move.Weapon3, Move.Weapon4, Move.Weapon5, Move.Reload, Move.Drop, Move.Use, Move.ToggleFlashlight }

    local selectPressed = false

    for index, weaponSwitchCommand in ipairs(weaponSwitchCommands) do
    
        if HasMoveCommand( input.commands, weaponSwitchCommand ) then

            if GorgeBuild_GetIsAbilityAvailable(index) and GorgeBuild_GetCanAffordAbility(self.buttons[index].techId)  then

                GorgeBuild_SendSelect(index)
                input.commands = RemoveMoveCommand( input.commands, weaponSwitchCommand )

            end
            
            selectPressed = true
            break
            
        end
        
    end  
    
    if selectPressed then

        GorgeBuild_OnClose()
        GorgeBuild_Close()

    elseif HasMoveCommand( input.commands, Move.SecondaryAttack )
        or HasMoveCommand( input.commands, Move.PrimaryAttack ) then

        --DebugPrint("before override: %d",input.commands)

        -- close menu
        GorgeBuild_OnClose()
        GorgeBuild_Close()

        -- leave the secondary attack command so the drop-ability can handle it
        input.commands = AddMoveCommand( input.commands, Move.SecondaryAttack )
        input.commands = RemoveMoveCommand( input.commands, Move.PrimaryAttack )
        --DebugPrint("after override: %d",input.commands)
        --DebugPrint("primary = %d secondary = %d", Move.PrimaryAttack, Move.SecondaryAttack)

    end

    return input, selectPressed

end

function GUIGorgeBuildMenu:_GetIsMouseOver(overItem)

    return GUIItemContainsPoint(overItem, Client.GetCursorPosScreen())
    
end

function GUIGorgeBuildMenu:OnAnimationCompleted(animatedItem, animationName, itemHandle)
end

-- called when the last animation remaining has completed this frame
function GUIGorgeBuildMenu:OnAnimationsEnd(item)
end